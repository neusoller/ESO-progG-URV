/*------------------------------------------------------------------------------

	"garlic_graf.c" : fase 1 / programador G

	Funciones de gestión de las ventanas de texto (gráficas), para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>

#include <garlic_system.h>	// definición de funciones y variables de sistema
#include <garlic_font.h>	// definición gráfica de caracteres

// --- funcionalitat addicional ---
#include "icons.h" 			// definició gràfica dels emojis

/* definiciones para realizar cálculos relativos a la posición de los caracteres
	dentro de las ventanas gráficas, que pueden ser 4 o 16 */
#define NVENT	4				// número de ventanas totales
#define PPART	2				// número de ventanas horizontales o verticales
								// (particiones de pantalla)
#define VCOLS	32				// columnas y filas de cualquier ventana
#define VFILS	24
#define PCOLS	VCOLS * PPART	// número de columnas totales (en pantalla)
#define PFILS	VFILS * PPART	// número de filas totales (en pantalla)

// --- funcionalitat addicional ---
#define MAX_PROC 16
#define MAX_SPRITES 8

typedef struct {
    int used;        // 0 = lliure, 1 = ocupat
    int icon;        // icona assignada
    void* gfx;       // adreça VRAM (retornada per oamAllocateGfx)
    int visible;     // 0 = ocult, 1 = visible
} SpriteSlot;

static SpriteSlot gSprites[MAX_PROC][MAX_SPRITES];

u16* mapPtr2;
u16* mapPtr3;
int bg2, bg3;

unsigned int quo_fdiv, mod_fdiv;	// Variables per a càlculs de divisió

/* _gg_generarMarco: dibuja el marco de la ventana que se indica por parámetro*/
void _gg_generarMarco(int v)
{
	/* desplaçament horitzontal:
		-> (v % PPART) * VCOLS:
			1. v % PPART: calcular quina columna es troba la finestra (0: esquerra 1: dreta)
			2. *VCOLS: obtindrà el desplaçament horitzontal (px)
		desplaçament vertial:
		-> ((v / PPART) * VFILS) * PCOLS:
			1. v / PPART: calcular quina fila es troba la finestra (0: superior 1: inferior)
			2. * VFILS: obtindrà el desplaçament vertical (px)
			3. * PCOLS: desplaçament dins del mapa de memòria gràfica
						cada fila ocupa PCOLS posicions de memòria (64 fase 1)
	*/
	unsigned short coordenades = ((v%PPART)*VCOLS) // horitzontal
								+(((v/PPART)*VFILS)*PCOLS); // vertical

	// cantonades de la finestra
	mapPtr3[coordenades] = 103;		// superior esquerra
	mapPtr3[coordenades+VCOLS-1] = 102;		// superior dreta
	mapPtr3[coordenades+(PCOLS * (VFILS-1))] = 100;		// inferior esquerra
	mapPtr3[coordenades+(PCOLS * (VFILS-1))+(VCOLS-1)] = 101;	// inferior dreta

	// linies horitzontals
	for(int i = 1; i < VCOLS-1; i = i + 1){
		mapPtr3[coordenades+i] = 99;	// superior
		mapPtr3[coordenades+i+PCOLS * (VFILS-1)] = 97;	// inferior
	}
	// linies verticals
	for (int i = 1; i < (VFILS-1);i++){
		mapPtr3[coordenades+i*PCOLS] = 96;	// esquerra
		mapPtr3[coordenades+i*PCOLS+VCOLS-1] = 98;	// dreta
	}
}


