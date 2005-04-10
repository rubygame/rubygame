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

#include "rubygame.h"

#ifdef HAVE_SDL_TTF_H
#include "SDL_ttf.h"

/* Return the major, minor, and patch numbers for SDL_ttf */
VALUE rbgm_font_version(VALUE module)
{ 
  return rb_ary_new3(3,
					 INT2NUM(SDL_TTF_MAJOR_VERSION),
					 INT2NUM(SDL_TTF_MINOR_VERSION),
					 INT2NUM(SDL_TTF_PATCHLEVEL));
}

VALUE rbgm_font_init(VALUE module)
{
	if(TTF_Init()!=0)
		rb_raise(eSDLError,"could not initialize Font module: %s",TTF_GetError());
	return Qnil;
}

VALUE rbgm_font_quit(VALUE module)
{
	if(TTF_WasInit())
		TTF_Quit();
	return Qnil;
}

VALUE rbgm_ttf_new(int argc, VALUE *argv, VALUE class)
{
	VALUE self;
	TTF_Font *font;
	
	if(!TTF_WasInit())
		rb_raise(eSDLError,"Font module must be initialized before making new font.");
	font = TTF_OpenFont(StringValuePtr(argv[0]), NUM2INT(argv[1]));
	if(font == NULL)
		rb_raise(eSDLError,"could not load font: %s",TTF_GetError());

	self = Data_Wrap_Struct(cTTF,0,TTF_CloseFont,font);
	rb_obj_call_init(self,argc,argv);
	return self;
}

VALUE rbgm_ttf_initialize(int argc, VALUE *argv, VALUE self)
{ 
	return self;
}

VALUE rbgm_ttf_getbold(VALUE self)
{
	TTF_Font *font;
	int style;

	Data_Get_Struct(self,TTF_Font,font);
	style = TTF_GetFontStyle(font);
	if((style & TTF_STYLE_BOLD) == TTF_STYLE_BOLD)
		return Qtrue;
	else
		return Qfalse;
}

VALUE rbgm_ttf_setbold(VALUE self,VALUE bold)
{
	TTF_Font *font;
	int style;

	Data_Get_Struct(self,TTF_Font,font);
	style = TTF_GetFontStyle(font);
	if((style & TTF_STYLE_BOLD) == TTF_STYLE_BOLD && !bold)
		TTF_SetFontStyle(font,style^TTF_STYLE_BOLD);
	else if(bold)
		TTF_SetFontStyle(font,style|TTF_STYLE_BOLD);
	return self;
}

VALUE rbgm_ttf_getitalic(VALUE self)
{
	TTF_Font *font;
	int style;

	Data_Get_Struct(self,TTF_Font,font);
	style = TTF_GetFontStyle(font);
	if((style & TTF_STYLE_ITALIC) == TTF_STYLE_ITALIC)
		return Qtrue;
	else
		return Qfalse;
}

VALUE rbgm_ttf_setitalic(VALUE self,VALUE italic)
{
	TTF_Font *font;
	int style;

	Data_Get_Struct(self,TTF_Font,font);
	style = TTF_GetFontStyle(font);
	if((style & TTF_STYLE_ITALIC) == TTF_STYLE_ITALIC && !italic)
		TTF_SetFontStyle(font,style^TTF_STYLE_ITALIC);
	else if(italic)
		TTF_SetFontStyle(font,style|TTF_STYLE_ITALIC);
	return self;
}

VALUE rbgm_ttf_getunderline(VALUE self)
{
	TTF_Font *font;
	int style;

	Data_Get_Struct(self,TTF_Font,font);
	style = TTF_GetFontStyle(font);
	if((style & TTF_STYLE_UNDERLINE) == TTF_STYLE_UNDERLINE)
		return Qtrue;
	else
		return Qfalse;
}

VALUE rbgm_ttf_setunderline(VALUE self,VALUE underline)
{
	TTF_Font *font;
	int style;

	Data_Get_Struct(self,TTF_Font,font);
	style = TTF_GetFontStyle(font);
	if((style & TTF_STYLE_UNDERLINE) == TTF_STYLE_UNDERLINE && !underline)
		TTF_SetFontStyle(font,style^TTF_STYLE_UNDERLINE);
	else if(underline)
		TTF_SetFontStyle(font,style|TTF_STYLE_UNDERLINE);
	return self;
}

VALUE rbgm_ttf_height(VALUE self)
{
	TTF_Font *font;
	Data_Get_Struct(self,TTF_Font,font);
	return INT2NUM(TTF_FontHeight(font));
}

VALUE rbgm_ttf_ascent(VALUE self)
{
	TTF_Font *font;
	Data_Get_Struct(self,TTF_Font,font);
	return INT2NUM(TTF_FontAscent(font));
}

VALUE rbgm_ttf_descent(VALUE self)
{
	TTF_Font *font;
	Data_Get_Struct(self,TTF_Font,font);
	return INT2NUM(TTF_FontDescent(font));
}

