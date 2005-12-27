/*
	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
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

#ifndef _RUBYGAME_H
#define _RUBYGAME_H

#include <SDL.h>
#include <ruby.h>
#include <stdio.h>

/* As of 20 Dec 2004 (svn revision 20) the symbols are defined in symbols.c 
 * so that it will compile cleanly on MacOSX.
 */

/* General */
extern VALUE mRubygame;
extern VALUE eSDLError;
extern VALUE cRect;
extern VALUE cSFont;
extern VALUE mKey;
extern VALUE mMouse;
extern VALUE rbgm_init(VALUE);
extern SDL_Rect *make_rect(int, int, int, int);
extern VALUE rbgm_usable(VALUE);
extern VALUE rbgm_unusable(VALUE);
extern VALUE rbgm_dummy(int, VALUE*, VALUE);
extern void Define_Rubygame_Constants();

/* Display */
extern VALUE mDisplay;
extern VALUE cScreen;
extern void Rubygame_Init_Screen();
extern VALUE rbgm_screen_setmode(int, VALUE*, VALUE);
extern VALUE rbgm_screen_getsurface(VALUE);
extern VALUE rbgm_screen_new(VALUE); /* dummy function */
extern VALUE rbgm_screen_getcaption(VALUE);
extern VALUE rbgm_screen_setcaption(int, VALUE*, VALUE);
extern VALUE rbgm_screen_update(int, VALUE*, VALUE);
extern VALUE rbgm_screen_updaterects(VALUE, VALUE);
extern VALUE rbgm_screen_flip(VALUE);