/* _gg_iniGraf: inicializa el procesador gráfico A para GARLIC 1.0 */
void _gg_iniGrafA()
{
    videoSetMode(MODE_5_2D);	// mode de vídeo 5 en 2D
    vramSetBankA(VRAM_A_MAIN_BG_0x06000000);	// memòria VRAM per als fons
	
	// --- funcionalitat addicional ---
	vramSetBankB(VRAM_B_MAIN_SPRITE);	// memòria VRAM per als fons dels emojis

	/*
		int bgInit(int layer, BgType type, BgSize size, int mapBase, int tileBase);
		-> mapBase: Posició a la VRAM on es reserva el tile map
			1. tile map = 2KB
			2. VRAM = 32KB
		
		@VRAM_2 = 0x06000000 + (8 ? 2048) = 0x06004000
		@VRAM_3 = 0x06000000 + (4 ? 2048) = 0x06002000
		
		-> tileBae: on es guarden les baldoses (tiles) en la VRAM
			1. Comparteixen l'espai de memòria 
	*/
    bg2 = bgInit(2, BgType_ExRotation, BgSize_ER_512x512, 0, 4);
    bg3 = bgInit(3, BgType_ExRotation, BgSize_ER_512x512, 16, 4);
	
	bgSetPriority(bg2, 0);
    bgSetPriority(bg3, 2);	// més prioritat -> poso 2 perquè a la 1 estaran els sprites

	oamInit(&oamMain, SpriteMapping_1D_128, false);

	// descomprimeix la font gr?fica (tiles de caràcters) i la copia a la memòria VRAM
	decompress(garlic_fontTiles,bgGetGfxPtr(bg3), LZ77Vram);
	
	// --- funcionalitat addicional ---
	//decompress(iconsTiles, dest, LZ77Vram);
	
	// copia la paleta de colors de la font gràfica
	dmaCopy(garlic_fontPal, BG_PALETTE, sizeof(garlic_fontPal));

	// --- funcionalitat addicional ---
	dmaCopy(iconsPal, SPRITE_PALETTE, sizeof(iconsPal)); // 256 colors × 2 bytes

	// per assignar els punters als mapes de fons
	mapPtr2 = bgGetMapPtr(bg2);
	mapPtr3 = bgGetMapPtr(bg3);

	// genera els marcs de les finestres
    for(unsigned char i = 0 ; i < NVENT ; i+=1)
		_gg_generarMarco(i);
	
	// zoom dels fons
	/*
		NDS utilitza un format de coma fixa (Q8.8) per escalar
			-> 8 bits alts:  part sencera
			-> 8 bits baixos: part fraccionaria
			
		escala real = 0x200/256 = 2.0 d'escala respecte la mida original
	*/
	bgSetScale(bg2, 0x200, 0x200);
	bgSetScale(bg3, 0x200, 0x200);
	
	bgUpdate(); 	// actualitza el fons gràfic
}



/* _gg_procesarFormato: copia los caracteres del string de formato sobre el
					  string resultante, pero identifica los códigos de formato
					  precedidos por '%' e inserta la representación ASCII de
					  los valores indicados por parámetro.
	Parámetros:
		formato	->	string con códigos de formato (ver descripción _gg_escribir);
		val1, val2	->	valores a transcribir, sean número de código ASCII (%c),
					un número natural (%d, %x) o un puntero a string (%s);
		resultado	->	mensaje resultante.
	Observación:
		Se supone que el string resultante tiene reservado espacio de memoria
		suficiente para albergar todo el mensaje, incluyendo los caracteres
		literales del formato y la transcripción a código ASCII de los valores.
*/
void _gg_procesarFormato(char *formato, unsigned int val1, unsigned int val2,
																char *resultado)
{
	unsigned char i = 0, j = 0;
    unsigned int val = 0;
    char car, numstr[12], compt = 0;
    int k = 0;

	// recorre la cadena de format per processar els caracters especials
    while ((car = formato[i]) != '\0') {
        if (car == '%' && compt < 2) {
            char next = formato[i + 1];

            if (next == '%') { // saltem
                resultado[k++] = '%';
                i += 2;
                continue;
            }

            if (next == 'd' || next == 'x' || next == 'c' || next == 's') {
                val = (compt == 0) ? val1 : val2;
                compt++;

                switch (next) {
                    case 'd': // decimal
                        _gs_num2str_dec(numstr, 12, val);
                        j = 0;
                        while (numstr[j] != '\0') {
                            if (numstr[j] != ' ') resultado[k++] = numstr[j];
                            j++;
                        }
                        break;

                    case 'x': // hexadecimal
                        _gs_num2str_hex(numstr, 12, val);
                        j = 0;
                        while (numstr[j] != '\0') {
                            if (numstr[j] != ' ') resultado[k++] = numstr[j];
                            j++;
                        }
                        break;

                    case 'c': // caracter
                        resultado[k++] = (char)val;
                        break;

                    case 's': { // string
                        char *p = (char *)val;
                        while (*p) resultado[k++] = *p++;
                        break;
                    }
                }
                i += 2;
                continue;
            }
        }
        resultado[k++] = car;
        i++;
    }

    resultado[k] = '\0';
}


