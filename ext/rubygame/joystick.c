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

/* Rubygame Joy module */

#if 0
VALUE rbgm_joy_init( VALUE module )
{
	SDL_InitSubsystem(SDL_INIT_JOYSTICK);
	/* is this enabled by default: */
	SDL_JoystickEventState(SDL_ENABLE); /* enable joystick events in queue */
}
#endif

VALUE rbgm_joy_numjoysticks( VALUE module )
{
	return INT2FIX(SDL_NumJoysticks());
}

VALUE rbgm_joy_getname( VALUE module, VALUE joynum )
{
	char *name;
	int n;
	int size=1024;

	name = (char *)malloc(size);
	n = snprintf(name,size,"%s",SDL_JoystickName(NUM2INT(joynum)));;
	return rb_str_new(name,n);
}

/* Rubygame Joystick class */

VALUE rbgm_joystick_new( int argc, VALUE *argv, VALUE module)
{
	VALUE self;
	SDL_Joystick *joy;
	int index;

	if(argc < 1)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 1)",argc);
	index = NUM2INT(argv[0]);

	joy = SDL_JoystickOpen(index);
	if(joy == NULL)
	{
		rb_raise(eSDLError,"Could not open joystick %d: %s",\
			index,SDL_GetError());
	}
	self = Data_Wrap_Struct(cJoystick, 0,SDL_JoystickClose, joy);
	rb_obj_call_init(self,argc,argv);
	return self;
}

VALUE rbgm_joystick_initialize( int argc, VALUE *argv, VALUE self)
{
	return self;
}

VALUE rbgm_joystick_index( VALUE self )
{
	SDL_Joystick *joy;

	Data_Get_Struct(self,SDL_Joystick,joy);
	return INT2FIX(SDL_JoystickIndex(joy));
}

VALUE rbgm_joystick_name( VALUE self )
{
	char *name;
	SDL_Joystick *joy;
	Uint8 index;
	int n;
	int size = 1024;

	Data_Get_Struct(self,SDL_Joystick,joy);
	index = SDL_JoystickIndex(joy);
	name = (char *)malloc(size);
	n = snprintf(name,size,"%s",SDL_JoystickName(index));
	return rb_str_new(name,n);
}

VALUE rbgm_joystick_numaxes( VALUE self )
{
	SDL_Joystick *joy;
	Data_Get_Struct(self,SDL_Joystick,joy);
	return INT2FIX(SDL_JoystickNumAxes(joy));
}

VALUE rbgm_joystick_numballs( VALUE self )
{
	SDL_Joystick *joy;
	Data_Get_Struct(self,SDL_Joystick,joy);
	return INT2FIX(SDL_JoystickNumBalls(joy));
}

VALUE rbgm_joystick_numhats( VALUE self )
{
	SDL_Joystick *joy;
	Data_Get_Struct(self,SDL_Joystick,joy);
	return INT2FIX(SDL_JoystickNumHats(joy));
}

VALUE rbgm_joystick_numbuttons( VALUE self )
{
	SDL_Joystick *joy;
	Data_Get_Struct(self,SDL_Joystick,joy);
	return INT2FIX(SDL_JoystickNumButtons(joy));
}

void Rubygame_Init_Joystick()
{
	mJoy = rb_define_module_under(mRubygame,"Joy");
	rb_define_module_function(mJoy,"num_joysticks",rbgm_joy_numjoysticks,0);
	rb_define_module_function(mJoy,"get_name",rbgm_joy_getname,1);

	cJoystick = rb_define_class_under(mJoy,"Joystick",rb_cObject);
	rb_define_singleton_method(cJoystick,"new",rbgm_joystick_new,-1);
	rb_define_method(cJoystick,"initialize",rbgm_joystick_initialize,-1);
	rb_define_method(cJoystick,"index",rbgm_joystick_index,0);
	rb_define_method(cJoystick,"name",rbgm_joystick_name,0);
	rb_define_method(cJoystick,"numaxes",rbgm_joystick_numaxes,0);
	rb_define_method(cJoystick,"numballs",rbgm_joystick_numballs,0);
	rb_define_method(cJoystick,"numhats",rbgm_joystick_numhats,0);
	rb_define_method(cJoystick,"numbuttons",rbgm_joystick_numbuttons,0);
}
