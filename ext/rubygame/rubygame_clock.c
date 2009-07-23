/*
 *  Functions for getting the time since initialization and delaying execution
 *  for a specified amounts of time.
 *
 * --
 *
 *  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004-2009  John Croisant
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * ++
 */

#include "rubygame_shared.h"
#include "rubygame_clock.h"

void Rubygame_Init_Clock();

VALUE cClock;

VALUE rbgm_clock_wait(int, VALUE*, VALUE);
VALUE rbgm_clock_delay(int, VALUE*, VALUE);
VALUE rbgm_clock_runtime(VALUE);


/* Initialize the SDL timer system, if it hasn't been already. */
void rg_init_sdl_timer()
{
  if(!SDL_WasInit(SDL_INIT_TIMER))
  {
    if(SDL_InitSubSystem(SDL_INIT_TIMER))
    {
      rb_raise(eSDLError,"Could not initialize timer system: %s",\
               SDL_GetError());
    }
  }
}


/*  NOTICE: if you change this value "officially", don't forget to update the
 *  documentation for rbgm_time_delay!!
 */
#define WORST_CLOCK_ACCURACY 12



/* Delays for the given amount of time, but possibly split into small
 * parts. Control is given to ruby between each part, so that other
 * threads can run.
 *
 * delay: How many milliseconds to delay.
 * nice:  If 1 (true), split the delay into smaller parts and allow
 *        other ruby threads to run between each part.
 *
 */
Uint32 rg_threaded_delay( Uint32 delay, int nice )
{
  Uint32 start;

  start = SDL_GetTicks();

  if( nice )
  {
    while( SDL_GetTicks() < start + delay )
    {
      SDL_Delay(1);
      rb_thread_schedule();       /* give control to ruby */
    }
  }
  else
  {
    SDL_Delay( delay );
  }

  return SDL_GetTicks() - start;
}


/*
 *  call-seq:
 *    Clock.wait( time, nice=false )  ->  Integer
 *
 *  time::  The target wait time, in milliseconds.
 *          (Non-negative Integer. Required.)
 *  nice::  If true, try to let other ruby threads run during the delay.
 *          (true or false. Optional.)
 *
 *  Returns:: The actual wait time, in milliseconds.
 *
 *  Pause the program for approximately +time+ milliseconds. Both this
 *  function and Clock.delay can be used to slow down the framerate so
 *  that the application doesn't use too much CPU time. See also
 *  Clock#tick for a good and easy way to limit the framerate.
 *
 *  The accuracy of this function depends on processor scheduling,
 *  which varies with operating system and hardware. The actual delay
 *  time may be up to 10ms longer than +time+. If you need more
 *  accuracy use Clock.delay, which is more accurate but uses slightly
 *  more CPU time.
 *
 *  If +nice+ is true, this function will try to allow other ruby
 *  threads to run during this function. Otherwise, other ruby threads
 *  will probably also be paused. Setting +nice+ to true is only
 *  useful if your application is multithreaded. It's safe (but
 *  pointless) to use this feature for single threaded applications.
 *
 *  The Rubygame timer system will be initialized when you call this
 *  function, if it has not been already. See Clock.runtime.
 *
 */
VALUE rbgm_clock_wait(int argc, VALUE *argv, VALUE module)
{
  rg_init_sdl_timer();

  VALUE  vtime, vnice;

  rb_scan_args(argc,argv,"11", &vtime, &vnice);

  int delay = NUM2INT(vtime);
  if( delay < 0 )
  {
    delay = 0;
  }

  int nice = (vnice == Qtrue) ? 1 : 0;

  return UINT2NUM( rg_threaded_delay(delay, nice) );
}



/*--
 *  From pygame code, with a few modifications:
 *    - takes 'accuracy' argument
 *    - ruby syntax for raising exceptions
 *    - uses rg_threaded_delay
 *++
 */
