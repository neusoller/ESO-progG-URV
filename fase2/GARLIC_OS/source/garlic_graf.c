/*------------------------------------------------------------------------------

	"garlic_graf.c" : fase 1 / programador G

	Funciones de gesti�n de las ventanas de texto (gr�ficas), para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>

#include "garlic_system.h"	// definici�n de funciones y variables de sistema
#include "garlic_font.h"	// definici�n gr�fica de caracteres

// --- funcionalitat addicional ---
#include "icons.h" 				// fase 1 definicio grafica dels emojis
#include "garlic_sprites.h"		// fase 2 addicional

/* definiciones para realizar c�lculos relativos a la posici�n de los caracteres
	dentro de las ventanas gr�ficas, que pueden ser 4 o 16 */
#define NVENT	16				// n�mero de ventanas totales
#define PPART	4				// n�mero de ventanas horizontales o verticales
								// (particiones de pantalla)
#define VCOLS	32				// columnas y filas de cualquier ventana
#define VFILS	24
#define PCOLS	VCOLS * PPART	// n�mero de columnas totales (en pantalla)
#define PFILS	VFILS * PPART	// n�mero de filas totales (en pantalla)

const unsigned int char_colors[] = {240, 96, 64};	// amarillo, verde, rojo

// --- funcionalitat addicional ---
#define MAX_PROC 16
#define MAX_SPRITES 8

// fase 2 addicional
extern int _gd_pidz;   // procés en execució (zócalo)
extern void gs_hideAllSprites(void);
extern void gs_refreshSprites(void);

// programa fase 1
int bg2, bg3;

// programa fase 2
int map2ptr;
const char espacios4[]="    ";
const char espacios8[]="        ";
char buffer[9];

/*
 *  Aquesta funció crea múltiples còpies de la mateixa baldosa, 
 *  una per a cada color.
 *  Cada còpia es guarda en una posició diferent del banc de baldosas,
 *  separada per blocs de 256 baldosas.
 *
 *  Per a cada píxel de la baldosa (32 halfwords per tile en format 8bpp),
 *  es comprova si el píxel original és blanc (0xFF). Si ho és, se substitueix
 *  pel color corresponent; si no, es queda transparent.
 */
void recolorTiles(unsigned char character, u16* baldosas)
{	
	int baldosaMida =32;
	short pixelsBaldosa;
	int numColors = sizeof(char_colors) / sizeof(char_colors[0]);
	//int numColors = sizeof(char_colors);
	for (int j = 0; j < numColors; j++) {
		int offset = 256 + j * 256;
		for (int x = 0; x < baldosaMida; x++) {
			pixelsBaldosa = 0;
			if ((baldosas[character * baldosaMida + x] & 0xff) == 0xff) {
				pixelsBaldosa |= char_colors[j];
			}
			if ((baldosas[character * baldosaMida + x] & 0xff00) == 0xff00) {
				pixelsBaldosa |= char_colors[j] << 8;
			}
			baldosas[(character + offset) * baldosaMida + x] = pixelsBaldosa;
		}
	}
}

/*
 *  Calcula i retorna el punter al mapa de baldosas corresponent a una finestra.
 *  Primer selecciona quin fons (BG2 o BG3), després calcula el desplaçament
 *	vertical (v / PPART), i el desplaçament horitzontal (v % PPART).
 *	Es retorna el punter amb la posició (0,0) de la finestra.
 */
u16 * getMapPointerAll(int v, char bg_boolean)
{
	u16 * mapPtr;
	int bg = bg_boolean ? bg3 : bg2;
	mapPtr = bgGetMapPtr(bg) + (v / PPART) * VFILS * PCOLS;

	if (v % PPART != 0) {
		mapPtr += VCOLS * (v % PPART);
	}
	return mapPtr;
}

