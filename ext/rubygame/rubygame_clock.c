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
VALUE rbgm_clock_getticks(VALUE);


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



/* Delays the given amount of time, but broken down into parts.
 * Control is yielded to ruby between each part, so that other
 * threads can run.
 *
 * delay: How many milliseconds to delay.
 * yield: How often (in ms) to give control to ruby.
 *        If -1, control is never given to ruby.
 *
 */
Uint32 rg_threaded_delay( Uint32 delay, int yield )
{
  Uint32 start;

  start = SDL_GetTicks();

  if( yield >= 0 )
  {
    while( delay - (SDL_GetTicks() - start) > yield )
    {
      if( yield > 0 )
      {
        SDL_Delay(yield);
      }
      rb_thread_schedule();       /* give control to ruby */
    }
  }

  int remainder = delay - (SDL_GetTicks() - start);
  if( remainder > 0 )
  {
    SDL_Delay( remainder );
  }

  return SDL_GetTicks() - start;
}


/*
 *  call-seq:
 *    Clock.wait( time, yield=false )  ->  Integer
 *
 *  time::    The target wait time, in milliseconds.
 *            (Non-negative Integer. Required.)
 *  yield::   How often (ms) to let other ruby threads run.
 *            If false (the default), other threads might stop
 *            until the delay is over.
 *            (Non-negative Integer or +false+. Optional.)
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
 *  If +yield+ is a non-negative number, this function will allow other
 *  ruby threads to run every +yield+ milliseconds. (A value of 0
 *  causes the function to continuously yield control until the time
 *  is over.) +yield+ is only useful if your application is
 *  multithreaded. It's safe (but pointless) to use this feature for
 *  single threaded applications.
 *
 *  The Rubygame timer system will be initialized when you call this
 *  function, if it has not been already. See Clock.runtime.
 *
 */
VALUE rbgm_clock_wait(int argc, VALUE *argv, VALUE module)
{
  rg_init_sdl_timer();

  VALUE  vtime, vyield;

  rb_scan_args(argc,argv,"11", &vtime, &vyield);

  Uint32 time = NUM2UINT(vtime);

  int yield = RTEST(vyield) ? NUM2UINT(vyield) : -1;

  return UINT2NUM( rg_threaded_delay(time, yield) );
}



/*--
 *  From pygame code, with a few modifications:
 *    - takes 'accuracy' argument
 *    - ruby syntax for raising exceptions
 *    - uses rg_threaded_delay
 *++
 */
static Uint32 accurate_delay(Uint32 ticks, Uint32 accuracy, int yield)
{
  Uint32 funcstart;
  int delay;

  if( accuracy <= 0 )
  {
    /* delay with no accuracy is like wait (no spinlock) */
    return rg_threaded_delay(ticks, yield);
  }

  funcstart = SDL_GetTicks();

  if(ticks >= accuracy)
  {
    delay = (ticks - 2) - (ticks % accuracy);
    if(delay >= accuracy)
    {
      rg_threaded_delay(delay, yield);
    }
  }
  do{
    delay = ticks - (SDL_GetTicks() - funcstart);	
  }while(delay > 0);

  return SDL_GetTicks() - funcstart;	
}



/*
 *  call-seq:
 *    Clock.delay( time, gran=12, yield=false )  ->  Integer
 *
 *  time::    The target delay time, in milliseconds.
 *            (Non-negative Integer. Required.)
 *  gran::    The assumed granularity (ms) of the system clock.
 *  yield::   How often (ms) to let other ruby threads run.
 *            If false (the default), other threads might stop
 *            until the delay is over.
 *            (Non-negative Integer or +false+. Optional.)
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
 *  This function uses "busy waiting" (spinlock) during the last part
 *  of the delay, for increased accuracy. The value of +gran+ affects
 *  how many milliseconds of the delay are spent in spinlock, and thus
 *  how much CPU it uses. A smaller +gran+ value uses less CPU, but if
 *  it's smaller than the true system granularity, this function may
 *  delay a few milliseconds too long. The default value (12ms) is very
 *  safe, but a value of approximately 5ms would give a better balance
 *  between accuracy and CPU usage on most modern computers.
 *  A granularity of 0ms makes this method act the same as Clock.wait
 *  (i.e. no spinlock at all, very low CPU usage).
 *
 *  If +yield+ is a non-negative number, this function will allow other
 *  ruby threads to run every +yield+ milliseconds. (A value of 0
 *  causes the function to continuously yield control until the time
 *  is over.) +yield+ is only useful if your application is
 *  multithreaded. It's safe (but pointless) to use this feature for
 *  single threaded applications.
 *
 *  The Rubygame timer system will be initialized when you call this
 *  function, if it has not been already. See Clock.runtime.
 *
 */
VALUE rbgm_clock_delay(int argc, VALUE *argv, VALUE module)
{
  rg_init_sdl_timer();

  VALUE vtime, vgran, vyield;

  rb_scan_args(argc,argv,"12", &vtime, &vgran, &vyield);

  Uint32 delay = NUM2UINT(vtime);

  Uint32 gran = RTEST(vgran) ? NUM2UINT(vgran) : WORST_CLOCK_ACCURACY;

  int yield = RTEST(vyield) ? NUM2UINT(vyield) : -1;

  return UINT2NUM( accurate_delay(delay, gran, yield) );
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
  rb_define_singleton_method(cClock, "wait",   rbgm_clock_wait,    -1);
  rb_define_singleton_method(cClock, "delay",  rbgm_clock_delay,   -1);
  rb_define_singleton_method(cClock, "runtime",rbgm_clock_runtime,  0);

  /* Clock instance methods are defined in clock.rb. */

}
