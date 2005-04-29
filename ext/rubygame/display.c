/*
	Rubygame -- Ruby code and bindings to SDL/OpenAL to facilitate game creation
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

/* Display module methods: */

/* Rubygame::
 *
 *
 *
 * This method takes these arguments:
 * - ::
 */

/* Rubygame::Display.set_mode(size,depth=0,flags=0)
 *
 * Create a new Rubygame window if there is none, or modify the existing one.
 * Returns the resulting Surface.
 *
 * This method takes these arguments:
 * - size::  requested window size (in pixels), in the form +[width,height]+
 * - depth:: requested color depth (in bits per pixel). If 0 (default), the
 *           current system color depth.
 * - flags:: 
 *           - SWSURFACE::  Create the video surface in system memory.
 *           - HWSURFACE::  Create the video surface in video memory.
 *           - ASYNCBLIT::  Enables the use of asynchronous updates of the 
 *                          display surface. This will usually slow down 
 *                          blitting on single CPU machines, but may provide a
 *                          speed increase on SMP systems.
 *           - ANYFORMAT::  Normally, if a video surface of the requested 
 *                          bits-per-pixel (bpp) is not available, Rubygame
 *                          will emulate one with a shadow surface. Passing 
 *                          +ANYFORMAT+ prevents this and causes Rubygame to
 *                          use the video surface regardless of its depth.
 *           - DOUBLEBUF::  Enable hardware double buffering; only valid with 
 *                          +HWSURFACE+. Calling Screen#flip will flip the
 *                          buffers and update the screen. All drawing will
 *                          take place on the surface that is not displayed at
 *                          the moment. If double buffering could not be 
 *                          enabled then Screen#flip will just update the
 *                          entire screen.
 *           - FULLSCREEN:: Rubygame will attempt to use a fullscreen mode. If 
 *                          a hardware resolution change is not possible (for 
 *                          whatever reason), the next higher resolution will
 *                          be used and the display window centered on a black
 *                          background.
 *           - RESIZABLE::  Create a resizable window. When the window is 
 *                          resized by the user a VideoResizeEvent is
 *                          generated and Display.set_mode can be called again
 *                          with the new size.
 *           - NOFRAME::    If possible, +NOFRAME+ causes Rubygame to create 
 *                          a window with no title bar or frame decoration.
 *                          Fullscreen modes automatically have this flag set.
 */
VALUE rbgm_display_setmode(int argc, VALUE *argv, VALUE module)
{
	SDL_Surface *screen;
	int w, h, depth;
	Uint32 flags;

	switch(argc)
	{
		case 1:
			w = NUM2INT(rb_ary_entry(argv[0],0));
			h = NUM2INT(rb_ary_entry(argv[0],1));
			depth = 0;
			flags = 0;
			break;
		case 2:
			w = NUM2INT(rb_ary_entry(argv[0],0));
			h = NUM2INT(rb_ary_entry(argv[0],1));
			depth = NUM2INT(argv[1]);
			flags = 0;
			break;
		case 3:
			w = NUM2INT(rb_ary_entry(argv[0],0));
			h = NUM2INT(rb_ary_entry(argv[0],1));
			depth = NUM2INT(argv[1]);
			flags = NUM2UINT(argv[2]);
			break;
		default:
			rb_raise(rb_eArgError,\
				"Wrong number of args to set mode(%d for 1..3)",argc);
			break;
	}

	screen = SDL_SetVideoMode( w,h,depth,flags );
	if( screen==NULL )
	{
		rb_raise(eSDLError,"Couldn't set %dx%d %d bpp video mode: %s",
			w,h, FIX2INT(depth), SDL_GetError());
	}
	//format = screen->format;
	//printf("New screen will be: %dx%d, %d bpp. Masks: %d, %d, %d, %d\n",w,h,depth,format->Rmask,format->Gmask,format->Bmask,format->Amask);
	return Data_Wrap_Struct( cScreen,0,0,screen ); 
}

/* Rubygame::Display.get_surface
 *
 * Returns the current display window, or raises Rubygame::SDLError if it
 * fails to get it (like if it doesn't exist yet).
 */
VALUE rbgm_display_getsurface(VALUE module)
{
	SDL_Surface *surface;
	surface = SDL_GetVideoSurface();
	if(surface==NULL)
		rb_raise(eSDLError,"Couldn't get video surface: %s",SDL_GetError());
	return Data_Wrap_Struct( cScreen,0,0,surface );
}

/* Screen methods: */

/*
Screen is a Singleton-style class that you can create/change the instance of
using Display.set_mode, and get with Display.get_surface
So, you can't make another one with Screen.new()
*/

/* Rubygame::Screen.new
 *
 * A dummy function which will raise StandardError!
 * Use Rubygame::Display.set_mode to create the Screen!
 */
VALUE rbgm_screen_new(VALUE class)
{
	rb_raise(rb_eStandardError,"Use Rubygame::Display.set_mode() to create instance of Singleton class Screen.");
	return Qnil; /* should never get here */
}

/* Rubygame::Screen#caption
 *
 * Returns the current window title and icon caption for the Screen as an
 * Array. See Screen#set_caption for a description of the window title/icon
 * caption. By default, the title and icon caption are empty strings.
 */
VALUE rbgm_screen_getcaption(VALUE module)
{
	char *title,*icon;
	SDL_WM_GetCaption( &title,&icon );
	if (title == NULL)
		title = "\0";
	if (icon == NULL)
		icon = "\0";
	return rb_ary_new3( 2,rb_str_new2(title),rb_str_new2(icon) );
}

