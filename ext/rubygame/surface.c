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

/* Surface class */
VALUE rbgm_surface_new(int argc, VALUE *argv, VALUE class)
{
	VALUE self;
	SDL_Surface *self_surf, *screen;
	SDL_PixelFormat *format;
	Uint32 flags, Rmask, Gmask, Bmask, Amask;
	int w, h, depth;
	
	/* Grab some format info from the screen surface */
	screen = SDL_GetVideoSurface();
	if( screen == NULL )
	{
		rb_raise(eSDLError,\
			"Could not get display surface to make new Surface: %s",\
			SDL_GetError());
	}
	format = screen->format;

	/* Prepare arguments for creating surface */
	/* Get width and height for new surface from argv[0] */
	Check_Type(argv[0],T_ARRAY);
	if(RARRAY(argv[0])->len >= 2)
	{
		w = NUM2INT(rb_ary_entry(argv[0],0));
		h = NUM2INT(rb_ary_entry(argv[0],1));
	}
	else
		rb_raise(rb_eArgError,"wrong size type (expected Array)");
	
	/* Get depth from arg or screen */
	/* if argv[1] exists, and is not nil or 0... */
	if(argc >= 2 && argv[1] != Qnil && NUM2INT(argv[1]) > 0)
	{
		/* then set depth from arg... */
		depth = NUM2INT(argv[1]);
	}
	else
	{
		/* else set depth from screen's depth. */
		depth = format->BitsPerPixel;
	}

	/* Get flags from arg, or set to 0*/
	/* if argv[2] exists, and is not nil... */
	if(argc >= 3 && argv[2] != Qnil)
	{
		/* then set flags from arg... */
		flags = NUM2UINT(argv[2]);
	}
	else
	{
		/* else set to 0. */
		flags = 0;
	}

	/* Get RGBA masks from screen */
	Rmask = format->Rmask;
	Gmask = format->Gmask;
	Bmask = format->Bmask;
	Amask = format->Amask;
		
	/* Create the new surface */

	self_surf = SDL_CreateRGBSurface(flags,w,h,depth,Rmask,Gmask,Bmask,Amask);
	if( self_surf == NULL )
	{
		rb_raise(eSDLError,"Could not create new surface: %s",SDL_GetError());
		return Qnil; /* should never get here */
	}

	/* Wrap the new surface in a crunchy candy VALUE shell */
	self = Data_Wrap_Struct( cSurface,0,SDL_FreeSurface,self_surf );
	/* The default initialize() does nothing, but could be overridden */
	rb_obj_call_init(self,argc,argv);
	return self;
}


VALUE rbgm_surface_initialize(int argc, VALUE *argv, VALUE self)
{
	return self;
}

VALUE rbgm_surface_get_w(VALUE self)
{
	SDL_Surface *surf;
	Data_Get_Struct(self, SDL_Surface, surf);
	return INT2NUM(surf->w);
}

VALUE rbgm_surface_get_h(VALUE self)
{
	SDL_Surface *surf;
	Data_Get_Struct(self, SDL_Surface, surf);
	return INT2NUM(surf->h);
}

VALUE rbgm_surface_get_size(VALUE self)
{
	SDL_Surface *surf;
	Data_Get_Struct(self, SDL_Surface, surf);
	return rb_ary_new3( 2, INT2NUM(surf->w), INT2NUM(surf->h) );
}

VALUE rbgm_surface_get_depth(VALUE self)
{
	SDL_Surface *surf;
	Data_Get_Struct(self, SDL_Surface, surf);
	return INT2NUM(surf->format->BitsPerPixel);
}

VALUE rbgm_surface_get_flags(VALUE self)
{
	SDL_Surface *surf;
	Data_Get_Struct(self, SDL_Surface, surf);
	return INT2NUM(surf->flags);
}

VALUE rbgm_surface_get_masks(VALUE self)
{
	SDL_Surface *surf;
	SDL_PixelFormat *format;

	Data_Get_Struct(self, SDL_Surface, surf);
	format = surf->format;
	return rb_ary_new3(4,\
		INT2NUM(format->Rmask),\
		INT2NUM(format->Gmask),\
		INT2NUM(format->Bmask),\
		INT2NUM(format->Amask));
}

VALUE rbgm_surface_get_alpha(VALUE self)
{
	SDL_Surface *surf;
	Data_Get_Struct(self, SDL_Surface, surf);
	return INT2NUM(surf->format->alpha);
}

VALUE rbgm_surface_set_alpha(int argc, VALUE *argv, VALUE self)
{
	SDL_Surface *surf;
	Uint8 alpha;
	Uint32 flags = SDL_SRCALPHA;

	switch(argc)
	{
		case 2: flags = NUM2INT(argv[1]);
			/* no break */
		case 1:;
			int temp;
			temp = NUM2INT(argv[0]);
			if(temp<0) alpha = 0;
			else if(temp>255) alpha = 255;
			else alpha = (Uint8) temp;
			break;
		default:
			rb_raise(rb_eArgError,\
				"Wrong number of args to set mode (%d for 1)",argc);
	}

	Data_Get_Struct(self,SDL_Surface,surf);
	if(SDL_SetAlpha(surf,flags,alpha)!=0)
		rb_raise(eSDLError,"%s",SDL_GetError());
	return self;
}

