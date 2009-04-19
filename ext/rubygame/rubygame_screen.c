/*
 *  Screen -- Rubygame-bound SDL display window
 *
 * --
 *  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004-2007  John Croisant
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * ++
 */

#include "rubygame_shared.h"
#include "rubygame_screen.h"
#include "rubygame_surface.h"

void Rubygame_Init_Screen();

VALUE cScreen;

VALUE rbgm_screen_setmode(int, VALUE*, VALUE);
VALUE rbgm_screen_getsurface(VALUE);

VALUE rbgm_screen_getresolution(VALUE);

VALUE rbgm_screen_getcaption(VALUE);
VALUE rbgm_screen_setcaption(VALUE, VALUE);

VALUE rbgm_screen_seticon(VALUE, VALUE);

VALUE rbgm_screen_update(int, VALUE*, VALUE);
VALUE rbgm_screen_updaterects(VALUE, VALUE);
VALUE rbgm_screen_flip(VALUE);

VALUE rbgm_screen_getshowcursor(VALUE);
VALUE rbgm_screen_setshowcursor(VALUE, VALUE);


/* call-seq:
 *     Screen.new( size, depth=0, flags=[SWSURFACE] )  ->  Screen
 *     (aliases: open; deprecated: set_mode, instance)
 *
 *  Create a new Rubygame window if there is none, or modify the existing one.
 *  You cannot create more than one Screen; the existing one will be replaced.
 *  (This is a limitation of SDL.)
 *  Returns the resulting Screen.
 *
 *  This method takes these arguments:
 *  size::  requested window size (in pixels), in the form [width,height]
 *  depth:: requested color depth (in bits per pixel). If 0 (default), the
 *          current system color depth.
 *  flags:: an Array of zero or more of the following flags (located under the
 *          Rubygame module).
 *          
 *          SWSURFACE::  Create the video surface in system memory.
 *          HWSURFACE::  Create the video surface in video memory.
 *          ASYNCBLIT::  Enables the use of asynchronous updates of the 
 *                       display surface. This will usually slow down 
 *                       blitting on single CPU machines, but may provide a
 *                       speed increase on SMP systems.
 *          ANYFORMAT::  Normally, if a video surface of the requested 
 *                       bits-per-pixel (bpp) is not available, Rubygame
 *                       will emulate one with a shadow surface. Passing 
 *                       +ANYFORMAT+ prevents this and causes Rubygame to
 *                       use the video surface regardless of its depth.
 *          DOUBLEBUF::  Enable hardware double buffering; only valid with 
 *                       +HWSURFACE+. Calling #flip will flip the
 *                       buffers and update the screen. All drawing will
 *                       take place on the surface that is not displayed at
 *                       the moment. If double buffering could not be 
 *                       enabled then #flip will just update the
 *                       entire screen.
 *          FULLSCREEN:: Rubygame will attempt to use a fullscreen mode. If
 *                       a hardware resolution change is not possible (for 
 *                       whatever reason), the next higher resolution will
 *                       be used and the display window centered on a black
 *                       background.
 *          OPENGL::     Create an OpenGL rendering context. You must set
 *                       proper OpenGL video attributes with GL#set_attrib
 *                       before calling this method with this flag. You can
 *                       then use separate opengl libraries (for example rbogl)
 *                       to do all OpenGL-related functions.
 *                       Please note that you can't blit or draw regular SDL
 *                       Surfaces onto an OpenGL-mode screen; you must use
 *                       OpenGL functions.
 *          RESIZABLE::  Create a resizable window. When the window is 
 *                       resized by the user, a ResizeEvent is
 *                       generated and this method can be called again
 *                       with the new size.
 *          NOFRAME::    If possible, create a window with no title bar or
 *                       frame decoration.
 *                       Fullscreen modes automatically have this flag set.
 */
VALUE rbgm_screen_setmode(int argc, VALUE *argv, VALUE module)
{
  SDL_Surface *screen;
  int w, h, depth;
  Uint32 flags;
	VALUE vsize, vdepth, vflags;

	rb_scan_args(argc, argv, "12", &vsize, &vdepth, &vflags);
	
	vsize = convert_to_array(vsize);
	w = NUM2INT(rb_ary_entry(vsize,0));
	h = NUM2INT(rb_ary_entry(vsize,1));

	depth = 0;
  if( RTEST(vdepth) )
	{
		depth = NUM2INT(vdepth);
	}

	flags = collapse_flags(vflags); /* in rubygame_shared */

  screen = SDL_SetVideoMode( w,h,depth,flags );

  if( screen==NULL )
	{
	  rb_raise(eSDLError,"Couldn't set [%d x %d] %d bpp video mode: %s",
			   w, h, depth, SDL_GetError());
	}
  //format = screen->format;
  //printf("New screen will be: %dx%d, %d bpp. Masks: %d, %d, %d, %d\n",w,h,depth,format->Rmask,format->Gmask,format->Bmask,format->Amask);
  return Data_Wrap_Struct( cScreen,0,0,screen ); 
}



