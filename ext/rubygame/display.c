/*
	Rubygame -- Ruby bindings to SDL to facilitate game creation
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

VALUE rbgm_screen_new(VALUE class)
{
	rb_raise(rb_eStandardError,"Use Rubygame::Display.set_mode() to create instance of Singleton class Screen.");
	return Qnil; /* should never get here */
}

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
			rb_raise(rb_eArgError,"Wrong number of args to set caption(%d for 1 or 2)",argc);
			break;
	}
			
	SDL_WM_SetCaption(title_str,iconized_str);
	return self;
}

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
	rb_define_method(cScreen,"get_caption",rbgm_screen_getcaption,0);
	rb_define_method(cScreen,"set_caption",rbgm_screen_setcaption,-1);
	rb_define_method(cScreen,"update",rbgm_screen_update,-1);
	rb_define_method(cScreen,"update_rects",rbgm_screen_updaterects,1);
	rb_define_method(cScreen,"flip",rbgm_screen_flip,0);
}
