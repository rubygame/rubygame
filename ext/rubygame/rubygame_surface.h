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


#ifndef _RUBYGAME_SURFACE_H
#define _RUBYGAME_SURFACE_H

extern void Rubygame_Init_Surface();

extern VALUE cSurface;

extern VALUE rbgm_surface_new(int, VALUE*, VALUE);

extern VALUE rbgm_surface_get_w(VALUE);
extern VALUE rbgm_surface_get_h(VALUE);
extern VALUE rbgm_surface_get_size(VALUE);

extern VALUE rbgm_surface_get_depth(VALUE);
extern VALUE rbgm_surface_get_flags(VALUE);
extern VALUE rbgm_surface_get_masks(VALUE);

extern VALUE rbgm_surface_get_alpha(VALUE);
extern VALUE rbgm_surface_set_alpha(int, VALUE*, VALUE);

extern VALUE rbgm_surface_get_colorkey(VALUE);
extern VALUE rbgm_surface_set_colorkey(int, VALUE*, VALUE);

extern VALUE rbgm_surface_blit(int, VALUE*, VALUE);

extern VALUE rbgm_surface_fill(int, VALUE*, VALUE);

extern VALUE rbgm_surface_getat(int, VALUE*, VALUE);

extern VALUE rbgm_surface_pixels(VALUE);

extern VALUE rbgm_surface_get_cliprect(VALUE);
extern VALUE rbgm_surface_set_cliprect(VALUE, VALUE);

#endif
