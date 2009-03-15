/*
 *  Functions for getting the time since initialization and delaying execution
 *  for a specified amounts of time.
 *
 * --
 *
 *  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004-2007  John Croisant
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
#include "rubygame_time.h"

void Rubygame_Init_Time();

VALUE cClock;

VALUE rbgm_time_wait(VALUE, VALUE);
VALUE rbgm_time_delay(int, VALUE*, VALUE);
VALUE rbgm_time_getticks(VALUE);


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
 *        If 0, control is never given to ruby.
 *
 */
Uint32 rg_threaded_delay( Uint32 delay, int yield )
{
  if( delay <= 0 )
    return 0;

  Uint32 start;

  start = SDL_GetTicks();

  if( yield > 0 )
  {
    while( delay - (SDL_GetTicks() - start) > yield )
    {
      SDL_Delay(yield);
      rb_thread_schedule();       /* give control to ruby */
    }
  }

  SDL_Delay( delay - (SDL_GetTicks() - start) ); /* remainder */

  return SDL_GetTicks() - start;
}


/*
 *  call-seq:
 *    wait( time )  ->  Integer
 *
 *  time:: how many milliseconds to wait.
 *
 *  Wait approximately the given time (the accuracy depends upon processor 
 *  scheduling, but 10ms is common). Returns the actual delay time, in 
 *  milliseconds. This method is less CPU-intensive than #delay, but is
 *  slightly less accurate.
 *
 *  The Rubygame timer system will be initialized when you call this function,
 *  if it has not been already.
 *
 */
VALUE rbgm_time_wait(VALUE module, VALUE milliseconds)
{
  if(!SDL_WasInit(SDL_INIT_TIMER))
  {
    if(SDL_InitSubSystem(SDL_INIT_TIMER))
    {
      rb_raise(eSDLError,"Could not initialize timer system: %s",\
               SDL_GetError());
    }
  }

  return INT2NUM( rg_threaded_delay( NUM2UINT(milliseconds), 0 ));
}

/*--
 *  From pygame code, with a few modifications:
 *    - takes 'accuracy' argument
 *    - ruby syntax for raising exceptions
 *    - uses rg_threaded_delay
 *++
 */
static int accurate_delay(int ticks, int accuracy, int yield)
{
  int funcstart, delay;
  if(ticks <= 0)
    return 0;

  if(!SDL_WasInit(SDL_INIT_TIMER))
  {
    if(SDL_InitSubSystem(SDL_INIT_TIMER))
    {
      rb_raise(eSDLError,"Could not initialize timer system: %s",\
               SDL_GetError());
    }
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
 *    delay( time, gran=12 )  ->  Integer
 *
 *  time:: how many milliseconds to delay.
 *  gran:: the granularity (in milliseconds) to assume for the system. A
 *         smaller value should use less CPU time, but if it's lower than the
 *         actual system granularity, this function might wait too long. The
 *         default, 12 ms, has a fairly low risk of over-waiting for many
 *         systems.

 *  Use the CPU to more accurately wait for the given period. Returns the
 *  actual delay time, in milliseconds. This function is more accurate than 
 *  #wait, but is also somewhat more CPU-intensive.
 *
 *  The Rubygame timer system will be initialized when you call this function,
 *  if it has not been already.
 *
 */
VALUE rbgm_time_delay(int argc, VALUE *argv, VALUE module)
{
  int ticks, goal, accuracy;
  VALUE vtime, vgran;

  rb_scan_args(argc,argv,"11", &vtime, &vgran);

  goal = NUM2INT(vtime);
  if(goal < 0)
    goal = 0;

  if( RTEST(vgran) )
    accuracy = NUM2INT(vgran);
  else
    accuracy = WORST_CLOCK_ACCURACY;

  ticks = accurate_delay( goal, accuracy, 0 );

  return INT2NUM(ticks);
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
VALUE rbgm_time_getticks( VALUE module )
{
  if(!SDL_WasInit(SDL_INIT_TIMER))
	if(SDL_InitSubSystem(SDL_INIT_TIMER))
	  rb_raise(eSDLError,"Could not initialize timer system: %s",\
			   SDL_GetError());
  return INT2NUM(SDL_GetTicks());
}

void Rubygame_Init_Time()
{
#if 0
	mRubygame = rb_define_module("Rubygame");
#endif

  /* Clock class */
  cClock = rb_define_class_under(mRubygame,"Clock",rb_cObject);
  /* Clock class methods */
  rb_define_singleton_method(cClock,"wait",rbgm_time_wait,1);
  rb_define_singleton_method(cClock,"delay",rbgm_time_delay,-1);
  rb_define_singleton_method(cClock,"runtime",rbgm_time_getticks,0);
}