/* _gg_escribir: escribe una cadena de caracteres en la ventana indicada;
	Parámetros:
		formato	->	cadena de formato, terminada con centinela '\0';
					admite '\n' (salto de línea), '\t' (tabulador, 4 espacios)
					y códigos entre 32 y 159 (los 32 últimos son caracteres
					gráficos), además de códigos de formato %c, %d, %x y %s
					(max. 2 códigos por cadena)
		val1	->	valor a sustituir en primer código de formato, si existe
		val2	->	valor a sustituir en segundo código de formato, si existe
					- los valores pueden ser un código ASCII (%c), un valor
					  natural de 32 bits (%d, %x) o un puntero a string (%s)
		ventana	->	número de ventana (de 0 a 3)
*/
void _gg_escribir(char *formato, unsigned int val1, unsigned int val2, int ventana)
{
	char res[VCOLS*3 + 1], compt;	// +1 per al '\0'
									// buffer per emmagatzemar el text formatat
	_gg_procesarFormato(formato,val1,val2,res);	// format a text
	
	/*
		pControl (32b):
		-> 16b superiors: el número de línia actual (filaAct)
		-> 16b inferiors: el nombre de caràcters escrits a la línia actual (numChar)
	*/
	unsigned short filaAct = _gd_wbfs[ventana].pControl >> 0x10; // AND de 16b cap a la dreta
	unsigned short numChar = _gd_wbfs[ventana].pControl & 0xFFFF; // màscara de 16b de l'esquerra
	
	int i = 0;
	int max = VCOLS * 3;                // màxim de caràcters a processar
	
	while (res[i] != '\0' && i < max) { // fins que no arribem a la centinella
		compt = res[i];
		
		if(compt == '\t') {		//tabulador -> afegim espais
			int tab = 4 - (numChar % 4);	// càlcul d'espais necessaris
			while(tab && numChar < VCOLS) { // equivalent a tab != 0
				_gd_wbfs[ventana].pChars[numChar++] = ' '; // escric els espais que facin falta
				tab--;
			}
		} else if(compt == '\n') { // si és un salt de línia
			while(numChar < VCOLS) {
				_gd_wbfs[ventana].pChars[numChar++] = ' '; // escric espais fins omplir el buffer de la línia
			}
		} else { // caràcters normals
			if (numChar < VCOLS) {
				_gd_wbfs[ventana].pChars[numChar++] = compt;
			}
		}
		
		// Si hem arribat al final de la línia o trobem un salt de línia
		if(compt == '\n' || numChar == VCOLS) {	
			swiWaitForVBlank();
			
			if(filaAct == VFILS) { // en cas que la pantalla estigui plena, fem scroll
				_gg_desplazar(ventana);
				filaAct--;
			}
			
			_gg_escribirLinea(ventana, filaAct, numChar); // escriu la línia
			numChar = 0;
			filaAct++;
		}
		i++;
	}
	_gd_wbfs[ventana].pControl = (filaAct << 16) | numChar; // guardo la nova posició de la finestra
}

/*
Sprite_icons:
	- PATH: GARLIC_OS/data
	- creació dels fitxers icons.h/icons.s -> "grit Sprite_icons.gif -gt -gzl -gB8 -Mh4 -Mw4 -pn 256 -pT 3 -oicons"
		això conté les dades dels emojis amb el format de la NDS
		-> info extreta de: https://www.coranac.com/man/grit/html/grit.htm
		-> descripció dels paràmetres:
			1. -gt : generació de tiles gràfics
			2. -gzl : comprimir amb LZ77
			3. -gB8 : 256 colors (8bpp)
			4. -Mh4 -Mw4 : converteix la imatge de 4x4 blocs a 8x8 px (sprites de 32x32px)
			5. -pn 256 : per indicar que a la paleta tenim 256 entrades
			6. -pT 3 : convertim el fons transparent
			7. -oicons : output icons
	- PATH final: include/icons.h, source/icons.s
	- clean i make pels nous canvis
*/

void _gg_spriteSet(unsigned char n, unsigned char icon)
{
    if (n >= MAX_SPRITES) return;   // només 8 per procés
    if (icon >= 64) return;         // només 64 icones disponibles

	// Obtenim PID
    extern int _gd_pidz;            // declarat a garlic_dtcm.s
    int proc = _gd_pidz & 0xF;      // ID de procés (fins a 16)

	// 16 processos | 1 procés pot tenir 8 sprites
    SpriteSlot* s = &gSprites[proc][n]; // agafem l'sprite concret que volem tractar [pid procés] [ quin sprite agafem dins del procés]

    // S'ha de guardar a la VRAM, en cas que no estigui reservada, s'ha de demanar
    if (!s->used) { // en cas que estigui ocupat voldrà dir que ja està utilitzant memòria VRAM i per tant no cal tornar a reservar de nou
        
		// aquí es demana 
		// espai de VRAM per una imatge de 32x32 píxels en mode 256 colors - 8b per píxel
		s->gfx = oamAllocateGfx(&oamMain, SpriteSize_32x32, SpriteColorFormat_256Color);
        if (!s->gfx) return; // en cas que no es pugui reservar -> es retorna sense espai reservat
        s->used = 1; // s'assigna com a ocupat per evitar tornar a reservar pel mateix sprite
        s->visible = 0; // poso que per defecta l'sprite sigui invisible, d'aquesta manera es controlarà millor quan visualitzar-lo
    }

    s->icon = icon; // guardem quin l'sprite hem assignat

	// copiem els píxels de la imatge de icons.s a la VRAM
	// 32x32 px , 8 bits per píxel = 1024 bytes
	// per tant, serà un punter que es desplaci fins a l'emoji que volem (a l'inici)
	const u8* src = ((const u8*)iconsTiles) + icon * 1024;
	dmaCopy(src, s->gfx, 1024); // ho copiem a la VRAM

    // aqui registro el sprite al sistema de vídeo de la nds
	int id = proc * MAX_SPRITES + n;
    oamSet(&oamMain, // -----------------------------------------els parametres s'han de confirmar ... 
           id, // index sprite
           40, 40,                   // posició inicial
           0,                      // prioritat
           0,                      // núm de paleta (0 -> per defecte)
           SpriteSize_32x32,	   // mida
           SpriteColorFormat_256Color, // formaat de color
           s->gfx,				   // adreça VRAM amb la imatge
           -1,                     // no usa affine transform
           false,                  // doble buffer OFF
		   false,                  // hidden -> si (per defecte)
           false, false,           // vflip/hflip
           false);                 // mosaic
}