VALUE rbgm_ttf_lineskip(VALUE self)
{
	TTF_Font *font;
	Data_Get_Struct(self,TTF_Font,font);
	return INT2NUM(TTF_FontLineSkip(font));
}

VALUE rbgm_ttf_render(int argc, VALUE *argv, VALUE self)
{
	SDL_Surface *surf;
	TTF_Font *font;
	int antialias;
	SDL_Color fore, back; /* foreground and background colors */

	if(argc<3)
		rb_raise(rb_eArgError,"wrong number of arguments (%d for 3)",argc);

	Data_Get_Struct(self,TTF_Font,font);

	antialias = argv[1];
	fore.r = NUM2UINT(rb_ary_entry(argv[2],0));
	fore.g = NUM2UINT(rb_ary_entry(argv[2],1));
	fore.b = NUM2UINT(rb_ary_entry(argv[2],2));

	if(argc>3)
	{
		back.r = NUM2UINT(rb_ary_entry(argv[3],0));
		back.g = NUM2UINT(rb_ary_entry(argv[3],1));
		back.b = NUM2UINT(rb_ary_entry(argv[3],2));
	}

	if(antialias) /* anti-aliasing enabled */
	{
		if(argc>3) /* background color provided */
			surf = TTF_RenderText_Shaded(font,StringValuePtr(argv[0]),fore,back);
		else /* no background color */
			surf = TTF_RenderText_Blended(font,StringValuePtr(argv[0]),fore);
	}
	else /* anti-aliasing not enabled */
	{
		if(argc>3) /* background color provided */	
		{
			/* remove colorkey, set color index 0 to background color */
			SDL_Color colors[] = {back};
			surf = TTF_RenderText_Solid(font,StringValuePtr(argv[0]),fore);
			SDL_SetColors(surf,colors,0,1);
			SDL_SetColorKey(surf,0,0);
		}
		else /* no background color */
		{
			surf = TTF_RenderText_Solid(font,StringValuePtr(argv[0]),fore);
		}
	}

	if(surf==NULL)
		rb_raise(eSDLError,"could not render font object: %s",TTF_GetError());
	return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,surf);
}

void Rubygame_Init_Font()
{
	mFont = rb_define_module_under(mRubygame,"Font");
	rb_define_module_function(mFont,"usable?",rbgm_usable,0);
	rb_define_module_function(mFont,"version",rbgm_font_version,0);
	rb_define_module_function(mFont,"init",rbgm_font_init,0);
	rb_define_module_function(mFont,"quit",rbgm_font_quit,0);

	cTTF = rb_define_class_under(mFont,"TTF",rb_cObject);
	rb_define_singleton_method(cTTF,"new",rbgm_ttf_new,-1);
	rb_define_method(cTTF,"initialize",rbgm_ttf_initialize,-1);
	rb_define_method(cTTF,"bold",rbgm_ttf_getbold,0);
	rb_define_method(cTTF,"bold=",rbgm_ttf_setbold,1);
	rb_define_method(cTTF,"italic",rbgm_ttf_getitalic,0);
	rb_define_method(cTTF,"italic=",rbgm_ttf_setitalic,1);
	rb_define_method(cTTF,"underline",rbgm_ttf_getunderline,0);
	rb_define_method(cTTF,"underline=",rbgm_ttf_setunderline,1);
	rb_define_method(cTTF,"height",rbgm_ttf_height,0);
	rb_define_method(cTTF,"ascent",rbgm_ttf_ascent,0);
	rb_define_method(cTTF,"descent",rbgm_ttf_descent,0);
	rb_define_method(cTTF,"line_skip",rbgm_ttf_lineskip,0);
	rb_define_method(cTTF,"render",rbgm_ttf_render,-1);
}

#else /* HAVE_SDL_TTF_H */

/* We don't have SDL_ttf, so the "version" is [0,0,0] */
VALUE rbgm_font_version(VALUE module)
{ 
  return rb_ary_new3(3,
					 INT2NUM(0),
					 INT2NUM(0),
					 INT2NUM(0));
}

void Rubygame_Init_Font()
{
	mFont = rb_define_module_under(mRubygame,"Font");
	rb_define_module_function(mFont,"usable?",rbgm_unusable,0);
	rb_define_module_function(mFont,"version",rbgm_font_version,0);
	rb_define_module_function(mFont,"init",rbgm_dummy,-1);
	rb_define_module_function(mFont,"quit",rbgm_dummy,-1);

	cTTF = rb_define_class_under(mFont,"TTF",rb_cObject);
	rb_define_singleton_method(cTTF,"new",rbgm_dummy,-1);
	rb_define_method(cTTF,"initialize",rbgm_dummy,-1);
	/* No TTF objects can be made, so the other funcs are unneeded. Maybe. */
}

#endif /* HAVE_SDL_TTF_H */