VALUE rbgm_surface_get_colorkey( VALUE self )
{
	SDL_Surface *surf;
	Uint32 colorkey;
	Uint8 r,g,b;

	Data_Get_Struct(self, SDL_Surface, surf);
	colorkey = surf->format->colorkey;
	if((int *)colorkey == NULL)
		return Qnil;
	SDL_GetRGB(colorkey, surf->format, &r, &g, &b);
	return rb_ary_new3(3,INT2NUM(r),INT2NUM(g),INT2NUM(b));
}

VALUE rbgm_surface_set_colorkey( int argc, VALUE *argv, VALUE self)
{
	SDL_Surface *surf;
	Uint32 color;
	Uint32 flag;
	Uint8 r,g,b;

	Data_Get_Struct(self, SDL_Surface, surf);
	if(argv[0] == Qnil)
	{
		flag = 0;
		color = 0;
	}
	else
	{
		if(argc > 1)
			flag = NUM2INT(argv[1]);
		else
			flag = SDL_SRCCOLORKEY;

		r = NUM2INT(rb_ary_entry(argv[0],0));
		g = NUM2INT(rb_ary_entry(argv[0],1));
		b = NUM2INT(rb_ary_entry(argv[0],2));
		//printf("RGB: %d,%d,%d  ",r,g,b);
		color = SDL_MapRGB(surf->format, r,g,b);
		//printf("colorkey: %d\n", color);
	}

	if(SDL_SetColorKey(surf,flag,color)!=0)
		rb_raise(eSDLError,"could not set colorkey: %s",SDL_GetError());
	return self;
}

VALUE rbgm_surface_blit(int argc, VALUE *argv, VALUE self)
{
	if(argc < 2 || argc > 3)
		rb_raise( rb_eArgError,"Wrong number of arguments to blit (%d for 2)",argc);

	//int temp_x,temp_y,dest_x,dest_y,dest_w,dest_h, src_x,src_y,src_w,src_h;
	int dest_x,dest_y, src_x,src_y,src_w,src_h;
	VALUE returnrect;
	SDL_Surface *src, *dest;
	SDL_Rect *src_rect, *dest_rect;
	Data_Get_Struct(self, SDL_Surface, src);
	Data_Get_Struct(argv[0], SDL_Surface, dest);

#if 0
	/* experimental (broken) rectangle cropping code */
	temp_x = rect_entry(argv[1],0);
	temp_y = rect_entry(argv[1],1);
	/* crop if it went off left or top */
	dest_x = (temp_x > 0) ? temp_x : 0;
	dest_y = (temp_y > 0) ? temp_y : 0;
	/* crop if it went off right or bottom */
	dest_w = (dest_x+src->w < dest->w) ? src->w : (dest->w - temp_x);
	dest_h = (dest_y+src->h < dest->h) ? src->h : (dest->h - temp_y);
#endif

	dest_x = rect_entry(argv[1],0);
	dest_y = rect_entry(argv[1],1);
	dest_rect = make_rect( dest_x, dest_y, src->w, src->h );

	/* did we get a src_rect argument or not? */
	if(argc>2)
	{
		/* it might be good to check that it's actually a rect here */
		src_x = rect_entry(argv[2],0);
		src_y = rect_entry(argv[2],1);
		src_w = rect_entry(argv[2],2);
		src_h = rect_entry(argv[2],3);
		src_rect = make_rect( src_x, src_y, src_w, src_h );
	}
	else
		src_rect = make_rect( 0, 0, src->w, src->h );
		
//	printf("dest_rect: [%d %d %d %d]\n",dest_rect->x,dest_rect->y,dest_rect->w,dest_rect->h);
//	printf("src_rect:  [%d %d %d %d]\n",src_rect->x,src_rect->y,src_rect->w,src_rect->h);
	SDL_BlitSurface(src,src_rect,dest,dest_rect);

	returnrect = rb_funcall(cRect,rb_intern("new"),4,
		INT2NUM(dest_x),INT2NUM(dest_y),\
		INT2NUM(src->w),INT2NUM(src->h));

	free(dest_rect);
	free(src_rect);
	return returnrect;
}

