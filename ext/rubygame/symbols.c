/*
	Rubygame -- Ruby code and bindings to SDL/OpenAL to facilitate game creation
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

#include <rubygame.h>

/*
 * This file contains all the C symbols used in Rubygame.
 * This should allow it to cleanly compile on MacOSX.
 */

/* General */
VALUE mRubygame;
VALUE eSDLError;
VALUE cRect;
VALUE mKey;
VALUE mMouse;
VALUE rbgm_init(VALUE);
SDL_Rect *make_rect(int x, int y, int w, int h);
int rect_entry(VALUE rect, int index);
void Define_Rubygame_Constants();

/* Display */
VALUE mDisplay;
VALUE cScreen;
void Rubygame_Init_Display();
VALUE rbgm_display_setmode(int, VALUE*, VALUE);
VALUE rbgm_display_getsurface(VALUE);
VALUE rbgm_screen_new(VALUE); /* dummy function */
VALUE rbgm_screen_getcaption(VALUE);
VALUE rbgm_screen_setcaption(int, VALUE*, VALUE);
VALUE rbgm_screen_update(int, VALUE*, VALUE);
VALUE rbgm_screen_updaterects(VALUE, VALUE);
VALUE rbgm_screen_flip(VALUE);

/* Draw */
VALUE mDraw;
void Rubygame_Init_Draw();
void draw_line(VALUE, VALUE, VALUE, VALUE, int);
VALUE rbgm_draw_line(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aaline(VALUE, VALUE, VALUE, VALUE, VALUE);
void draw_rect(VALUE, VALUE, VALUE, VALUE, int);
VALUE rbgm_draw_rect(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillrect(VALUE, VALUE, VALUE, VALUE, VALUE);
void draw_circle(VALUE, VALUE, VALUE, VALUE, int, int);
VALUE rbgm_draw_circle(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aacircle(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillcircle(VALUE, VALUE, VALUE, VALUE, VALUE);
void draw_ellipse(VALUE, VALUE, VALUE, VALUE, int, int);
VALUE rbgm_draw_ellipse(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aaellipse(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillellipse(VALUE, VALUE, VALUE, VALUE, VALUE);
void draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE, int);
VALUE rbgm_draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillpie(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE);
void draw_polygon(VALUE, VALUE, VALUE, int, int);
VALUE rbgm_draw_polygon(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aapolygon(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillpolygon(VALUE, VALUE, VALUE, VALUE);

/* Event */
VALUE mEvent;
VALUE cEvent;
VALUE cQueue;
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
void Rubygame_Init_Event();
VALUE convert_active(Uint8);
VALUE convert_keymod(SDLMod);
VALUE convert_mousebuttons(Uint8);
VALUE rbgm_convert_sdlevent(SDL_Event);
VALUE rbgm_queue_getsdl(VALUE);

/* Font */
VALUE mFont;
VALUE cTTF;
VALUE cSFont;
void Rubygame_Init_Font();
VALUE rbgm_font_init(VALUE);
VALUE rbgm_font_quit(VALUE);
VALUE rbgm_ttf_new(int, VALUE*, VALUE);
VALUE rbgm_ttf_getbold(VALUE);
VALUE rbgm_ttf_setbold(VALUE, VALUE);
VALUE rbgm_ttf_getitalic(VALUE);
VALUE rbgm_ttf_setitalic(VALUE, VALUE);
VALUE rbgm_ttf_getunderline(VALUE);
VALUE rbgm_ttf_setunderline(VALUE, VALUE);
VALUE rbgm_ttf_height(VALUE);
VALUE rbgm_ttf_ascent(VALUE);
VALUE rbgm_ttf_descent(VALUE);
VALUE rbgm_ttf_lineskip(VALUE);
VALUE rbgm_ttf_render(int, VALUE*, VALUE);

/* Image */
VALUE mImage;
void Rubygame_Init_Image();
VALUE rbgm_image_load(VALUE, VALUE);
VALUE rbgm_image_savebmp(VALUE, VALUE, VALUE);

/* Joy */
VALUE mJoy;
VALUE cJoystick;
void Rubygame_Init_Joystick();
VALUE rbgm_joy_numjoysticks(VALUE);
VALUE rbgm_joy_getname(VALUE, VALUE);
VALUE rbgm_joystick_new(int, VALUE*, VALUE);
VALUE rbgm_joystick_index(VALUE);
VALUE rbgm_joystick_name(VALUE);
VALUE rbgm_joystick_numaxes(VALUE);
VALUE rbgm_joystick_numballs(VALUE);
VALUE rbgm_joystick_numhats(VALUE);
VALUE rbgm_joystick_numbuttons(VALUE);

/* Surface */
VALUE cSurface;
void Rubygame_Init_Surface();
VALUE rbgm_surface_new(int, VALUE*, VALUE);
VALUE rbgm_surface_get_w(VALUE);
VALUE rbgm_surface_get_h(VALUE);
VALUE rbgm_surface_get_size(VALUE);
VALUE rbgm_surface_get_depth(VALUE);
VALUE rbgm_surface_get_flags(VALUE);
VALUE rbgm_surface_get_masks(VALUE);
VALUE rbgm_surface_get_alpha(VALUE);
VALUE rbgm_surface_set_alpha(int, VALUE*, VALUE);
VALUE rbgm_surface_get_colorkey(VALUE);
VALUE rbgm_surface_set_colorkey(int, VALUE*, VALUE);
VALUE rbgm_surface_blit(int, VALUE*, VALUE);
VALUE rbgm_surface_fill( int, VALUE*, VALUE);
VALUE rbgm_surface_getat( int, VALUE*, VALUE);

/* Time */
VALUE mTime;
void Rubygame_Init_Time();
VALUE rbgm_time_wait(VALUE, VALUE);
VALUE rbgm_time_delay(VALUE, VALUE);
VALUE rbgm_time_getticks(VALUE);

/* Transform */
VALUE mTrans;
void Rubygame_Init_Transform();
VALUE rbgm_transform_rotozoom(int, VALUE*, VALUE);
VALUE rbgm_transform_rotozoomsize(int, VALUE*, VALUE);
VALUE rbgm_transform_zoom(int, VALUE*, VALUE);
VALUE rbgm_transform_zoomsize(int, VALUE*, VALUE);
