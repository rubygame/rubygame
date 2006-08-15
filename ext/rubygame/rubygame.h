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

#ifndef _RUBYGAME_H
#define _RUBYGAME_H

#include <SDL.h>
#include <ruby.h>
#include <stdio.h>

#define RUBYGAME_MAJOR_VERSION 2
#define RUBYGAME_MINOR_VERSION 0
#define RUBYGAME_PATCHLEVEL 0

/* General */
extern VALUE mRubygame;
extern VALUE eSDLError;
extern VALUE cRect;
extern VALUE cSFont;
extern VALUE mKey;
extern VALUE mMouse;
extern VALUE rbgm_init(VALUE);
extern SDL_Rect *make_rect(int, int, int, int);
extern VALUE rbgm_usable(VALUE);
extern VALUE rbgm_unusable(VALUE);
extern VALUE rbgm_dummy(int, VALUE*, VALUE);
extern void Define_Rubygame_Constants();

#endif
