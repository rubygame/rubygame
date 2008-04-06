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

#include "rubygame_shared.h"
#include "rubygame_main.h"
#include "rubygame_event.h"
#include "rubygame_gl.h"
#include "rubygame_joystick.h"
#include "rubygame_screen.h"
#include "rubygame_surface.h"
#include "rubygame_time.h"

VALUE rbgm_init(VALUE);
VALUE rbgm_quit(VALUE);

/* 
 *  call-seq:
 *    key_name(sym) -> string
 *
 *  Given the sym of a key, returns a printable representation.  This
 *  differs from key2str in that this will return a printable string
 *  for any key, even non-printable keys such as the arrow keys.
 *
 *  This method may raise SDLError if the SDL video subsystem could
 *  not be initialized for some reason.
 *
 *  Example:
 *    include Rubygame
 *    Event.key_name( K_A )       # => "a"
 *    Event.key_name( K_RETURN )  # => "return"
 *    Event.key_name( K_LEFT )    # => "left"
 */
VALUE rbgm_event_keyname(VALUE self, VALUE sym)
{
	/* SDL_GetKeyName only works when video system has been initialized. */
	if( init_video_system() == 0 )
	{
		SDLKey key = NUM2INT(sym);
		char *result = SDL_GetKeyName(key);
		return rb_str_new2(result);		
	}
	else
	{
		rb_raise(eSDLError,"Could not initialize SDL video subsystem.");
		return Qnil;
	}
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
	if( SDL_Init(SDL_INIT_EVERYTHING) != 0 )
	{
		rb_raise(eSDLError,"Could not initialize SDL.");
		return Qnil; /* should never get here */
	}

	SDL_EnableUNICODE(1);
}

/*
 *  call-seq:
 *     quit  ->  nil
 *
 *  Quit Rubygame. This should be used before your program terminates,
 *  especially if you have been using a fullscreen Screen! (Otherwise,
 *  the desktop resolution might not revert to its previous setting on
 *  some platforms, and your users will be frustrated and confused!)
 */
VALUE rbgm_quit(VALUE module)
{
	SDL_Quit();
	return Qnil;
}


void Init_rubygame_core()
{
	Init_rubygame_shared();

	mRubygame = rb_define_module("Rubygame");

	rb_define_module_function(mRubygame,"init",rbgm_init,0);
	rb_define_module_function(mRubygame,"quit",rbgm_quit,0);
	cRect = rb_define_class_under(mRubygame,"Rect",rb_cArray);

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

	Rubygame_Init_Time();
	Rubygame_Init_Surface();
	Rubygame_Init_Screen();
	Rubygame_Init_Event();
	Rubygame_Init_Joystick();
  Rubygame_Init_GL();

	VALUE cEvent = rb_define_class_under(mRubygame,"Event",rb_cObject);
	rb_define_singleton_method(cEvent,"key_name",rbgm_event_keyname, 1);

	/* Define fully opaque and full transparent (0 and 255) */
	rb_define_const(mRubygame,"ALPHA_OPAQUE",UINT2NUM(SDL_ALPHA_OPAQUE));
	rb_define_const(mRubygame,"ALPHA_TRANSPARENT",
	                UINT2NUM(SDL_ALPHA_TRANSPARENT));
}