/* _gg_generarMarco: dibuja el marco de la ventana que se indica por par�metro*/
void _gg_generarMarco(int v, int color)
{

	u16 * mapPtr = getMapPointerAll(v, 1);
	
	//unsigned short coordenades = ((v%PPART)*VCOLS) // horitzontal
	//							+(((v/PPART)*VFILS)*PCOLS); // vertical

	int indexColor = color * 256;

	// cantonades de la finestra
	mapPtr[0 + 0 * PCOLS] = 103 + indexColor;		// superior esquerra
	mapPtr[(VCOLS - 1) + 0 * PCOLS] = 102 + indexColor;		// superior dreta
	mapPtr[0 + (VFILS -1) * PCOLS] = 100 + indexColor;		// inferior esquerra
	mapPtr[(VCOLS - 1) + (VFILS -1) * PCOLS] = 101 + indexColor;	// inferior dreta

	// linies horitzontals
	for(int i = 1; i < VCOLS-1; i = i + 1){
		mapPtr[i] = 99 + indexColor;	// superior
		mapPtr[i + (VFILS - 1) * PCOLS] = 97 + indexColor;	// inferior
	}
	// linies verticals
	for (int i = 1; i < (VFILS-1);i++){
		mapPtr[i * PCOLS] = 96 + indexColor;	// esquerra
		mapPtr[i * PCOLS + VCOLS - 1] = 98 + indexColor;	// dreta
	}
}