/* Rubygame::Screen#set_caption(title,icon_cap=nil)
 *
 * Sets the window title and icon caption for the Screen.
 *
 * This method takes these arguments:
 * - title::    a String, (usually) displayed at the top of the Rubygame
 *              window (when not in fullscreen mode). Where (even whether) this
 *              is shown depends on the system.
 * - icon_cap:: a String, (usually) displayed when the window is iconized
 *              (minimized), for example to the taskbar. If +icon_cap+ is
 *              omitted, it will be the same as +title+. Where (even whether)
 *              this is shown depends on the system.
 */
VALUE rbgm_screen_setcaption(int argc, VALUE *argv, VALUE self)
{
	char *title_str, *iconized_str;
	title_str = StringValuePtr(argv[0]);
	switch(argc)
	{
		case 1:
			iconized_str = StringValuePtr(argv[0]); /* same as title */
			break;
		case 2:
			iconized_str = StringValuePtr(argv[1]);
			break;
		default:
			rb_raise(rb_eArgError,"Wrong number of args to set caption(%d for 1)",argc);
			break;
	}
			
	SDL_WM_SetCaption(title_str,iconized_str);
	return self;
}

/* Rubygame::Screen#update
 * Rubygame::Screen#update(rect)
 * Rubygame::Screen#update(x,y,w,h)
 *
 * Updates (refreshes) all or part of the Rubygame window, revealing to the 
 * user any changes that have been made since the last update. If you're using
 * a double-buffered display (see Display.set_mode), you should use Screen#flip
 * instead.
 *
 * This method takes these arguments:
 * - rect:: a Rubygame::Rect representing the area of the screen to update. Can
 *          also be an length-4 Array, or given as 4 separate arguments. If
 *          omitted, the entire screen is updated.
 */
VALUE rbgm_screen_update(int argc, VALUE *argv, VALUE self)
{
	int x,y,w,h;
	SDL_Surface *screen;
	Data_Get_Struct(self,SDL_Surface,screen);

	switch(argc)
	{
		case 0:
			x = y = w = h = 0;
			break;
		case 1:
			x = NUM2INT(rect_entry(argv[0],0));
			y = NUM2INT(rect_entry(argv[0],1));
			w = NUM2INT(rect_entry(argv[0],2));
			h = NUM2INT(rect_entry(argv[0],3));
			break;
		case 4:
			x = NUM2INT(argv[0]);
			y = NUM2INT(argv[1]);
			w = NUM2INT(argv[2]);
			h = NUM2INT(argv[3]);
			break;
		default:
			rb_raise(rb_eArgError,"wrong number of args to update (%d for 0,1 or 4)",argc);
			break;
	}

	SDL_UpdateRect(screen,x,y,w,h);
	return self;
}
/* Rubygame::Screen#update_rects(rects)
 *
 * Updates (as Screen#update does) several areas of the screen.
 *
 * This method takes these arguments:
 * - rects:: an Array containing any number of Rubygame::Rect objects, each
 *           rect representing a portion of the screen to update.
 */
VALUE rbgm_screen_updaterects(VALUE self, VALUE array_rects)
{
	int i, num_rects;
	VALUE each_rect;
	SDL_Surface *screen;

	/* unwrap the Screen instance from self (VALUE) */
	Data_Get_Struct(self,SDL_Surface,screen);

	/* prepare an (uninitialized) array of Rects */
	num_rects = RARRAY(array_rects)->len;
	SDL_Rect *rects[num_rects];

	/* initialize the array of Rects from array_rects */
	for( i=0; i < num_rects; i++ )
	{
		each_rect = rb_ary_entry(array_rects,i);
		rects[i]->x = rect_entry(each_rect,0);
		rects[i]->y = rect_entry(each_rect,1);
		rects[i]->w = rect_entry(each_rect,2);
		rects[i]->h = rect_entry(each_rect,3);
	}

	/* call the SDL method to update from all these rects */
	SDL_UpdateRects( screen, num_rects, *rects );

	return self;
}

/* Rubygame::Screen#flip
 *
 * If the Rubygame display is double-buffered (see Display.set_mode), flips
 * the buffers and updates the whole screen. Otherwise, just updates the
 * whole screen.
 */
VALUE rbgm_screen_flip(VALUE self)
{
	SDL_Surface *screen;
	Data_Get_Struct(self, SDL_Surface, screen);
	SDL_Flip(screen);
	return self;
}

/* Rubification: */

void Rubygame_Init_Display()
{
	/* Display module */
	mDisplay = rb_define_module_under(mRubygame,"Display");
	/* Display methods */
	rb_define_module_function(mDisplay,"set_mode",rbgm_display_setmode, -1);
	rb_define_module_function(mDisplay,"get_surface",\
		rbgm_display_getsurface, 0);

	/* Screen class */
	cScreen = rb_define_class_under(mDisplay,"Screen",cSurface);
	rb_define_singleton_method(cScreen,"new",rbgm_screen_new,0); /* dummy */

	/* Inherited from Surface, should not be called on Screen */
	rb_undef_method(cScreen,"set_alpha"); 
	rb_undef_method(cScreen,"set_colorkey");

	/* Screen methods */
	rb_define_method(cScreen,"caption",rbgm_screen_getcaption,0);
	rb_define_method(cScreen,"set_caption",rbgm_screen_setcaption,-1);
	rb_define_method(cScreen,"update",rbgm_screen_update,-1);
	rb_define_method(cScreen,"update_rects",rbgm_screen_updaterects,1);
	rb_define_method(cScreen,"flip",rbgm_screen_flip,0);
}
