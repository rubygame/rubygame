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
#ifdef HAVE_SDL_GFX
#include <SDL_rotozoom.h>

VALUE rbgm_transform_rotozoom(int argc, VALUE *argv, VALUE module)
{
	SDL_Surface *src, *dst;
	double angle, zoom;
	int smooth = 0;

	if(argc < 3)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 3)",argc);
	Data_Get_Struct(argv[0],SDL_Surface,src);
	angle = NUM2DBL(argv[1]);
	zoom = NUM2DBL(argv[2]);
	if(argc > 3)
		smooth = argv[3];

	dst = rotozoomSurface(src, angle, zoom, smooth);
	if(dst == NULL)
		rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());

	return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,dst);
}

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

void Rubygame_Init_Transform()
{
	mTrans = rb_define_module_under(mRubygame,"Transform");

	rb_define_module_function(mTrans,"rotozoom",rbgm_transform_rotozoom,-1);
	rb_define_module_function(mTrans,"rotozoom_size",rbgm_transform_rotozoomsize,-1);
	rb_define_module_function(mTrans,"zoom",rbgm_transform_zoom,-1);
	rb_define_module_function(mTrans,"zoom_size",rbgm_transform_zoomsize,-1);
}
#else /* ndef HAVE_SDL_GFX */
/*
If SDL_gfx is not installed, module still exists, but
all functions are dummy functions which raise StandardError
*/

VALUE rbgm_trans_notloaded(int argc, VALUE *argv, VALUE classmod)
{
//	rb_raise(rb_eStandardError,"Transform module could not be loaded: SDL_gfx is missing. Install SDL_gfx and recompile Rubygame.");
	return Qnil;
}

void Rubygame_Init_Transform()
{
	mTrans = rb_define_module_under(mRubygame,"Transform");

	rb_define_module_function(mTrans,"rotozoom",rbgm_trans_notloaded,-1);
	rb_define_module_function(mTrans,"rotozoom_size",rbgm_trans_notloaded,-1);
	rb_define_module_function(mTrans,"zoom",rbgm_trans_notloaded,-1);
	rb_define_module_function(mTrans,"zoom_size",rbgm_trans_notloaded,-1);
}

#endif /* HAVE_SDL_GFX */
