/*
 *--
 * Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 * Copyright (C) 2004-2007  John Croisant
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *++
 */

#ifndef _RUBYGAME_GFX_H
#define _RUBYGAME_GFX_H

#include <SDL_gfxPrimitives.h>
#include <SDL_rotozoom.h>

#ifndef SDL_GFXPRIMITIVES_MAJOR
#define SDL_GFXPRIMITIVES_MAJOR 0
#endif

#ifndef SDL_GFXPRIMITIVES_MINOR
#define SDL_GFXPRIMITIVES_MINOR 0
#endif

#ifndef SDL_GFXPRIMITIVES_MICRO
#define SDL_GFXPRIMITIVES_MICRO 0
#endif


/* If we have at least version 2.0.12 of SDL_gfxPrimitives, draw_pie calls 
   filledPieRGBA, otherwise it calls filledpieRGBA (lowercase pie)*/
#ifndef HAVE_UPPERCASEPIE
#if ((SDL_GFXPRIMITIVES_MAJOR > 2) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR > 0) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR == 0 && SDL_GFXPRIMITIVES_MICRO >= 12))
#define HAVE_UPPERCASEPIE
#endif
#endif

/* Separate X/Y rotozoom scaling was not supported prior to 2.0.13. */
/* Check if we have at least version 2.0.13 of SDL_gfxPrimitives */
#ifndef HAVE_ROTOZOOMXY
#if ((SDL_GFXPRIMITIVES_MAJOR > 2) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR > 0) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR == 0 && SDL_GFXPRIMITIVES_MICRO >= 13))
#define HAVE_ROTOZOOMXY
#endif
#endif

/* Non-filled pie shapes (arcs) were not supported prior to 2.0.11. */
/* Check if we have at least version 2.0.11 of SDL_gfxPrimitives */
#ifndef HAVE_NONFILLEDPIE
#if ((SDL_GFXPRIMITIVES_MAJOR > 2) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR > 0) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR == 0 && SDL_GFXPRIMITIVES_MICRO >= 11))
#define HAVE_NONFILLEDPIE
#endif
#endif

extern void Init_rubygame_gfx();
extern void extract_xy(VALUE, Sint16*, Sint16*);

extern void draw_line(VALUE, VALUE, VALUE, VALUE, int);
extern VALUE rbgm_draw_line(VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_aaline(VALUE, VALUE, VALUE, VALUE);

extern void draw_rect(VALUE, VALUE, VALUE, VALUE, int);
extern VALUE rbgm_draw_rect(VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillrect(VALUE, VALUE, VALUE, VALUE);

extern void draw_circle(VALUE, VALUE, VALUE, VALUE, int, int);
extern VALUE rbgm_draw_circle(VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_aacircle(VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillcircle(VALUE, VALUE, VALUE, VALUE);

extern void draw_ellipse(VALUE, VALUE, VALUE, VALUE, int, int);
extern VALUE rbgm_draw_ellipse(VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_aaellipse(VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillellipse(VALUE, VALUE, VALUE, VALUE);

extern void draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE, int);
extern VALUE rbgm_draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillpie(VALUE, VALUE, VALUE, VALUE, VALUE);

extern void draw_polygon(VALUE, VALUE, VALUE, int, int);
extern VALUE rbgm_draw_polygon(VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_aapolygon(VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillpolygon(VALUE, VALUE, VALUE);

extern VALUE rbgm_transform_rotozoom(int, VALUE*, VALUE);
extern VALUE rbgm_transform_rotozoomsize(int, VALUE*, VALUE);

extern VALUE rbgm_transform_zoom(int, VALUE*, VALUE);
extern VALUE rbgm_transform_zoomsize(int, VALUE*, VALUE);

#endif
