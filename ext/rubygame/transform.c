/*
	= Rubygame::Transform -- Surface rotation, zooming, and flipping functions.

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
#ifdef HAVE_SDL_ROTOZOOM_H
#include <SDL_rotozoom.h>

/* Separate X/Y rotozoom scaling was not supported prior to 2.0.13. */
/* Check if we have at least version 2.0.13 of SDL_gfxPrimitives */
#ifndef HAVE_ROTOZOOMXY
#include <SDL_gfxPrimitives.h>  /* to get the version numbers */
#if ((SDL_GFXPRIMITIVES_MAJOR > 2) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR > 0) || (SDL_GFXPRIMITIVES_MAJOR == 2 && SDL_GFXPRIMITIVES_MINOR == 0 && SDL_GFXPRIMITIVES_MICRO >= 13))
#define HAVE_ROTOZOOMXY
#endif
#endif /* HAVE_ROTOZOOMXY */

/*
 *  call-seq:
 *     Transform.rotozoom( surface, angle, zoom, smooth )
 *
 *  Return a rotated and/or zoomed version of the given surface. Note that
 *  rotating a Surface anything other than a multiple of 90 degrees will 
 *  cause the new surface to be larger than the original to accomodate the
 *  corners (which would otherwise extend beyond the surface).
 *
 *  This function takes these arguments:
 *  - surface:: the source surface.
 *  - angle::   degrees to rotate counter-clockwise (negative for clockwise).
 *  - zoom::    scaling factor. If Rubygame was compiled with SDL_gfx >= 
 *              2.0.13, this can be an Array of 2 Numerics for separate X and Y
 *              scaling, and can be negative to indicate flipping horizontally
 *              or vertically.
 *  - smooth::  whether to anti-alias the new surface. This option can be
 *              omitted, in which case the surface will not be anti-aliased.
 *              If true, the new surface will be 32bit RGBA.
 */
VALUE rbgm_transform_rotozoom(int argc, VALUE *argv, VALUE module)
{
	SDL_Surface *src, *dst;
	double angle, zoomx, zoomy;
	int smooth = 0;

	if(argc < 3)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 3)",argc);

	/* argv[0], the source surface. */
	Data_Get_Struct(argv[0],SDL_Surface,src);

	/* argv[1], the angle of rotation. */
	angle = NUM2DBL(argv[1]);

	/* Parsing of argv[2] is delayed until below, because its type
	   affects which function we call. */

	/* argv[3] (optional), rotozoom smoothly? */
	if(argc > 3)
		smooth = argv[3];

	/* argv[2], the zoom factor(s) */
	if(TYPE(argv[2])==T_ARRAY)
	{
#ifdef HAVE_ROTOZOOMXY		
		/* Do the real function. */
		zoomx = NUM2DBL(rb_ary_entry(argv[2],0));
		zoomy = NUM2DBL(rb_ary_entry(argv[2],1));
		dst = rotozoomSurfaceXY(src, angle, zoomx, zoomy, smooth);
		if(dst == NULL)
		  rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());

#else
		/* Warn and return nil. You should have checked first! */
		rb_warn("Separate X/Y rotozoom scale factors is not supported by your version of SDL_gfx (%d,%d,%d). Please upgrade to 2.0.13 or later.", SDL_GFXPRIMITIVES_MAJOR, SDL_GFXPRIMITIVES_MINOR, SDL_GFXPRIMITIVES_MICRO);
		return Qnil;
#endif

	}
	else if(FIXNUM_P(argv[2]) || TYPE(argv[2])==T_FLOAT)
	{
		zoomx = NUM2DBL(argv[2]);
		dst = rotozoomSurface(src, angle, zoomx, smooth);
		if(dst == NULL)
		  rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());
	}
	else
		rb_raise(rb_eArgError,"wrong zoom factor type (expected Array or Numeric)");

	return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,dst);
}

/*
 *  call-seq:
 *     Transform.rotozoomsize( size, angle, zoom )
 *
 *  Return the dimensions of the surface that would be returned if
 *  Transform.rotozoom() were called with a surface of the given size, and
 *  the same angle and zoom factors.
 *
 *  - size::  an Array with the hypothetical surface width and height (pixels)
 *  - angle:: degrees to rotate counter-clockwise (negative for clockwise).
 *  - zoom::  scaling factor. If Rubygame was compiled with SDL_gfx >= 2.0.13,
 *            this can be an Array of 2 Numerics for separate X and Y scaling,
 *            and can be negative to indicate flipping across Y and/or X axes.
 */
