@;==============================================================================
@;
@;	"garlic_itcm_graf.s":	código de rutinas de soporte a la gestión de
@;							ventanas gráficas (versión 1.0)
@;
@;==============================================================================

NVENT	= 16					@; número de ventanas totales
PPART	= 4					@; número de ventanas horizontales o verticales
							@; (particiones de pantalla)
L2_PPART = 2				@; log base 2 de PPART

VCOLS	= 32				@; columnas y filas de cualquier ventana
VFILS	= 24
PCOLS	= VCOLS * PPART		@; número de columnas totales (en pantalla)
PFILS	= VFILS * PPART		@; número de filas totales (en pantalla)

WBUFS_LEN = 68				@; longitud de cada buffer de ventana (32+4)

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
	push {r3-r12, lr}
		mov r4, r0				@; r4 = número de finestra (v)
		
		@; Guardem r1-r3 perquè cal passar r1 = 0 a getMapPointerAll
		push {r1-r3}
		mov r1, #0				@; boolean = 0 serà bg2
		bl getMapPointerAll		@; retorna en r0 el punter base a la finestra v
		pop {r1-r3}
		
		@; r0 conté la direcció base de la finestra, però a la fila 0
		mov r5, #PCOLS			@; r5 = PCOLS (núm total de columnes, 128)
		mul r6, r5, r1			@; r6 = r5 * r1 -> núm de caselles a saltar (halfwords)
		add r0, r6, lsl #1		@; r0 = r0 (base finestra) + (R6 << 1)
								@; perquè cada casella = 2 bytes (halfword)
								@; r0 = adreça de la primera casella de la fila de la finestra
		
		ldr r5, =_gd_wbfs		@; r5 = @base de _gd_wbfs[0]
		mov r7, #WBUFS_LEN		@; r7 = mida en bytes d'un WBUF (68)
		mul r6, r4, r7			@; r6 = v * WBUFS_LEN -> desplaçament fins a _gd_wbfs[v]
		add r5, r6				@; r5 = &_gd_wbfs[v]
								@; punter a l'estructura WBUF de la finestra v
		
		@; per llegir pControl
		ldr r8, [r5]			@; r8 = pControl de _gd_wbfs[v]
		ldr r7, =0xFFFF			@; per als 16 bits baixos
		and r8, r8, r7			@; r8 = núm de caràcters pendents (pControl & 0xFFFF)
		
		mov r7, r5				@; tindrem el punter de pControl a r7
								@; r7 = &_gd_wbfs[v].pControl
		
		add r5, #4				@; r5 = &_gd_wbfs[v].pChars[0]
								@; pChars comença 4 bytes després
		
		@; comptadors pels bucle
		mov r9, #0				@; índex per pChars
		mov r6, #0				@; per marcar la posició buida
		
	@; pels caracters pendents es farà:
	@; 	- copiar pChars al mapa bg2
	@;	- després posar 0 els caracters de pChars tractats
	.Lbucle:
		mov r12, r9, lsl #1		@; r12 = i*2
								@; offset en bytes dins de pChars i del mapa (halfword)
		
		ldrh r10, [r5, r12]		@; llegeixo el codi de la baldosa + color de la finestra
								@; r10 = pChars[i] (r5 -> punter a pChars , r12 -> offset (i))
		strh r10, [r0, r12]		@; escriu el codi a la fila del bg2
								@; mapa[fila][i] = pChars[i]
		
		strh r6, [r5, r12]		@; poso a 0
		
		add r9, #1				@; i++
		
		cmp r9, r8
		blo .Lbucle2			@; si i < núm caràcters pendents (r8) saltem 
		b .Lfin					@; si i >=, sortim
	.Lbucle2:
		cmp r9, r2
		blo .Lbucle				@; si i < nombre màxim de caràcters a escriure (r2), seguim amb el bucle
		@; si i >=, sortim
		
	@; Actualitzar pControl	
	.Lfin:
		sub r8, r9				@; r8 = r8 - r9 = caracters antics - escrits
		ldr r9, [r7]			@; r9 = carreguem el pControl original
		ldr r10, =0xFFFF0000	@; netejo els bits baixos per els nous caracters 
		and r9, r10				@; r9 = pControl & 0xFFFF0000, només bits alts (color, fila)
		orr r9, r9, r8			@; r9 = bits alts + pendents nous
		str r9, [r7]			@; assignem el nou valor de pControl
		
	pop {r3-r12, pc}

	.global _gg_desplazar
	@; Rutina para desplazar una posición hacia arriba todas las filas de la
	@; ventana (v), y borrar el contenido de la última fila
	@;Parámetros:
	@;	R0: ventana a desplazar (int v)