/* Draw */
extern VALUE mDraw;
extern void Rubygame_Init_Draw();
extern VALUE rbgm_draw_version(VALUE);
extern void draw_line(VALUE, VALUE, VALUE, VALUE, int);
extern VALUE rbgm_draw_line(VALUE, VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_aaline(VALUE, VALUE, VALUE, VALUE, VALUE);
extern void draw_rect(VALUE, VALUE, VALUE, VALUE, int);
extern VALUE rbgm_draw_rect(VALUE, VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillrect(VALUE, VALUE, VALUE, VALUE, VALUE);
extern void draw_circle(VALUE, VALUE, VALUE, VALUE, int, int);
extern VALUE rbgm_draw_circle(VALUE, VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_aacircle(VALUE, VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillcircle(VALUE, VALUE, VALUE, VALUE, VALUE);
extern void draw_ellipse(VALUE, VALUE, VALUE, VALUE, int, int);
extern VALUE rbgm_draw_ellipse(VALUE, VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_aaellipse(VALUE, VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillellipse(VALUE, VALUE, VALUE, VALUE, VALUE);
extern void draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE, int);
extern VALUE rbgm_draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillpie(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE);
extern void draw_polygon(VALUE, VALUE, VALUE, int, int);
extern VALUE rbgm_draw_polygon(VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_aapolygon(VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_draw_fillpolygon(VALUE, VALUE, VALUE, VALUE);

/* Event */
extern VALUE cEvent;
extern VALUE cQueue;
extern VALUE cActiveEvent;
extern VALUE cKeyDownEvent;
extern VALUE cKeyUpEvent;
extern VALUE cMouseMotionEvent;
extern VALUE cMouseDownEvent;
extern VALUE cMouseUpEvent;
extern VALUE cJoyAxisEvent;
extern VALUE cJoyBallEvent;
extern VALUE cJoyHatEvent;
extern VALUE cJoyDownEvent;
extern VALUE cJoyUpEvent;
extern VALUE cQuitEvent;
extern VALUE cSysWMEvent;
extern VALUE cResizeEvent;
extern void Rubygame_Init_Event();
extern VALUE convert_active(Uint8);
extern VALUE convert_keymod(SDLMod);
extern VALUE convert_mousebuttons(Uint8);
extern VALUE rbgm_convert_sdlevent(SDL_Event);
extern VALUE rbgm_queue_getsdl(VALUE);

/* Font */
extern VALUE cTTF;
extern void Rubygame_Init_TTF();
extern VALUE rbgm_ttf_version(VALUE);
extern VALUE rbgm_ttf_init(VALUE);
extern VALUE rbgm_ttf_quit(VALUE);
extern VALUE rbgm_ttf_new(int, VALUE*, VALUE);
extern VALUE rbgm_ttf_getbold(VALUE);
extern VALUE rbgm_ttf_setbold(VALUE, VALUE);
extern VALUE rbgm_ttf_getitalic(VALUE);
extern VALUE rbgm_ttf_setitalic(VALUE, VALUE);
extern VALUE rbgm_ttf_getunderline(VALUE);
extern VALUE rbgm_ttf_setunderline(VALUE, VALUE);
extern VALUE rbgm_ttf_height(VALUE);
extern VALUE rbgm_ttf_ascent(VALUE);
extern VALUE rbgm_ttf_descent(VALUE);
extern VALUE rbgm_ttf_lineskip(VALUE);
extern VALUE rbgm_ttf_render(int, VALUE*, VALUE);

/* Image */
extern VALUE mImage;
extern void Rubygame_Init_Image();
extern VALUE rbgm_image_version(VALUE);
extern VALUE rbgm_image_load(VALUE, VALUE);
extern VALUE rbgm_image_savebmp(VALUE, VALUE, VALUE);

/* Joy */
extern VALUE cJoy;
extern void Rubygame_Init_Joystick();
extern VALUE rbgm_joy_numjoysticks(VALUE);
extern VALUE rbgm_joy_getname(VALUE, VALUE);
extern VALUE rbgm_joystick_new(int, VALUE*, VALUE);
extern VALUE rbgm_joystick_index(VALUE);
extern VALUE rbgm_joystick_name(VALUE);
extern VALUE rbgm_joystick_numaxes(VALUE);
extern VALUE rbgm_joystick_numballs(VALUE);
extern VALUE rbgm_joystick_numhats(VALUE);
extern VALUE rbgm_joystick_numbuttons(VALUE);

/* Surface */
extern VALUE cSurface;
extern void Rubygame_Init_Surface();
extern VALUE rbgm_surface_new(int, VALUE*, VALUE);
extern VALUE rbgm_surface_get_w(VALUE);
extern VALUE rbgm_surface_get_h(VALUE);
extern VALUE rbgm_surface_get_size(VALUE);
extern VALUE rbgm_surface_get_depth(VALUE);
extern VALUE rbgm_surface_get_flags(VALUE);
extern VALUE rbgm_surface_get_masks(VALUE);
extern VALUE rbgm_surface_get_alpha(VALUE);
extern VALUE rbgm_surface_set_alpha(int, VALUE*, VALUE);
extern VALUE rbgm_surface_get_colorkey(VALUE);
extern VALUE rbgm_surface_set_colorkey(int, VALUE*, VALUE);
extern VALUE rbgm_surface_blit(int, VALUE*, VALUE);
extern VALUE rbgm_surface_fill( int, VALUE*, VALUE);
extern VALUE rbgm_surface_getat( int, VALUE*, VALUE);

/* Time */
extern VALUE mTime;
extern void Rubygame_Init_Time();
extern VALUE rbgm_time_wait(VALUE, VALUE);
extern VALUE rbgm_time_delay(int, VALUE*, VALUE);
extern VALUE rbgm_time_getticks(VALUE);

/* Transform */
extern VALUE mTrans;
extern void Rubygame_Init_Transform();
extern VALUE rbgm_transform_rotozoom(int, VALUE*, VALUE);
extern VALUE rbgm_transform_rotozoomsize(int, VALUE*, VALUE);
extern VALUE rbgm_transform_zoom(int, VALUE*, VALUE);
extern VALUE rbgm_transform_zoomsize(int, VALUE*, VALUE);

#endif /* _RUBYGAME_H */
