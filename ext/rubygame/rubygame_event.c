/*--
 * Rubygame -- Ruby bindings to SDL to facilitate game creation
 * Copyright (C) 2004-2007  John Croisant
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
#include "rubygame_event.h"

void Rubygame_Init_Event();
VALUE cEvent;
VALUE cActiveEvent;
VALUE cKeyDownEvent;
VALUE cKeyUpEvent;
VALUE cMouseMotionEvent;
VALUE cMouseDownEvent;
VALUE cMouseUpEvent;
VALUE cJoyAxisEvent;
VALUE cJoyBallEvent;
VALUE cJoyHatEvent;
VALUE cJoyDownEvent;
VALUE cJoyUpEvent;
VALUE cQuitEvent;
VALUE cSysWMEvent;
VALUE cResizeEvent;
VALUE cExposeEvent;
VALUE convert_active(Uint8);
VALUE convert_keymod(SDLMod);
VALUE convert_mousebuttons(Uint8);
VALUE rbgm_convert_sdlevent(SDL_Event);
VALUE rbgm_queue_getsdl(VALUE);

/*
 *--
 *
 *  SDL Type             Ruby type         Ruby new() args
 * ---------------------------------------------------------------------------
 *  SDL_ACTIVEEVENT      ActiveEvent       gain,state
 *  SDL_KEYDOWN          KeyDownEvent      key,[mods,...]
 *  SDL_KEYUP            KeyUpEvent        key,[mods,...]
 *  SDL_MOUSEMOTION      MouseMotionEvent  [x,y],[xrel,yrel],[buttons,...]
 *  SDL_MOUSEBUTTONDOWN  MouseDownEvent    [x,y],button
 *  SDL_MOUSEBUTTONUP    MouseUpEvent      [x,y],button
 *  SDL_JOYAXISMOTION    JoyAxisEvent      joy,axis,value
 *  SDL_JOYBALLMOTION    JoyBallEvent      joy,ball,[xrel,yrel]
 *  SDL_JOYHATMOTION     JoyHatEvent       joy,hat,value
 *  SDL_JOYBUTTONDOWN    JoyDownEvent      joy,button
 *  SDL_JOYBUTTONUP      JoyUpEvent        joy,button
 *  SDL_VIDEORESIZE      VideoResizeEvent  [w,h]
 *  SDL_QUIT             QuitEvent         (no args)
 * --------------------------------------------------------------------------
 *
 *++
 */

/* Convert info about whether the window has mouse/keyboard focus */
VALUE convert_active( Uint8 state )
{
  VALUE array;

  array = rb_ary_new();
  if(state != 0)
  {
    if(state & SDL_APPMOUSEFOCUS)
      rb_ary_push(array, make_symbol("mouse") );
    if(state & SDL_APPINPUTFOCUS)
      rb_ary_push(array, make_symbol("keyboard") );
    if(state & SDL_APPACTIVE)
      rb_ary_push(array, make_symbol("active") );
  }
  return array;
}

/* Convert an OR'd list of KMODs into a Ruby array of symbols. */
VALUE convert_keymod( SDLMod mods )
{
  VALUE array;

  array = rb_ary_new();
  if(mods != 0)
  {
    /*        KEY MODIFIER                                   SYMBOL */
    if(mods & KMOD_LSHIFT)   rb_ary_push(array, make_symbol( "left_shift"  ));
    if(mods & KMOD_RSHIFT)   rb_ary_push(array, make_symbol( "right_shift" ));
    if(mods & KMOD_LCTRL)    rb_ary_push(array, make_symbol( "left_ctrl"   ));
    if(mods & KMOD_RCTRL)    rb_ary_push(array, make_symbol( "right_ctrl"  ));
    if(mods & KMOD_LALT)     rb_ary_push(array, make_symbol( "left_alt"    ));
    if(mods & KMOD_RALT)     rb_ary_push(array, make_symbol( "right_alt"   ));
    if(mods & KMOD_LMETA)    rb_ary_push(array, make_symbol( "left_meta"   ));
    if(mods & KMOD_RMETA)    rb_ary_push(array, make_symbol( "right_meta"  ));
    if(mods & KMOD_NUM)      rb_ary_push(array, make_symbol( "numlock"     ));
    if(mods & KMOD_CAPS)     rb_ary_push(array, make_symbol( "capslock"    ));
    if(mods & KMOD_MODE)     rb_ary_push(array, make_symbol( "mode"        ));
  }
  return array;
}