_gg_desplazar:
	push {r1-r12, lr}
		mov r4, r0				@; r4 = número de finestra (v)
		
		@; Guardem r1-r3, r12 perquè cal passar r1 = 0 a getMapPointerAll
		push {r1-r3,r12}
		mov r1, #0				@; boolean = 0 serà bg2
		bl getMapPointerAll		@; retorna en r0 el punter base a la finestra v
		pop {r1-r3,r12}
		
		mov r1, r0				@; r1 = base mapa (fila de dalt)
		mov r12, r0				@; r12 = base mapa (fila de sota)
		
		@; per calcular el desplaçament d'una fila completa
		mov r3, #PCOLS			@; r3 = PCOLS
		mov r2, #1
		mul r5, r3, r2			@; r5 = PCOLS * 1 (r2) -> nombre de caselles per una fila
		add r0, r5, lsl #1		@; r0 = base + (PCOLS * 2)
		
		mov r6, #VCOLS			@; r6 = VCOLS
		mov r7, #0				@; r7 = columna actual
		
		mov r10, #VFILS - 1		@; índex de l'última fila visible
		mul r11, r3, r10		@; r11 = PCOLS * (VFILS-1)
								@; núm de caselles fins a l'última fila visible
		add r12, r11, lsl #1	@; r12 = base + (PCOLS*(VFILS-1)*2)
								@; punter a la fila VFILS-1
		
	@; per desplaçar fins l'última fila - 1
	.LbucleDesp:
		mov r9, r7, lsl #1		@; r9 = columna * 2 (offset en bytes dins de la fila)
		
		ldrh r8, [r0, r9]		@; r8 = les coordenades del mapa
		strh r8, [r1, r9]		@; r8 = actualitzar coordenades
		
		add r7, #1				@; columna ++
		cmp r7, r6				@; mirem si hem arribat al final (columnes visibles)
		blo .LbucleDesp			@; si columna < VCOLS -> continuem copiant la mateixa fila
		
		@; quan hem acabat totes les columnes visibles d'aquest fila:
		@; saltem a la següent fila
		mov r7, #0				@; posem a 0 la columna per la següent fila
		mov r1, r0				@; desplaçem tot cap amunt
		add r0, r5, lsl #1		@; saltem PCOLS caselles = PCOLS * 2 bytes
		
		@; si encara no hem arribat a l'última fila visible
		cmp r1, r12				@; r12 = adreça de l'última fila visible
		blo .LbucleDesp			@; si encara no hem arribat a l'última fila -> continua desplaçant
		
		mov r12, #0				@; l'utilitzo per escriure a la fila (baldosa + color = 0)
		
	.LbuclePosarFilaANull:
		mov r9, r7, lsl #1		@; r9 = columna * 2 -> offset de la columna
		strh r12, [r1, r9]		@; mapa amb l'última fila i columna = 0
		
		add r7, #1				@; columna ++
		cmp r7, r6				@; mirem si columna < VCOLS 
		blo .LbuclePosarFilaANull	@; si queden columnes visibles -> continua el loop
	pop {r1-r12, pc}


	.global _gg_escribirLineaTabla
	@; escribe los campos básicos de una linea de la tabla correspondiente al
	@; zócalo indicado por parámetro con el color especificado; los campos
	@; son: número de zócalo, PID, keyName y dirección inicial
	@;Parámetros:
	@;	R0 (z)		->	número de zócalo
	@;	R1 (color)	->	número de color (0..3)
