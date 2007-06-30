/*
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
 *
 */

#ifndef _RUBYGAME_SHARED_H
#define _RUBYGAME_SHARED_H

#include <SDL.h>
#include <ruby.h>
#include <stdio.h>

/* General */
extern VALUE mRubygame;
extern VALUE eSDLError;
extern VALUE cSurface;
extern VALUE cRect;
extern SDL_Rect *make_rect(int, int, int, int);
extern Uint32 collapse_flags(VALUE);
extern VALUE convert_to_array(VALUE);
extern void Init_rubygame_shared();

/* Apparently it is not desirable to define these functions when
 * using Micrsoft Visual C.
 */
#ifndef _MSC_VER

static inline int max(int a, int b) {
	return a > b ? a : b;
}
static inline int min(int a, int b) {
	return a > b ? b : a;
}

#endif

#endif
