/*--
 * This file is one part of:
 *   Rubygame -- Ruby bindings to SDL to facilitate game creation
 *
 * Copyright (C) 2008  John Croisant
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *++
 */


#include "rubygame_shared.h"

void Rubygame_Init_Event2();

VALUE mEvents;




/* 
 * Make a new event from the given klassname and array of arguments.
 *
 */
VALUE rg_make_rbevent( char *klassname, int argc, VALUE *argv )
{
  VALUE klass = rb_const_get( mEvents, rb_intern(klassname) );
  return rb_funcall2( klass, rb_intern("new"), argc, argv );
}



/*
 * Convert SDL's ACTIVEEVENT into zero or more of:
 *
 *   InputFocusGained  or  InputFocusLost
 *   MouseFocusGained  or  MouseFocusLost
 *   WindowMinimized   or  WindowUnminimized
 *
 * Returns a ruby Array of the events it generated.
 *
 */
VALUE rg_convert_activeevent( SDL_Event ev )
{
  char *klassname;

  /*
  Uint8 any_state = SDL_APPACTIVE | SDL_APPINPUTFOCUS | SDL_APPMOUSEFOCUS;

  if( (ev.active.state & any_state) == 0 )
  {
    rb_raise(eSDLError, 
             "unknown ACTIVEEVENT state %d. This is a bug in Rubygame.",
             ev.active.state);
  }
  */

  VALUE events = rb_ary_new();

  if( SDL_APPACTIVE & ev.active.state )
  {
  	klassname = ev.active.gain ? "WindowUnminimized" : "WindowMinimized";
    rb_ary_push(events, rg_make_rbevent( klassname, 0, (VALUE *)NULL ));
  }

  if( SDL_APPINPUTFOCUS & ev.active.state )
  {
    klassname = ev.active.gain ? "InputFocusGained" : "InputFocusLost";
    rb_ary_push(events, rg_make_rbevent( klassname, 0, (VALUE *)NULL ));

  }

  if( SDL_APPMOUSEFOCUS & ev.active.state )
  {
    klassname = ev.active.gain ? "MouseFocusGained" : "MouseFocusLost";
    rb_ary_push(events, rg_make_rbevent( klassname, 0, (VALUE *)NULL ));
  }


  return events;
}



/*
 * Convert SDL's ExposeEvent into WindowExposed.
 *
 */
VALUE rg_convert_exposeevent( SDL_Event ev )
{
  return rg_make_rbevent( "WindowExposed", 0, (VALUE *)NULL );
}




/*
 * Convert SDL's joystick axis events into JoystickAxisMoved.
 *
 */
VALUE rg_convert_joyaxisevent( SDL_Event ev )
{

  VALUE joystick_id = UINT2NUM( ev.jaxis.which );

  VALUE axis = UINT2NUM( ev.jaxis.axis );


  double dvalue = 0.0;

  /* Convert value to the -1.0 .. 1.0 range */
  if( ev.jaxis.value > 0 )
  {
    dvalue = (double)(ev.jaxis.value)/32767.f;
  }
  else if( ev.jaxis.value < 0 )
  {
    dvalue = (double)(ev.jaxis.value)/32768.f;
  }

  VALUE value = rb_float_new( dvalue );


  VALUE args[] = { joystick_id, axis, value };

  return rg_make_rbevent( "JoystickAxisMoved", 3, args);

}




/*
 * Convert SDL's joystick ball events into JoystickBallMoved.
 *
 */
VALUE rg_convert_joyballevent( SDL_Event ev )
{

  VALUE joystick_id = UINT2NUM( ev.jball.which );

  VALUE ball = UINT2NUM( ev.jball.ball );

  VALUE rel = rb_ary_new();
  rb_ary_push( rel, UINT2NUM( ev.jball.xrel ) );
  rb_ary_push( rel, UINT2NUM( ev.jball.yrel ) );


  VALUE args[] = { joystick_id, ball, rel };

  return rg_make_rbevent( "JoystickBallMoved", 3, args);

}




