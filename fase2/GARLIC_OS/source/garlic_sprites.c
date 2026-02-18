// source/garlic_sprites.c
#include <nds.h>
#include "garlic_sprites.h"

// ------------------------------------------------------------
// Rutines del professor (Sprites_sopo.s)
// ------------------------------------------------------------
extern void SPR_crea_sprite(u8 idx, u8 forma, u8 tam, u16 baldosa);
extern void SPR_mueve_sprite(u8 idx, s16 px, s16 py);
extern void SPR_muestra_sprite(u8 idx);
extern void SPR_oculta_sprite(u8 idx);
extern void SPR_actualiza_sprites(u16* baseOAM, u8 limite);

extern void SPR_activa_rotacionEscalado(u8 idx, u8 grupo);
extern void SPR_fija_escalado(u8 grupo, u16 sx, u16 sy);

// ------------------------------------------------------------
// Recursos gràfics
// ------------------------------------------------------------
extern const unsigned short iconsPal[];
extern const unsigned char  iconsTiles[];

// ------------------------------------------------------------
// Variables UI (Fase 2): zoom i visibilitat de finestres
// ------------------------------------------------------------
extern u16 _gi_zoom;                    // típic Q8.8 (ex: 0x200, 0x100, 0x80)
extern int _gi_ventanaVisible(int v);   // retorna 0/1 si la finestra és visible

// origen global de les finestres
extern u16 _gi_orgX;
extern u16 _gi_orgY;

extern volatile int _gi_za;		// zócalo actiu

// ------------------------------------------------------------
// Constants
// ------------------------------------------------------------
#define MAX_ZOCALOS   16
#define MAX_SPRITES   8
#define TOTAL_SPRITES (MAX_ZOCALOS * MAX_SPRITES)

// OAM MAIN base (pantalla superior normalment)
#define OAM_MAIN_BASE ((u16*)0x07000000)

// ------------------------------------------------------------
// Estat intern
// ------------------------------------------------------------
// coordenades internes que després les transformo a zoom/scroll
static u8  spr_defined[MAX_ZOCALOS][MAX_SPRITES];
static u8  spr_icon[MAX_ZOCALOS][MAX_SPRITES];
static u8  spr_visible[MAX_ZOCALOS][MAX_SPRITES];
static s16 spr_px[MAX_ZOCALOS][MAX_SPRITES];
static s16 spr_py[MAX_ZOCALOS][MAX_SPRITES];
static inline u8 spr_global(int z, int n) { return (u8)(z * MAX_SPRITES + n); }

// ------------------------------------------------------------
// FASE 1
// ------------------------------------------------------------
void gs_spriteSet(int z, int n, int icon)
{
    if ((unsigned)z >= MAX_ZOCALOS) return;
    if ((unsigned)n >= MAX_SPRITES) return;
    if ((unsigned)icon >= 64) return; // (0..63)

    u8 idx = spr_global(z, n);		// idx global OAM (0..127)

    // 1 Sprite = 32x32, 256 colors:
    // 32x32 => 16 tiles (8x8) => tile_base = icon * 16
    u16 tile_base = (u16)(icon * 16);

    // forma = 0 (quadrat), tam = 2 (32x32)
    SPR_crea_sprite(idx, 0, 2, tile_base);

    // per aplicar zoom global després
    SPR_activa_rotacionEscalado(idx, 0);

	// actualitzem estat intern
    spr_defined[z][n] = 1;
    spr_icon[z][n] = (u8)icon;

    // Per defecte el deixem ocult fins que facin Show()
    spr_visible[z][n] = 0;
    SPR_oculta_sprite(idx);
	
	// recalcula posicions/visibilitat
	gs_refreshSprites();
}

void gs_spriteMove(int z, int n, int px, int py)
{
    if ((unsigned)z >= MAX_ZOCALOS) return;
    if ((unsigned)n >= MAX_SPRITES) return;
    if (!spr_defined[z][n]) return;		// si l'sprite no està creat

	// guardem la posició lógica
    spr_px[z][n] = (s16)px;
    spr_py[z][n] = (s16)py;
	
	// Recalcular posició final a la pantalla
	gs_refreshSprites();
}

void gs_spriteShow(int z, int n)
{
    if ((unsigned)z >= MAX_ZOCALOS) return;
    if ((unsigned)n >= MAX_SPRITES) return;
    if (!spr_defined[z][n]) return;
	
	u8 idx = spr_global(z, n);
    spr_visible[z][n] = 1;	// marcar com a visible
	
	SPR_activa_rotacionEscalado(idx, 0);
	SPR_muestra_sprite(idx);
	gs_refreshSprites();
}

