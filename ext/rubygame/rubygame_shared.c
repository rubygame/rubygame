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
VALUE mNamedResource;


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

/* Returns a symbol from the given char* string */
VALUE make_symbol(char *string)
{
	return ID2SYM(rb_intern(string));
}

/* Returns a char* string from the given symbol */
char *unmake_symbol(VALUE symbol)
{
	return rb_id2name( SYM2ID(symbol) );
}


/* Lowercase, change spaces to underscores, and convert to symbol.
 * Equivalent to: str.downcase!.gsub!(" ","_").intern
 */
VALUE sanitized_symbol(char *string)
{
	VALUE str = rb_str_new2(string);

	rb_funcall( str, rb_intern("downcase!"), 0 );
	rb_funcall( str, rb_intern("gsub!"), 2, rb_str_new2(" "), rb_str_new2("_") );
	return rb_funcall( str, rb_intern("intern"), 0 );
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
				int len = RARRAY_LEN(vflags);
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

/* Takes a Color, Array, or color name (Symbol or String).
 * Returns an RGBA Array, or raises eTypeError if it can't.
 */
VALUE convert_color(VALUE color)
{
	if( rb_respond_to(color, rb_intern("to_sdl_rgba_ary")) )
	{
		return rb_funcall( color, rb_intern("to_sdl_rgba_ary"), 0 );
	}
	else if( rb_respond_to(color, rb_intern("to_ary")) )
	{
		return convert_to_array( color );
	}
	else if( TYPE(color) == T_SYMBOL || TYPE(color) == T_STRING )
	{
		VALUE mColor = rb_const_get( mRubygame, rb_intern("Color") );
		return convert_color( rb_funcall( mColor, rb_intern("[]"), 1, color) );
	}
	else
	{
		rb_raise(rb_eTypeError, "unsupported type %s for color",
						 rb_obj_classname(color));
	}
}

SDL_Color make_sdl_color(VALUE vcolor)
{
	SDL_Color color;
	vcolor = convert_color(vcolor);
	extract_rgb_u8_as_u8(vcolor, &(color.r), &(color.g), &(color.b));
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

	if( RARRAY_LEN(color) > 3 )
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
 * Issues a deprecation warning for the given feature/method.
 *
 * ++
 */
void rg_deprecated( char *feature, char *version )
{
  rb_warning( "%s is DEPRECATED and will be removed in Rubygame %s! "
              "Please see the docs for more information.",
              feature, version );
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

/* --
 *
 * Includes the Rubygame::NamedResource mixin in the given class
 * and performs the `included' callback.
 *
 * ++
 */
void rg_include_named_resource( VALUE klass )
{
  /* Include the mixin, and manually perform the 'included' callback. */
	rb_include_module( klass, mNamedResource );
  rb_funcall( mNamedResource, rb_intern("included"), 1, klass );
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


  /* Rubygame::NamedResource mixin. See named_resource.rb. */
  rb_require("rubygame/named_resource");
  mNamedResource = rb_const_get(mRubygame, rb_intern("NamedResource"));

}