/* Returns a sanitized symbol for the given key. */
VALUE key_symbol( SDLKey key )
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
		case SDLK_KP_ENTER:       name = "keypad_enter";        break;
#endif
		default:                     name = SDL_GetKeyName(key);     break;
	}

	return sanitized_symbol( name );
}

/* Return a descriptive symbol for the given mouse button.
 * e.g. :mouse_left, :mouse_wheel_up, etc.
 */
VALUE mouse_symbol( Uint8 button )
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
			int size = 8;
			char *name = (char *)malloc(size);
			snprintf( name, size, "mouse_%d", button );
			return make_symbol(name);
		}
	}
}

/* convert a button state into a list of mouse button sym */
VALUE convert_mousebuttons( Uint8 state )
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


/* Convert a unicode char into a UTF8 string. */
VALUE convert_unicode( Uint16 unicode )
{
	
  /* asprintf is a glibc extention and doesn't seem to want to play nice on 
   * windows.  Until a more capable C programmer than me comes along and fixes
   * it, this workaround should hopefully do the trick -- Roger */
  /* char *str;
	 asprintf( &str, "[%d].pack('U')", unicode ); */

  char str[512]; /* Safe until the day someone makes a 513-byte unicode char */
  snprintf(str, 511, "[%d].pack('U')", unicode);
  str[511] = '\0'; /* Ensure null termination */

  return rb_eval_string( str );
}


/*--
 *
 *  Queue-related functions.
 *
 *++
 */

/*--
 *
 *  call-seq:
 *    rbgm_convert_sdlevent( SDL_Event )  ->  Rubygame_Event
 *
 *  Converts an SDL_Event (C type) into a Rubygame Event of the corresponding
 *  class.
 *
 *++
 */

