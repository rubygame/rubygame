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

/* Thank you, Ruby/SDL, for doing most of this :) */

#include "rubygame.h"

void Define_Rubygame_Constants()
{
	
/* Flags for subsystem initialization */
rb_define_const(mRubygame,"INIT_TIMER",INT2NUM(SDL_INIT_TIMER));
rb_define_const(mRubygame,"INIT_AUDIO",INT2NUM(SDL_INIT_AUDIO));
rb_define_const(mRubygame,"INIT_VIDEO",INT2NUM(SDL_INIT_VIDEO));
rb_define_const(mRubygame,"INIT_CDROM",INT2NUM(SDL_INIT_CDROM));
rb_define_const(mRubygame,"INIT_JOYSTICK",INT2NUM(SDL_INIT_JOYSTICK));
rb_define_const(mRubygame,"INIT_NOPARACHUTE",INT2NUM(SDL_INIT_NOPARACHUTE));
rb_define_const(mRubygame,"INIT_EVENTTHREAD",INT2NUM(SDL_INIT_EVENTTHREAD));
rb_define_const(mRubygame,"INIT_EVERYTHING",INT2NUM(SDL_INIT_EVERYTHING));

	
/* Flags for making surfaces/display */
rb_define_const(mRubygame,"SWSURFACE",INT2NUM(SDL_SWSURFACE));
rb_define_const(mRubygame,"HWSURFACE",INT2NUM(SDL_HWSURFACE));
rb_define_const(mRubygame,"ASYNCBLIT",INT2NUM(SDL_ASYNCBLIT));
rb_define_const(mRubygame,"ANYFORMAT",INT2NUM(SDL_ANYFORMAT));
rb_define_const(mRubygame,"HWPALETTE",INT2NUM(SDL_HWPALETTE));
rb_define_const(mRubygame,"DOUBLEBUF",INT2NUM(SDL_DOUBLEBUF));
rb_define_const(mRubygame,"FULLSCREEN",INT2NUM(SDL_FULLSCREEN));
rb_define_const(mRubygame,"OPENGL",INT2NUM(SDL_OPENGL));
rb_define_const(mRubygame,"OPENGLBLIT",INT2NUM(SDL_OPENGLBLIT));
rb_define_const(mRubygame,"RESIZABLE",INT2NUM(SDL_RESIZABLE));
rb_define_const(mRubygame,"NOFRAME",INT2NUM(SDL_NOFRAME));
rb_define_const(mRubygame,"HWACCEL",INT2NUM(SDL_HWACCEL));
rb_define_const(mRubygame,"SRCCOLORKEY",INT2NUM(SDL_SRCCOLORKEY));
rb_define_const(mRubygame,"RLEACCELOK",INT2NUM(SDL_RLEACCELOK));
rb_define_const(mRubygame,"RLEACCEL",INT2NUM(SDL_RLEACCEL));
rb_define_const(mRubygame,"SRCALPHA",INT2NUM(SDL_SRCALPHA));
rb_define_const(mRubygame,"PREALLOC",INT2NUM(SDL_PREALLOC));

	
/* Define fully opaque and full transparent (0 and 255) */
rb_define_const(mRubygame,"ALPHA_OPAQUE",INT2NUM(SDL_ALPHA_OPAQUE));
rb_define_const(mRubygame,"ALPHA_TRANSPARENT",INT2NUM(SDL_ALPHA_TRANSPARENT));

	
/* Flags for palettes (?) */
rb_define_const(mRubygame,"LOGPAL",INT2NUM(SDL_LOGPAL));
rb_define_const(mRubygame,"PHYSPAL",INT2NUM(SDL_PHYSPAL));

	
/* ASCII keys */
rb_define_const(mRubygame,"K_UNKNOWN",INT2NUM(SDLK_UNKNOWN));
rb_define_const(mRubygame,"K_FIRST",INT2NUM(SDLK_FIRST));
rb_define_const(mRubygame,"K_BACKSPACE",INT2NUM(SDLK_BACKSPACE));
rb_define_const(mRubygame,"K_TAB",INT2NUM(SDLK_TAB));
rb_define_const(mRubygame,"K_CLEAR",INT2NUM(SDLK_CLEAR));
rb_define_const(mRubygame,"K_RETURN",INT2NUM(SDLK_RETURN));
rb_define_const(mRubygame,"K_PAUSE",INT2NUM(SDLK_PAUSE));
rb_define_const(mRubygame,"K_ESCAPE",INT2NUM(SDLK_ESCAPE));
rb_define_const(mRubygame,"K_SPACE",INT2NUM(SDLK_SPACE));
rb_define_const(mRubygame,"K_EXCLAIM",INT2NUM(SDLK_EXCLAIM));
rb_define_const(mRubygame,"K_QUOTEDBL",INT2NUM(SDLK_QUOTEDBL));
rb_define_const(mRubygame,"K_HASH",INT2NUM(SDLK_HASH));
rb_define_const(mRubygame,"K_DOLLAR",INT2NUM(SDLK_DOLLAR));
rb_define_const(mRubygame,"K_AMPERSAND",INT2NUM(SDLK_AMPERSAND));
rb_define_const(mRubygame,"K_QUOTE",INT2NUM(SDLK_QUOTE));
rb_define_const(mRubygame,"K_LEFTPAREN",INT2NUM(SDLK_LEFTPAREN));
rb_define_const(mRubygame,"K_RIGHTPAREN",INT2NUM(SDLK_RIGHTPAREN));
rb_define_const(mRubygame,"K_ASTERISK",INT2NUM(SDLK_ASTERISK));
rb_define_const(mRubygame,"K_PLUS",INT2NUM(SDLK_PLUS));
rb_define_const(mRubygame,"K_COMMA",INT2NUM(SDLK_COMMA));
rb_define_const(mRubygame,"K_MINUS",INT2NUM(SDLK_MINUS));
rb_define_const(mRubygame,"K_PERIOD",INT2NUM(SDLK_PERIOD));
rb_define_const(mRubygame,"K_SLASH",INT2NUM(SDLK_SLASH));
rb_define_const(mRubygame,"K_0",INT2NUM(SDLK_0));
rb_define_const(mRubygame,"K_1",INT2NUM(SDLK_1));
rb_define_const(mRubygame,"K_2",INT2NUM(SDLK_2));
rb_define_const(mRubygame,"K_3",INT2NUM(SDLK_3));
rb_define_const(mRubygame,"K_4",INT2NUM(SDLK_4));
rb_define_const(mRubygame,"K_5",INT2NUM(SDLK_5));
rb_define_const(mRubygame,"K_6",INT2NUM(SDLK_6));
rb_define_const(mRubygame,"K_7",INT2NUM(SDLK_7));
rb_define_const(mRubygame,"K_8",INT2NUM(SDLK_8));
rb_define_const(mRubygame,"K_9",INT2NUM(SDLK_9));
rb_define_const(mRubygame,"K_COLON",INT2NUM(SDLK_COLON));
rb_define_const(mRubygame,"K_SEMICOLON",INT2NUM(SDLK_SEMICOLON));
rb_define_const(mRubygame,"K_LESS",INT2NUM(SDLK_LESS));
rb_define_const(mRubygame,"K_EQUALS",INT2NUM(SDLK_EQUALS));
rb_define_const(mRubygame,"K_GREATER",INT2NUM(SDLK_GREATER));
rb_define_const(mRubygame,"K_QUESTION",INT2NUM(SDLK_QUESTION));
rb_define_const(mRubygame,"K_AT",INT2NUM(SDLK_AT));
rb_define_const(mRubygame,"K_LEFTBRACKET",INT2NUM(SDLK_LEFTBRACKET));
rb_define_const(mRubygame,"K_BACKSLASH",INT2NUM(SDLK_BACKSLASH));
rb_define_const(mRubygame,"K_RIGHTBRACKET",INT2NUM(SDLK_RIGHTBRACKET));
rb_define_const(mRubygame,"K_CARET",INT2NUM(SDLK_CARET));
rb_define_const(mRubygame,"K_UNDERSCORE",INT2NUM(SDLK_UNDERSCORE));
rb_define_const(mRubygame,"K_BACKQUOTE",INT2NUM(SDLK_BACKQUOTE));
rb_define_const(mRubygame,"K_A",INT2NUM(SDLK_a));
rb_define_const(mRubygame,"K_B",INT2NUM(SDLK_b));
rb_define_const(mRubygame,"K_C",INT2NUM(SDLK_c));
rb_define_const(mRubygame,"K_D",INT2NUM(SDLK_d));
rb_define_const(mRubygame,"K_E",INT2NUM(SDLK_e));
rb_define_const(mRubygame,"K_F",INT2NUM(SDLK_f));
rb_define_const(mRubygame,"K_G",INT2NUM(SDLK_g));
rb_define_const(mRubygame,"K_H",INT2NUM(SDLK_h));
rb_define_const(mRubygame,"K_I",INT2NUM(SDLK_i));
rb_define_const(mRubygame,"K_J",INT2NUM(SDLK_j));
rb_define_const(mRubygame,"K_K",INT2NUM(SDLK_k));
rb_define_const(mRubygame,"K_L",INT2NUM(SDLK_l));
rb_define_const(mRubygame,"K_M",INT2NUM(SDLK_m));
rb_define_const(mRubygame,"K_N",INT2NUM(SDLK_n));
rb_define_const(mRubygame,"K_O",INT2NUM(SDLK_o));
rb_define_const(mRubygame,"K_P",INT2NUM(SDLK_p));
rb_define_const(mRubygame,"K_Q",INT2NUM(SDLK_q));
rb_define_const(mRubygame,"K_R",INT2NUM(SDLK_r));
rb_define_const(mRubygame,"K_S",INT2NUM(SDLK_s));
rb_define_const(mRubygame,"K_T",INT2NUM(SDLK_t));
rb_define_const(mRubygame,"K_U",INT2NUM(SDLK_u));
rb_define_const(mRubygame,"K_V",INT2NUM(SDLK_v));
rb_define_const(mRubygame,"K_W",INT2NUM(SDLK_w));
rb_define_const(mRubygame,"K_X",INT2NUM(SDLK_x));
rb_define_const(mRubygame,"K_Y",INT2NUM(SDLK_y));
rb_define_const(mRubygame,"K_Z",INT2NUM(SDLK_z));
rb_define_const(mRubygame,"K_DELETE",INT2NUM(SDLK_DELETE));

	
/* International keyboard syms */
rb_define_const(mRubygame,"K_WORLD_0",INT2NUM(SDLK_WORLD_0));
rb_define_const(mRubygame,"K_WORLD_1",INT2NUM(SDLK_WORLD_1));
rb_define_const(mRubygame,"K_WORLD_2",INT2NUM(SDLK_WORLD_2));
rb_define_const(mRubygame,"K_WORLD_3",INT2NUM(SDLK_WORLD_3));
rb_define_const(mRubygame,"K_WORLD_4",INT2NUM(SDLK_WORLD_4));
rb_define_const(mRubygame,"K_WORLD_5",INT2NUM(SDLK_WORLD_5));
rb_define_const(mRubygame,"K_WORLD_6",INT2NUM(SDLK_WORLD_6));
rb_define_const(mRubygame,"K_WORLD_7",INT2NUM(SDLK_WORLD_7));
rb_define_const(mRubygame,"K_WORLD_8",INT2NUM(SDLK_WORLD_8));
rb_define_const(mRubygame,"K_WORLD_9",INT2NUM(SDLK_WORLD_9));
rb_define_const(mRubygame,"K_WORLD_10",INT2NUM(SDLK_WORLD_10));
rb_define_const(mRubygame,"K_WORLD_11",INT2NUM(SDLK_WORLD_11));
rb_define_const(mRubygame,"K_WORLD_12",INT2NUM(SDLK_WORLD_12));
rb_define_const(mRubygame,"K_WORLD_13",INT2NUM(SDLK_WORLD_13));
rb_define_const(mRubygame,"K_WORLD_14",INT2NUM(SDLK_WORLD_14));
rb_define_const(mRubygame,"K_WORLD_15",INT2NUM(SDLK_WORLD_15));
rb_define_const(mRubygame,"K_WORLD_16",INT2NUM(SDLK_WORLD_16));
rb_define_const(mRubygame,"K_WORLD_17",INT2NUM(SDLK_WORLD_17));
rb_define_const(mRubygame,"K_WORLD_18",INT2NUM(SDLK_WORLD_18));
rb_define_const(mRubygame,"K_WORLD_19",INT2NUM(SDLK_WORLD_19));
rb_define_const(mRubygame,"K_WORLD_20",INT2NUM(SDLK_WORLD_20));
rb_define_const(mRubygame,"K_WORLD_21",INT2NUM(SDLK_WORLD_21));
rb_define_const(mRubygame,"K_WORLD_22",INT2NUM(SDLK_WORLD_22));
rb_define_const(mRubygame,"K_WORLD_23",INT2NUM(SDLK_WORLD_23));
rb_define_const(mRubygame,"K_WORLD_24",INT2NUM(SDLK_WORLD_24));
rb_define_const(mRubygame,"K_WORLD_25",INT2NUM(SDLK_WORLD_25));
rb_define_const(mRubygame,"K_WORLD_26",INT2NUM(SDLK_WORLD_26));
rb_define_const(mRubygame,"K_WORLD_27",INT2NUM(SDLK_WORLD_27));
rb_define_const(mRubygame,"K_WORLD_28",INT2NUM(SDLK_WORLD_28));
rb_define_const(mRubygame,"K_WORLD_29",INT2NUM(SDLK_WORLD_29));
rb_define_const(mRubygame,"K_WORLD_30",INT2NUM(SDLK_WORLD_30));
rb_define_const(mRubygame,"K_WORLD_31",INT2NUM(SDLK_WORLD_31));
rb_define_const(mRubygame,"K_WORLD_32",INT2NUM(SDLK_WORLD_32));
rb_define_const(mRubygame,"K_WORLD_33",INT2NUM(SDLK_WORLD_33));
rb_define_const(mRubygame,"K_WORLD_34",INT2NUM(SDLK_WORLD_34));
rb_define_const(mRubygame,"K_WORLD_35",INT2NUM(SDLK_WORLD_35));
rb_define_const(mRubygame,"K_WORLD_36",INT2NUM(SDLK_WORLD_36));
rb_define_const(mRubygame,"K_WORLD_37",INT2NUM(SDLK_WORLD_37));
rb_define_const(mRubygame,"K_WORLD_38",INT2NUM(SDLK_WORLD_38));
rb_define_const(mRubygame,"K_WORLD_39",INT2NUM(SDLK_WORLD_39));
rb_define_const(mRubygame,"K_WORLD_40",INT2NUM(SDLK_WORLD_40));
rb_define_const(mRubygame,"K_WORLD_41",INT2NUM(SDLK_WORLD_41));
rb_define_const(mRubygame,"K_WORLD_42",INT2NUM(SDLK_WORLD_42));
rb_define_const(mRubygame,"K_WORLD_43",INT2NUM(SDLK_WORLD_43));
rb_define_const(mRubygame,"K_WORLD_44",INT2NUM(SDLK_WORLD_44));
rb_define_const(mRubygame,"K_WORLD_45",INT2NUM(SDLK_WORLD_45));
rb_define_const(mRubygame,"K_WORLD_46",INT2NUM(SDLK_WORLD_46));
rb_define_const(mRubygame,"K_WORLD_47",INT2NUM(SDLK_WORLD_47));
rb_define_const(mRubygame,"K_WORLD_48",INT2NUM(SDLK_WORLD_48));
rb_define_const(mRubygame,"K_WORLD_49",INT2NUM(SDLK_WORLD_49));
rb_define_const(mRubygame,"K_WORLD_50",INT2NUM(SDLK_WORLD_50));
rb_define_const(mRubygame,"K_WORLD_51",INT2NUM(SDLK_WORLD_51));
rb_define_const(mRubygame,"K_WORLD_52",INT2NUM(SDLK_WORLD_52));
rb_define_const(mRubygame,"K_WORLD_53",INT2NUM(SDLK_WORLD_53));
rb_define_const(mRubygame,"K_WORLD_54",INT2NUM(SDLK_WORLD_54));
rb_define_const(mRubygame,"K_WORLD_55",INT2NUM(SDLK_WORLD_55));
rb_define_const(mRubygame,"K_WORLD_56",INT2NUM(SDLK_WORLD_56));
rb_define_const(mRubygame,"K_WORLD_57",INT2NUM(SDLK_WORLD_57));
rb_define_const(mRubygame,"K_WORLD_58",INT2NUM(SDLK_WORLD_58));
rb_define_const(mRubygame,"K_WORLD_59",INT2NUM(SDLK_WORLD_59));
rb_define_const(mRubygame,"K_WORLD_60",INT2NUM(SDLK_WORLD_60));
rb_define_const(mRubygame,"K_WORLD_61",INT2NUM(SDLK_WORLD_61));
rb_define_const(mRubygame,"K_WORLD_62",INT2NUM(SDLK_WORLD_62));
rb_define_const(mRubygame,"K_WORLD_63",INT2NUM(SDLK_WORLD_63));
rb_define_const(mRubygame,"K_WORLD_64",INT2NUM(SDLK_WORLD_64));
rb_define_const(mRubygame,"K_WORLD_65",INT2NUM(SDLK_WORLD_65));
rb_define_const(mRubygame,"K_WORLD_66",INT2NUM(SDLK_WORLD_66));
rb_define_const(mRubygame,"K_WORLD_67",INT2NUM(SDLK_WORLD_67));
rb_define_const(mRubygame,"K_WORLD_68",INT2NUM(SDLK_WORLD_68));
rb_define_const(mRubygame,"K_WORLD_69",INT2NUM(SDLK_WORLD_69));
rb_define_const(mRubygame,"K_WORLD_70",INT2NUM(SDLK_WORLD_70));
rb_define_const(mRubygame,"K_WORLD_71",INT2NUM(SDLK_WORLD_71));
rb_define_const(mRubygame,"K_WORLD_72",INT2NUM(SDLK_WORLD_72));
rb_define_const(mRubygame,"K_WORLD_73",INT2NUM(SDLK_WORLD_73));
rb_define_const(mRubygame,"K_WORLD_74",INT2NUM(SDLK_WORLD_74));
rb_define_const(mRubygame,"K_WORLD_75",INT2NUM(SDLK_WORLD_75));
rb_define_const(mRubygame,"K_WORLD_76",INT2NUM(SDLK_WORLD_76));
rb_define_const(mRubygame,"K_WORLD_77",INT2NUM(SDLK_WORLD_77));
rb_define_const(mRubygame,"K_WORLD_78",INT2NUM(SDLK_WORLD_78));
rb_define_const(mRubygame,"K_WORLD_79",INT2NUM(SDLK_WORLD_79));
rb_define_const(mRubygame,"K_WORLD_80",INT2NUM(SDLK_WORLD_80));
rb_define_const(mRubygame,"K_WORLD_81",INT2NUM(SDLK_WORLD_81));
rb_define_const(mRubygame,"K_WORLD_82",INT2NUM(SDLK_WORLD_82));
rb_define_const(mRubygame,"K_WORLD_83",INT2NUM(SDLK_WORLD_83));
rb_define_const(mRubygame,"K_WORLD_84",INT2NUM(SDLK_WORLD_84));
rb_define_const(mRubygame,"K_WORLD_85",INT2NUM(SDLK_WORLD_85));
rb_define_const(mRubygame,"K_WORLD_86",INT2NUM(SDLK_WORLD_86));
rb_define_const(mRubygame,"K_WORLD_87",INT2NUM(SDLK_WORLD_87));
rb_define_const(mRubygame,"K_WORLD_88",INT2NUM(SDLK_WORLD_88));
rb_define_const(mRubygame,"K_WORLD_89",INT2NUM(SDLK_WORLD_89));
rb_define_const(mRubygame,"K_WORLD_90",INT2NUM(SDLK_WORLD_90));
rb_define_const(mRubygame,"K_WORLD_91",INT2NUM(SDLK_WORLD_91));
rb_define_const(mRubygame,"K_WORLD_92",INT2NUM(SDLK_WORLD_92));
rb_define_const(mRubygame,"K_WORLD_93",INT2NUM(SDLK_WORLD_93));
rb_define_const(mRubygame,"K_WORLD_94",INT2NUM(SDLK_WORLD_94));
rb_define_const(mRubygame,"K_WORLD_95",INT2NUM(SDLK_WORLD_95));

	
/* Numeric keypad */
rb_define_const(mRubygame,"K_KP0",INT2NUM(SDLK_KP0));
rb_define_const(mRubygame,"K_KP1",INT2NUM(SDLK_KP1));
rb_define_const(mRubygame,"K_KP2",INT2NUM(SDLK_KP2));
rb_define_const(mRubygame,"K_KP3",INT2NUM(SDLK_KP3));
rb_define_const(mRubygame,"K_KP4",INT2NUM(SDLK_KP4));
rb_define_const(mRubygame,"K_KP5",INT2NUM(SDLK_KP5));
rb_define_const(mRubygame,"K_KP6",INT2NUM(SDLK_KP6));
rb_define_const(mRubygame,"K_KP7",INT2NUM(SDLK_KP7));
rb_define_const(mRubygame,"K_KP8",INT2NUM(SDLK_KP8));
rb_define_const(mRubygame,"K_KP9",INT2NUM(SDLK_KP9));
rb_define_const(mRubygame,"K_KP_PERIOD",INT2NUM(SDLK_KP_PERIOD));
rb_define_const(mRubygame,"K_KP_DIVIDE",INT2NUM(SDLK_KP_DIVIDE));
rb_define_const(mRubygame,"K_KP_MULTIPLY",INT2NUM(SDLK_KP_MULTIPLY));
rb_define_const(mRubygame,"K_KP_MINUS",INT2NUM(SDLK_KP_MINUS));
rb_define_const(mRubygame,"K_KP_PLUS",INT2NUM(SDLK_KP_PLUS));
rb_define_const(mRubygame,"K_KP_ENTER",INT2NUM(SDLK_KP_ENTER));
rb_define_const(mRubygame,"K_KP_EQUALS",INT2NUM(SDLK_KP_EQUALS));

	
/* Arrows + Home/End pad */
rb_define_const(mRubygame,"K_UP",INT2NUM(SDLK_UP));
rb_define_const(mRubygame,"K_DOWN",INT2NUM(SDLK_DOWN));
rb_define_const(mRubygame,"K_RIGHT",INT2NUM(SDLK_RIGHT));
rb_define_const(mRubygame,"K_LEFT",INT2NUM(SDLK_LEFT));
rb_define_const(mRubygame,"K_INSERT",INT2NUM(SDLK_INSERT));
rb_define_const(mRubygame,"K_HOME",INT2NUM(SDLK_HOME));
rb_define_const(mRubygame,"K_END",INT2NUM(SDLK_END));
rb_define_const(mRubygame,"K_PAGEUP",INT2NUM(SDLK_PAGEUP));
rb_define_const(mRubygame,"K_PAGEDOWN",INT2NUM(SDLK_PAGEDOWN));

	
/* Function keys */
rb_define_const(mRubygame,"K_F1",INT2NUM(SDLK_F1));
rb_define_const(mRubygame,"K_F2",INT2NUM(SDLK_F2));
rb_define_const(mRubygame,"K_F3",INT2NUM(SDLK_F3));
rb_define_const(mRubygame,"K_F4",INT2NUM(SDLK_F4));
rb_define_const(mRubygame,"K_F5",INT2NUM(SDLK_F5));
rb_define_const(mRubygame,"K_F6",INT2NUM(SDLK_F6));
rb_define_const(mRubygame,"K_F7",INT2NUM(SDLK_F7));
rb_define_const(mRubygame,"K_F8",INT2NUM(SDLK_F8));
rb_define_const(mRubygame,"K_F9",INT2NUM(SDLK_F9));
rb_define_const(mRubygame,"K_F10",INT2NUM(SDLK_F10));
rb_define_const(mRubygame,"K_F11",INT2NUM(SDLK_F11));
rb_define_const(mRubygame,"K_F12",INT2NUM(SDLK_F12));
rb_define_const(mRubygame,"K_F13",INT2NUM(SDLK_F13));
rb_define_const(mRubygame,"K_F14",INT2NUM(SDLK_F14));
rb_define_const(mRubygame,"K_F15",INT2NUM(SDLK_F15));

	
/* Key state modifier keys */
rb_define_const(mRubygame,"K_NUMLOCK",INT2NUM(SDLK_NUMLOCK));
rb_define_const(mRubygame,"K_CAPSLOCK",INT2NUM(SDLK_CAPSLOCK));
rb_define_const(mRubygame,"K_SCROLLOCK",INT2NUM(SDLK_SCROLLOCK));
rb_define_const(mRubygame,"K_RSHIFT",INT2NUM(SDLK_RSHIFT));
rb_define_const(mRubygame,"K_LSHIFT",INT2NUM(SDLK_LSHIFT));
rb_define_const(mRubygame,"K_RCTRL",INT2NUM(SDLK_RCTRL));
rb_define_const(mRubygame,"K_LCTRL",INT2NUM(SDLK_LCTRL));
rb_define_const(mRubygame,"K_RALT",INT2NUM(SDLK_RALT));
rb_define_const(mRubygame,"K_LALT",INT2NUM(SDLK_LALT));
rb_define_const(mRubygame,"K_RMETA",INT2NUM(SDLK_RMETA));
rb_define_const(mRubygame,"K_LMETA",INT2NUM(SDLK_LMETA));
rb_define_const(mRubygame,"K_LSUPER",INT2NUM(SDLK_LSUPER));
rb_define_const(mRubygame,"K_RSUPER",INT2NUM(SDLK_RSUPER));
rb_define_const(mRubygame,"K_MODE",INT2NUM(SDLK_MODE));

	
/* Miscellaneous function keys */
rb_define_const(mRubygame,"K_HELP",INT2NUM(SDLK_HELP));
rb_define_const(mRubygame,"K_PRINT",INT2NUM(SDLK_PRINT));
rb_define_const(mRubygame,"K_SYSREQ",INT2NUM(SDLK_SYSREQ));
rb_define_const(mRubygame,"K_BREAK",INT2NUM(SDLK_BREAK));
rb_define_const(mRubygame,"K_MENU",INT2NUM(SDLK_MENU));
rb_define_const(mRubygame,"K_POWER",INT2NUM(SDLK_POWER));
rb_define_const(mRubygame,"K_EURO",INT2NUM(SDLK_EURO));

/* Add any other keys here */
rb_define_const(mRubygame,"K_LAST",INT2NUM(SDLK_LAST));


#if 0	
/* key mods */
/* rb_define_const(mRubygame,"K_MOD_NONE",INT2NUM(KMOD_NONE)); */
/* rb_define_const(mRubygame,"K_MOD_LSHIFT",INT2NUM(KMOD_LSHIFT)); */
/* rb_define_const(mRubygame,"K_MOD_RSHIFT",INT2NUM(KMOD_RSHIFT)); */
/* rb_define_const(mRubygame,"K_MOD_LCTRL",INT2NUM(KMOD_LCTRL)); */
/* rb_define_const(mRubygame,"K_MOD_RCTRL",INT2NUM(KMOD_RCTRL)); */
/* rb_define_const(mRubygame,"K_MOD_LALT",INT2NUM(KMOD_LALT)); */
/* rb_define_const(mRubygame,"K_MOD_RALT",INT2NUM(KMOD_RALT)); */
/* rb_define_const(mRubygame,"K_MOD_LMETA",INT2NUM(KMOD_LMETA)); */
/* rb_define_const(mRubygame,"K_MOD_RMETA",INT2NUM(KMOD_RMETA)); */
/* rb_define_const(mRubygame,"K_MOD_NUM",INT2NUM(KMOD_NUM)); */
/* rb_define_const(mRubygame,"K_MOD_CAPS",INT2NUM(KMOD_CAPS)); */
/* rb_define_const(mRubygame,"K_MOD_MODE",INT2NUM(KMOD_MODE)); */
/* rb_define_const(mRubygame,"K_MOD_RESERVED",INT2NUM(KMOD_RESERVED)); */

/* rb_define_const(mRubygame,"K_MOD_CTRL",INT2NUM(KMOD_CTRL)); */
/* rb_define_const(mRubygame,"K_MOD_SHIFT",INT2NUM(KMOD_SHIFT)); */
/* rb_define_const(mRubygame,"K_MOD_ALT",INT2NUM(KMOD_ALT)); */
/* rb_define_const(mRubygame,"K_MOD_META",INT2NUM(KMOD_META)); */
#endif


/* Event constants */
rb_define_const(mRubygame,"NOEVENT",INT2NUM(SDL_NOEVENT));
rb_define_const(mRubygame,"ACTIVEEVENT",INT2NUM(SDL_ACTIVEEVENT));
rb_define_const(mRubygame,"KEYDOWN",INT2NUM(SDL_KEYDOWN));
rb_define_const(mRubygame,"KEYUP",INT2NUM(SDL_KEYUP));
rb_define_const(mRubygame,"MOUSEMOTION",INT2NUM(SDL_MOUSEMOTION));
rb_define_const(mRubygame,"MOUSEBUTTONDOWN",INT2NUM(SDL_MOUSEBUTTONDOWN));
rb_define_const(mRubygame,"MOUSEBUTTONUP",INT2NUM(SDL_MOUSEBUTTONUP));
rb_define_const(mRubygame,"JOYAXISMOTION",INT2NUM(SDL_JOYAXISMOTION));
rb_define_const(mRubygame,"JOYBALLMOTION",INT2NUM(SDL_JOYBALLMOTION));
rb_define_const(mRubygame,"JOYHATMOTION",INT2NUM(SDL_JOYHATMOTION));
rb_define_const(mRubygame,"JOYBUTTONDOWN",INT2NUM(SDL_JOYBUTTONDOWN));
rb_define_const(mRubygame,"JOYBUTTONUP",INT2NUM(SDL_JOYBUTTONUP));
rb_define_const(mRubygame,"QUIT",INT2NUM(SDL_QUIT));
rb_define_const(mRubygame,"SYSWMEVENT",INT2NUM(SDL_SYSWMEVENT));
rb_define_const(mRubygame,"VIDEORESIZE",INT2NUM(SDL_VIDEORESIZE));
rb_define_const(mRubygame,"VIDEOEXPOSE",INT2NUM(SDL_VIDEOEXPOSE));
rb_define_const(mRubygame,"USEREVENT",INT2NUM(SDL_USEREVENT));

	
/* Joystick constants */
rb_define_const(mRubygame,"HAT_CENTERED",INT2NUM(SDL_HAT_CENTERED));
rb_define_const(mRubygame,"HAT_UP",INT2NUM(SDL_HAT_UP));
rb_define_const(mRubygame,"HAT_RIGHT",INT2NUM(SDL_HAT_RIGHT));
rb_define_const(mRubygame,"HAT_DOWN",INT2NUM(SDL_HAT_DOWN));
rb_define_const(mRubygame,"HAT_LEFT",INT2NUM(SDL_HAT_LEFT));
rb_define_const(mRubygame,"HAT_RIGHTUP",INT2NUM(SDL_HAT_RIGHTUP));
rb_define_const(mRubygame,"HAT_RIGHTDOWN",INT2NUM(SDL_HAT_RIGHTDOWN));
rb_define_const(mRubygame,"HAT_LEFTUP",INT2NUM(SDL_HAT_LEFTUP));
rb_define_const(mRubygame,"HAT_LEFTDOWN",INT2NUM(SDL_HAT_LEFTDOWN));


/* Mixer constants */
/*
rb_define_const(mMixer,"FORMAT_U8",INT2NUM(AUDIO_U8));
rb_define_const(mMixer,"FORMAT_S8",INT2NUM(AUDIO_S8));
rb_define_const(mMixer,"FORMAT_U16LSB",INT2NUM(AUDIO_U16LSB));
rb_define_const(mMixer,"FORMAT_S16LSB",INT2NUM(AUDIO_S16LSB));
rb_define_const(mMixer,"FORMAT_U16MSB",INT2NUM(AUDIO_U16MSB));
rb_define_const(mMixer,"FORMAT_S16MSB",INT2NUM(AUDIO_S16MSB));
rb_define_const(mMixer,"FORMAT_U16",INT2NUM(AUDIO_U16));
rb_define_const(mMixer,"FORMAT_S16",INT2NUM(AUDIO_S16));
rb_define_const(mMixer,"FORMAT_U16SYS",INT2NUM(AUDIO_U16SYS));
rb_define_const(mMixer,"FORMAT_S16SYS",INT2NUM(AUDIO_S16SYS));
rb_define_const(mMixer,"CHANNELS",INT2NUM(MIX_CHANNELS));
rb_define_const(mMixer,"DEFAULT_FREQUENCY",INT2NUM(MIX_DEFAULT_FREQUENCY));
rb_define_const(mMixer,"DEFAULT_FORMAT",INT2NUM(MIX_DEFAULT_FORMAT));
rb_define_const(mMixer,"DEFAULT_CHANNELS",INT2NUM(MIX_DEFAULT_CHANNELS));
rb_define_const(mMixer,"MAX_VOLUME",INT2NUM(MIX_MAX_VOLUME));
*/

	
/* Mouse constants */
rb_define_const(mRubygame,"MOUSE_LEFT",INT2NUM(SDL_BUTTON_LEFT));
rb_define_const(mRubygame,"MOUSE_MIDDLE",INT2NUM(SDL_BUTTON_MIDDLE));
rb_define_const(mRubygame,"MOUSE_RIGHT",INT2NUM(SDL_BUTTON_RIGHT));
rb_define_const(mRubygame,"MOUSE_LMASK",INT2NUM(SDL_BUTTON_LMASK));
rb_define_const(mRubygame,"MOUSE_MMASK",INT2NUM(SDL_BUTTON_MMASK));
rb_define_const(mRubygame,"MOUSE_RMASK",INT2NUM(SDL_BUTTON_RMASK));


	
/* OpenGL constants */
rb_define_const(mRubygame,"GL_RED_SIZE",INT2NUM(SDL_GL_RED_SIZE));
rb_define_const(mRubygame,"GL_GREEN_SIZE",INT2NUM(SDL_GL_GREEN_SIZE));
rb_define_const(mRubygame,"GL_BLUE_SIZE",INT2NUM(SDL_GL_BLUE_SIZE));
rb_define_const(mRubygame,"GL_ALPHA_SIZE",INT2NUM(SDL_GL_ALPHA_SIZE));
rb_define_const(mRubygame,"GL_BUFFER_SIZE",INT2NUM(SDL_GL_BUFFER_SIZE));
rb_define_const(mRubygame,"GL_DOUBLEBUFFER",INT2NUM(SDL_GL_DOUBLEBUFFER));
rb_define_const(mRubygame,"GL_DEPTH_SIZE",INT2NUM(SDL_GL_DEPTH_SIZE));
rb_define_const(mRubygame,"GL_STENCIL_SIZE",INT2NUM(SDL_GL_STENCIL_SIZE));
rb_define_const(mRubygame,"GL_ACCUM_RED_SIZE",INT2NUM(SDL_GL_ACCUM_RED_SIZE));
rb_define_const(mRubygame,"GL_ACCUM_GREEN_SIZE",INT2NUM(SDL_GL_ACCUM_GREEN_SIZE));
rb_define_const(mRubygame,"GL_ACCUM_BLUE_SIZE",INT2NUM(SDL_GL_ACCUM_BLUE_SIZE));
rb_define_const(mRubygame,"GL_ACCUM_ALPHA_SIZE",INT2NUM(SDL_GL_ACCUM_ALPHA_SIZE));
	
}
