/*--
 *
 *	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *	Copyright (C) 2004-2007  John Croisant
 *
 *	This library is free software; you can redistribute it and/or
 *	modify it under the terms of the GNU Lesser General Public
 *	License as published by the Free Software Foundation; either
 *	version 2.1 of the License, or (at your option) any later version.
 *
 *	This library is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *	Lesser General Public License for more details.
 *
 *	You should have received a copy of the GNU Lesser General Public
 *	License along with this library; if not, write to the Free Software
 *	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *++
 */

#include "rubygame_shared.h"
#include "rubygame_joystick.h"

void Rubygame_Init_Joystick();
VALUE cJoy;

VALUE rbgm_joy_numjoysticks(VALUE);
VALUE rbgm_joy_getname(VALUE, VALUE);

VALUE rbgm_joystick_new(VALUE, VALUE);

VALUE rbgm_joystick_index(VALUE);
VALUE rbgm_joystick_name(VALUE);
VALUE rbgm_joystick_numaxes(VALUE);
VALUE rbgm_joystick_numballs(VALUE);
VALUE rbgm_joystick_numhats(VALUE);
VALUE rbgm_joystick_numbuttons(VALUE);


/* 
 *  call-seq:
 *    num_joysticks  ->  Integer
 *
 *  Returns the total number of joysticks detected on the system.
 */
VALUE rbgm_joy_numjoysticks( VALUE module )
{
	return INT2FIX(SDL_NumJoysticks());
}

/* 
 *  call-seq:
 *    get_name( n )  ->  String
 *
 *  Returns the name of nth joystick on the system, up to 1024 
 *  characters long. The name is implementation-dependent.
 *  See also #name().
 */
VALUE rbgm_joy_getname( VALUE module, VALUE joynum )
{
	return rb_str_new2(SDL_JoystickName(NUM2INT(joynum)));
}


/*
* Internal function to safely deallocate the joystick, that is,
*  only if SDL Joystick module is still initialised.
*/
static void RBGM_JoystickClose(SDL_Joystick *joy) 
{
	if(SDL_WasInit(SDL_INIT_JOYSTICK)) 
	{
		SDL_JoystickClose(joy);
	}
}



/* 
 *  call-seq:
 *    Joystick.activate_all()  ->  [joystick1, joystick2, ...]
 *
 *  Activate all joysticks on the system, equivalent to calling
 *  Joystick.new for every joystick available. This will allow
 *  joystick-related events to be sent to the EventQueue for
 *  all joysticks.
 *  
 *  Returns::  Array of zero or more Joysticks.
 *
 */
VALUE rbgm_joystick_activateall(VALUE module)
{
	/* Initialize if it isn't already. */
	if( !SDL_WasInit(SDL_INIT_JOYSTICK) )
	{
		if( SDL_Init(SDL_INIT_JOYSTICK) != 0 )
		{
			rb_raise( eSDLError, "Could not initialize SDL joystick." );
		}
	}

	int num_joysticks = SDL_NumJoysticks();
	int i = 0;

	/* Collect Joystick instances in an Array. */
	VALUE joysticks = rb_ary_new();

	for(; i < num_joysticks; ++i )
	{
		rb_ary_push( joysticks, rbgm_joystick_new(module, INT2NUM(i)) );
	}

	return joysticks;
}


/* 
 *  call-seq:
 *    Joystick.deactivate_all()
 *
 *  Deactivate all joysticks on the system. This will stop all
 *  joystick-related events from being sent to the EventQueue.
 *
 */
VALUE rbgm_joystick_deactivateall(VALUE module)
{
	/* Return right away if it wasn't active. */
	if( !SDL_WasInit(SDL_INIT_JOYSTICK) )
	{
		return Qnil;
	}

	int num_joysticks = SDL_NumJoysticks();
	int i = 0;
	SDL_Joystick *joy;

	for(; i < num_joysticks; ++i )
	{
		joy = SDL_JoystickOpen(i);
		if(joy != NULL)
		{
			SDL_JoystickClose( joy );
		}
	}

	return Qnil;
}



/* 
 *  call-seq:
 *    new( n )  ->  Joystick
 *
 *  Create and initialize an interface to the nth joystick on the
 *  system. Raises SDLError if the joystick could not be opened.
 */
VALUE rbgm_joystick_new( VALUE module, VALUE vindex )
{
	VALUE self;
	SDL_Joystick *joy;
	int index;

	index = NUM2INT(vindex);

	joy = SDL_JoystickOpen(index);
	if(joy == NULL)
	{
		rb_raise(eSDLError,"Could not open joystick %d: %s",\
			index,SDL_GetError());
	}
	self = Data_Wrap_Struct(cJoy, 0, RBGM_JoystickClose, joy);
	return self;
}

/* 
 *  call-seq:
 *    index  ->  Integer
 *
 *  Returns the index number of the Joystick, i.e. the identifier number of the
 *  joystick that this interface controls. This is the same number that was
 *  given to #new().
 */