/*
 *  call-seq:
 *     Screen.close
 *
 *  Close the Screen, making the Rubygame window disappear.
 *  This method also exits from fullscreen mode, if needed.
 *
 *  After calling this method, you should discard any references
 *  to the old Screen surface, as it is no longer valid, even
 *  if you call Screen.new again.
 *
 *  (Note: You do not need to close the Screen to change its size
 *  or flags, you can simply call Screen.new while already open.)
 *
 */
VALUE rbgm_screen_close(VALUE module)
{
	SDL_QuitSubSystem(SDL_INIT_VIDEO);
	return Qnil;
}


/*
 *  call-seq:
 *     Screen.open?
 *
 *  True if there is an open Rubygame window.
 *  See Screen.new and Screen.close.
 *
 */
VALUE rbgm_screen_openp(VALUE module)
{
  return (SDL_GetVideoSurface() == NULL) ? Qfalse : Qtrue;
}



/*  call-seq:
 *     Screen.get_surface
 *
 *  Returns the current display window, or raises SDLError if it
 *  fails to get it (for example, if it doesn't exist yet).
 */
VALUE rbgm_screen_getsurface(VALUE module)
{
  SDL_Surface *surface;
  surface = SDL_GetVideoSurface();
  if(surface==NULL)
	{
		rb_raise(eSDLError,"Couldn't get video surface: %s",SDL_GetError());
	}
  return Data_Wrap_Struct( cScreen,0,0,surface );
}


/*  call-seq:
 *     Screen.get_resolution  ->  [width, height]
 *
 *  Returns the pixel dimensions of the user's display (i.e. monitor).
 *  (That is not the same as Screen#size, which only measures the
 *  Rubygame window.) You can use this information to detect
 *  how large of a Screen can fit on the user's display.
 *
 *  This method can _only_ be used when there is no open Screen instance.
 *  This method raises SDLError if there is a Screen instance (i.e.
 *  you have done Screen.new before). This is a limitation of the SDL
 *  function SDL_GetVideoInfo, which behaves differently when a Screen
 *  is open than when it is closed.
 *
 *  This method will also raise SDLError if it cannot get the display
 *  size for some other reason.
 *
 */
VALUE rbgm_screen_getresolution(VALUE module)
{
  VALUE array;
  const SDL_VideoInfo* hw;
  init_video_system();

  /* Test for existing Screen */
  SDL_Surface *surface;
  surface = SDL_GetVideoSurface();
  if(surface != NULL)
	{
		rb_raise(eSDLError, "You cannot get resolution when there is " \
             "an open Screen. See the docs for the reason.");
	}

  hw = SDL_GetVideoInfo();
  if(hw==NULL)
	{
		rb_raise(eSDLError,"Couldn't get video info: %s",SDL_GetError());
	}

  array = rb_ary_new();
  rb_ary_push(array, INT2NUM(hw->current_w));
  rb_ary_push(array, INT2NUM(hw->current_h));
  return array;
}


/* Screen instance methods: */


/*  call-seq:
 *     title  ->  String
 *
 *  Returns the current window title for the Screen.
 *  The default is an empty string.
 */
VALUE rbgm_screen_getcaption(VALUE self)
{
  char *title,*icon;

  SDL_WM_GetCaption( &title,&icon ); 
  if (title == NULL)
		title = "\0";
	/* We don't really care about icon. */
  return rb_str_new2(title);
}

/*  call-seq:
 *    title = title
 *
 *  Sets the window title for the Screen.
 *
 *  title::    a String, (usually) displayed at the top of the Rubygame
 *             window (when not in fullscreen mode). If omitted or +nil+,
 *             +title+ will be an empty string.
 *             How this string is displayed (if at all) is system-dependent.
 */
VALUE rbgm_screen_setcaption(VALUE self, VALUE title)
{
  char *title_str;
  title_str = "";				/* default to blank */

	if( RTEST(title) )
	{
		title_str = StringValuePtr(title);
	}
  SDL_WM_SetCaption(title_str,title_str);
  return self;
}

/*  call-seq:
 *    icon = icon
 *
 *  Sets the window icon for the Screen.
 *
 *  icon::    a Rubygame::Surface to be displayed at the top of the Rubygame
 *            window (when not in fullscreen mode), and in other OS-specific
 *            areas (like the taskbar entry). If omitted or +nil+, no icon
 *            will be shown at all.
 *
 *  NOTE: The SDL docs state that icons on Win32 systems must be 32x32 pixels.
 *  That may or may not be true anymore, but you might want to consider it
 *  when creating games to run on Windows.
 *
 */
