/*
 * Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 * Copyright (C) 2004-2006  John 'jacius' Croisant
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
 *
 */

#ifndef _RUBYGAME_TTF_H
#define _RUBYGAME_TTF_H

#ifdef HAVE_SDL_TTF_H
#include "SDL_ttf.h"
#endif

#ifndef SDL_TTF_MAJOR_VERSION
#define SDL_TTF_MAJOR_VERSION 0
#endif

#ifndef SDL_TTF_MINOR_VERSION
#define SDL_TTF_MINOR_VERSION 0
#endif

#ifndef SDL_TTF_PATCHLEVEL
#define SDL_TTF_PATCHLEVEL 0
#endif

extern void Rubygame_Init_TTF();

extern VALUE cTTF;

extern VALUE rbgm_ttf_setup(VALUE);
extern VALUE rbgm_ttf_quit(VALUE);
extern VALUE rbgm_ttf_new(int, VALUE*, VALUE);
extern VALUE rbgm_ttf_initialize(int, VALUE*, VALUE);

extern VALUE rbgm_ttf_getbold(VALUE);
extern VALUE rbgm_ttf_setbold(VALUE, VALUE);

extern VALUE rbgm_ttf_getitalic(VALUE);
extern VALUE rbgm_ttf_setitalic(VALUE, VALUE);

extern VALUE rbgm_ttf_getunderline(VALUE);
extern VALUE rbgm_ttf_setunderline(VALUE, VALUE);

extern VALUE rbgm_ttf_height(VALUE);
extern VALUE rbgm_ttf_ascent(VALUE);
extern VALUE rbgm_ttf_descent(VALUE);
extern VALUE rbgm_ttf_lineskip(VALUE);

extern VALUE rbgm_ttf_render(int, VALUE*, VALUE);

#endif
