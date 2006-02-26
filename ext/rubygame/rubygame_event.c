/*--
 * Rubygame -- Ruby bindings to SDL to facilitate game creation
 * Copyright (C) 2004-2005  John 'jacius' Croisant
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

#include "rubygame.h"
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


/*--
 *
 *  Queue-related functions.
 *
 *++
 * */

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
    if(mods & KMOD_LSHIFT)   rb_ary_push(array,INT2NUM( SDLK_LSHIFT    ));
    if(mods & KMOD_RSHIFT)   rb_ary_push(array,INT2NUM( SDLK_RSHIFT    ));
    if(mods & KMOD_LCTRL)    rb_ary_push(array,INT2NUM( SDLK_LCTRL     ));
    if(mods & KMOD_RCTRL)    rb_ary_push(array,INT2NUM( SDLK_RCTRL     ));
    if(mods & KMOD_LALT)     rb_ary_push(array,INT2NUM( SDLK_LALT      ));
    if(mods & KMOD_RALT)     rb_ary_push(array,INT2NUM( SDLK_RALT      ));
    if(mods & KMOD_LMETA)    rb_ary_push(array,INT2NUM( SDLK_LMETA     ));
    if(mods & KMOD_RMETA)    rb_ary_push(array,INT2NUM( SDLK_RMETA     ));
    if(mods & KMOD_NUM)      rb_ary_push(array,INT2NUM( SDLK_NUMLOCK   ));
    if(mods & KMOD_CAPS)     rb_ary_push(array,INT2NUM( SDLK_CAPSLOCK  ));
    if(mods & KMOD_MODE)     rb_ary_push(array,INT2NUM( SDLK_MODE      ));
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
        INT2NUM(ev.key.keysym.sym),\
        /* convert OR'd list of mods into Array of keysyms */
        convert_keymod(ev.key.keysym.mod)\
        );
      break;
    case SDL_KEYUP: /* Same as SDL_KEYDOWN */
      /* KeyUpEvent.new(keysym,[mods,...]) */
      return rb_funcall(cKeyUpEvent,new,2,\
        INT2NUM(ev.key.keysym.sym),\
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

/*--
 *  The event documentation is in rubygame/lib/rubygame/event.rb
 *++
 */
void Rubygame_Init_Event()
{
#if 0
  /* Pretend to define Rubygame module, so RDoc knows about it: */
  mRubygame = rb_define_module("Rubygame");
#endif

  rb_define_singleton_method(mRubygame, "fetch_sdl_events",rbgm_fetchevents,0);

  /* Define a plethora of event types! */
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
}
