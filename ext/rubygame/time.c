/*
	Rubygame -- Ruby bindings to SDL to facilitate game creation
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

VALUE rbgm_time_wait(VALUE module, VALUE milliseconds)
{
	int start, delay;

	delay = NUM2UINT(milliseconds);
	start = SDL_GetTicks();
	SDL_Delay(delay);
	return INT2NUM(SDL_GetTicks() - start);
}

#define WORST_CLOCK_ACCURACY 12
VALUE rbgm_time_delay(VALUE module, VALUE milliseconds)
{
	int start, delay, ticks;

	ticks = NUM2UINT(milliseconds);
	start = SDL_GetTicks();
	if(ticks >= WORST_CLOCK_ACCURACY)
	{
		delay = (ticks - 2) - (ticks % WORST_CLOCK_ACCURACY);
		if(delay >= WORST_CLOCK_ACCURACY)
			SDL_Delay(delay);
	}
	while((ticks - (SDL_GetTicks() - start)) > 0)
	{ /* do nothing */ }
	return INT2NUM(SDL_GetTicks() - start);
}

VALUE rbgm_time_getticks( VALUE module )
{
	if(SDL_WasInit(SDL_INIT_TIMER)==0)
		rb_raise(eSDLError,"Timer system must be initialized before calling get_ticks.");
	return INT2NUM(SDL_GetTicks());
}

/* Rubification: */
void Rubygame_Init_Time()
{
	/* Time module */
	mTime = rb_define_module_under(mRubygame,"Time");
	/* Time methods */
	rb_define_module_function(mTime,"wait",rbgm_time_wait,1);
	rb_define_module_function(mTime,"delay",rbgm_time_delay,1);
	rb_define_module_function(mTime,"get_ticks",rbgm_time_getticks,0);
}
