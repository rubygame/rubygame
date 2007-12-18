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
SDL_Color make_sdl_color(VALUE);
int init_video_system();
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

VALUE make_symbol(char *string)
{
	return ID2SYM(rb_intern(string));
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
				int len = RARRAY(vflags)->len;
				for(i=0;  i < len;  i++)
        {
          flags |= NUM2UINT(  rb_ary_entry( vflags,i )  );
        }
				break;
			}
			case T_BIGNUM: {
				flags = rb_big2uint( vflags );
				break;
            }
			case T_FIXNUM: {
				flags = NUM2UINT( vflags );
				break;
			}
			default: {
				rb_raise(rb_eArgError,"Wrong type for argument `flags' (wanted Number or Array).");
			}
    }
	}

	return flags;
}

VALUE convert_to_array(VALUE val)
{
	VALUE v = rb_check_array_type(val);
	if( TYPE(v) != T_ARRAY )
	{
		rb_raise(rb_eTypeError, "can't convert %s into Array",
						 rb_obj_classname(val));
	}
	return v;
}

/* Takes a Color or Array, returns an RGBA Array */
VALUE convert_color(VALUE color)
{
	if( rb_respond_to(color, rb_intern("to_sdl_rgba_ary")) )
	{
		return rb_funcall( color, rb_intern("to_sdl_rgba_ary"), 0 );
	}
	else
	{
		return convert_to_array( color );
	}
}

SDL_Color make_sdl_color(VALUE arr)
{
	SDL_Color color;
	arr = convert_to_array(arr);
	extract_rgb_u8_as_u8(arr, &(color.r), &(color.g), &(color.b));
	return color;
}

void extract_rgb_u8_as_u8(VALUE color, Uint8 *r, Uint8 *g, Uint8 *b)
{
	*r = NUM2UINT(rb_ary_entry(color, 0));
	*g = NUM2UINT(rb_ary_entry(color, 1));
	*b = NUM2UINT(rb_ary_entry(color, 2));
}

void extract_rgba_u8_as_u8(VALUE color, Uint8 *r, Uint8 *g, Uint8 *b, Uint8 *a)
{
	*r = NUM2UINT(rb_ary_entry(color, 0));
	*g = NUM2UINT(rb_ary_entry(color, 1));
	*b = NUM2UINT(rb_ary_entry(color, 2));

	if( RARRAY(color)->len > 3 )
	{
		*a = NUM2UINT(rb_ary_entry(color, 3));
	}
	else
	{
		*a = 255;
	}
}

/* --
 *
 *  call-seq:
 *     init_video_system()  ->  int
 *
 *  Initialize SDL's video subsystem.
 *  Return 0 (zero) on success, non-zero on failure.
 *
 *  If it has already been initialized, return 0 immediately.
 *
 * ++
 */
int init_video_system()
{
	if( SDL_WasInit(SDL_INIT_VIDEO) == 0 )
	{
		return SDL_Init(SDL_INIT_VIDEO);
	}
	else
	{
		return 0;
	}
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
