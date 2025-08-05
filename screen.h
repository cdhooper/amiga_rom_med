/*
 * Amiga screen functions, including screen scroll and text rendering.
 *
 * This header file is part of the code base for a simple Amiga ROM
 * replacement sufficient to allow programs using some parts of GadTools
 * to function.
 *
 * Copyright 2025 Chris Hooper. This program and source may be used
 * and distributed freely, for any purpose which benefits the Amiga
 * community. All redistributions must retain this Copyright notice.
 *
 * DISCLAIMER: THE SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY WARRANTY.
 * THE AUTHOR ASSUMES NO LIABILITY FOR ANY DAMAGE ARISING OUT OF THE USE
 * OR MISUSE OF THIS UTILITY OR INFORMATION REPORTED BY THIS UTILITY.
 */
#ifndef _SCREEN_H
#define _SCREEN_H

#define SCREEN_WIDTH      640
#define SCREEN_HEIGHT     200
#define SCREEN_BITPLANES    3  // 8 colors
#define FONT_WIDTH          8  // pixels
#define FONT_HEIGHT         8  // pixels

#define BITPLANE_OFFSET   (SCREEN_WIDTH / 8 * (SCREEN_HEIGHT + 64))
#define BITPLANE_0_BASE   0x00020000
#define BITPLANE_1_BASE   (BITPLANE_0_BASE + BITPLANE_OFFSET)
#define BITPLANE_2_BASE   (BITPLANE_1_BASE + BITPLANE_OFFSET)

void show_char(uint ch);
void show_char_at(uint ch, uint x, uint y);
void show_string(const uint8_t *str);
void show_string_at(const uint8_t *str, uint x, uint y);
void blit(void);
void screen_init(void);

extern uint dbg_cursor_x;    // Debug cursor column position on screen
extern uint dbg_cursor_y;    // Debug cursor row position on screen

#endif /* _SCREEN_H */