VALUE rbgm_convert_sdlevent( SDL_Event ev )
{
  VALUE new = rb_intern("new"); /* to call new() for any class */

  /*
  switch for each particular type, call new() for the corresponding
  Rubygame class, with the proper arguments.
  */
  switch(ev.type)
  {
    case SDL_ACTIVEEVENT:
      /* ActiveEvent.new(gain,state) */
      return rb_funcall(cActiveEvent,new,2,\
        ev.active.gain, convert_active(ev.active.state));
      break;


    case SDL_KEYDOWN:
      /* KeyDownEvent.new( key, mods=[], unicode=nil ) */
      return rb_funcall(cKeyDownEvent, new,
                        3,
                        key_symbol(      ev.key.keysym.sym     ),
                        convert_keymod(  ev.key.keysym.mod     ),
                        convert_unicode( ev.key.keysym.unicode ) );
      break;

    case SDL_KEYUP:
      /* KeyUpEvent.new( key, mods=[], unicode=nil ) */
      return rb_funcall(cKeyUpEvent, new,
                        3,
                        key_symbol(      ev.key.keysym.sym     ),
                        convert_keymod(  ev.key.keysym.mod     ),
                        convert_unicode( ev.key.keysym.unicode ) );
      break;


    case SDL_MOUSEMOTION:;
      /* MouseMotionEvent.new([x,y],[xrel,yrel],[buttons,...]) */
      return rb_funcall(cMouseMotionEvent,new,3,\
        rb_ary_new3(2,INT2NUM(ev.motion.x),INT2NUM(ev.motion.y)),\
        rb_ary_new3(2,INT2NUM(ev.motion.xrel),\
          INT2NUM(ev.motion.yrel)),\
        /* Prepare list of buttons from OR'd list */
        convert_mousebuttons(ev.motion.state));
      break;

    case SDL_MOUSEBUTTONDOWN:
      /* MouseDownEvent.new([x,y],button) */
      return rb_funcall(cMouseDownEvent,new,2,\
        rb_ary_new3(2,INT2NUM(ev.button.x),INT2NUM(ev.button.y)),\
        mouse_symbol(ev.button.button));
      break;

    case SDL_MOUSEBUTTONUP:
      /* MouseUpEvent.new([x,y],button) */
      return rb_funcall(cMouseUpEvent,new,2,\
        rb_ary_new3(2,INT2NUM(ev.button.x),INT2NUM(ev.button.y)),\
        mouse_symbol(ev.button.button));
      break;


    case SDL_JOYAXISMOTION:
      /* JoyAxisEvent.new(joy,axis,value) */
      /* Eventually, joy might be a reference to a Joystick instance? */
      return rb_funcall(cJoyAxisEvent,new,3,\
        INT2NUM(ev.jaxis.which),INT2NUM(ev.jaxis.axis),\
        INT2NUM(ev.jaxis.value));
      break;
    case SDL_JOYBALLMOTION:
      /* JoyBallEvent.new(joy,ball,) */
      /* Eventually, joy might be a reference to a Joystick instance? */
      return rb_funcall(cJoyBallEvent,new,3,\
        INT2NUM(ev.jball.which),INT2NUM(ev.jball.ball),
        rb_ary_new3(2,INT2NUM(ev.jball.xrel),INT2NUM(ev.jball.yrel)));
      break;
    case SDL_JOYHATMOTION:
      /* JoyHatEvent.new(joy,hat,value) */
      /* Eventually, joy might be a reference to a Joystick instance? */
      return rb_funcall(cJoyHatEvent,new,3,\
        INT2NUM(ev.jhat.which),INT2NUM(ev.jhat.hat),\
        INT2NUM(ev.jhat.value));
      break;
    case SDL_JOYBUTTONDOWN:
      /* JoyDownEvent.new(joy,button) */
      /* Eventually, joy might be a reference to a Joystick instance? */
      return rb_funcall(cJoyDownEvent,new,2,\
        INT2NUM(ev.jbutton.which),INT2NUM(ev.jbutton.button));
      break;
    case SDL_JOYBUTTONUP:
      /* JoyUp.new(joy,button) */
      /* Eventually, joy might be a reference to a Joystick instance? */
      return rb_funcall(cJoyUpEvent,new,2,\
        INT2NUM(ev.jbutton.which),INT2NUM(ev.jbutton.button));
      break;
    case SDL_VIDEORESIZE:
      /* ResizeEvent.new([w,h]) */
      return rb_funcall(cResizeEvent,new,1,\
        rb_ary_new3(2,INT2NUM(ev.resize.w),INT2NUM(ev.resize.h)));
      break;
    case SDL_VIDEOEXPOSE:
      /* ExposeEvent.new( ) */
      return rb_funcall(cExposeEvent,new,0);
      break;
    case SDL_QUIT:
      /* QuitEvent.new( ) */
      return rb_funcall(cQuitEvent,new,0);
      break;
    default:
      rb_warn("Cannot convert unknown event type (%d).", ev.type);
      return Qnil;
      break;
  }
  return Qnil; /* should never get here */
}

/* 
 *  call-seq:
 *    fetch_sdl_events -> [Event, ...]
 *
 *  Retrieves all pending events from SDL's event stack and converts them
 *  into Rubygame Event objects. Returns an Array of all the events, in
 *  the order they were read.
 *
 *  This method is used by the EventQueue class, so don't call it if you are
 *  using EventQueue for event management! If you do, the EventQueue will not
 *  receive all the events, because they will have been removed from SDL's
 *  event stack by this method.
 *
 *  However, if you aren't using EventQueue, you can safely use this method
 *  to make your own event management system.
 */
VALUE rbgm_fetchevents(VALUE self)
{
  SDL_Event event;
  VALUE event_array;

  event_array = rb_ary_new();
  /* put each in *event until no pending events are in SDL's queue */
  /* for now, we don't care what type the event in. Filtering comes later */
  while(SDL_PollEvent(&event)==1) 
  {
    rb_ary_push(event_array, rbgm_convert_sdlevent(event) );
  }
  return event_array;
}

/* 
 *  call-seq:
 *    enable_key_repeat -> nil
 *
 *  By default, when a key is pressed down, only one keydown event happens.
 *  Using this function, you can change the behavior.  If a key is held
 *  down more than delay milliseconds, a keyup and keydown event for that key
 *  will fire every interval milliseconds.  The module constants
 *  DEFAULT_KEY_REPEAT_DELAY and DEFAULT_KEY_REPEAT_INTERVAL are available as
 *  good values. To re-enable the default behavior,
 *  use zero for both arguments.
 */