/*
 * Convert SDL's joystick button events into JoystickButtonPressed or
 * JoystickButtonReleased.
 *
 */
VALUE rg_convert_joybuttonevent( SDL_Event ev )
{

  VALUE joystick_id = UINT2NUM( ev.jball.which );

  VALUE button = UINT2NUM( ev.jbutton.button );

  VALUE args[] = { joystick_id, button };

  switch( ev.jbutton.state )
  {
    case SDL_PRESSED:
      return rg_make_rbevent( "JoystickButtonPressed", 2, args);

    case SDL_RELEASED:
      return rg_make_rbevent( "JoystickButtonReleased", 2, args);

    default:
      rb_raise(eSDLError, 
               "unknown joystick button state %d. This is a bug in Rubygame.",
               ev.active.state);
  }

}




VALUE rg_convert_joyhatsymbol( Uint8 value )
{
  switch(value)
  {
    case SDL_HAT_RIGHTUP:    return make_symbol("up_right");
    case SDL_HAT_RIGHTDOWN:  return make_symbol("down_right");
    case SDL_HAT_LEFTUP:     return make_symbol("up_left");
    case SDL_HAT_LEFTDOWN:   return make_symbol("down_left");
    case SDL_HAT_UP:         return make_symbol("up");
    case SDL_HAT_RIGHT:      return make_symbol("right");
    case SDL_HAT_DOWN:       return make_symbol("down");
    case SDL_HAT_LEFT:       return make_symbol("left");
    default:                 return Qnil;
  }
}


/*
 * Convert SDL's joystick hat events into JoystickHatMoved.
 *
 */
VALUE rg_convert_joyhatevent( SDL_Event ev )
{

  VALUE joystick_id = UINT2NUM( ev.jhat.which );
  VALUE hat = UINT2NUM( ev.jhat.hat );
  VALUE direction = rg_convert_joyhatsymbol( ev.jhat.value );

  VALUE args[] = { joystick_id, hat, direction };

  return rg_make_rbevent( "JoystickHatMoved", 3, args);

}




/* Returns a sanitized symbol for the given key. */
VALUE rg_convert_key_symbol2( SDLKey key )
{
	char *name;

	switch(key)
	{
#if 1
		case SDLK_1:              name = "number 1";            break;
		case SDLK_2:              name = "number 2";            break;
		case SDLK_3:              name = "number 3";            break;
		case SDLK_4:              name = "number 4";            break;
		case SDLK_5:              name = "number 5";            break;
		case SDLK_6:              name = "number 6";            break;
		case SDLK_7:              name = "number 7";            break;
		case SDLK_8:              name = "number 8";            break;
		case SDLK_9:              name = "number 9";            break;
		case SDLK_0:              name = "number 0";            break;
		case SDLK_EXCLAIM:        name = "exclamation mark";    break;
		case SDLK_QUOTEDBL:       name = "double quote";        break;
		case SDLK_HASH:           name = "hash";                break;
		case SDLK_DOLLAR:         name = "dollar";              break;
		case SDLK_AMPERSAND:      name = "ampersand";           break;
		case SDLK_QUOTE:          name = "quote";               break;
		case SDLK_LEFTPAREN:      name = "left parenthesis";    break;
		case SDLK_RIGHTPAREN:     name = "right parenthesis";   break;
		case SDLK_ASTERISK:       name = "asterisk";            break;
		case SDLK_PLUS:           name = "plus";                break;
		case SDLK_MINUS:          name = "minus";               break;
		case SDLK_PERIOD:         name = "period";              break;
		case SDLK_COMMA:          name = "comma";               break;
		case SDLK_SLASH:          name = "slash";               break;
		case SDLK_SEMICOLON:      name = "semicolon";           break;
		case SDLK_LESS:           name = "less than";           break;
		case SDLK_EQUALS:         name = "equals";              break;
		case SDLK_GREATER:        name = "greater than";        break;
		case SDLK_QUESTION:       name = "question mark";       break;
		case SDLK_AT:             name = "at";                  break;
		case SDLK_LEFTBRACKET:    name = "left bracket";        break;
		case SDLK_BACKSLASH:      name = "backslash";           break;
		case SDLK_RIGHTBRACKET:   name = "right bracket";       break;
		case SDLK_CARET:          name = "caret";               break;
		case SDLK_UNDERSCORE:     name = "underscore";          break;
		case SDLK_BACKQUOTE:      name = "backquote";           break;
		case SDLK_KP1:            name = "keypad 1";            break;
		case SDLK_KP2:            name = "keypad 2";            break;
		case SDLK_KP3:            name = "keypad 3";            break;
		case SDLK_KP4:            name = "keypad 4";            break;
		case SDLK_KP5:            name = "keypad 5";            break;
		case SDLK_KP6:            name = "keypad 6";            break;
		case SDLK_KP7:            name = "keypad 7";            break;
		case SDLK_KP8:            name = "keypad 8";            break;
		case SDLK_KP9:            name = "keypad 9";            break;
		case SDLK_KP0:            name = "keypad 0";            break;
		case SDLK_KP_PERIOD:      name = "keypad period";       break;
		case SDLK_KP_DIVIDE:      name = "keypad divide";       break;
		case SDLK_KP_MULTIPLY:    name = "keypad multiply";     break;
		case SDLK_KP_MINUS:       name = "keypad minus";        break;
		case SDLK_KP_PLUS:        name = "keypad plus";         break;
		case SDLK_KP_EQUALS:      name = "keypad equals";       break;
		case SDLK_KP_ENTER:       name = "keypad enter";        break;
#endif
		default:                  name = SDL_GetKeyName(key);   break;
	}

	return sanitized_symbol( name );
}



