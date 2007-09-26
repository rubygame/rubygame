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
void Define_Rubygame_Constants();
int init_video_system();

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
 *    Rubygame.key_name( Rubygame::K_A )       # => "a"
 *    Rubygame.key_name( Rubygame::K_RETURN )  # => "return"
 *    Rubygame.key_name( Rubygame::K_LEFT )    # => "left"
 */
VALUE rbgm_keyname(VALUE self, VALUE sym)
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


void Init_rubygame_core()
{
	Init_rubygame_shared();

	mRubygame = rb_define_module("Rubygame");

	rb_define_module_function(mRubygame,"init",rbgm_init,0);
	rb_define_module_function(mRubygame,"quit",rbgm_quit,0);
	rb_define_singleton_method(mRubygame,"key_name",rbgm_keyname, 1);
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

	/* Flags for subsystem initialization */
	rb_define_const(mRubygame,"INIT_TIMER",INT2NUM(SDL_INIT_TIMER));
	rb_define_const(mRubygame,"INIT_AUDIO",INT2NUM(SDL_INIT_AUDIO));
	rb_define_const(mRubygame,"INIT_VIDEO",INT2NUM(SDL_INIT_VIDEO));
	rb_define_const(mRubygame,"INIT_CDROM",INT2NUM(SDL_INIT_CDROM));
	rb_define_const(mRubygame,"INIT_JOYSTICK",INT2NUM(SDL_INIT_JOYSTICK));
	rb_define_const(mRubygame,"INIT_NOPARACHUTE",INT2NUM(SDL_INIT_NOPARACHUTE));
	rb_define_const(mRubygame,"INIT_EVENTTHREAD",UINT2NUM(SDL_INIT_EVENTTHREAD));
	rb_define_const(mRubygame,"INIT_EVERYTHING",UINT2NUM(SDL_INIT_EVERYTHING));

	
	/* Define fully opaque and full transparent (0 and 255) */
	rb_define_const(mRubygame,"ALPHA_OPAQUE",UINT2NUM(SDL_ALPHA_OPAQUE));
	rb_define_const(mRubygame,"ALPHA_TRANSPARENT",
	                UINT2NUM(SDL_ALPHA_TRANSPARENT));


	/* Flags for palettes (?) */
	rb_define_const(mRubygame,"LOGPAL",UINT2NUM(SDL_LOGPAL));
	rb_define_const(mRubygame,"PHYSPAL",UINT2NUM(SDL_PHYSPAL));
}
