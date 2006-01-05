/*
	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
	Copyright (C) 2004  John 'jacius' Croisant

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "rubygame.h"

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


/*
 *  Rubygame is a combination extension and library for the Ruby language,
 *  designed for creating computer games, and having fun creating them.
 *  As an extension, it provides an interface to the Simple DirectMedia Library
 *  (SDL) and its companion libraries SDL_gfx, SDL_image, and SDL_ttf.
 *  As a Ruby library, it provides classes/modules which implement some useful
 *  concepts such as Sprites, Event Queues, and rasterized fonts (SFont)
 *
 *  To get acquainted with Rubygame, first take a look at the fundamental
 *  classes: Screen, Surface, and Rect. 
 *
 *  As a next step, read about the event Queue and the hardware events, which
 *  allow you to take keyboard and mouse input, among other things:
 *  - ActiveEvent
 *  - JoyAxisEvent
 *  - JoyBallEvent
 *  - JoyDownEvent
 *  - JoyHatEvent
 *  - JoyUpEvent
 *  - KeyDownEvent
 *  - KeyUpEvent
 *  - MouseDownEvent
 *  - MouseMotionEvent
 *  - MouseUpEvent
 *  - QuitEvent
 *  - ResizeEvent
 *
 *  Finally, familiarize yourself with the TTF and SFont classes for rendering
 *  text, the Image module for loading and saving image files, the Draw and
 *  Transform modules for "special effects", the Time module for controlling
 *  framerate and delays, and last but by no means least, the Sprites module
 *  for easy-to-use, yet highly flexible on-screen objects!
 *
 *  There are several sample applications in the rubygame/samples/ directory
 *  packaged with Rubygame which can also help you get started.
 *
 *  At this time, Rubygame has no support for loading or playing sound of any
 *  kind, nor any explicit support for 3D graphics (i.e., OpenGL). There has
 *  to be *something* to look forward to, doesn't there?
 */
void Init_rubygame()
{
	mRubygame = rb_define_module("Rubygame");
	Define_Rubygame_Constants();

	rb_define_module_function(mRubygame,"init",rbgm_init,0);
	cRect = rb_define_class_under(mRubygame,"Rect",rb_cArray);
	eSDLError = rb_define_class_under(mRubygame,"SDLError",rb_eStandardError);

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
}