/* Convert an OR'd list of KMODs into a Ruby array of symbols. */
VALUE rg_convert_keymods2( SDLMod mods )
{
  VALUE array;

  array = rb_ary_new();
  if(mods != 0)
  {
    /* KEY MODIFIER SYMBOL */
    if(mods & KMOD_LSHIFT) rb_ary_push(array, make_symbol( "left_shift"  ));
    if(mods & KMOD_RSHIFT) rb_ary_push(array, make_symbol( "right_shift" ));
    if(mods & KMOD_LCTRL)  rb_ary_push(array, make_symbol( "left_ctrl"   ));
    if(mods & KMOD_RCTRL)  rb_ary_push(array, make_symbol( "right_ctrl"  ));
    if(mods & KMOD_LALT)   rb_ary_push(array, make_symbol( "left_alt"    ));
    if(mods & KMOD_RALT)   rb_ary_push(array, make_symbol( "right_alt"   ));
    if(mods & KMOD_LMETA)  rb_ary_push(array, make_symbol( "left_meta"   ));
    if(mods & KMOD_RMETA)  rb_ary_push(array, make_symbol( "right_meta"  ));
    if(mods & KMOD_NUM)    rb_ary_push(array, make_symbol( "numlock"     ));
    if(mods & KMOD_CAPS)   rb_ary_push(array, make_symbol( "capslock"    ));
    if(mods & KMOD_MODE)   rb_ary_push(array, make_symbol( "mode"        ));
  }
  return array;
}



/* Convert a unicode char into a UTF8 ruby byte-string. */
VALUE rg_convert_unicode2( Uint16 unicode )
{
  if( unicode > 0 )
  {
    char str[32];
    snprintf(str, 32, "[%d].pack('U')", unicode);

    return rb_eval_string( str );
  }
  else
  {
    return rb_str_new("", 0);
  }
}



/*
 * Convert SDL's keyboard events into KeyPressed / KeyReleased.
 *
 */
