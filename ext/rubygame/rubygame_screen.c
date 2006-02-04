/*
 *  Screen -- Rubygame-bound SDL display window
 *
 * --
 *  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004-2006  John 'jacius' Croisant
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

#include "rubygame.h"
#include "rubygame_screen.h"
#include "rubygame_surface.h"

void Rubygame_Init_Screen();

VALUE cScreen;

VALUE rbgm_screen_setmode(int, VALUE*, VALUE);
VALUE rbgm_screen_getsurface(VALUE);
VALUE rbgm_screen_new(VALUE);

VALUE rbgm_screen_getcaption(VALUE);
VALUE rbgm_screen_setcaption(int, VALUE*, VALUE);

VALUE rbgm_screen_update(int, VALUE*, VALUE);
VALUE rbgm_screen_updaterects(VALUE, VALUE);
VALUE rbgm_screen_flip(VALUE);

VALUE rbgm_screen_getshowcursor(VALUE);
VALUE rbgm_screen_setshowcursor(VALUE, VALUE);


/* call-seq:
 *  set_mode(size, depth=0, flags=[SWSURFACE])
 *
 *  Create a new Rubygame window if there is none, or modify the existing one.
 *  Returns the resulting Surface.
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
 *          RESIZABLE::  Create a resizable window. When the window is 
 *                       resized by the user, a ResizeEvent is
 *                       generated and #set_mode can be called again
 *                       with the new size.
 *          NOFRAME::    If possible, create a window with no title bar or
 *                       frame decoration.
 *                       Fullscreen modes automatically have this flag set.
 */
VALUE rbgm_screen_setmode(int argc, VALUE *argv, VALUE module)
{
  SDL_Surface *screen;
  int w, h, depth, i;
  Uint32 flags;

  w = h = depth = flags = 0;

  if(argc < 1 || argc > 3)
	rb_raise(rb_eArgError,"Wrong number of args to set mode(%d for 1)",argc);

  if(argc >= 1)
	{
	  w = NUM2INT(rb_ary_entry(argv[0],0));
	  h = NUM2INT(rb_ary_entry(argv[0],1));
	}

  if(argc >= 2 && argv[1] != Qnil)
	depth = NUM2INT(argv[1]);

  if(argc >= 3 && argv[2] != Qnil)
	{
    switch( TYPE(argv[2]) ){
    case T_ARRAY:;
      for(i=0;  i < RARRAY(argv[2])->len;  i++)
        {
          flags |= NUM2UINT(  rb_ary_entry( argv[2],i )  );
        }
      break;
    case T_FIXNUM:;
      flags = NUM2UINT( argv[2] );
      break;
    default:;
      rb_raise(rb_eArgError,"Wrong type for argument `flags' (wanted Fixnum or Array).");
    }
	}

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

/*  call-seq:
 *     get_surface
 *
 *  Returns the current display window, or raises SDLError if it
 *  fails to get it (for example, if it doesn't exist yet).
 */
VALUE rbgm_screen_getsurface(VALUE module)
{
  SDL_Surface *surface;
  surface = SDL_GetVideoSurface();
  if(surface==NULL)
	rb_raise(eSDLError,"Couldn't get video surface: %s",SDL_GetError());
  return Data_Wrap_Struct( cScreen,0,0,surface );
}

/* Screen methods: */

/*
*/

/*  call-seq:
 *     new
 *
 *  A dummy function which will raise StandardError!
 *  You must instead use Screen.set_mode() to create or change the Screen mode!
 *
 *  Screen is a Singleton-style class, which means that only one may exist at a
 *  time (per application). You can create a Screen or change the existing one
 *  using Screen.set_mode, and get a reference to an existing Screen with 
 *  Screen.get_surface
 *
 *  A Screen.new method would imply that more than one could be created, so to
 *  avoid confusion Screen has no such method.
 *
 *  (But, this annoying behavior feels like a really bad wart, so in the 
 *  future, Screen.new will probably be an alias to #set_mode. Let me know what
 *  you think about this.)
 */
VALUE rbgm_screen_new(VALUE class)
{
  rb_raise(rb_eStandardError,"Use Screen.set_mode() to create instance of Singleton class Screen.");
  return Qnil; /* should never get here */
}

/*  call-seq:
 *     caption
 *
 *  Returns the current window title and icon caption for the Screen as an
 *  Array. See #set_caption for a description of the window title/icon
 *  caption. By default, the title and icon caption are empty strings.
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
/*  call-seq:
 *    set_caption(title, icon_cap=nil)
 *
 *  Sets the window title and icon caption for the Screen.
 *
 *  This method takes these arguments:
 *  title::    a String, (usually) displayed at the top of the Rubygame
 *             window (when not in fullscreen mode). If omitted or +nil+,
 *             +title+ will be an empty string.
 *             How this string is displayed (if at all) is system-dependent.
 *  icon_cap:: a String, (usually) displayed when the window is iconized
 *             (minimized), for example to the taskbar. If omitted on +nil+,
 *             +icon_cap+ will be the same as +title+.
 *             How this string is displayed (if at all) is system-dependent.
 */
VALUE rbgm_screen_setcaption(int argc, VALUE *argv, VALUE self)
{
  char *title_str, *icon_str;

  title_str = "";				/* default to blank */

  if(argc >= 1 && argv[0] != Qnil)
	title_str = StringValuePtr(argv[0]);

  if(argc >= 2 && argv[1] != Qnil)
	icon_str = StringValuePtr(argv[1]);
  else
	icon_str = title_str;		/* default to same as title string */

  SDL_WM_SetCaption(title_str,icon_str);
  return self;
}

/*  call-seq:
 *     update()
 *     update(rect)
 *     update(x,y,w,h)
 *
 *  Updates (refreshes) all or part of the Rubygame window, revealing to the 
 *  user any changes that have been made since the last update. If you're using
 *  a double-buffered display (see Display.set_mode), you should use
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

  switch(argc)
	{
	case 0:
	  x = y = w = h = 0;
	  break;
	case 1:
	  if(argv[0]==Qnil)			/* nil */
		x = y = w = h = 0;
	  else						/* Array/Rect */
		{
		  x = NUM2INT(rb_ary_entry(argv[0],0));
		  y = NUM2INT(rb_ary_entry(argv[0],1));
		  w = NUM2INT(rb_ary_entry(argv[0],2));
		  h = NUM2INT(rb_ary_entry(argv[0],3));
		}
	  break;
	case 4:
	  x = NUM2INT(argv[0]);
	  y = NUM2INT(argv[1]);
	  w = NUM2INT(argv[2]);
	  h = NUM2INT(argv[3]);
	  break;
	default:
	  rb_raise(rb_eArgError,"wrong number of args to update (%d for 0)",argc);
	  break;
	}

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
  SDL_Rect **rects;

  /* unwrap the Screen instance from self (VALUE) */
  Data_Get_Struct(self,SDL_Surface,screen);

  /* prepare an (uninitialized) array of Rects */
  num_rects = RARRAY(array_rects)->len;
  rects = alloca(sizeof (SDL_Rect*) * num_rects);

  /* initialize the array of Rects from array_rects */
  for( i=0; i < num_rects; i++ )
	{
	  each_rect = rb_ary_entry(array_rects,i);
	  rects[i]->x = NUM2INT(rb_ary_entry(each_rect,0));
	  rects[i]->y = NUM2INT(rb_ary_entry(each_rect,1));
	  rects[i]->w = NUM2INT(rb_ary_entry(each_rect,2));
	  rects[i]->h = NUM2INT(rb_ary_entry(each_rect,3));
	}

  /* call the SDL method to update from all these rects */
  SDL_UpdateRects( screen, num_rects, *rects );

  return self;
}