static Uint32 accurate_delay(Uint32 ticks, Uint32 accuracy, int nice)
{
  Uint32 funcstart;
  int delay;

  if( accuracy <= 0 )
  {
    /* delay with no accuracy is like wait (no busy waiting) */
    return rg_threaded_delay(ticks, nice);
  }

  funcstart = SDL_GetTicks();

  if(ticks >= accuracy)
  {
    delay = ticks - (ticks % accuracy);
    delay -= 2;   /* Aim low so we don't overshoot. */

    if(delay >= accuracy && delay > 0)
    {
      rg_threaded_delay(delay, nice);
    }
  }

  do{
    delay = ticks - (SDL_GetTicks() - funcstart);

    if( nice == 1 )
    {
      rb_thread_schedule();     /* give control to ruby */
    }
  }while(delay > 0);

  return SDL_GetTicks() - funcstart;	
}



/*
 *  call-seq:
 *    Clock.delay( time, gran=12, nice=false )  ->  Integer
 *
 *  time::  The target delay time, in milliseconds.
 *          (Non-negative integer. Required.)
 *  gran::  The assumed granularity (in ms) of the system clock.
 *          (Non-negative integer. Optional. Default: 12.)
 *  nice::  If true, try to let other ruby threads run during the delay.
 *          (true or false. Optional. Default: false.)
 *
 *  Returns:: The actual delay time, in milliseconds.
 *
 *  Pause the program for +time+ milliseconds. This function is more
 *  accurate than Clock.wait, but uses slightly more CPU time. Both
 *  this function and Clock.wait can be used to slow down the
 *  framerate so that the application doesn't use too much CPU time.
 *  See also Clock#tick for a good and easy way to limit the
 *  framerate.
 *
 *  This function uses "busy waiting" during the last part
 *  of the delay, for increased accuracy. The value of +gran+ affects
 *  how many milliseconds of the delay are spent in busy waiting, and thus
 *  how much CPU it uses. A smaller +gran+ value uses less CPU, but if
 *  it's smaller than the true system granularity, this function may
 *  delay a few milliseconds too long. The default value (12ms) is very
 *  safe, but a value of approximately 5ms would give a better balance
 *  between accuracy and CPU usage on most modern computers.
 *  A granularity of 0ms makes this method act the same as Clock.wait
 *  (i.e. no busy waiting at all, very low CPU usage).
 *
 *  If +nice+ is true, this function will try to allow other ruby
 *  threads to run during this function. Otherwise, other ruby threads
 *  will probably also be paused. Setting +nice+ to true is only
 *  useful if your application is multithreaded. It's safe (but
 *  pointless) to use this feature for single threaded applications.
 *
 *  The Rubygame timer system will be initialized when you call this
 *  function, if it has not been already. See Clock.runtime.
 *
 */
VALUE rbgm_clock_delay(int argc, VALUE *argv, VALUE module)
{
  rg_init_sdl_timer();

  VALUE vtime, vgran, vnice;

  rb_scan_args(argc,argv,"12", &vtime, &vgran, &vnice);

  int delay = NUM2INT(vtime);
  if( delay < 0 )
  {
    delay = 0;
  }

  int gran;
  if( RTEST(vgran) )
  {
    gran = NUM2UINT(vgran);
    if( gran < 0 )
    {
      gran = 0;
    }
  }
  else
  {
    gran = WORST_CLOCK_ACCURACY;
  }

  int nice = (vnice == Qtrue) ? 1 : 0;

  return UINT2NUM( accurate_delay(delay, gran, nice) );
}



/*
 *  call-seq:
 *    runtime  ->  Integer
 *
 *  Return the number of milliseconds since the Rubygame timer system
 *  was initialized.
 *
 *  The Rubygame timer system will be initialized when you call this function,
 *  if it has not been already.
 */
VALUE rbgm_clock_runtime( VALUE module )
{
  rg_init_sdl_timer();

  return UINT2NUM(SDL_GetTicks());
}



void Rubygame_Init_Clock()
{
#if 0
	mRubygame = rb_define_module("Rubygame");
#endif

  /* Clock class */
  cClock = rb_define_class_under(mRubygame, "Clock", rb_cObject);

  /* Clock class methods */
  rb_define_singleton_method(cClock, "oldwait",   rbgm_clock_wait,    -1);
  rb_define_singleton_method(cClock, "olddelay",  rbgm_clock_delay,   -1);
  rb_define_singleton_method(cClock, "oldruntime",rbgm_clock_runtime,  0);

  /* Clock instance methods are defined in clock.rb. */

}
