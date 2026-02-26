#include <GARLIC_API.h>

/* Funcions utilitàries sense libc */
static int str_len(const char *s) {
    int n = 0;
    while (s[n] != '\0') n++;
    return n;
}

/* Genera una matriu ADFGVX aleatòria (A..Z + 0..9) dins m[6][6] */
static void generar_matriu_adfgvx(char m[6][6]) {
    const char simbols[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    int usat[36];

    // Inicialitzar "usat" a 0 (sense memset)
    for (int i = 0; i < 36; i++) usat[i] = 0;

    // Emplenar matriu amb selecció aleatòria sense repeticions
    for (int r = 0; r < 6; r++) {
        for (int c = 0; c < 6; c++) {
            int idx;
            do {
                idx = (int)(GARLIC_random() % 36);
            } while (usat[idx]);

            usat[idx] = 1;
            m[r][c] = simbols[idx];
        }
    }
}

/* Imprimeix la matriu ADFGVX */
static void imprimir_matriu_adfgvx(const char m[6][6]) {
    GARLIC_printf("Matriu ADFGVX generada:\n");
    for (int r = 0; r < 6; r++) {
        for (int c = 0; c < 6; c++) {
            GARLIC_printf("%c ", (unsigned int)m[r][c]);
        }
        GARLIC_printf("\n");
    }
}

/* Xifra en ADFGVX: per cada caràcter, escriu 2 lletres A/D/F/G/V/X
   Nota: ignora caràcters que NO estiguin a la matriu (espais, accents, etc.) */
static void adfgvx_encrypt(const char m[6][6], const char *input,
                           char *output, int out_max) {
    const char adfgvx[] = "ADFGVX";
    int in_len = str_len(input);
    int pos = 0;

    // Necessitem 2 chars de sortida per cada char d’entrada trobat
    for (int i = 0; i < in_len; i++) {
        char ch = input[i];
        int trobat = 0;

        for (int r = 0; r < 6 && !trobat; r++) {
            for (int c = 0; c < 6; c++) {
                if (m[r][c] == ch) {
                    // Comprovar espai (pos+2 + '\0')
                    if (pos + 2 >= out_max) {
                        output[pos] = '\0';
                        return;
                    }
                    output[pos++] = adfgvx[r];
                    output[pos++] = adfgvx[c];
                    trobat = 1;
                    break;
                }
            }
        }
    }

    output[pos] = '\0';
}

/* Entrada del programa d'usuari de GARLIC */
int _start(int arg) {
    // Ajusta arg a rang 0..3 (com fan molts progs)
    if (arg < 0) arg = 0;
    if (arg > 3) arg = 3;

    GARLIC_printf("-- Programa USR1 -- PID(%d) arg(%d)\n",
                  GARLIC_pid(), (unsigned int)arg);

    // IMPORTANT: tot local (stack) per evitar .bss/.data -> 2 segments LOAD
    char matriu[6][6];

    generar_matriu_adfgvx(matriu);
    imprimir_matriu_adfgvx(matriu);

    // Missatge 1
    const char missatge_1[] = "HELLO";
    char xifrat_1[128];
    adfgvx_encrypt(matriu, missatge_1, xifrat_1, (int)sizeof(xifrat_1));
    GARLIC_printf("Missatge original 1: %s\n", (unsigned int)missatge_1);
    GARLIC_printf("Text xifrat 1: %s\n", (unsigned int)xifrat_1);

    // Missatge 2 (sense accents; la matriu només té A..Z i 0..9)
    const char missatge_2[] = "ESTRUCTURA DE SISTEMES OPERATIUS";
    char xifrat_2[256];
    adfgvx_encrypt(matriu, missatge_2, xifrat_2, (int)sizeof(xifrat_2));
    GARLIC_printf("Missatge original 2: %s\n", (unsigned int)missatge_2);
    GARLIC_printf("Text xifrat 2: %s\n", (unsigned int)xifrat_2);

    return 0;
}