VALUE rbgm_transform_rzsize(int argc, VALUE *argv, VALUE module)
{
	int w,h, dstw,dsth;
	double angle, zoomx, zoomy;

	if(argc < 3)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 3)",argc);
	w = NUM2INT(rb_ary_entry(argv[0],0));
	h = NUM2INT(rb_ary_entry(argv[0],0));
	angle = NUM2DBL(argv[1]);

	if(TYPE(argv[2])==T_ARRAY)
	{
/* Separate X/Y rotozoom scaling was not supported prior to 2.0.13. */
/* Check if we have at least version 2.0.13 of SDL_gfxPrimitives */
#ifdef HAVE_ROTOZOOMXY
	  /* Do the real function. */
		zoomx = NUM2DBL(rb_ary_entry(argv[1],0));
		zoomy = NUM2DBL(rb_ary_entry(argv[1],1));
		rotozoomSurfaceSizeXY(w, h, angle, zoomx, zoomy, &dstw, &dsth);

#else 
		/* Warn and return nil. You should have checked first! */
		rb_warn("Separate X/Y rotozoom scale factors is not supported by your version of SDL_gfx (%d,%d,%d). Please upgrade to 2.0.13 or later.", SDL_GFXPRIMITIVES_MAJOR, SDL_GFXPRIMITIVES_MINOR, SDL_GFXPRIMITIVES_MICRO);
		return Qnil;
#endif

	}
	else if(FIXNUM_P(argv[1]) || TYPE(argv[1])==T_FLOAT)
	{
		zoomx = NUM2DBL(argv[1]);
		rotozoomSurfaceSize(w, h, angle, zoomx, &dstw, &dsth);
	}
	else
		rb_raise(rb_eArgError,"wrong zoom factor type (expected Array or Numeric)");


	/*	 if(dstw == NULL || dsth == NULL)
		 rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());*/
	return rb_ary_new3(2,INT2NUM(dstw),INT2NUM(dsth));

}

#if 0
VALUE rbgm_transform_rotozoomsize(int argc, VALUE *argv, VALUE module)
{
	int w,h, dstw,dsth;
	double angle, zoom;

	if(argc < 3)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 3)",argc);
	w = NUM2INT(rb_ary_entry(argv[0],0));
	h = NUM2INT(rb_ary_entry(argv[0],0));
	angle = NUM2DBL(argv[1]);
	zoom = NUM2DBL(argv[2]);

	rotozoomSurfaceSize(w, h, angle, zoom, &dstw, &dsth);
	return rb_ary_new3(2,INT2NUM(dstw),INT2NUM(dsth));
}
#endif

/* 
 *  call-seq:
 *     Transform.zoom(surface, zoom, smooth)
 *
 *  Return a zoomed version of the given Surface.
 *
 *  This function takes these arguments:
 *  - surface:: the surface to zoom
 *  - zoom::    the factor to scale by in both x and y directions, or an Array
 *              with separate x and y scale factors.
 *  - smooth::  whether to anti-alias the new surface. This option can be
 *              omitted, in which case the surface will not be anti-aliased.
 *              If true, the new surface will be 32bit RGBA.
 */
VALUE rbgm_transform_zoom(int argc, VALUE *argv, VALUE module)
{
	SDL_Surface *src, *dst;
	double zoomx, zoomy;
	int smooth = 0;

	if(argc < 2)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 3)",argc);
	Data_Get_Struct(argv[0],SDL_Surface,src);

	if(TYPE(argv[1])==T_ARRAY)
	{
		zoomx = NUM2DBL(rb_ary_entry(argv[1],0));
		zoomy = NUM2DBL(rb_ary_entry(argv[1],1));
	}
	else if(FIXNUM_P(argv[1]) || TYPE(argv[1])==T_FLOAT)
	{
		zoomx = NUM2DBL(argv[1]);
		zoomy = zoomx;
	}
	else
		rb_raise(rb_eArgError,"wrong zoom factor type (expected Array or Numeric)");

	if(argc > 2)
		smooth = argv[3];

	dst = zoomSurface(src,zoomx,zoomy,smooth);
	if(dst == NULL)
		rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());
	return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,dst);
}

