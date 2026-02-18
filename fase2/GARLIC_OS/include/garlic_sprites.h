#ifndef GARLIC_SPRITES_H
#define GARLIC_SPRITES_H

// Gestió de sprites per procés (zócalo) i índex (0..7)
void gs_spriteSet(int z, int n, int icon);
void gs_spriteMove(int z, int n, int px, int py);
void gs_spriteShow(int z, int n);
void gs_spriteHide(int z, int n);

// Funcions globals per la Fase 2
void gs_hideAllSprites(void);
void gs_refreshSprites(void);
void gs_resetSpritesZocalo(int z);

#endif // GARLIC_SPRITES_H