/* _gg_iniGraf: inicializa el procesador gr�fico A para GARLIC 1.0 */
void _gg_iniGrafA()
{
	videoSetMode(MODE_5_2D| DISPLAY_SPR_ACTIVE| DISPLAY_SPR_1D );
	vramSetBankA(VRAM_A_MAIN_BG_0x06000000);
	
	//  fase 2 addicional
    vramSetBankB(VRAM_B_MAIN_SPRITE_0x06400000);		// Assigna el banc VRAM B a gràfics de sprites (OAM)
	oamInit(&oamMain, SpriteMapping_1D_128, false);		// Inicialitza l'OAM principal i sense rotació per defecte
    dmaCopy(iconsTiles, SPRITE_GFX, iconsTilesLen);		// Copia els sprites (tiles) a la VRAM de sprites
	dmaCopy(iconsPal, SPRITE_PALETTE, 512);				// Copia la paleta de colors dels sprites a la VRAM (256 colors)
	
	/*
		int bgInit(int layer, BgType type, BgSize size, int mapBase, int tileBase);
		-> mapBase: Posici� a la VRAM on es reserva el tile map
			1. tile map = 2KB
			2. VRAM = 32KB
		
		@VRAM_2 = 0x06000000 + (8 ? 2048) = 0x06004000
		@VRAM_3 = 0x06000000 + (4 ? 2048) = 0x06002000
		
		-> tileBae: on es guarden les baldoses (tiles) en la VRAM
			1. Comparteixen l'espai de mem�ria 
	*/
    bg2 = bgInit(2, BgType_ExRotation, BgSize_ER_1024x1024, 0, 4);
    bg3 = bgInit(3, BgType_ExRotation, BgSize_ER_1024x1024, 16, 4);
	
	map2ptr = (int) bgGetMapPtr(bg2);
	
	bgSetPriority(bg2, 2);
    bgSetPriority(bg3, 0);	// més prioritat -> poso 2 perquè a la 1 estaran els sprites

	// descomprimeix la font gr?fica (tiles de caràcters) i la copia a la memòria VRAM
	decompress(garlic_fontTiles,bgGetGfxPtr(bg3), LZ77Vram);
	
	// copia la paleta de colors de la font gr�fica
	dmaCopy(garlic_fontPal, BG_PALETTE, sizeof(garlic_fontPal));

	u16* baldosas = bgGetGfxPtr(bg3);		//direcció inicial de les baldosas del fons bg3(u8)
	for (int i = 0; i < 128; i++) {			//128 baldoses b�siques
		recolorTiles(i, baldosas);
	}

	// genera els marcs de les finestres
    for(unsigned char i = 0 ; i < NVENT ; i++)
		_gg_generarMarco(i, 3);
	
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
					  string resultante, pero identifica los c�digos de formato
					  precedidos por '%' e inserta la representaci�n ASCII de
					  los valores indicados por par�metro.
	Par�metros:
		formato	->	string con c�digos de formato (ver descripci�n _gg_escribir);
		val1, val2	->	valores a transcribir, sean n�mero de c�digo ASCII (%c),
					un n�mero natural (%d, %x) o un puntero a string (%s);
		resultado	->	mensaje resultante.
	Observaci�n:
		Se supone que el string resultante tiene reservado espacio de memoria
		suficiente para albergar todo el mensaje, incluyendo los caracteres
		literales del formato y la transcripci�n a c�digo ASCII de los valores.
*/
void _gg_procesarFormato(char *formato, unsigned int val1, unsigned int val2,
																short *resultado, char color)
{
	int i = 0;
	int k = 0;
    int counter;
	char caracter = formato[i];
    char valTaula[27];
	int valorsPerTransformar = 1;
	int counterPercentage = 0;

	// recorre la cadena de format per processar els caracters especials
    while (caracter != '\0') {
        if (caracter == '%') {
			counterPercentage = 0;
			while (caracter == '%') { // saltem
				resultado[k++] = caracter | color << 8;
				caracter = formato[++i];
				counterPercentage++;
            }

			switch (formato[i]) {
				case '0':
					resultado[--k] = ' ';
					color = 0;
					break;
				case '1':
					resultado[--k] = ' ';
					color = 1;
					break;
				case '2':
					resultado[--k] = ' ';
					color = 2;
					break;
				case '3':
					resultado[--k] = ' ';
					color = 3;
					break;
				default:
					if (valorsPerTransformar > 0 && counterPercentage < 2 && valorsPerTransformar <= 2) {
						resultado[--k] = ' ';
						counterPercentage = 0;
						unsigned int val = valorsPerTransformar == 1 ? val1 : val2;
						valorsPerTransformar++;
						if (caracter == 'c')
						{
							resultado[k++] = (char) val | color << 8;
						}
						else if (caracter == 'd')
						{
							_gs_num2str_dec(valTaula, 12, val);
							counter = 0;
							
							while (valTaula[counter] != '\0')
							{
								if (valTaula[counter] != ' ')
								{
									resultado[k++] = valTaula[counter] | color << 8;
								}
								counter++;
							}
						}
						else if (caracter == 'x')
						{
							_gs_num2str_hex(valTaula, 12, val);
							counter = 0;
							while (valTaula[counter] != '\0')
							{
								if (valTaula[counter] != '0')
								{
									resultado[k++] = valTaula[counter] | color << 8;
								}
								counter++;
							}
						}
						else if (caracter == 's')
						{
							int j = 0;
							char* address = (char *) val;
							while (address[j] != '\0')
							{
								resultado[k++] = address[j++] | color << 8;
							}
						}
					}
					else
					{
						resultado[k++] = caracter | color << 8;
					}
					break;
			}
		}
		else
		{
			resultado[k++] = caracter | color << 8;
		}
		caracter = formato[++i];
	}
    resultado[k] = '\0' | color << 8;
}

/* _gg_escribir: escribe una cadena de caracteres en la ventana indicada;
	Par�metros:
		formato	->	cadena de formato, terminada con centinela '\0';
					admite '\n' (salto de l�nea), '\t' (tabulador, 4 espacios)
					y c�digos entre 32 y 159 (los 32 �ltimos son caracteres
					gr�ficos), adem�s de c�digos de formato %c, %d, %x y %s
					(max. 2 c�digos por cadena)
		val1	->	valor a sustituir en primer c�digo de formato, si existe
		val2	->	valor a sustituir en segundo c�digo de formato, si existe
					- los valores pueden ser un c�digo ASCII (%c), un valor
					  natural de 32 bits (%d, %x) o un puntero a string (%s)
		ventana	->	n�mero de ventana (de 0 a 3)
*/
void _gg_escribir(char *formato, unsigned int val1, unsigned int val2, int ventana)
{
	garlicWBUF* buffer = _gd_wbfs + ventana;
	int pControl = buffer->pControl;
	int numChar = pControl & 0xFFFF;
	
	short res[VCOLS*3 + 1] = {}; // +1 per al '\0'
	char color = (pControl & 0xF0000000) >> 28;
	color = (_gd_wbfs[ventana].pControl & 0xF0000000) >> 28; // Agafem els 4 bits alts per identificar el color amb una m�scara AND
	_gg_procesarFormato(formato, val1, val2, res, color);	// format a text
	
	// una vegada s'ha processat el format, variables:
	int i = 0;
	//int zocalo = _gi_za;
	int zocalo = ventana;
	char compt = res[i] & 0xFF;
	color = (res[i] & 0xFF00) >> 8;
	
	/*
		pControl (32b):
		-> 16b superiors: el número de línia actual (filaAct)
	*/
	unsigned short filaAct = (pControl & 0x0FFF0000) >> 16; // AND de 16b cap a la dreta
	
	while (res[i] != '\0') { // fins que no arribem a la centinella		
		if(compt == '\t') {		//tabulador -> afegim espais
			while(numChar < VCOLS && numChar % 4 != 0) { // equivalent a tab != 0
				unsigned short ch = ' ';
                ch = ch >= 128 ? ch + 8 * zocalo : ch - 32;
				// ch += color * 256; ---> mirar si cal aplicar el color per el tabulador
                // aquí no apliquem color (color_boolean = false)
                buffer->pChars[numChar++] = ch;
			}
		} else if(compt == '\n') { // si és un salt de línia -> es gestiona més avall
			/*unsigned short ch = ' ';
            ch = ch >= 128 ? ch + 8 * zocalo : ch - 32;
            ch += color * 256;      // aquí sí, amb color actual
            buffer->pChars[numChar++] = ch;*/
		} else { // caracters normals
			if (numChar < VCOLS) {
				unsigned short ch = compt;                     // codi ASCII
				ch = ch >= 128 ? ch + 8 * zocalo : ch - 32;    // índex de baldosa
				ch += color * 256;                             // aplicar color actual
				buffer->pChars[numChar++] = ch;
			}
		}
		
		// Si hem arribat al final de la línia o trobem un salt de línia
		if(compt == '\n' || numChar == VCOLS) {	
			swiWaitForVBlank();
			
			if(filaAct == (VFILS - 1)) { // en cas que la pantalla estigui plena, fem scroll
				if (numChar != 0)
				{
					_gg_escribirLinea(ventana, filaAct, numChar);
				}
				_gg_desplazar(ventana);
				//filaAct--;
			} else {
				if (numChar != 0) {
					_gg_escribirLinea(ventana, filaAct, numChar); // escriu la línia
				}
				//numChar = 0;
				filaAct++;
			}
			numChar = 0;
		}
		pControl = numChar | (filaAct << 16) | (color << 28);
		buffer->pControl = pControl;
		i++;
        compt = res[i] & 0xFF;
		color =  (res[i] & 0xFF00) >> 8;
	}
}

// ens servirà de pont API
void _gg_spriteSet(unsigned char n, unsigned char icon) {
    gs_spriteSet(_gd_pidz & 0xF, n, icon);
}

void _gg_spriteMove(unsigned char n, short px, short py) {
    gs_spriteMove(_gd_pidz & 0xF, n, px, py);
}

void _gg_spriteShow(unsigned char n) {
    gs_spriteShow(_gd_pidz & 0xF, n);
}

void _gg_spriteHide(unsigned char n) {
    gs_spriteHide(_gd_pidz & 0xF, n);
}

// fase 2 addicional 
// crides directes a funcionalitats globals de sprites
void _gg_hideAllSprites(void) { gs_hideAllSprites(); }
void _gg_refreshSprites(void) { gs_refreshSprites(); }