/*
 *  Code that is common to all Rubygame modules.
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

#include "rubygame_shared.h"

VALUE mRubygame;
VALUE cSurface;
VALUE cRect;
VALUE eSDLError;
SDL_Rect *make_rect(int, int, int, int);
void Init_rubygame_shared();

SDL_Rect *make_rect(int x, int y, int w, int h)
{
	SDL_Rect *rect;
	rect = (SDL_Rect *) malloc(sizeof(SDL_Rect));
	rect->x = x;
	rect->y = y;
	rect->w = w;
	rect->h = h;
	return rect;
}

/* Take either nil, Numeric or an Array of Numerics, returns Uint32. */
Uint32 collapse_flags(VALUE vflags)
{
	Uint32 flags = 0;
	int i;

	if( RTEST(vflags) )
	{
    switch( TYPE(vflags) ){
			case T_ARRAY: {
				for(i=0;  i < RARRAY(vflags)->len;  i++)
        {
          flags |= NUM2UINT(  rb_ary_entry( vflags,i )  );
        }
				break;
			}

			case T_FIXNUM: {
				flags = NUM2UINT( vflags );
				break;
			}
			default: {
				rb_raise(rb_eArgError,"Wrong type for argument `flags' (wanted Fixnum or Array).");
			}
    }
	}

	return flags;
}

void Init_rubygame_shared()
{

	mRubygame = rb_define_module("Rubygame");

	/* Rubygame::Surface class */
	if( !rb_const_defined(mRubygame,rb_intern("Surface")) )
	{
		cSurface = rb_define_class_under(mRubygame,"Surface",rb_cObject);
	}
	else
	{
		cSurface = rb_const_get(mRubygame,rb_intern("Surface"));
	}

	/* Rubygame::SDLError class */
	if( !rb_const_defined(mRubygame,rb_intern("SDLError")))
	{
		/* Indicates that an SDL function did not execute properly. */
		eSDLError = rb_define_class_under(mRubygame,"SDLError",rb_eStandardError);
	}
	else
	{
		eSDLError = rb_const_get(mRubygame,rb_intern("SDLError"));
	}

	/* Rubygame::VERSIONS hash table */
	if( !rb_const_defined(mRubygame, rb_intern("VERSIONS")))
	{
		/* A Hash containing the version	s of rubygame and it's 
		 *	 compile-time dependencies. */
		rb_define_const(mRubygame,"VERSIONS",rb_hash_new());
	}
}