VALUE rbgm_screen_seticon(VALUE self, VALUE data)
{
  SDL_Surface *icon;
  
  Data_Get_Struct(data, SDL_Surface, icon);
  SDL_WM_SetIcon(icon, NULL);
  
  return self;
}

/*  call-seq:
 *     update()
 *     update(rect)
 *     update(x,y,w,h)
 *
 *  Updates (refreshes) all or part of the Rubygame window, revealing to the 
 *  user any changes that have been made since the last update. If you're using
 *  a double-buffered display (see Screen.new), you should use
 *  Screen#flip instead.
 *
 *  This method takes these arguments:
 *  rect:: a Rubygame::Rect representing the area of the screen to update.
 *         Can also be an length-4 Array, or given as 4 separate arguments.
 *         If omitted or nil, the entire screen is updated.
 */
VALUE rbgm_screen_update(int argc, VALUE *argv, VALUE self)
{
  int x,y,w,h;
  SDL_Surface *screen;
  Data_Get_Struct(self,SDL_Surface,screen);
	VALUE vx, vy, vw, vh;

	rb_scan_args(argc, argv, "04", &vx, &vy, &vw, &vh);

	x = y = w = h = 0;

	if( RTEST(vx) )
	{
		switch( TYPE(vx) ) {
			case T_ARRAY: {
				if( RARRAY_LEN(vx) < 4 )
				{
					rb_raise(rb_eArgError,"Array is too short to be a Rect (%s for 4)",
									 RARRAY_LEN(vx));
				}
				x = NUM2INT(rb_ary_entry(vx,0));
				y = NUM2INT(rb_ary_entry(vx,1));
				w = NUM2INT(rb_ary_entry(vx,2));
				h = NUM2INT(rb_ary_entry(vx,3));
				break;
			}
			case T_FLOAT:
			case T_BIGNUM:
			case T_FIXNUM: {
				x = NUM2INT(vx);
				y = NUM2INT(vy);
				w = NUM2INT(vw);
				h = NUM2INT(vh);
				break;
			}
			default: {
				rb_raise(rb_eTypeError,"Unrecognized type for x (wanted Array or Numeric).");
				break;
			}
		}
	}

	Sint16 left,top,right,bottom;

	left   = min( max( 0,    x    ), screen->w );
	top    = min( max( 0,    y    ), screen->h );
	right  = min( max( left, x + w), screen->w );
	bottom = min( max( top,  y + h), screen->h );

	x = left;
	y = top;
	w = right - left;
	h = bottom - top;

  SDL_UpdateRect(screen,x,y,w,h);
  return self;
}

/*  call-seq:
 *     update_rects(rects)
 *
 *  Updates (as Screen#update does) several areas of the screen.
 *
 *  This method takes these arguments:
 *  rects:: an Array containing any number of Rect objects, each
 *          rect representing a portion of the screen to update.
 */
VALUE rbgm_screen_updaterects(VALUE self, VALUE array_rects)
{
  int i, num_rects;
  VALUE each_rect;
  SDL_Surface *screen;
  SDL_Rect *rects;

  /* unwrap the Screen instance from self (VALUE) */
  Data_Get_Struct(self,SDL_Surface,screen);

  /* prepare an (uninitialized) array of Rects */
  array_rects = convert_to_array(array_rects);
  num_rects = RARRAY_LEN(array_rects);
  rects = ALLOCA_N(SDL_Rect, num_rects);

  /* initialize the array of Rects from array_rects */
  for( i=0; i < num_rects; i++ )
  {
    each_rect = convert_to_array(rb_ary_entry(array_rects,i));

    Sint16 x,y,left,top,right,bottom;
    Uint16 w,h;

    x = NUM2INT(rb_ary_entry(each_rect,0));
    y = NUM2INT(rb_ary_entry(each_rect,1));
    w = NUM2INT(rb_ary_entry(each_rect,2));
    h = NUM2INT(rb_ary_entry(each_rect,3));

		left   = min( max( 0,    x    ), screen->w );
		top    = min( max( 0,    y    ), screen->h );
		right  = min( max( left, x + w), screen->w );
		bottom = min( max( top,  y + h), screen->h );

    rects[i].x = left;
    rects[i].y = top;
    rects[i].w = right - left;
    rects[i].h = bottom - top;
  }

  /* call the SDL method to update from all these rects */
  SDL_UpdateRects( screen, num_rects, rects );

  return self;
}

/*  call-seq:
 *     flip()
 *
 *  If the Rubygame display is double-buffered (see Screen.new), flips
 *  the buffers and updates the whole screen. Otherwise, just updates the
 *  whole screen.
 */
