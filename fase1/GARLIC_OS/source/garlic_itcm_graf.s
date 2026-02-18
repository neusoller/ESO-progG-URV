@;==============================================================================
@;
@;	"garlic_itcm_graf.s":	código de rutinas de soporte a la gestión de
@;							ventanas gráficas (versión 1.0)
@;
@;==============================================================================

NVENT	= 4					@; número de ventanas totales
PPART	= 2					@; número de ventanas horizontales o verticales
							@; (particiones de pantalla)
L2_PPART = 1				@; log base 2 de PPART

VCOLS	= 32				@; columnas y filas de cualquier ventana
VFILS	= 24
PCOLS	= VCOLS * PPART		@; número de columnas totales (en pantalla)
PFILS	= VFILS * PPART		@; número de filas totales (en pantalla)

WBUFS_LEN = 36				@; longitud de cada buffer de ventana (32+4)

.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gg_escribirLinea
	@; Rutina para escribir toda una linea de caracteres almacenada en el
	@; buffer de la ventana especificada;
	@;Parámetros:
	@;	R0: ventana a actualizar (int v)
	@;	R1: fila actual (int f)
	@;	R2: número de caracteres a escribir (int n)
_gg_escribirLinea:
	push {r0-r6, lr}
		@; comprovar el nombre de files
		cmp r0, #NVENT
		bhs .L_Finalitzar		@; si el número de finestra és més gran o igual a NVENT, salta
	
		@; crida de la funció _gg_desplazar
		cmp r1, #VFILS			@; mirem si la fila actual (r1) és més gran o igual a VFILS 
		subeq r1, #1			@; continuem escrivint a la línia de sobre
		bleq _gg_desplazar		@; si és més gran o igual cridem la funció per fer scroll

		@; coordenades relatives
		lsr r3, r0, #L2_PPART	@; fila relativa -> (v / PPART) == v >> L2_PPART
		and r4, r0, #L2_PPART	@; columna relativa -> (v % PART) == (PPART - 1) and v
								@; L2_PPART = 1 ( log_2(PPART) = log_2(2) = 1)
								@; AND amb PPART per obtenir el residu de la divisió (v % PPART)
		mov r6, r0
	
		@; coordenades reals
		@; combino les coordenades relatives amb dimensions de la pantalla
		mov r0, #VCOLS
		mul r4, r0, r4			@; r4 -> columna_act * VCOLS
		mov r0, #VFILS
		mul r3, r0, r3			@; r3 -> fila_act * VFILS
		mov r0, #PCOLS
		mla r3, r0, r3, r4		@; r3 -> columna + (fila * PCOLS)
		lsl r3, r3, #1			@; desplaçament a l'esquerra 
								@; per convertir la coordenada a Half-word de 16 bits
								@; aixó ho faig perquè cada tile ocupa 2 bytes

		@; Carregar la direcció de la memòria gràfica
		ldr r4, =mapPtr2 		@; carrega la base de la memòria gràfica del mapa 2
		ldr r4, [r4]			@; @ del mapa
		
		@; Càlcul del offset	
		add r4, r4, r3			@; tindrem la direcc� de la finestra a tractar
		lsl r0, #1				@; PCOLS en HWord, PCOLS*2 (important pel c�lcul correcte)
		mla r4, r1, r0, r4		@; offset -> fila_act * columnes_totals_pantalla + mapPtr2
		
		@; posicionament -> carregar buffer
		ldr r3, =_gd_wbfs
		mov r0, #WBUFS_LEN
		mla r3, r6, r0, r3		@; r3 -> @ del buffer (per tenir el caracter)
		add r3, #4				@; salto l'integer +4
		
		@; loop
		mov r0, #0				@; index caracters
		mov r1, #0				@; index mapa baldosas
		
	.L_MentreCaracters:
		cmp r2, #0
		beq .L_Finalitzar		@; s'acaba quan hem acabat d'escriure tot el que teniem
		
		ldrb r5, [r3, r0]		@; caracter llegit
								@; r3 -> @ buffer car�cters a escriure
		@; comparar 128
		cmp r5, #128
		bge .L_add
		sub r5, #32				@; r5 -> conversió de codi ASCII a �ndex de tile restant 32
								@; els caràcters ASCII visibles comencen a 32 (espai)
								@; la memòria gràfica té els caràcters ordenats en el mateix
								@; ordre que l'ASCII, però sense els primers 32 caràcters

	.L_add:	
		strh r5, [r4, r1]		@; guardem el valor resultat de r5
								@; r4 -> @ base on s'ha de guardar el caracter (finestra) - HWord
								@; r1 -> index on s'emmagatzema - Byte
		
		add r0, #1				@; avancem cap al següent caracter del buffer
		add r1, #2				@; següent posició on s'emmagatzemarà el proper caràcter a la memòria gràfica
		sub r2, #1				@; comptador caràcters que resten per escriure
		b .L_MentreCaracters
	
	.L_Finalitzar:

	pop {r0-r6, pc}


	.global _gg_desplazar
	@; Rutina para desplazar una posición hacia arriba todas las filas de la
	@; ventana (v), y borrar el contenido de la última fila
	@;Parámetros:
	@;	R0: ventana a desplazar (int v)
_gg_desplazar:
	push {r0-r6, lr}
		mov r1, #PPART
		ldr r2, =quo_fdiv		@; r2 -> quoficient
		ldr r3, =mod_fdiv		@; r3 -> mòdul
		
		@; c�lcul de fila i columna a partir de la finestra
		bl _ga_divmod
		cmp r0, #0				@; 0 si no hi ha hagut error
		bne .L_Final			@; != 0 -> problema amb divmod
		
		@; carreguem els valors del resultat de _ga_divmod als registres r2 i r3
		ldr r2, [r2]
		ldr r3, [r3]
		
		mov r0, #VCOLS
		mul r3, r0, r3			@; col_act = col_act * VCOLS
		
		mov r0, #VFILS			@; fila_act = fila_act * VFILS
		mul r2, r0, r2
		
		mov r0, #PCOLS
		mla r3, r0, r2, r3		@; coordenades = colu_act + fila_act * PCOLS
		lsl r3, #1

		
		ldr r4, =mapPtr2		@; @ base mapa2
		ldr r4, [r4]			@; direcció mapa2
		lsl r0, #1				@; halfwords: desplaçament a l'esquerra, per tant multipliquem x2
		add r4, r4, r3			@; direcció real = mapPtr2 + coordenades 
	
		@; desplaçament de files
		mov r3, #0				@; index fila
	
	.L_DesplFila:
		mov r1, #0				@; posició columna
								@; la reinicio per a cada iteració de L_DesplFila
	
		cmp r3, #VFILS			@; final finestra
		beq .L_Final			@; saltem a L_Final
		mla r2, r3, r0, r4		@; direcció fila actual actualitzada
		add r5, r2, r0			@; fila inferior

	.L_BucleColumnes:
		cmp r1, #VCOLS*2		@; per saber si hem arribat al final de columnes
		
		addeq r3, #1			@; passem a la següent fila
		beq .L_DesplFila
		
		ldrh r6, [r5, r1]		@; carrego el valor de la fila inferior
		cmp r3, #VFILS-1		@; cas última fila
		
		moveq r6, #0			@; cas última fila: omplim a 0 tota la fila -> s'esborra
		strh r6, [r2, r1]		@; copio el valor a la fila superior
		
		add r1, #2				@; passem a la següent columna
		b .L_BucleColumnes

	.L_Final:

	pop {r0-r6, pc}


.end