void _gg_spriteShow(unsigned char n) 
{
	if (n >= MAX_SPRITES) return;	// només 8 per procés

	// Obtenim PID
    extern int _gd_pidz;			// declarat a garlic_dtcm.s
    int proc = _gd_pidz & 0xF;      // ID de procés (fins a 16)
	int id   = proc * MAX_SPRITES + n;		// índex global dins de l’OAM (únic per sprite)

    SpriteSlot *s = &gSprites[proc][n];		// agafem l'sprite concret que volem tractar [pid procés] [ quin sprite agafem dins del procés]
    
	if (!s->used || !s->gfx) return; 		// encara no s'ha fet spriteSet

    s->visible = 1;		// quan volguem visualitzar s'ha de posar a 1

    oamSetHidden(&oamMain, id, false);		// mostra l'sprite sense alterar-lo (posició, mida, paleta ni priority...)
    oamUpdate(&oamMain);	// ho sincronitzem amb el maquinari de la DNS
}


void _gg_spriteHide(unsigned char n)
{
    if (n >= MAX_SPRITES) return;		// només 8 per procés

    extern int _gd_pidz;				// declarat a garlic_dtcm.s
    int proc = _gd_pidz & 0xF;			// ID de procés (fins a 16)

    SpriteSlot* s = &gSprites[proc][n];		// agafem l'sprite concret que volem tractar [pid procés] [ quin sprite agafem dins del procés]
    if (!s->used) return;					// si no té VRAM reservada, res a fer

    s->visible = 0;		// posem a 0 ja que no el volem visualitzar

    int id = proc * MAX_SPRITES + n;     // índex global dins de l’OAM (únic per sprite)
	
    oamSetHidden(&oamMain, id, true);	// marca l’entrada OAM com a “hidden”
    oamUpdate(&oamMain);	// ho sincronitzem amb el maquinari de la DNS
}

void _gg_spriteMove(unsigned char n, short px, short py)
{
    if (n >= MAX_SPRITES) return;		// només 8 per procés

    extern int _gd_pidz;				// declarat a garlic_dtcm.s
    int proc = _gd_pidz & 0xF;			// ID de procés (fins a 16)
    
	SpriteSlot *s = &gSprites[proc][n];		// agafem l'sprite concret que volem tractar [pid procés] [ quin sprite agafem dins del procés]
    if (!s->used || !s->gfx) return;		// cal VRAM i gfx creats

    // per evitar perdre completament el sprite en cas de sortir per pantalla

	// es pot sortir parcialment de pantalla (fins a -32, la meitat en 32x32)
    if (px < -32) px = -32;
    if (py < -32) py = -32;
	// limita al rang de la pantalla principal de la NDS (255x191)
    if (px > 255) px = 255; // horitzontal
    if (py > 191) py = 191; // vertical 

    int id = proc * MAX_SPRITES + n;		// índex global dins de l’OAM (únic per sprite)

	// per actualitzar la posició 
    oamSet(&oamMain,
           id,
           px, py,						// posició nova de la pantalla
           0,							// priority (com al Set)
           0,							// índex de paleta -> idx paleta (0 defecte)
           SpriteSize_32x32,			// mida sprite
           SpriteColorFormat_256Color,	// format de color
           s->gfx,						// RAM on hi ha la imatge (tile data)
           -1,							// sense matriu
           false,						// sense doble buffer
           s->visible ? false : true,   // amaga si estava ocult
           false, false, false);

    oamUpdate(&oamMain);				// ho sincronitzem amb el maquinari de la DNS
}