VALUE rbgm_surface_fill( int argc, VALUE *argv, VALUE self )
{
	SDL_Surface *surf;
	SDL_Rect *rect;
	Uint32 color;
	Uint8 r,g,b,a;

	Data_Get_Struct(self, SDL_Surface, surf);

	if(argc < 1)
	{
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 1 or 2)",argc);
	}

	r = FIX2UINT(rb_ary_entry(argv[0],0));
	g = FIX2UINT(rb_ary_entry(argv[0],1));
	b = FIX2UINT(rb_ary_entry(argv[0],2));
	/* if the array is larger than [R,G,B], it should be [R,G,B,A] */
	if(RARRAY(argv[0])->len > 3)
	{
		a = FIX2UINT(rb_ary_entry(argv[0],3));
		color = SDL_MapRGBA(surf->format, r,g,b,a);
	}
	else
	{
		color = SDL_MapRGB(surf->format, r,g,b);
	}

	switch(argc)
	{
		case 1: /* fill whole thing */
			SDL_FillRect(surf,NULL,color);
			break;
		case 2: /* fill a given rect */
			//printf("Going to make a rect for fill...\n");
			rect = make_rect(\
				rect_entry(argv[1],0),\
				rect_entry(argv[1],1),\
				rect_entry(argv[1],2),\
				rect_entry(argv[1],3)\
			);
			SDL_FillRect(surf,rect,color);
			free(rect);
			break;
		default:
			rb_raise( rb_eArgError,"Wrong number of arguments to fill (%d for 1 or 2)",NUM2INT(argc));
			break;
	}
	return self;
}

VALUE rbgm_surface_getat( int argc, VALUE *argv, VALUE self )
{
	SDL_Surface *surf;
	int x,y;
	int locked=0;
	Uint32 color;
	Uint8 *pixels, *pix;
	Uint8 r,g,b,a;

	Data_Get_Struct(self, SDL_Surface, surf);

	if(argc>2)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 1)",argc);

	if(argc==1)
	{
		x = NUM2INT(rb_ary_entry(argv[0],0));
		y = NUM2INT(rb_ary_entry(argv[0],1));
	}
	else
	{
		x = NUM2INT(argv[0]);
		y = NUM2INT(argv[1]);
	}

	if(x<0 || x>surf->w)
		rb_raise(rb_eIndexError,"x index out of bounds (%d, min 0, max %d)",\
			x,surf->w);
	if(y<0 || y>surf->h)
		rb_raise(rb_eIndexError,"y index out of bounds (%d, min 0, max %d)",\
			y,surf->h);

	/* lock surface */
	if(SDL_MUSTLOCK(surf))
	{
		if(SDL_LockSurface(surf)==0)
			locked += 1;
		else
			rb_raise(eSDLError,"could not lock surface: %s",SDL_GetError());
	}

/* borrowed from pygame */
	pixels = (Uint8 *) surf->pixels;

    switch(surf->format->BytesPerPixel)
    {
        case 1:
            color = (Uint32)*((Uint8 *)(pixels + y * surf->pitch) + x);
            break;
        case 2:
            color = (Uint32)*((Uint16 *)(pixels + y * surf->pitch) + x);
            break;
        case 3:
            pix = ((Uint8 *)(pixels + y * surf->pitch) + x * 3);
#if SDL_BYTEORDER == SDL_LIL_ENDIAN
            color = (pix[0]) + (pix[1]<<8) + (pix[2]<<16);
#else
            color = (pix[2]) + (pix[1]<<8) + (pix[0]<<16);
#endif
            break;
        default: /*case 4:*/
            color = *((Uint32*)(pixels + y * surf->pitch) + x);
            break;
	}

/* end borrowed from pygame */

	/* recursively unlock surface*/
	while(locked>1)
	{
		SDL_UnlockSurface(surf);
		locked -= 1;
	}

	if((int *)color == NULL)
	{
		VALUE zero = INT2NUM(0);
		return rb_ary_new3(4,zero,zero,zero,zero);
	}

	SDL_GetRGBA(color, surf->format, &r, &g, &b, &a);
	return rb_ary_new3(4,INT2NUM(r),INT2NUM(g),INT2NUM(b),INT2NUM(a));
}

void Rubygame_Init_Surface()
{
	cSurface = rb_define_class_under(mRubygame,"Surface",rb_cObject);
	rb_define_singleton_method(cSurface,"new",rbgm_surface_new,-1);
	rb_define_method(cSurface,"initialize",rbgm_surface_initialize,-1);
	rb_define_method(cSurface,"w",rbgm_surface_get_w,0);
	rb_define_alias(cSurface,"width","w");
	rb_define_method(cSurface,"h",rbgm_surface_get_h,0);
	rb_define_alias(cSurface,"height","h");
	rb_define_method(cSurface,"size",rbgm_surface_get_size,0);
	rb_define_method(cSurface,"depth",rbgm_surface_get_depth,0);
	rb_define_method(cSurface,"flags",rbgm_surface_get_flags,0);
	rb_define_method(cSurface,"masks",rbgm_surface_get_masks,0);
	rb_define_method(cSurface,"alpha",rbgm_surface_get_alpha,0);
	rb_define_method(cSurface,"set_alpha",rbgm_surface_set_alpha,-1);
	rb_define_method(cSurface,"get_colorkey",rbgm_surface_get_colorkey,0);
	rb_define_method(cSurface,"set_colorkey",rbgm_surface_set_colorkey,-1);
	rb_define_method(cSurface,"blit",rbgm_surface_blit,-1);
	rb_define_method(cSurface,"fill",rbgm_surface_fill,-1);
	rb_define_method(cSurface,"get_at",rbgm_surface_getat,-1);
}