VALUE rg_convert_keyboardevent( SDL_Event ev )
{
  VALUE key  = rg_convert_key_symbol2( ev.key.keysym.sym );
  VALUE mods = rg_convert_keymods2(    ev.key.keysym.mod );

  switch( ev.key.state )
  {
    case SDL_PRESSED: {
      VALUE unicode = rg_convert_unicode2( ev.key.keysym.unicode );
      VALUE args[] = { key, mods, unicode };

      return rg_make_rbevent( "KeyPressed", 3, args);
    }

    case SDL_RELEASED: {
      VALUE args[] = { key, mods };

      return rg_make_rbevent( "KeyReleased", 2, args );
    }

    default:
      rb_raise(eSDLError, 
               "unknown keyboard event state %d. This is a bug in Rubygame.",
               ev.active.state);
  }
}





/*
 * Return a descriptive symbol for the given mouse button.
 * e.g. :mouse_left, :mouse_wheel_up, etc.
 *
 */
VALUE rg_convert_mouse_symbol2( Uint8 button )
{
	switch( button )
	{
		case SDL_BUTTON_LEFT:
			return make_symbol("mouse_left");
		case SDL_BUTTON_MIDDLE:
			return make_symbol("mouse_middle");
		case SDL_BUTTON_RIGHT:
			return make_symbol("mouse_right");
		case SDL_BUTTON_WHEELUP:
			return make_symbol("mouse_wheel_up");
		case SDL_BUTTON_WHEELDOWN:
			return make_symbol("mouse_wheel_down");
		default: {
			int size = 32;
			char *name = (char *)malloc(size);
			snprintf( name, size, "mouse_%d", button );
			return make_symbol(name);
		}
	}
}



/*
 * Convert SDL's mouse click events into MousePressed / MouseReleased.
 *
 */
VALUE rg_convert_mouseclickevent( SDL_Event ev )
{

  VALUE button = rg_convert_mouse_symbol2( ev.button.button );

  VALUE pos = rb_ary_new();
  rb_ary_push( pos, UINT2NUM( ev.button.x ) );
  rb_ary_push( pos, UINT2NUM( ev.button.y ) );

  VALUE args[] = { pos, button };


  switch( ev.button.state )
  {
    case SDL_PRESSED:
      return rg_make_rbevent( "MousePressed", 2, args);

    case SDL_RELEASED:
      return rg_make_rbevent( "MouseReleased", 2, args );

    default:
      rb_raise(eSDLError, 
               "unknown mouse event state %d. This is a bug in Rubygame.",
               ev.active.state);
  }

}



/*
 * Convert a button state into a list of mouse button symbols.
 *
 */
VALUE rg_convert_mousebuttons2( Uint8 state )
{
  VALUE buttons;

  buttons = rb_ary_new();
  if(state & SDL_BUTTON(SDL_BUTTON_LEFT))
    rb_ary_push(buttons, make_symbol("mouse_left"));
  if(state & SDL_BUTTON(SDL_BUTTON_MIDDLE))
    rb_ary_push(buttons, make_symbol("mouse_middle"));
  if(state & SDL_BUTTON(SDL_BUTTON_RIGHT))
    rb_ary_push(buttons, make_symbol("mouse_right"));
  if(state & SDL_BUTTON(SDL_BUTTON_WHEELUP))
    rb_ary_push(buttons, make_symbol("mouse_wheel_up"));
  if(state & SDL_BUTTON(SDL_BUTTON_WHEELDOWN))
    rb_ary_push(buttons, make_symbol("mouse_wheel_down"));
  return buttons;
}


/*
 * Convert SDL's mouse motion events into MouseMoved
 *
 */
VALUE rg_convert_mousemotionevent( SDL_Event ev )
{

  VALUE buttons = rg_convert_mousebuttons2( ev.motion.state );


  VALUE pos = rb_ary_new();
  rb_ary_push( pos, UINT2NUM( ev.motion.x ) );
  rb_ary_push( pos, UINT2NUM( ev.motion.y ) );


  VALUE rel = rb_ary_new();
  rb_ary_push( rel, INT2NUM( ev.motion.xrel ) );
  rb_ary_push( rel, INT2NUM( ev.motion.yrel ) );


  VALUE args[] = { pos, rel, buttons };

  return rg_make_rbevent( "MouseMoved", 3, args);

}