VALUE rbgm_enableKeyRepeat(VALUE self, VALUE delay, VALUE interval)
{
	int cDelay = NUM2INT(delay);
	int cInterval = NUM2INT(interval);
	int res = SDL_EnableKeyRepeat(cDelay, cInterval);
	if (res != 0) {
		rb_raise(eSDLError, "SDL_EnableKeyRepeat failure!");
	}
	return Qnil;
}

/*
 *--
 *  The event documentation is in rubygame/lib/rubygame/event.rb
 *++
 */
void Rubygame_Init_Event()
{
#if 0
  mRubygame = rb_define_module("Rubygame");
#endif

  rb_define_singleton_method(mRubygame, "fetch_sdl_events",rbgm_fetchevents,0);
  rb_define_singleton_method(mRubygame, "enable_key_repeat",
  	rbgm_enableKeyRepeat,2);

  cEvent =        rb_define_class_under(mRubygame,"Event",rb_cObject);
  cActiveEvent =  rb_define_class_under(mRubygame,"ActiveEvent",cEvent);
  cKeyDownEvent = rb_define_class_under(mRubygame,"KeyDownEvent",cEvent);
  cKeyUpEvent =   rb_define_class_under(mRubygame,"KeyUpEvent",cEvent);
  cMouseMotionEvent = rb_define_class_under(mRubygame,"MouseMotionEvent",\
                                            cEvent);
  cMouseDownEvent = rb_define_class_under(mRubygame,"MouseDownEvent",cEvent);
  cMouseUpEvent = rb_define_class_under(mRubygame,"MouseUpEvent",cEvent);
  cJoyAxisEvent = rb_define_class_under(mRubygame,"JoyAxisEvent",cEvent);
  cJoyBallEvent = rb_define_class_under(mRubygame,"JoyBallEvent",cEvent);
  cJoyHatEvent =  rb_define_class_under(mRubygame,"JoyHatEvent",cEvent);
  cJoyDownEvent = rb_define_class_under(mRubygame,"JoyDownEvent",cEvent);
  cJoyUpEvent =   rb_define_class_under(mRubygame,"JoyUpEvent",cEvent);
  cQuitEvent =    rb_define_class_under(mRubygame,"QuitEvent",cEvent);
  cResizeEvent =  rb_define_class_under(mRubygame,"ResizeEvent",cEvent);
  cExposeEvent =  rb_define_class_under(mRubygame,"ExposeEvent",cEvent);

	/* Constants for key repeating */
	rb_define_const(mRubygame,"DEFAULT_KEY_REPEAT_DELAY",
		UINT2NUM(SDL_DEFAULT_REPEAT_DELAY));
	rb_define_const(mRubygame,"DEFAULT_KEY_REPEAT_INTERVAL",
		UINT2NUM(SDL_DEFAULT_REPEAT_INTERVAL));

	/* Joystick constants */	
	rb_define_const(mRubygame,"HAT_CENTERED",UINT2NUM(SDL_HAT_CENTERED));
	rb_define_const(mRubygame,"HAT_UP",UINT2NUM(SDL_HAT_UP));
	rb_define_const(mRubygame,"HAT_RIGHT",UINT2NUM(SDL_HAT_RIGHT));
	rb_define_const(mRubygame,"HAT_DOWN",UINT2NUM(SDL_HAT_DOWN));
	rb_define_const(mRubygame,"HAT_LEFT",UINT2NUM(SDL_HAT_LEFT));
	rb_define_const(mRubygame,"HAT_RIGHTUP",UINT2NUM(SDL_HAT_RIGHTUP));
	rb_define_const(mRubygame,"HAT_RIGHTDOWN",UINT2NUM(SDL_HAT_RIGHTDOWN));
	rb_define_const(mRubygame,"HAT_LEFTUP",UINT2NUM(SDL_HAT_LEFTUP));
	rb_define_const(mRubygame,"HAT_LEFTDOWN",UINT2NUM(SDL_HAT_LEFTDOWN));

}
