/*
 *  Functions for getting the time since initialization and delaying execution
 *  for a specified amounts of time.
 *
 * --
 *
 *  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004  John 'jacius' Croisant
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

#include "rubygame.h"
#include "rubygame_time.h"

void Rubygame_Init_Time();

VALUE mTime;

VALUE rbgm_time_wait(VALUE, VALUE);
VALUE rbgm_time_delay(int, VALUE*, VALUE);
VALUE rbgm_time_getticks(VALUE);


/*  NOTICE: if you change this value "officially", don't forget to update the
 *  documentation for rbgm_time_delay!!
 */
#define WORST_CLOCK_ACCURACY 12


/*
 *  call-seq:
 *    wait( time )  ->  Integer
 *
 *  Wait approximately the given time (the accuracy depends upon processor 
 *  scheduling, but 10ms is common). Returns the actual delay time, in 
 *  milliseconds. This method is less CPU-intensive than #delay, but is
 *  slightly less accurate.
 *
 *  The Rubygame timer system will be initialized when you call this function,
 *  if it has not been already.
 *
 *  This function takes this argument:
 *  time:: the time in milliseconds to wait.
 */
VALUE rbgm_time_wait(VALUE module, VALUE milliseconds)
{
  Uint32 start, delay;

  if(!SDL_WasInit(SDL_INIT_TIMER))
    if(SDL_InitSubSystem(SDL_INIT_TIMER))
      rb_raise(eSDLError,"Could not initialize timer system: %s",\
               SDL_GetError());

  delay = NUM2UINT(milliseconds);
  start = SDL_GetTicks();
  SDL_Delay(delay);
  return INT2NUM(SDL_GetTicks() - start);
}

/*--
 *  From pygame code, with a few modifications:
 *    - takes 'accuracy' argument
 *    - ruby syntax for raising exceptions
 *++
 */
static int accurate_delay(int ticks,int accuracy)
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
		  SDL_Delay(delay);
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
 *  Use the CPU to more accurately wait for the given period. Returns the
 *  actual delay time, in milliseconds. This function is more accurate than 
 *  #wait, but is also more CPU-intensive.
 *
 *  The Rubygame timer system will be initialized when you call this function,
 *  if it has not been already.
 *
 *  This function takes these arguments:
 *  time:: the time in milliseconds to delay.
 *  gran:: the granularity (in milliseconds) to assume for the system. A
 *         smaller value should use less CPU time, but if it's lower than the
 *         actual system granularity, this function might wait too long. The
 *         default, 12 ms, has a fairly low risk of over-waiting for many
 *         systems.
 */
VALUE rbgm_time_delay(int argc, VALUE *argv, VALUE module)
{
  int ticks, goal, accuracy;

  if (argc < 1)
    rb_raise(rb_eArgError,"wrong number of arguments (%d for 1)", argc);
  goal = NUM2INT(argv[0]);
  if(goal < 0)
    goal = 0;

  if(argc > 1 && argv[1] != Qnil)
    accuracy = NUM2INT(argv[1]);
  else
    accuracy = WORST_CLOCK_ACCURACY;

  ticks = accurate_delay(goal,accuracy);

  return INT2NUM(ticks);
}

/*
 *  call-seq:
 *    get_ticks  ->  Integer
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

/* 
 *  Document-module: Rubygame::Time
 *
 *  The Time module provides methods for tracking running time and delaying
 *  execution of the program for specified time periods. This is used to
 *  provide a consistent framerate, prevent the program from gluttonizing
 *  all the resources of the computer,  etc.
 *
 *  See also the Clock class, which uses these methods to provide a convenient
 *  way to monitor and and limit application framerate.
 */
void Rubygame_Init_Time()
{
#if 0
	/* Pretend to define Rubygame module, so RDoc knows about it: */
	mRubygame = rb_define_module("Rubygame");
#endif

  /* Time module */
  mTime = rb_define_module_under(mRubygame,"Time");
  /* Time methods */
  rb_define_module_function(mTime,"wait",rbgm_time_wait,1);
  rb_define_module_function(mTime,"delay",rbgm_time_delay,-1);
  rb_define_module_function(mTime,"get_ticks",rbgm_time_getticks,0);
}
