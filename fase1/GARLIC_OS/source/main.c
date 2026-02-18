/*------------------------------------------------------------------------------

	"main.c" : fase 1 / programador G

	Programa de prueba de llamada de funciones gráficas de GARLIC 1.0,
	pero sin cargar procesos en memoria ni multiplexación.

------------------------------------------------------------------------------*/
#include <nds.h>

#include <garlic_system.h>	// definición de funciones y variables de sistema

#include <GARLIC_API.h>		// inclusión del API para simular un proceso

int hola(int);				// función que simula la ejecución del proceso
extern int prnt(int);		// otra función (externa) de test correspondiente
							// a un proceso de usuario

extern int xf1(int);		// programa d'usuari

extern int * punixTime;		// puntero a zona de memoria con el tiempo real


/* Inicializaciones generales del sistema Garlic */
//------------------------------------------------------------------------------
void inicializarSistema() {
//------------------------------------------------------------------------------
	int v;

	_gg_iniGrafA();			// inicializar procesador gráfico A
	for (v = 0; v < 4; v++)	// para todas las ventanas
		_gd_wbfs[v].pControl = 0;		// inicializar los buffers de ventana
	
	_gd_seed = *punixTime;	// inicializar semilla para números aleatorios con
	_gd_seed <<= 16;		// el valor de tiempo real UNIX, desplazado 16 bits
}
//------------------------------------------------------------------------------
/*
	Per controlar la finestra
	modifica el pid per posar la finestra que ens interessa
	- w: número de finestra (0..3)
*/
static inline void set_window(unsigned w)
{   // w = 0..3
    extern int _gd_pidz; // pid
    _gd_pidz = (_gd_pidz & ~0x3) | (w & 0x3);	// esborra els 2 bits baixos
												// poso el número de finestra
												// el pid queda intacte
}
//------------------------------------------------------------------------------
/*
	Calculo el offset d'una finestra
	- w: número de finestra (0..3)
	- x, by: coordenades de la cantonada superior esquerra dins la pantalla
*/
static inline void wnd_offset(unsigned w, int *bx, int *by)
{
    const int WIN_W = 128, WIN_H = 96; // Cada finestra té mida 128x96 píxels (per PPART=2)
    *bx = (w % 2) * WIN_W; // per les columnes
    *by = (w / 2) * WIN_H; // per les files
}
//------------------------------------------------------------------------------
/*
	Per controlar el swiWaitForVBlank. Espera N frames i els tracta
*/
static void wait_frames(int n)
{
	for(int i=0;i<n;++i) swiWaitForVBlank();
}
//------------------------------------------------------------------------------
/*
	Preparo l'sprite per ensenyar-lo per pantalla en diferents coordenades
	- w: finestra
	- n: índex del sprite
	- icon: número d’icona
	- (x, y): coordenades dins la finestra
*/
static void place_sprite(unsigned w, unsigned char n, int icon, short x, short y){
    int bx, by;
	
	wnd_offset(w, &bx, &by); // primer calculem l'offset
    set_window(w); // indiquem quina finestra
	
    _gg_spriteSet(n, icon); // assigno l'sprite 
    _gg_spriteShow(n); // el fem visible
    _gg_spriteMove(n, bx + x, by + y); // el situem a on ens interessi
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// JOC DE PROVES
void run_sprites_demo(void)
{
    int bx, by;
	
	// Aqui configuro 4 sprites
	// - posició
	// - icona
	// - finestra on es mostraran
    struct { unsigned char n; int icon; unsigned w; short x, y; } cfg[] = {
        {0, 9, 0,  16, 16},   // dalt-esq - abella
        {1, 16, 1,  80, 12},   // dalt-dreta - flor
        {2, 19, 2,  24, 60},   // baix-esq - estrella
        {3, 25, 3, 100, 40},   // baix-dreta - sindria
    };
	
	// mostrar 4 sprites
	for(int i=0;i<4;++i) place_sprite(cfg[i].w, cfg[i].n, cfg[i].icon, cfg[i].x, cfg[i].y);
	wait_frames(120); // 2s aprox.
	
	// l'abella es mou a la dreta fins arribar al final
	set_window(0);
    for(int x=8; x<=104; ++x){
        _gg_spriteMove(0, 0 + x, 16);   // offset de finestra aplicat dins place_sprite; aquí ja és global
        swiWaitForVBlank();
    }
    wait_frames(60);
	
	// el tulipà s'amaga i torna a aparèixer
	set_window(1); // finestra 1
	_gg_spriteHide(1); // s'amaga
	wait_frames(60);
    _gg_spriteShow(1); // apareix
	wait_frames(60);
	
	// la síndria es transforma en pop
	set_window(2);
	_gg_spriteSet(2, 12);  // es transforma en pop (=12)
	wait_frames(60);
	
	// proves de la posició a les cantonades
	wnd_offset(3, &bx, &by); // offset finestra 3
	set_window(3);
	
	_gg_spriteMove(3, bx - 10, by - 10);      // parcialment entre les 4 finestres
	wait_frames(80);
	
	_gg_spriteMove(3, bx + 127 - 16, by + 95 - 16);     // cantonada inf-dreta dins finestra
														// resto 16 perquè és la meitat del sprite i vull que es vegi un tros
	wait_frames(80);
	
	_gg_spriteMove(3, 256 + 20, 192 + 20);    // fora total de pantalla
	wait_frames(80);
}

//------------------------------------------------------------------------------
int main(int argc, char **argv) {
//------------------------------------------------------------------------------
	
	inicializarSistema();
	
	_gg_escribir("********************************", 0, 0, 0);
	_gg_escribir("*                              *", 0, 0, 0);
	_gg_escribir("* Sistema Operativo GARLIC 1.0 *", 0, 0, 0);
	_gg_escribir("*                              *", 0, 0, 0);
	_gg_escribir("********************************", 0, 0, 0);
	_gg_escribir("*** Inicio fase 1_G\n", 0, 0, 0);
	
	_gd_pidz = 6;	// simular zócalo 6
	hola(0);
	_gd_pidz = 7;	// simular zócalo 7
	hola(2);
	_gd_pidz = 5;	// simular zócalo 5
	prnt(1);

	_gg_escribir("*** Final fase 1_G\n", 0, 0, 0);

	int arg = 2;
    xf1(arg);  // Executar el programa d'usuari
	
	run_sprites_demo();

	while (1)
	{
		swiWaitForVBlank();
	}							// parar el procesador en un bucle infinito
	return 0;
}


/* Proceso de prueba */
//------------------------------------------------------------------------------
int hola(int arg) {
//------------------------------------------------------------------------------
	unsigned int i, j, iter;
	
	if (arg < 0) arg = 0;			// limitar valor máximo y 
	else if (arg > 3) arg = 3;		// valor mínimo del argumento
	
									// esccribir mensaje inicial
	GARLIC_printf("-- Programa HOLA  -  PID (%d) --\n", GARLIC_pid());
	
	j = 1;							// j = cálculo de 10 elevado a arg
	for (i = 0; i < arg; i++)
		j *= 10;
						// cálculo aleatorio del número de iteraciones 'iter'
	GARLIC_divmod(GARLIC_random(), j, &i, &iter);
	iter++;							// asegurar que hay al menos una iteración
	
	for (i = 0; i < iter; i++)		// escribir mensajes
		GARLIC_printf("(%d)\t%d: Hello world!\n", GARLIC_pid(), i);
		
	return 0;
}


