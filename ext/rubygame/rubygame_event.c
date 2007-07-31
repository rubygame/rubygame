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
VALUE lookup_keysymbol( SDLKey );
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
      rb_ary_push(array,rb_str_new2("mouse\0"));
    if(state & SDL_APPINPUTFOCUS)
      rb_ary_push(array,rb_str_new2("keyboard\0"));
    if(state & SDL_APPACTIVE)
      rb_ary_push(array,rb_str_new2("active\0"));
  }
  return array;
}

/* Convert an OR'd list of KMODs into a Ruby array of keysyms. */
VALUE convert_keymod( SDLMod mods )
{
  VALUE array;

  array = rb_ary_new();
  if(mods != 0)
  {
    /*        KEY MODIFIER                              KEY SYM */
    if(mods & KMOD_LSHIFT) rb_ary_push(array, lookup_keysymbol(SDLK_LSHIFT  ));
    if(mods & KMOD_RSHIFT) rb_ary_push(array, lookup_keysymbol(SDLK_RSHIFT  ));
    if(mods & KMOD_LCTRL)  rb_ary_push(array, lookup_keysymbol(SDLK_LCTRL   ));
    if(mods & KMOD_RCTRL)  rb_ary_push(array, lookup_keysymbol(SDLK_RCTRL   ));
    if(mods & KMOD_LALT)   rb_ary_push(array, lookup_keysymbol(SDLK_LALT    ));
    if(mods & KMOD_RALT)   rb_ary_push(array, lookup_keysymbol(SDLK_RALT    ));
    if(mods & KMOD_LMETA)  rb_ary_push(array, lookup_keysymbol(SDLK_LMETA   ));
    if(mods & KMOD_RMETA)  rb_ary_push(array, lookup_keysymbol(SDLK_RMETA   ));
    if(mods & KMOD_NUM)    rb_ary_push(array, lookup_keysymbol(SDLK_NUMLOCK ));
    if(mods & KMOD_CAPS)   rb_ary_push(array, lookup_keysymbol(SDLK_CAPSLOCK));
    if(mods & KMOD_MODE)   rb_ary_push(array, lookup_keysymbol(SDLK_MODE    ));
  }
  return array;
}

/* convert a button state into a list of mouse button sym */
VALUE convert_mousebuttons( Uint8 state )
{
  VALUE buttons;

  buttons = rb_ary_new();
  if(state & SDL_BUTTON(1))
    rb_ary_push(buttons, INT2NUM(SDL_BUTTON_LEFT));
  if(state & SDL_BUTTON(2))
    rb_ary_push(buttons, INT2NUM(SDL_BUTTON_MIDDLE));
  if(state & SDL_BUTTON(3))
    rb_ary_push(buttons, INT2NUM(SDL_BUTTON_RIGHT));
  return buttons;
}


#if 0
/* 
 * (This method is no longer used, as it depends on unicode enabled in SDL,
 * and doesn't work for KeyUpEvents)
 */
/* Convert a unicode char into an ascii string or hex if it is not ascii */
VALUE convert_unicode( Uint16 unicode )
{
  char *str;
  if( unicode < 0x80 && unicode > 0 )
    asprintf( &str,"%c\0",(char)unicode );
  else
    asprintf( &str,"0x%04X\0",unicode );
  return rb_str_new2(str);
}
#endif


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
      /* KeyDownEvent.new(keysym,[mods,...]) */
      return rb_funcall(cKeyDownEvent,new,2,\
        /* keysym, string version is set in new()*/
        lookup_keysymbol(ev.key.keysym.sym),\
        /* convert OR'd list of mods into Array of keysyms */
        convert_keymod(ev.key.keysym.mod)\
        );
      break;
    case SDL_KEYUP: /* Same as SDL_KEYDOWN */
      /* KeyUpEvent.new(keysym,[mods,...]) */
      return rb_funcall(cKeyUpEvent,new,2,\
        lookup_keysymbol(ev.key.keysym.sym),\
        convert_keymod(ev.key.keysym.mod));
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
        INT2NUM(ev.button.button));
      break;
    case SDL_MOUSEBUTTONUP:
      /* MouseUpEvent.new([x,y],button) */
      return rb_funcall(cMouseUpEvent,new,2,\
        rb_ary_new3(2,INT2NUM(ev.button.x),INT2NUM(ev.button.y)),\
        INT2NUM(ev.button.button));
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
ID rbgm_fetchevents(VALUE self)
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