void gs_spriteHide(int z, int n)
{
    if ((unsigned)z >= MAX_ZOCALOS) return;
    if ((unsigned)n >= MAX_SPRITES) return;
    if (!spr_defined[z][n]) return;

    spr_visible[z][n] = 0; // marcar com a no visible
    SPR_oculta_sprite(spr_global(z, n));
	gs_refreshSprites();
}

// ------------------------------------------------------------
// FASE 2
// ------------------------------------------------------------
void gs_hideAllSprites(void)
{
	// amaga tots els sprites -> garlic_itcm_ui.s
    for (int i = 0; i < TOTAL_SPRITES; i++) {
        SPR_oculta_sprite((u8)i);
    }
}

static inline s16 clamp_s16(int v)
{
	return (s16)v; // conversió a s16
}

void gs_refreshSprites(void)
{
    u32 zoom = _gi_zoom;
	// límits
    if (zoom < 256) zoom = 256; 	// 1.0
    if (zoom > 1024) zoom = 1024;	// 4.0

	// aplicar l'escalat 
    SPR_fija_escalado(0, (u16)zoom, (u16)zoom);

	// recorro tots els zócalos
    for (int z = 0; z < MAX_ZOCALOS; z++) {
	
        int vvis = _gi_ventanaVisible(z);	// indica si la finestra z és visible

        // base del zócalo en coordenades
        int baseX, baseY;

		// --- 16 finestres ---
		// la pantalla representa un bloc de 4x4 finestres dins de l'espai
		
		// X en blocs de 1024
		// Y en blocs de 769
		// cada finestra ocupa 256x192
		
        if (zoom >= 768) {	// mode 16
			int blockX = ((int)_gi_orgX / 1024) * 1024;
			int blockY = ((int)_gi_orgY / 768)  * 768;

			baseX = blockX + (z & 3) * 256;
			baseY = blockY + (z >> 2) * 192;
        } else {
            // bloc visible simple
            baseX = (z & 3) * 256;
            baseY = (z >> 2) * 192;
        }

		// 8 sprites del zócalo
        for (int n = 0; n < MAX_SPRITES; n++) {
            if (!spr_defined[z][n]) continue;	// si no existeix
			
            u8 idx = spr_global(z, n);

			// Si la finestra no és visible o el sprite està marcat com ocult,
            // l'ocultem i continuem.
            if (!vvis || !spr_visible[z][n]) {
                SPR_oculta_sprite(idx);
                continue;
            }
			
			// --- coordenades de l'sprite
			// El sprite està definit relatiu a la finestra (spr_px/py),
            // el passo a món sumant el baseX/baseY del zócalo.
            int wx = baseX + (int)spr_px[z][n];
            int wy = baseY + (int)spr_py[z][n];

            // --- per la projecció
			// quan el zoom és més gran, més petit
            int sx = (((wx - (int)_gi_orgX) * 256) + ((int)zoom/2)) / (int)zoom;
            int sy = (((wy - (int)_gi_orgY) * 256) + ((int)zoom/2)) / (int)zoom;

			// mida projectada aprox. d’un sprite 32x32
			// com més zoom, més petit serà a pantalla
            int sSize = (32 * 256) / (int)zoom;
            if (sSize < 1) sSize = 1;

			// --- fora de pantalla
			// si queda completament fora -> l'oculto
            if (sx <= -sSize || sx >= 256 || sy <= -sSize || sy >= 192) {
                SPR_oculta_sprite(idx);
                continue;
            }
			
			// actualitzem
            SPR_activa_rotacionEscalado(idx, 0);
            SPR_mueve_sprite(idx, clamp_s16(sx), clamp_s16(sy));
            SPR_muestra_sprite(idx);
        }
    }

    SPR_actualiza_sprites(OAM_MAIN_BASE, TOTAL_SPRITES);
}

// Reinicialitza els 8 sprites d’un zócalo
void gs_resetSpritesZocalo(int z)
{
    if (z < 0 || z >= MAX_ZOCALOS) return;

    for (int n = 0; n < MAX_SPRITES; n++) {
        spr_defined[z][n] = 0;
        spr_visible[z][n] = 0;
        spr_px[z][n] = 0;
        spr_py[z][n] = 0;

        u8 idx = spr_global(z, n);
        SPR_oculta_sprite(idx);
    }

    SPR_actualiza_sprites(OAM_MAIN_BASE, TOTAL_SPRITES);
}
