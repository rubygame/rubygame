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
int rect_entry(VALUE rect, int index)
{
	int value;

	printf("Entered rect_entry... ");
	switch(TYPE(rect))
	{
		case T_ARRAY:
			printf("It's an array... ");
			value = FIX2INT(rb_ary_entry(rect,index));
			printf("value %d...\n",value);
			return value;
			break;
		case T_OBJECT:
			printf("It's an object... ");
			value = FIX2INT(rb_funcall(rect,rb_intern("[]"),1,index));
			printf("value %d...\n",value);
			return value;
			break;
		default:
			rb_raise(rb_eArgError,"Cannot get index of non- Object/Array");
	}
}
*/

int rect_entry( VALUE rect, int index )
{
	VALUE array;

	array = rb_funcall(rect,rb_intern("to_a"),0);
	return NUM2INT(rb_ary_entry(array,index));
}

static VALUE rbgm_init(VALUE module)
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

/* wrap a ton of SDL constants */
void Define_Rubygame_Constants();

/* initialization function prototypes: */
void Rubygame_Init_Surface();
void Rubygame_Init_Display();
void Rubygame_Init_Event();
void Rubygame_Init_Time();
void Rubygame_Init_Image();
void Rubygame_Init_Draw();
void Rubygame_Init_Joystick();
void Rubygame_Init_Font();
void Rubygame_Init_Transform();

/* Wrap it all together into one module: */
void Init_rubygame()
{
	mRubygame = rb_define_module("Rubygame");
	Define_Rubygame_Constants();

	rb_define_module_function(mRubygame,"init",rbgm_init,0);
	cRect = rb_define_class_under(mRubygame,"Rect",rb_cObject);
	eSDLError = rb_define_class_under(mRubygame,"SDLError",rb_eStandardError);

	mKey = rb_define_module_under(mRubygame,"Key");
	mMouse = rb_define_module_under(mRubygame,"Mouse");

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
