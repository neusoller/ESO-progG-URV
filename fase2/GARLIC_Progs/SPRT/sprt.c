#include "GARLIC_API.h"

int _start(int arg)
{
	short W = 256, H = 192;
	
	const short half = 16;
	short L = -half;
	short R = (short)(W - half);
	short T = -half;
	short B = (short)(H - half);

    short px[8], py[8];
    short vx[8], vy[8];

    int mode = arg & 3;

    int nSprites = 1;
    if (mode == 1) nSprites = 2;
    else if (mode == 2) nSprites = 2;
    else if (mode == 3) nSprites = 8;

	if (mode == 2) { W = 128; H = 96; }   // comportament “4 finestres”
	if (mode == 3) { W = 64;  H = 48; }   // comportament “16 finestres”

    // Crear i mostrar tots els sprites
    for (int n = 0; n < nSprites; n++) {
        unsigned char icon = (unsigned char)((n * 7 + 3) & 63);

        GARLIC_spriteSet((unsigned char)n, icon);

        px[n] = (short)(20 + (n & 3) * 60);   // 4 columnes
        py[n] = (short)(20 + (n >> 2) * 60);  // 2 files

        vx[n] = (short)(1 + (n & 1));
        vy[n] = (short)(1 + ((n >> 1) & 1));

        GARLIC_spriteMove((unsigned char)n, px[n], py[n]);
        GARLIC_spriteShow((unsigned char)n);
    }

    // Només per mode 2 (arg=2)
    unsigned int tick = 0;
    const unsigned int HIDE_PERIOD = 20;
    int hideIdx = 0;
    int hidden = 0;

    while (1) {
        for (int n = 0; n < nSprites; n++) {
            px[n] = (short)(px[n] + vx[n]);
            py[n] = (short)(py[n] + vy[n]);

            if (px[n] <= L) { px[n] = L; vx[n] = (short)(-vx[n]); }
            else if (px[n] >= R) { px[n] = R; vx[n] = (short)(-vx[n]); }

            if (py[n] <= T) { py[n] = T; vy[n] = (short)(-vy[n]); }
            else if (py[n] >= B) { py[n] = B; vy[n] = (short)(-vy[n]); }

            GARLIC_spriteMove((unsigned char)n, px[n], py[n]);
        }

        if (mode == 2) {
            tick++;
            if (tick >= HIDE_PERIOD) {
                tick = 0;

                if (!hidden) {
                    GARLIC_spriteHide((unsigned char)hideIdx);
                    hidden = 1;
                } else {
                    GARLIC_spriteShow((unsigned char)hideIdx);
                    hidden = 0;

                    hideIdx++;
                    if (hideIdx >= nSprites) hideIdx = 0;
                }
            }
        }

        GARLIC_delay(0);
    }

    return 0;
}