/*
 * Convert SDL's resize events into WindowResized
 *
 */
VALUE rg_convert_resizeevent( SDL_Event ev )
{

  VALUE size = rb_ary_new();
  rb_ary_push( size, UINT2NUM( ev.resize.w ) );
  rb_ary_push( size, UINT2NUM( ev.resize.h ) );

  VALUE args[] = { size };

  return rg_make_rbevent( "WindowResized", 1, args);

}




/*
 * Convert SDL's quit event into QuitRequested
 *
 */
VALUE rg_convert_quitevent( SDL_Event ev )
{
  return rg_make_rbevent( "QuitRequested", 0, (VALUE *)NULL );
}




/*--
 *
 *  call-seq:
 *    rg_convert_sdlevent2( SDL_Event )  ->  VALUE rubygame_event
 *
 *  Converts an SDL_Event (C type) into a Rubygame event of the corresponding
 *  class.
 *
 *++
 */

VALUE rg_convert_sdlevent2( SDL_Event ev )
{

  switch(ev.type)
  {

    case SDL_ACTIVEEVENT:
      return rg_convert_activeevent(ev);

    case SDL_VIDEOEXPOSE:
      return rg_convert_exposeevent(ev);

    case SDL_JOYAXISMOTION:
      return rg_convert_joyaxisevent(ev);

    case SDL_JOYBALLMOTION:
      return rg_convert_joyballevent(ev);

    case SDL_JOYBUTTONDOWN:
    case SDL_JOYBUTTONUP:
      return rg_convert_joybuttonevent(ev);

    case SDL_JOYHATMOTION:
      return rg_convert_joyhatevent(ev);

    case SDL_KEYDOWN:
    case SDL_KEYUP:
      return rg_convert_keyboardevent(ev);

    case SDL_MOUSEBUTTONDOWN:
    case SDL_MOUSEBUTTONUP:
      return rg_convert_mouseclickevent(ev);

    case SDL_MOUSEMOTION:
      return rg_convert_mousemotionevent(ev);

    case SDL_VIDEORESIZE:
      return rg_convert_resizeevent(ev);

    case SDL_QUIT:
      return rg_convert_quitevent(ev);

    default:
      rb_warn("Cannot convert unknown event type (%d).", ev.type);
      return Qnil;

  }

}




/* 
 *  call-seq:
 *    fetch_sdl_events -> [event, ...]
 *
 *  NOTE: This method converts the SDL events into the new-style event
 *  classes, located in the Rubygame::Events module. For converting to
 *  the older (deprecated) events, see Rubygame.fetch_sdl_events.
 *
 *  Retrieves all pending events from SDL's event stack and converts them
 *  into Rubygame event objects. Returns an Array of all the events, in
 *  the order they were read.
 *
 *  This method is used by the EventQueue class (among others), so
 *  don't call it if you are using any of Rubygame's event management
 *  classes (e.g. EventQueue)! If you do, they will not receive all
 *  the events, because some events will have been removed from SDL's
 *  event stack by this method.
 *
 *  However, if you aren't using EventQueue, you can safely use this method
 *  to make your own event management system.
 *
 */
VALUE rg_fetch_sdl_events2( VALUE module )
{
  SDL_Event event;
  VALUE events = rb_ary_new();
  VALUE thing;

  while(SDL_PollEvent(&event)==1) 
  {
    /* Either an event or array of zero or more events. */
    thing = rg_convert_sdlevent2( event );

    if( TYPE(thing) == T_ARRAY )
    {
      rb_ary_concat( events, thing );
    }
    else
    {
      rb_ary_push( events, thing );
    }
  }

  return events;
}




void Rubygame_Init_Event2()
{
#if 0
  mRubygame = rb_define_module("Rubygame");
#endif

  mEvents = rb_define_module_under( mRubygame, "Events" );

  rb_define_singleton_method( mEvents, "fetch_sdl_events",
                              rg_fetch_sdl_events2, 0);

}