/* 
 *  call-seq:
 *     Transform.zoom_size(size, zoom)  =>  [w,h]
 *
 *  Return the dimensions of the surface that would be returned if
 *  Transform.zoom() were called with a surface of the given size, and
 *  the same zoom factors.
 *
 *  This function takes these arguments:
 *  - size:: an Array with the hypothetical surface width and height (pixels)
 *  - zoom:: the factor to scale by in both x and y directions, or an Array
 *           with separate x and y scale factors.
 */
VALUE rbgm_transform_zoomsize(int argc, VALUE *argv, VALUE module)
{
	int w,h, dstw,dsth;
	double zoomx, zoomy;

	if(argc < 3)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 3)",argc);
	w = NUM2INT(rb_ary_entry(argv[0],0));
	h = NUM2INT(rb_ary_entry(argv[0],0));

	if(TYPE(argv[1])==T_ARRAY)
	{
		zoomx = NUM2DBL(rb_ary_entry(argv[1],0));
		zoomy = NUM2DBL(rb_ary_entry(argv[1],1));
	}
	else if(FIXNUM_P(argv[1]) || TYPE(argv[1])==T_FLOAT)
	{
		zoomx = NUM2DBL(argv[1]);
		zoomy = zoomx;
	}
	else
		rb_raise(rb_eArgError,"wrong zoom factor type (expected Array or Numeric)");

	zoomSurfaceSize(w, h,  zoomx, zoomy, &dstw, &dsth);
	return rb_ary_new3(2,INT2NUM(dstw),INT2NUM(dsth));
}

/* 
 * call-seq:
 *    Transform.flip(surface, flipXp, flipYp)
 * 
 *  This function is usable only if Rubygame was compiled with SDL_gfx 2.0.13
 *  or greater.
 *
 *  Flips the source +surface+ horizontally (if flipXp is true), vertically
 *  (if flipYp is true), or both (if both are true).
 *
 *  You can achieve the same effect by giving X or Y zoom factors of -1 to
 *  Transform.rotozoom (if compiled with SDL_gfx 2.0.13 or greater).
 */
VALUE rbgm_transform_flip(int argc, VALUE *argv, VALUE module)
{
#ifdef HAVE_ROTOZOOMXY
	SDL_Surface *src, *dst;
	int flipx, flipy;

	if(argc < 2)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 3)",argc);
	Data_Get_Struct(argv[0],SDL_Surface,src);

	flipx = argv[1];
    flipy = argv[2];

	dst = rotozoomSurfaceXY(src,0,(flipx ? -1.0 : 1.0),(flipy ? -1.0 : 1.0),0);
	if(dst == NULL)
		rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());
	return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,dst);

#else

	rb_warn("Surface flipping is not supported by your version of SDL_gfx (%d,%d,%d). Please upgrade to 2.0.13 or later.", SDL_GFXPRIMITIVES_MAJOR, SDL_GFXPRIMITIVES_MINOR, SDL_GFXPRIMITIVES_MICRO);
	return Qnil;

#endif /* HAVE_ROTOZOOMXY */

}
	
void Rubygame_Init_Transform()
{
	mTrans = rb_define_module_under(mRubygame,"Transform");
	rb_define_module_function(mTrans,"usable?",rbgm_usable,0);

	rb_define_module_function(mTrans,"rotozoom",rbgm_transform_rotozoom,-1);
	rb_define_module_function(mTrans,"rotozoom_size",rbgm_transform_rzsize,-1);
	rb_define_module_function(mTrans,"zoom",rbgm_transform_zoom,-1);
	rb_define_module_function(mTrans,"zoom_size",rbgm_transform_zoomsize,-1);
	rb_define_module_function(mTrans,"flip",rbgm_transform_flip,-1);
}

/*
If SDL_gfx is not installed, the module still exists, but
all functions are dummy functions which return nil.
Programs should check if it is loaded with Rubygame::Transform.usable?
and act appropriately!
*/

#else /* HAVE_SDL_ROTOZOOM_H */

void Rubygame_Init_Transform()
{
	mTrans = rb_define_module_under(mRubygame,"Transform");
	rb_define_module_function(mTrans,"usable?",rbgm_unusable,0);

	rb_define_module_function(mTrans,"rotozoom",rbgm_dummy,-1);
	rb_define_module_function(mTrans,"rotozoom_size",rbgm_dummy,-1);
	rb_define_module_function(mTrans,"zoom",rbgm_dummy,-1);
	rb_define_module_function(mTrans,"zoom_size",rbgm_dummy,-1);
	rb_define_module_function(mTrans,"flip",rbgm_dummy,-1);
}

#endif /* HAVE_SDL_ROTOZOOM_H */