/*  call-seq:
 *     flip()
 *
 *  If the Rubygame display is double-buffered (see #set_mode), flips
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
 *  this is a limitation of SDL. You *must* use Screen.set_mode to create the
 *  Screen or modify its properties.
 *
 *  Also note that no changes to the Screen will be seen until it is refreshed.
 *  See #update, #update_rects, and #flip for ways to refresh all or part of
 *  the Screen.
 *
 */
void Rubygame_Init_Screen()
{

#if 0
  /* Pretend to define Rubygame module, so RDoc knows about it: */
  mRubygame = rb_define_module("Rubygame");
#endif

  /* Screen class */
  cScreen = rb_define_class_under(mRubygame,"Screen",cSurface); // in surface.c
  rb_define_singleton_method(cScreen,"new",rbgm_screen_new,0); /* dummy func */
  rb_define_singleton_method(cScreen,"set_mode",rbgm_screen_setmode, -1);
  rb_define_singleton_method(cScreen,"get_surface",rbgm_screen_getsurface, 0);

  /* These are inherited from Surface, but should not be called on Screen */
  rb_undef_method(cScreen,"set_alpha"); 
  rb_undef_method(cScreen,"set_colorkey");

  /* Screen methods */
  rb_define_method(cScreen,"caption",rbgm_screen_getcaption,0);
  rb_define_method(cScreen,"set_caption",rbgm_screen_setcaption,-1);
  rb_define_method(cScreen,"update",rbgm_screen_update,-1);
  rb_define_method(cScreen,"update_rects",rbgm_screen_updaterects,1);
  rb_define_method(cScreen,"flip",rbgm_screen_flip,0);
  rb_define_method(cScreen,"show_cursor?",rbgm_screen_getshowcursor,0);
  rb_define_method(cScreen,"show_cursor=",rbgm_screen_setshowcursor,1);
}