VALUE rbgm_joystick_index( VALUE self )
{
	SDL_Joystick *joy;

	Data_Get_Struct(self,SDL_Joystick,joy);
	return INT2FIX(SDL_JoystickIndex(joy));
}

/* 
 *  call-seq:
 *    name  ->  String
 *
 *  Returns a String containing the name of the Joystick, up to 1024
 *  characters long. The name is implementation-dependent. See also 
 *  #get_name().
 */
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

/* 
 *  call-seq:
 *    axes  ->  Integer
 *
 *  Returns the number of axes (singular: axis) featured on the Joystick. Each
 *  control stick generally has two axes (X and Y), although there are other
 *  types of controls which are represented as one or more axes. See also
 *  #axis_state().
 */
VALUE rbgm_joystick_numaxes( VALUE self )
{
	SDL_Joystick *joy;
	Data_Get_Struct(self,SDL_Joystick,joy);
	return INT2FIX(SDL_JoystickNumAxes(joy));
}

/* 
 *  call-seq:
 *    balls  ->  Integer
 *
 *  Returns the number of trackballs featured on the Joystick. A trackball is
 *  usually a small sphere which can be rotated in-place in any direction,
 *  registering relative movement along two axes. See alse #ball_state().
 */
VALUE rbgm_joystick_numballs( VALUE self )
{
	SDL_Joystick *joy;
	Data_Get_Struct(self,SDL_Joystick,joy);
	return INT2FIX(SDL_JoystickNumBalls(joy));
}

/* 
 *  call-seq:
 *    hats  ->  Integer
 *
 *  Returns the number of hats featured on the Joystick. A hat is a switch
 *  which can be pushed in one of several directions, or centered. See also
 *  #hat_state().
 */
VALUE rbgm_joystick_numhats( VALUE self )
{
	SDL_Joystick *joy;
	Data_Get_Struct(self,SDL_Joystick,joy);
	return INT2FIX(SDL_JoystickNumHats(joy));
}

/* 
 *  call-seq:
 *    buttons  ->  Integer
 *
 *  Returns the number of buttons featured on the Joystick. A button can
 *  be in one of two states: neutral, or pushed. See also #button_state()
 */
VALUE rbgm_joystick_numbuttons( VALUE self )
{
	SDL_Joystick *joy;
	Data_Get_Struct(self,SDL_Joystick,joy);
  SDL_JoystickUpdate();
	return INT2FIX(SDL_JoystickNumButtons(joy));
}


/*  Document-class: Rubygame::Joystick
 *
 *  The Joystick class interfaces with joysticks, gamepads, and other
 *  similar hardware devices used to play games. Each joystick may
 *  have zero or more #axes, #balls, #hats, and/or #buttons.
 *
 *  After a Joystick object is successfully created, events for that
 *  Joystick will begin appearing on the EventQueue when a button is
 *  pressed or released, a control stick is moved, etc.
 *
 *  You can use Joystick.activate_all to start receiving events for
 *  all joysticks (equivalent to creating them all individually with
 *  Joystick.new). You can use Joystick.deactivate_all to stop
 *  receiving events for all joysticks.
 *
 *  As of Rubygame 2.4, these are the current, "new-style" Joystick
 *  event classes:
 *
 *  * Events::JoystickAxisMoved
 *  * Events::JoystickButtonPressed
 *  * Events::JoystickButtonReleased
 *  * Events::JoystickBallMoved
 *  * Events::JoystickHatMoved
 *
 *  These old Joystick-related events are deprecated and will be
 *  removed in Rubygame 3.0:
 *
 *  * JoyAxisEvent
 *  * JoyBallEvent
 *  * JoyHatEvent
 *  * JoyDownEvent
 *  * JoyUpEvent
 *
 *  For more information about "new-style" events, see
 *  EventQueue.enable_new_style_events.
 *
 */
void Rubygame_Init_Joystick()
{
#if 0
	mRubygame = rb_define_module("Rubygame");
#endif

	cJoy = rb_define_class_under(mRubygame,"Joystick",rb_cObject);
	rb_define_singleton_method(cJoy,"num_joysticks",rbgm_joy_numjoysticks,0);
	rb_define_singleton_method(cJoy,"get_name",rbgm_joy_getname,1);

	rb_define_singleton_method(cJoy,"activate_all",rbgm_joystick_activateall,0);
	rb_define_singleton_method(cJoy,"deactivate_all",rbgm_joystick_deactivateall,0);

	rb_define_singleton_method(cJoy,"new",rbgm_joystick_new,1);
	rb_define_method(cJoy,"index",rbgm_joystick_index,0);
	rb_define_method(cJoy,"name",rbgm_joystick_name,0);
	rb_define_method(cJoy,"axes",rbgm_joystick_numaxes,0);
	rb_define_method(cJoy,"balls",rbgm_joystick_numballs,0);
	rb_define_method(cJoy,"hats",rbgm_joystick_numhats,0);
	rb_define_method(cJoy,"buttons",rbgm_joystick_numbuttons,0);
}