VALUE rbgm_screen_flip(VALUE self)
{
  SDL_Surface *screen;
  Data_Get_Struct(self, SDL_Surface, screen);
  SDL_Flip(screen);
  return self;
}

/*  call-seq: 
 *    show_cursor? ->  true or false
 *
 *  Returns true if the mouse cursor is shown, or false if hidden. See also 
 *  #show_cursor=
 */
VALUE rbgm_screen_getshowcursor(VALUE self)
{
  return SDL_ShowCursor(SDL_QUERY);
}

/*  call-seq: 
 *    show_cursor = value  ->  true or false or nil
 *
 *  Set whether the mouse cursor is displayed or not. If +value+ is true,
 *  the cursor will be shown; if false, it will be hidden. See also 
 *  #show_cursor?
 */
VALUE rbgm_screen_setshowcursor(VALUE self, VALUE val)
{
  int state;

  if(val == Qtrue) { state = SDL_ENABLE; }
  else if(val == Qfalse || val == Qnil) { state = SDL_DISABLE; }
  else { return Qnil; }

  return SDL_ShowCursor(state);
}

/*
 *  Document-class: Rubygame::Screen
 *
 *  Screen represents the display window for the game. The Screen is a
 *  special Surface that is displayed to the user. By changing and then 
 *  updating the Screen many times per second, we can create the illusion
 *  of continous motion.
 *
 *  Screen inherits most of the Surface methods, and can be passed to methods
 *  which expect a Surface, including Surface#blit and the Draw functions.
 *  However, the Screen cannot have a colorkey or an alpha channel, so
 *  Surface#set_colorkey and Surface#set_alpha are not inherited.
 *
 *  Please note that only *one* Screen can exist, per application, at a time;
 *  this is a limitation of SDL. You *must* use Screen.new (or its alias,
 *  Screen.open) to create or modify the Screen.
 *
 *  Also note that no changes to the Screen will be seen until it is refreshed.
 *  See #update, #update_rects, and #flip for ways to refresh all or part of
 *  the Screen.
 *
 */
void Rubygame_Init_Screen()
{
#if 0
  mRubygame = rb_define_module("Rubygame");
  cSurface = rb_define_class_under(mRubygame,"Surface",rb_cObject);
#endif

  /* Screen class */
  cScreen = rb_define_class_under(mRubygame,"Screen",cSurface);
  rb_define_singleton_method(cScreen,"new",rbgm_screen_setmode, -1);
  rb_define_alias(rb_singleton_class(cScreen),"open","new");
  rb_define_alias(rb_singleton_class(cScreen),"set_mode","new");
  rb_define_alias(rb_singleton_class(cScreen),"instance","new");
  rb_define_singleton_method(cScreen,"close", rbgm_screen_close, 0);
  rb_define_singleton_method(cScreen,"open?", rbgm_screen_openp, 0);
  rb_define_singleton_method(cScreen,"get_surface",rbgm_screen_getsurface, 0);
  rb_define_singleton_method(cScreen,"get_resolution",rbgm_screen_getresolution, 0);

  /* These are inherited from Surface, but should not be called on Screen */
  rb_undef_method(cScreen,"set_alpha"); 
  rb_undef_method(cScreen,"set_colorkey");

  /* Screen methods */
  rb_define_method(cScreen,"title",rbgm_screen_getcaption,0);
  rb_define_method(cScreen,"title=",rbgm_screen_setcaption,1);
  rb_define_method(cScreen,"icon=",rbgm_screen_seticon,1);
  rb_define_method(cScreen,"update",rbgm_screen_update,-1);
  rb_define_method(cScreen,"update_rects",rbgm_screen_updaterects,1);
  rb_define_method(cScreen,"flip",rbgm_screen_flip,0);
  rb_define_method(cScreen,"show_cursor?",rbgm_screen_getshowcursor,0);
  rb_define_method(cScreen,"show_cursor=",rbgm_screen_setshowcursor,1);

	/* Screen initialization flags */
	rb_define_const(mRubygame,"DOUBLEBUF",UINT2NUM(SDL_DOUBLEBUF));
	rb_define_const(mRubygame,"FULLSCREEN",UINT2NUM(SDL_FULLSCREEN));
	rb_define_const(mRubygame,"OPENGL",UINT2NUM(SDL_OPENGL));
	rb_define_const(mRubygame,"OPENGLBLIT",UINT2NUM(SDL_OPENGLBLIT));
	rb_define_const(mRubygame,"RESIZABLE",UINT2NUM(SDL_RESIZABLE));
	rb_define_const(mRubygame,"NOFRAME",UINT2NUM(SDL_NOFRAME));
}