_gg_escribirLineaTabla:
	push {r0-r3, r11, r12, lr}
		mov r12, r0				@; r12 = Zocalo
		mov r11, r1				@; r11 = Color
		ldr r0, =_gd_pcbs		@; carrego el punter a l'array de struct de garlicPCB
		
		mov r1, #24				@; mida per PCB = 6 * 32b
		mul r1, r12
		add r10, r0, r1			@; r10 = Ptr a struct de PCB del procés
		
		@; mirar si és el proceso de S.O. (zócalo 0)
		ldr r0, [r10, #0]		@; cargar el PID
		cmp r0, #0
		bne .L_escriure
		
		@; mirar si es el zócalo 0
		cmp r12, #0
		beq .L_escriure			@; és el procés de SO, per tant, escriurem
		
		@; PID == 0, Z != 0 -> procés acabat, esborrar el contingut del zócalo
		ldr r0, =espacios4		@; cargar 4 espacios per la funcion de _gs_escribirStringSub
		add r1, r12, #4			@; offset de 4 file
								@; la info del zócalo 0 s'escriu a la fila 4
		mov r2, #4				@; offset per arribar a la columna de PID (4)
		mov r3, r11				@; color
		bl _gs_escribirStringSub
		
		mov r2, #9				@; offset per arribar al KeyName
		bl _gs_escribirStringSub
		b .L_escriureZ
		
		@; escriure info de PID i Keyname
		.L_escriure:
		ldr r0, =buffer			@; cargar buffer per guardar el string de PID
		mov r1, #4				@; mida
		ldr r2, [r10, #0]		@; PID
		bl _gs_num2str_dec
		
		ldr r0, =buffer
		add r1, r12, #4			@; offset per fila de PID
		mov r2, #5				@; offset per columna del PID
		mov r3, r11				@; color
		bl _gs_escribirStringSub
		
		@; escriure keyname
		add r0, r10, #16		@; cargar ptr a KeyName
		add r1, r12, #4			@; anar a la fila del z
		mov r2, #9				@; columna de keyname
		mov r3, r11				@; color
		bl _gs_escribirStringSub
		
		@; escriure info de Zocalo
		.L_escriureZ:
		ldr r0, =buffer
		mov r1, #3				@; max zocalo = 16, +1 de centinella
		mov r2, r12				@; zócalo
		bl _gs_num2str_dec
		
		ldr r0, =buffer
		add r1, r12, #4
		mov r2, #1				@; offset de zócalo
		mov r3, r11				@; color
		bl _gs_escribirStringSub

	pop {r0-r3, r11, r12, pc}




	.global _gg_escribirCar
	@; escribe un carácter (baldosa) en la posición de la ventana indicada,
	@; con un color concreto;
	@;Parámetros:
	@;	R0 (vx)		->	coordenada x de ventana (0..31)
	@;	R1 (vy)		->	coordenada y de ventana (0..23)
	@;	R2 (car)	->	código del carácter, como número de baldosa (0..127)
	@;	R3 (color)	->	número de color del texto (0..3)
	@; pila (vent)	->	número de ventana (0..15)
_gg_escribirCar:
	push {r0-r7, lr}
		add r0, r0, #1      		@; vx = vx + 1  (ajust de coordenada X dins la finestra: marge/offset intern)
		
		ldr r4, [sp, #9*4]			@; r4 = ventana (5è param)
									@; després del push tenim 9 words -> sp + 36 (1 reg = 32b)
		push {r0}					@; guardem vx (r0)
		mov r0, r4					@; r0 = num. finstra (0..15)
		bl _gg_calcularPosVentana	@; retorna a r0 el punter base del mapa (tilemap) corresponent a la finestra
		mov r5, r0					@; r5 = baseMapaVentana
									@; adreça base on s'escriuren tiles d'aquesta finestra
									@; pos 0,0 de la finestra indicada
		pop {r0}					@; recuperem r0 = vx ajustat
		
		mov r6, #PCOLS*2			@; r6 = PCOLS tiles * 2 bytes per tile
									@; bytes per fila del mapa global
		mla r5, r1, r6, r5			@; fila * desplaçament per fila (32 pos. * 2) + ptr finestra
									@; r5 = r5 + vy * (PCOLS * 2)
									@; apunta a l'inici de la fila vy dins del mapa de la finestra
		mov r6, r0, lsl #1			@; r6 = vx * 2 
									@; despl. en bytes dins la fila, (*2) perquè cada tile és halfword
		add r5, r6					@; r5 = posició del caràcter a escriure
		
		mov r6, r3, lsl #7			@; r6 = color << 7
									@; posem el color als bits alts del codi de baldosa (format tile+color)
		add r2, r6					@; r2 = c + (color<<7) = caràcter a escribir
		strh r2, [r5]				@; escriu el halfword (tile+color) al mapa a la posició calculada
		
	pop {r0-r7, pc}



	.global _gg_escribirMat
	@; escribe una matriz de 8x8 carácteres a partir de una posición de la
	@; ventana indicada, con un color concreto;
	@;Parámetros:
	@;	R0 (vx)		->	coordenada x inicial de ventana (0..31)
	@;	R1 (vy)		->	coordenada y inicial de ventana (0..23)
	@;	R2 (m)		->	puntero a matriz 8x8 de códigos ASCII (dirección)
	@;	R3 (color)	->	número de color del texto (0..3)
	@; pila	(vent)	->	número de ventana (0..15)
_gg_escribirMat:
	push {r0-r12, lr}
		
		add r0, r0, #1				@; vx = vx + 1  (ajust d'X dins la finestra)
		
		ldr r4, [sp, #14*4]			@; r4 = ventana (5è paràmetre)
									@; després del push {r0-r12,lr} hi ha 14 paraules (13 regs + lr) = 14*4 bytes
									@; 1 reg = 32b
		push {r0}					@; guardem vx (r0)
		mov r0, r4					@; r0 = num. finstra (0..15)
		bl _gg_calcularPosVentana	@; retorna a r0 el punter base del mapa (tilemap) corresponent a la finestra
		mov r5, r0					@; r5 = baseMapaVentana
									@; adreça base on s'escriuren tiles d'aquesta finestra
									@; pos 0,0 de la finestra indicada
		pop {r0}					@; recuperem r0 = vx ajustat
		
		mov r3, r3, lsl #7			@; r3 = (color << 7)
									@; per sumar-lo a cada tile escrit
		
		mov r6, #PCOLS				@; r6 = PCOLS (columnes totals del mapa global: 128)
		mul r7, r6, r1				@; r7 = vy * PCOLS
									@; nombre de caselles que hem de saltar per baixar vy files
		
		add r7, r5, r7, lsl #1		@; r7 = baseMapa + (vy * PCOLS * 2 bytes)
									@; r7 apunta a l'inici de la fila vy dins el mapa de la finestra
		mov r8, r0, lsl #1			@; r8 = vx * 2 bytes
									@; Offset dins la fila (1 tile = 1 halfword = 2 bytes)
		add r5, r8, r7				@; r5 = adreça exacta del tile (vx, vy)
                                    @; punter on començar a escriure la matriu 8x8
		
		mov r11, #0					@; r11 = contador X dins de la matriu (0..7)
		mov r12, #0					@; r12 = contador global d'elements matriu (0..63)
		
		.L_IniciLoop:
		cmp r11, #7					@; hem acabat una fila de 8 elements? (x > 7)
		ble .L_ControladorX			@; si x <= 7, encara estem dins la mateixa fila, per tant, continua
		
		mov r11, #0					@; si hem passat de 7, reset x = 0 (comença nova fila)
		
		cmp r12, #63				@; hem recorregut els 64 elements? (0..63)
		bgt .L_FiLoop				@; si r12 > 63, ja hem acabat tota la matriu
		
		add r5, r6, lsl #1			@; r5 += PCOLS*2 bytes
									@; baixem una fila real dins el tilemap, que té amplada PCOLS
		sub r5, #16					@; r5 -= 16 bytes
									@; tirem 8 tiles a l'esquerra
                                    @; perquè al final d'una fila hem avançat 8*2=16 bytes en X
                                    @; així tornem a la columna inicial per començar la següent fila 8x8
		.L_ControladorX:
		
		ldrb r7, [r2]				@; r7 = m[k] = caràcter actual de la matriu (1 byte)
									@; r2 apunta a la matriu (char m[][8]) linealitzada
		cmp r7, #0					@; si el caracter és 0
		beq .L_NoImprimir			@; no imprimim res (==0), deixem el car. tal com estava
		
		sub r7, #32					@; convertim ASCII a índex de tile
		add r7, r3					@; afegim el color: tileFinal = (tileIndex) + (color<<7)
		strh r7, [r5]				@; escriu halfword (tile + color) al mapa en la posició actual
		
		.L_NoImprimir:
		add r5, #2					@; avança una columna al mapa (1 tile = 2 bytes)
		add r11, #1					@; x++ (seguent posició dins la fila de 8)
		add r12, #1					@; k++ (seguent element global dins 8x8)
		add r2, #1					@; punter m++ (seguent byte de la matriu)
		b .L_IniciLoop
		.L_FiLoop:
	pop {r0-r12, pc}



	.global _gg_rsiTIMER2
	@; Rutina de Servicio de Interrupción (RSI) para actualizar la representa-
	@; ción del PC actual.
_gg_rsiTIMER2:
	push {r0-r5, lr}
		mov r5, #0					@; r5 = z = comptador del bucle (zócalo / índex de procés 0..15)
		ldr r4, =_gd_pcbs			@; r4 = punter base a l'array de PCBs (_gd_pcbs[])
									@; cada PCB pcupa 24 bytes (6 words de 4 bytes)
		
		.L_IniciLoopRSI:
		cmp r5, #16					@; hem recorregut els 16 zócalos?
		bhs	.L_FiLoopRSI			@; si r5 >= 16, sortim del bucle
		
		@; mirar si PID ==0, en cas que si -> saltar a la següent posició de PCBs
		ldr r0, [r4, #0]			@; r0 = PID del PCB actual
		cmp r0, #0					@; PID==0 -> no hi ha procés carregat
		bne .L_escriurePC			@; si PID != 0 -> hi ha procés -> escriurem el PC
		
		cmp r5, #0					@; zócalo 0 és el procés del SO (control), no s'ha d'esborrar com un buit
		beq .L_escriurePC			@; si és zócalo 0, també escriurem el PC (o el mantenim)
		
		@; PID == 0 i zócalo != 0 -> esborrar PC anterior
		ldr r0, =espacios8			@; r0 = string amb 8 espais (per esborrar el PC anterior a la taula)
		add r1, r5, #4				@; r1 = fila de la taula on escriure
									@; +4 perquè les primeres files (0..3) són capçalera/títol
		mov r2, #14					@; r2 = columna (offset) on comença el camp "PCactual" dins la línia
		mov r3, #0					@; r3 = color blanc
		
		bl _gs_escribirStringSub	@; escriu "espacios8" a (fila=r1, col=r2) de la taula, amb color r3
		b .L_SegIteracioRSI			@; següent PCB
		
		.L_escriurePC:
		@; PCB != 0 o zóclo == 0 -> escriure el PC actual en hexadecimal a la taula
		ldr r0, =buffer				@; r0 = punter a buffer on guardo el string del PC
		mov r1, #9					@; r1 = mida del buffer (8 hex digits + '\0')
		ldr r2, [r4, #4]			@; r2 = PC actual del procés (segon camp del PCB: offset 4)
									@; carrego el valor del PC
		bl _gs_num2str_hex			@; converteix r2 a string hexa dins buffer (r0)
		ldr r0, =buffer				@; r0 = string ja formatat (PC en hexa)
		
		add r1, r5, #4	 			@; r1 = fila de la taula (zócalo + 4 per saltar la capçalera)
		mov r2, #14					@; r2 = columna on va el camp "PCactual"
		mov r3, #0				 	@; r3 = color blanc
		
		bl _gs_escribirStringSub	@; escriu el PC (en text) a la taula en la posició
		
		.L_SegIteracioRSI:
		add r4, #24					@; avançar al següent PCB
									@; r4 += sizeof(PCB) = 24 bytes
		add r5, #1					@; següent zócalo
		
		b .L_IniciLoopRSI
		.L_FiLoopRSI:
		
	pop {r0-r5, pc}


	.global _gg_calcularPosVentana
	@;Parámetros:
	@; 	R0 -> num ventana
	@; 	Return -> Dir. de la pos 0,0 de la ventana en el mapa
_gg_calcularPosVentana:
	push {r1-r5, lr}
		
		and r1, r0, #3				@; r1 = v % PPART
									@; r1 indica la "columna" de finestra dins la graella (0..3)
		
		mov r2, r0, lsr #L2_PPART	@; r2 = v / PPART
									@; L2_PPART=2 perquè PPART=4 (2^2)
									@; r2 indica la "fila" de finestra dins la graella (0..3)
		
		mov r3, #PCOLS*VFILS		@; r3 = PCOLS*VFILS
									@; PCOLS = 128 = columnes totals del mapa global
                                    @; VFILS = 24 = files visibles d'una finestra
                                    @; PCOLS*VFILS = caselles que ocupa una franja vertical de 24 files
		mov r5, #VCOLS				@; r5 = 32 = amplada finestra
		
		mul r4, r2, r3				@; r4 = (v/PPART) * (PCOLS*VFILS)
                                    @; offset en tiles per saltar "files de finestres" completes:
		
		mla r2, r1, r5, r4			@; r2 = r4 + (v%PPART)*VCOLS
		
		mov r2, r2, lsl #1			@; r2 = r2 * 2 
									@; per passar de tiles a bytes
		ldr r1, =map2ptr		 	@; r1 = adreça de la variable global map2ptr (punter bg2)
		ldr r1, [r1]				@; r1 = valor de map2ptr (punter base real del mapa)
		
		add r0, r1, r2				@; r0 = map2ptr + offsetBytes
                                    @; retorna el punter a la posició (0,0) de la finestra v dins el mapa global
		
	pop {r1-r5, pc}

.end