VALUE lookup_keysymbol( SDLKey key )
{
	switch(key)
	{
		/* English Alphabet */
		case SDLK_a: return make_symbol("a");
		case SDLK_b: return make_symbol("b");
		case SDLK_c: return make_symbol("c");
		case SDLK_d: return make_symbol("d");
		case SDLK_e: return make_symbol("e");
		case SDLK_f: return make_symbol("f");
		case SDLK_g: return make_symbol("g");
		case SDLK_h: return make_symbol("h");
		case SDLK_i: return make_symbol("i");
		case SDLK_j: return make_symbol("j");
		case SDLK_k: return make_symbol("k");
		case SDLK_l: return make_symbol("l");
		case SDLK_m: return make_symbol("m");
		case SDLK_n: return make_symbol("n");
		case SDLK_o: return make_symbol("o");
		case SDLK_p: return make_symbol("p");
		case SDLK_q: return make_symbol("q");
		case SDLK_r: return make_symbol("r");
		case SDLK_s: return make_symbol("s");
		case SDLK_t: return make_symbol("t");
		case SDLK_u: return make_symbol("u");
		case SDLK_v: return make_symbol("v");
		case SDLK_w: return make_symbol("w");
		case SDLK_x: return make_symbol("x");
		case SDLK_y: return make_symbol("y");
		case SDLK_z: return make_symbol("z");


		/* Digits */
		case SDLK_0: return make_symbol("digit_0");
		case SDLK_1: return make_symbol("digit_1");
		case SDLK_2: return make_symbol("digit_2");
		case SDLK_3: return make_symbol("digit_3");
		case SDLK_4: return make_symbol("digit_4");
		case SDLK_5: return make_symbol("digit_5");
		case SDLK_6: return make_symbol("digit_6");
		case SDLK_7: return make_symbol("digit_7");
		case SDLK_8: return make_symbol("digit_8");
		case SDLK_9: return make_symbol("digit_9");


		/* Punctuation */
		case SDLK_TAB:          return make_symbol("tab");
		case SDLK_SPACE:        return make_symbol("space");
		case SDLK_RETURN:       return make_symbol("return");

		case SDLK_COMMA:        return make_symbol("comma");
		case SDLK_PERIOD:       return make_symbol("period");
		case SDLK_COLON:        return make_symbol("colon");
		case SDLK_SEMICOLON:    return make_symbol("semicolon");
		case SDLK_QUOTE:        return make_symbol("quote");
		case SDLK_QUOTEDBL:     return make_symbol("double_quote");

		case SDLK_BACKQUOTE:    return make_symbol("backquote");
		case SDLK_EXCLAIM:      return make_symbol("exclaim");
		case SDLK_AT:           return make_symbol("at");
		case SDLK_HASH:         return make_symbol("hash");
		case SDLK_DOLLAR:       return make_symbol("dollar");
		case SDLK_CARET:        return make_symbol("caret");
		case SDLK_AMPERSAND:    return make_symbol("ampersand");
		case SDLK_ASTERISK:     return make_symbol("asterisk");

		case SDLK_LEFTPAREN:    return make_symbol("left_paren");
		case SDLK_RIGHTPAREN:   return make_symbol("right_paren");
		case SDLK_LEFTBRACKET:  return make_symbol("left_bracket");
		case SDLK_RIGHTBRACKET: return make_symbol("right_bracket");

		case SDLK_LESS:         return make_symbol("less_than");
		case SDLK_GREATER:      return make_symbol("greater_than");
		case SDLK_EQUALS:       return make_symbol("equals");
		case SDLK_PLUS:         return make_symbol("plus");
		case SDLK_MINUS:        return make_symbol("minus");

		case SDLK_BACKSLASH:    return make_symbol("backslash");
		case SDLK_SLASH:        return make_symbol("slash");
		case SDLK_QUESTION:     return make_symbol("question");
		case SDLK_UNDERSCORE:   return make_symbol("underscore");

	
		/* International keyboard symbols */
		case SDLK_WORLD_0:  return make_symbol("world_0");
		case SDLK_WORLD_1:  return make_symbol("world_1");
		case SDLK_WORLD_2:  return make_symbol("world_2");
		case SDLK_WORLD_3:  return make_symbol("world_3");
		case SDLK_WORLD_4:  return make_symbol("world_4");
		case SDLK_WORLD_5:  return make_symbol("world_5");
		case SDLK_WORLD_6:  return make_symbol("world_6");
		case SDLK_WORLD_7:  return make_symbol("world_7");
		case SDLK_WORLD_8:  return make_symbol("world_8");
		case SDLK_WORLD_9:  return make_symbol("world_9");
		case SDLK_WORLD_10: return make_symbol("world_10");
		case SDLK_WORLD_11: return make_symbol("world_11");
		case SDLK_WORLD_12: return make_symbol("world_12");
		case SDLK_WORLD_13: return make_symbol("world_13");
		case SDLK_WORLD_14: return make_symbol("world_14");
		case SDLK_WORLD_15: return make_symbol("world_15");
		case SDLK_WORLD_16: return make_symbol("world_16");
		case SDLK_WORLD_17: return make_symbol("world_17");
		case SDLK_WORLD_18: return make_symbol("world_18");
		case SDLK_WORLD_19: return make_symbol("world_19");
		case SDLK_WORLD_20: return make_symbol("world_20");
		case SDLK_WORLD_21: return make_symbol("world_21");
		case SDLK_WORLD_22: return make_symbol("world_22");
		case SDLK_WORLD_23: return make_symbol("world_23");
		case SDLK_WORLD_24: return make_symbol("world_24");
		case SDLK_WORLD_25: return make_symbol("world_25");
		case SDLK_WORLD_26: return make_symbol("world_26");
		case SDLK_WORLD_27: return make_symbol("world_27");
		case SDLK_WORLD_28: return make_symbol("world_28");
		case SDLK_WORLD_29: return make_symbol("world_29");
		case SDLK_WORLD_30: return make_symbol("world_30");
		case SDLK_WORLD_31: return make_symbol("world_31");
		case SDLK_WORLD_32: return make_symbol("world_32");
		case SDLK_WORLD_33: return make_symbol("world_33");
		case SDLK_WORLD_34: return make_symbol("world_34");
		case SDLK_WORLD_35: return make_symbol("world_35");
		case SDLK_WORLD_36: return make_symbol("world_36");
		case SDLK_WORLD_37: return make_symbol("world_37");
		case SDLK_WORLD_38: return make_symbol("world_38");
		case SDLK_WORLD_39: return make_symbol("world_39");
		case SDLK_WORLD_40: return make_symbol("world_40");
		case SDLK_WORLD_41: return make_symbol("world_41");
		case SDLK_WORLD_42: return make_symbol("world_42");
		case SDLK_WORLD_43: return make_symbol("world_43");
		case SDLK_WORLD_44: return make_symbol("world_44");
		case SDLK_WORLD_45: return make_symbol("world_45");
		case SDLK_WORLD_46: return make_symbol("world_46");
		case SDLK_WORLD_47: return make_symbol("world_47");
		case SDLK_WORLD_48: return make_symbol("world_48");
		case SDLK_WORLD_49: return make_symbol("world_49");
		case SDLK_WORLD_50: return make_symbol("world_50");
		case SDLK_WORLD_51: return make_symbol("world_51");
		case SDLK_WORLD_52: return make_symbol("world_52");
		case SDLK_WORLD_53: return make_symbol("world_53");
		case SDLK_WORLD_54: return make_symbol("world_54");
		case SDLK_WORLD_55: return make_symbol("world_55");
		case SDLK_WORLD_56: return make_symbol("world_56");
		case SDLK_WORLD_57: return make_symbol("world_57");
		case SDLK_WORLD_58: return make_symbol("world_58");
		case SDLK_WORLD_59: return make_symbol("world_59");
		case SDLK_WORLD_60: return make_symbol("world_60");
		case SDLK_WORLD_61: return make_symbol("world_61");
		case SDLK_WORLD_62: return make_symbol("world_62");
		case SDLK_WORLD_63: return make_symbol("world_63");
		case SDLK_WORLD_64: return make_symbol("world_64");
		case SDLK_WORLD_65: return make_symbol("world_65");
		case SDLK_WORLD_66: return make_symbol("world_66");
		case SDLK_WORLD_67: return make_symbol("world_67");
		case SDLK_WORLD_68: return make_symbol("world_68");
		case SDLK_WORLD_69: return make_symbol("world_69");
		case SDLK_WORLD_70: return make_symbol("world_70");
		case SDLK_WORLD_71: return make_symbol("world_71");
		case SDLK_WORLD_72: return make_symbol("world_72");
		case SDLK_WORLD_73: return make_symbol("world_73");
		case SDLK_WORLD_74: return make_symbol("world_74");
		case SDLK_WORLD_75: return make_symbol("world_75");
		case SDLK_WORLD_76: return make_symbol("world_76");
		case SDLK_WORLD_77: return make_symbol("world_77");
		case SDLK_WORLD_78: return make_symbol("world_78");
		case SDLK_WORLD_79: return make_symbol("world_79");
		case SDLK_WORLD_80: return make_symbol("world_80");
		case SDLK_WORLD_81: return make_symbol("world_81");
		case SDLK_WORLD_82: return make_symbol("world_82");
		case SDLK_WORLD_83: return make_symbol("world_83");
		case SDLK_WORLD_84: return make_symbol("world_84");
		case SDLK_WORLD_85: return make_symbol("world_85");
		case SDLK_WORLD_86: return make_symbol("world_86");
		case SDLK_WORLD_87: return make_symbol("world_87");
		case SDLK_WORLD_88: return make_symbol("world_88");
		case SDLK_WORLD_89: return make_symbol("world_89");
		case SDLK_WORLD_90: return make_symbol("world_90");
		case SDLK_WORLD_91: return make_symbol("world_91");
		case SDLK_WORLD_92: return make_symbol("world_92");
		case SDLK_WORLD_93: return make_symbol("world_93");
		case SDLK_WORLD_94: return make_symbol("world_94");
		case SDLK_WORLD_95: return make_symbol("world_95");

	
		/* Numeric keypad symbols */
		case SDLK_KP0:         return make_symbol("keypad_0");
		case SDLK_KP1:         return make_symbol("keypad_1");
		case SDLK_KP2:         return make_symbol("keypad_2");
		case SDLK_KP3:         return make_symbol("keypad_3");
		case SDLK_KP4:         return make_symbol("keypad_4");
		case SDLK_KP5:         return make_symbol("keypad_5");
		case SDLK_KP6:         return make_symbol("keypad_6");
		case SDLK_KP7:         return make_symbol("keypad_7");
		case SDLK_KP8:         return make_symbol("keypad_8");
		case SDLK_KP9:         return make_symbol("keypad_9");
		case SDLK_KP_PERIOD:   return make_symbol("keypad_period");
		case SDLK_KP_DIVIDE:   return make_symbol("keypad_divide");
		case SDLK_KP_MULTIPLY: return make_symbol("keypad_multiply");
		case SDLK_KP_MINUS:    return make_symbol("keypad_minus");
		case SDLK_KP_PLUS:     return make_symbol("keypad_plus");
		case SDLK_KP_ENTER:    return make_symbol("keypad_enter");
		case SDLK_KP_EQUALS:   return make_symbol("keypad_equals");

	
		/* Arrows + Home/End pad */
		case SDLK_UP:       return make_symbol("up");
		case SDLK_DOWN:     return make_symbol("down");
		case SDLK_RIGHT:    return make_symbol("right");
		case SDLK_LEFT:     return make_symbol("left");
		case SDLK_INSERT:   return make_symbol("insert");
		case SDLK_HOME:     return make_symbol("home");
		case SDLK_END:      return make_symbol("end");
		case SDLK_PAGEUP:   return make_symbol("pageup");
		case SDLK_PAGEDOWN: return make_symbol("pagedown");

	
		/* Function keys */
		case SDLK_F1:  return make_symbol("f1");
		case SDLK_F2:  return make_symbol("f2");
		case SDLK_F3:  return make_symbol("f3");
		case SDLK_F4:  return make_symbol("f4");
		case SDLK_F5:  return make_symbol("f5");
		case SDLK_F6:  return make_symbol("f6");
		case SDLK_F7:  return make_symbol("f7");
		case SDLK_F8:  return make_symbol("f8");
		case SDLK_F9:  return make_symbol("f9");
		case SDLK_F10: return make_symbol("f10");
		case SDLK_F11: return make_symbol("f11");
		case SDLK_F12: return make_symbol("f12");
		case SDLK_F13: return make_symbol("f13");
		case SDLK_F14: return make_symbol("f14");
		case SDLK_F15: return make_symbol("f15");

	
		/* Key state modifier keys */
		case SDLK_NUMLOCK:   return make_symbol("numlock");
		case SDLK_CAPSLOCK:  return make_symbol("capslock");
		case SDLK_SCROLLOCK: return make_symbol("scrollock");
		case SDLK_MODE:      return make_symbol("mode");

		case SDLK_RSHIFT:    return make_symbol("right_shift");
		case SDLK_RCTRL:     return make_symbol("right_ctrl");
		case SDLK_RALT:      return make_symbol("right_alt");
		case SDLK_RMETA:     return make_symbol("right_meta");
		case SDLK_RSUPER:    return make_symbol("right_super");

		case SDLK_LSHIFT:    return make_symbol("left_shift");
		case SDLK_LCTRL:     return make_symbol("left_ctrl");
		case SDLK_LALT:      return make_symbol("left_alt");
		case SDLK_LMETA:     return make_symbol("left_meta");
		case SDLK_LSUPER:    return make_symbol("left_super");


		/* Miscellaneous keys */
		case SDLK_ESCAPE:    return make_symbol("escape");
		case SDLK_BACKSPACE: return make_symbol("backspace");
		case SDLK_DELETE:    return make_symbol("delete");
		case SDLK_CLEAR:     return make_symbol("clear");
		case SDLK_HELP:      return make_symbol("help");
		case SDLK_PRINT:     return make_symbol("print");
		case SDLK_SYSREQ:    return make_symbol("sysreq");
		case SDLK_BREAK:     return make_symbol("break");
		case SDLK_MENU:      return make_symbol("menu");
		case SDLK_POWER:     return make_symbol("power");
		case SDLK_EURO:      return make_symbol("euro");


		/* Unknown key */
		case SDLK_UNKNOWN:
		default:
			return make_symbol("unknown");
	}
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

	
	/* Mouse constants */
	rb_define_const(mRubygame,"MOUSE_LEFT",UINT2NUM(SDL_BUTTON_LEFT));
	rb_define_const(mRubygame,"MOUSE_MIDDLE",UINT2NUM(SDL_BUTTON_MIDDLE));
	rb_define_const(mRubygame,"MOUSE_RIGHT",UINT2NUM(SDL_BUTTON_RIGHT));
}

