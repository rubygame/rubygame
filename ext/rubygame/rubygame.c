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

int rect_entry( VALUE rect, int index )
{
	VALUE array;

	array = rb_funcall(rect,rb_intern("to_a"),0);
	return NUM2INT(rb_ary_entry(array,index));
}

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

/* Wrap it all together into one module: */
void Init_rubygame()
{
	mRubygame = rb_define_module("Rubygame");
	Define_Rubygame_Constants();

	rb_define_module_function(mRubygame,"init",rbgm_init,0);
	cRect = rb_define_class_under(mRubygame,"Rect",rb_cObject);
	eSDLError = rb_define_class_under(mRubygame,"SDLError",rb_eStandardError);
	eALError = rb_define_class_under(mRubygame,"ALError",rb_eStandardError);

	//mKey = rb_define_module_under(mRubygame,"Key");
	//mMouse = rb_define_module_under(mRubygame,"Mouse");

	Rubygame_Init_Time();
	Rubygame_Init_Surface();
	Rubygame_Init_Display();
	Rubygame_Init_Event();
	Rubygame_Init_Image();
	Rubygame_Init_Draw();
	Rubygame_Init_Transform();
	Rubygame_Init_Joystick();
	Rubygame_Init_Font();
}
