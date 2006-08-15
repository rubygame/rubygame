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


#ifndef RUBYGAME_TRANSFORM_H
#define RUBYGAME_TRANSFORM_H

#ifdef HAVE_SDL_ROTOZOOM_H
#include <SDL_rotozoom.h>

/* Separate X/Y rotozoom scaling was not supported prior to 2.0.13. */
/* Check if we have at least version 2.0.13 of SDL_gfxPrimitives */
#ifndef HAVE_ROTOZOOMXY
#include <SDL_gfxPrimitives.h>  /* to get the version numbers */
#if ((SDL_GFXPRIMITIVES_MAJOR > 2) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR > 0) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR == 0 && SDL_GFXPRIMITIVES_MICRO >= 13))
#define HAVE_ROTOZOOMXY
#endif
#endif
#endif

#ifndef SDL_GFXPRIMITIVES_MAJOR
#define SDL_GFXPRIMITIVES_MAJOR 0
#endif

#ifndef SDL_GFXPRIMITIVES_MINOR
#define SDL_GFXPRIMITIVES_MINOR 0
#endif

#ifndef SDL_GFXPRIMITIVES_MICRO
#define SDL_GFXPRIMITIVES_MICRO 0
#endif

extern void Rubygame_Init_Transform();

extern VALUE mTrans;

extern VALUE rbgm_transform_rotozoom(int, VALUE*, VALUE);
extern VALUE rbgm_transform_rotozoomsize(int, VALUE*, VALUE);

extern VALUE rbgm_transform_zoom(int, VALUE*, VALUE);
extern VALUE rbgm_transform_zoomsize(int, VALUE*, VALUE);

extern VALUE rbgm_transform_flip(int, VALUE*, VALUE);

#endif
