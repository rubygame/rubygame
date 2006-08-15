/*
 *--
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
 *++
 */

#include "rubygame.h"

#include "rubygame_draw.h"
#include "rubygame_event.h"
#include "rubygame_gl.h"
#include "rubygame_image.h"
#include "rubygame_joystick.h"
#include "rubygame_screen.h"
#include "rubygame_surface.h"
#include "rubygame_time.h"
#include "rubygame_transform.h"
#include "rubygame_ttf.h"

VALUE mRubygame;
VALUE eSDLError;
VALUE cRect;
VALUE cSFont;
VALUE mKey;
VALUE mMouse;
VALUE rbgm_init(VALUE);
SDL_Rect *make_rect(int, int, int, int);
VALUE rbgm_usable(VALUE);
VALUE rbgm_unusable(VALUE);
VALUE rbgm_dummy(int, VALUE*, VALUE);
void Define_Rubygame_Constants();

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

/* 
 *  call-seq:
 *     usable? -> true or false
 *
 *  Returns +true+ if the feature(s) associated with this module/class are
 *  available for use. This means that Rubygame was compiled and linked
 *  against the C library which provides the feature, i.e. SDL_gfx, SDL_image,
 *  or SDL_ttf.
 *
 *  If the features are not available (for example, if the libraries were not
 *  installed or detected when Rubygame was compiled), returns +false+.
 */
VALUE rbgm_usable(VALUE mod)
{
  return Qtrue;
}

/* --
 * Same docs as rbgm_usable. Which function to use is decided at compile time.
 * ++
 */
VALUE rbgm_unusable(VALUE mod)
{
  return Qfalse;
}

VALUE rbgm_dummy(int argc, VALUE *argv, VALUE classmod)
{
  return Qnil;
}

/*
 *  call-seq:
 *     init  ->  nil
 *
 *  Initialize Rubygame. This should be called soon after you +require+
 *  Rubygame, so that everything will work properly.
 */
VALUE rbgm_init(VALUE module)
{
	if(SDL_Init(SDL_INIT_EVERYTHING)==0)
	{
		return Qnil;
	}
	else
	{
		rb_raise(eSDLError,"Could not initialize SDL.");
		return Qnil; /* should never get here */
	}
}


void Init_rubygame()
{
	mRubygame = rb_define_module("Rubygame");
	Define_Rubygame_Constants();

	rb_define_module_function(mRubygame,"init",rbgm_init,0);
	cRect = rb_define_class_under(mRubygame,"Rect",rb_cArray);
	eSDLError = rb_define_class_under(mRubygame,"SDLError",rb_eStandardError);

  rb_define_const(mRubygame,"VERSIONS",rb_hash_new());
  rb_hash_aset(rb_ivar_get(mRubygame,rb_intern("VERSIONS")),
               ID2SYM(rb_intern("rubygame")),
               rb_ary_new3(3,
                           INT2NUM(RUBYGAME_MAJOR_VERSION),
                           INT2NUM(RUBYGAME_MINOR_VERSION),
                           INT2NUM(RUBYGAME_PATCHLEVEL)));
  rb_hash_aset(rb_ivar_get(mRubygame,rb_intern("VERSIONS")),
               ID2SYM(rb_intern("sdl")),
               rb_ary_new3(3,
                           INT2NUM(SDL_MAJOR_VERSION),
                           INT2NUM(SDL_MINOR_VERSION),
                           INT2NUM(SDL_PATCHLEVEL)));

	//mKey = rb_define_module_under(mRubygame,"Key");
	//mMouse = rb_define_module_under(mRubygame,"Mouse");

	Rubygame_Init_Time();
	Rubygame_Init_Surface();
	Rubygame_Init_Screen();
	Rubygame_Init_Event();
	Rubygame_Init_Image();
	Rubygame_Init_Draw();
	Rubygame_Init_Transform();
	Rubygame_Init_Joystick();
	Rubygame_Init_TTF();
  Rubygame_Init_GL();
}
