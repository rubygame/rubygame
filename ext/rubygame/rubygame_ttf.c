/*
 *  Interface to SDL_ttf library, for rendering TrueType Fonts to Surfaces.
 *--
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
 *++
 */

#include "rubygame_shared.h"
#include "rubygame_ttf.h"
#include "rubygame_surface.h"

void Rubygame_Init_TTF();
VALUE cTTF;

VALUE rbgm_ttf_setup(VALUE);
VALUE rbgm_ttf_quit(VALUE);
VALUE rbgm_ttf_new(VALUE, VALUE, VALUE);

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

VALUE rbgm_ttf_sizetext(VALUE, VALUE);
VALUE rbgm_ttf_size_utf8(VALUE, VALUE);
VALUE rbgm_ttf_size_unicode(VALUE, VALUE);

VALUE rbgm_ttf_render(int, VALUE*, VALUE);
VALUE rbgm_ttf_render_utf8(int , VALUE*, VALUE);
VALUE rbgm_ttf_render_unicode(int , VALUE*, VALUE);

/*
 *  call-seq:
 *    setup  ->  nil
 *
 *  Attempt to setup the TTF class for use by initializing SDL_ttf.
 *  This *must* be called before the TTF class can be used.
 *  Raises SDLError if there is a problem initializing SDL_ttf.
 */
VALUE rbgm_ttf_setup(VALUE module)
{
	if(!TTF_WasInit() && TTF_Init()!=0)
		rb_raise(eSDLError,"could not setup TTF class: %s",TTF_GetError());
	return Qnil;
}

/*
 *  call-seq:
 *    quit  ->  nil
 *
 *  Clean up and quit SDL_ttf, making the TTF class unusable as a result
 *  (until it is setup again). This does not need to be called before Rubygame
 *  exits, as it will be done automatically.
 */
VALUE rbgm_ttf_quit(VALUE module)
{
	if(TTF_WasInit())
		TTF_Quit();
	return Qnil;
}

/*
 *  call-seq:
 *    new( file, size )  ->  TTF
 *
 *  Create a new TTF object, which can render text to a Surface with a
 *  particular font style and size.
 *
 *  This function takes these arguments:
 *  file:: filename of the TrueType font to use. Should be a +TTF+ or 
 *         +FON+ file.
 *  size:: point size (based on 72DPI). (That means the height in pixels from
 *         the bottom of the descent to the top of the ascent.)
 */
VALUE rbgm_ttf_new(VALUE class, VALUE vfile, VALUE vsize)
{
	VALUE self;
	TTF_Font *font;
	
	if(!TTF_WasInit())
		rb_raise(eSDLError,"Font module must be initialized before making new font.");
	font = TTF_OpenFont(StringValuePtr(vfile), NUM2INT(vsize));
	if(font == NULL)
		rb_raise(eSDLError,"could not load font: %s",TTF_GetError());

	self = Data_Wrap_Struct(cTTF,0,TTF_CloseFont,font);
	return self;
}

VALUE rbgm_ttf_initialize(int argc, VALUE *argv, VALUE self)
{ 
	return self;
}


/*--
* Checks to see if the TTF font wrapped in the self VALUE  has the style in the parameter style.
* ++
*/ 
static VALUE RBGM_ttf_get_style(VALUE self, int style) 
{
	TTF_Font *font;
	int mystyle;

	Data_Get_Struct(self, TTF_Font, font);
	mystyle = TTF_GetFontStyle(font);

	if ((mystyle & style) == style) return Qtrue;
	return Qfalse;
}


/*--
* Sets or unsets the style in int style for the TTF font wrapped in the self VALUE,
* using enable to determine what to do. If enable is Qtrue, the style is set, if it is 
* Qfalse, the style is unset. 
* ++
*/ 
static VALUE RBGM_ttf_set_style(VALUE self, VALUE enable, int style) 
{
	int oldstyle;	
	TTF_Font *font;

	Data_Get_Struct(self,TTF_Font,font);
	oldstyle = TTF_GetFontStyle(font);
	
	if(((oldstyle & style) ==style) && !RTEST(enable)) 
		{   /* The style is set but we want to remove it. */
			TTF_SetFontStyle(font,oldstyle^style);
			return Qtrue;
			/* The old value */
		} 
	else if( RTEST(enable) )  
		{   /* The style is not set and we want to add it. */
			TTF_SetFontStyle(font,oldstyle|style);
			return Qfalse;			
			/* The old value */
		}

	return enable;
}

/*  call-seq:
 *    bold  ->  Bool
 *
 *  True if bolding is enabled for the font.
 */
VALUE rbgm_ttf_getbold(VALUE self)
{
	return RBGM_ttf_get_style(self, TTF_STYLE_BOLD); 
}

/*  call-seq:
 *    bold = value  ->  Bool
 *
 *  Set whether bolding is enabled for this font. Returns the old value.
 */
VALUE rbgm_ttf_setbold(VALUE self, VALUE bold)
{
	return RBGM_ttf_set_style(self, bold, TTF_STYLE_BOLD); 
}

/*  call-seq:
 *    italic  ->  Bool
 *
 *  True if italicizing is enabled for the font.
 */
VALUE rbgm_ttf_getitalic(VALUE self)
{
	return RBGM_ttf_get_style(self, TTF_STYLE_ITALIC); 
}

/*  call-seq:
 *    italic = value  ->  Bool
 *
 *  Set whether italicizing is enabled for this font. Returns the old value.
 */
VALUE rbgm_ttf_setitalic(VALUE self,VALUE italic)
{
	return RBGM_ttf_set_style(self, italic, TTF_STYLE_ITALIC); 
}

/*  call-seq:
 *    underline  ->  Bool
 *
 *  True if underlining is enabled for the font.
 */
VALUE rbgm_ttf_getunderline(VALUE self)
{
	return RBGM_ttf_get_style(self, TTF_STYLE_UNDERLINE); 
}

/*  call-seq:
 *    underline = value  ->  Bool
 *
 *  Set whether underlining is enabled for this font. Returns the old value.
 */
VALUE rbgm_ttf_setunderline(VALUE self, VALUE underline)
{
	return RBGM_ttf_set_style(self, underline, TTF_STYLE_UNDERLINE); 
}

/*  call-seq:
 *    height  ->  Integer
 *
 *  Return the biggest height (bottom to top; in pixels) of all glyphs in the 
 *  font.
 */
VALUE rbgm_ttf_height(VALUE self)
{
	TTF_Font *font;
	Data_Get_Struct(self,TTF_Font,font);
	return INT2NUM(TTF_FontHeight(font));
}

/*  call-seq:
 *    ascent  ->  Integer
 *
 *  Return the biggest ascent (baseline to top; in pixels) of all glyphs in 
 *  the font.
 */
VALUE rbgm_ttf_ascent(VALUE self)
{
	TTF_Font *font;
	Data_Get_Struct(self,TTF_Font,font);
	return INT2NUM(TTF_FontAscent(font));
}

/*  call-seq:
 *    descent  ->  Integer
 *
 *  Return the biggest descent (baseline to bottom; in pixels) of all glyphs in
 *  the font.
 */
VALUE rbgm_ttf_descent(VALUE self)
{
	TTF_Font *font;
	Data_Get_Struct(self,TTF_Font,font);
	return INT2NUM(TTF_FontDescent(font));
}

/*  call-seq:
 *    lineskip  ->  Integer
 *
 *  Return the recommended distance (in pixels) from a point on a line of text
 *  to the same point on the line of text below it.
 */
VALUE rbgm_ttf_lineskip(VALUE self)
{
	TTF_Font *font;
	Data_Get_Struct(self,TTF_Font,font);
	return INT2NUM(TTF_FontLineSkip(font));
}

/*
 * call-seq:
 *   size_text(text) -> [ width, height ]
 * 
 * The width and height the text would be if
 * it were rendered, without the overhead of
 * actually rendering it.
 */
VALUE rbgm_ttf_sizetext(VALUE self, VALUE string)
{
	TTF_Font *font;
	int w;
	int h;
	VALUE result;
	Data_Get_Struct(self, TTF_Font,font);
	result = rb_ary_new();
	
	TTF_SizeText(font,StringValuePtr(string),&w,&h);
	
	rb_ary_push(result, INT2NUM(w));
	rb_ary_push(result, INT2NUM(h));
	
	return result;
}

/*
 * call-seq:
 *   size_utf8(text) -> [ width, height ]
 * 
 * The width and height the UTF-8 encoded text would be if
 * it were rendered, without the overhead of
 * actually rendering it.
 */
 
VALUE rbgm_ttf_size_utf8(VALUE self, VALUE string)
{
	TTF_Font *font;
	int w;
	int h;
	VALUE result;
	Data_Get_Struct(self, TTF_Font,font);
	result = rb_ary_new();
	
	TTF_SizeUTF8(font,StringValuePtr(string),&w,&h);
	
	rb_ary_push(result, INT2NUM(w));
	rb_ary_push(result, INT2NUM(h));
	
	return result;
}

/*
 * call-seq:
 *   size_unicode(text) -> [ width, height ]
 * 
 * The width and height the UNICODE encoded text would be if
 * it were rendered, without the overhead of
 * actually rendering it.
 */
 
VALUE rbgm_ttf_size_unicode(VALUE self, VALUE string)
{
	TTF_Font *font;
	int w;
	int h;
	VALUE result;
	Data_Get_Struct(self, TTF_Font,font);
	result = rb_ary_new();
	TTF_SizeUNICODE(font,(Uint16*)StringValuePtr(string),&w,&h);
	
	rb_ary_push(result, INT2NUM(w));
	rb_ary_push(result, INT2NUM(h));
	
	return result;
}

/*
* Helper function for color handling for the rendering functions.
*/

static void RBGM_array_to_color(SDL_Color * color, VALUE arr) {
	if( RTEST(arr) )
	{
		arr = convert_to_array(arr);
		color->r = NUM2UINT(rb_ary_entry(arr, 0));
		color->g = NUM2UINT(rb_ary_entry(arr, 1));
		color->b = NUM2UINT(rb_ary_entry(arr, 2));
	}
}

/*
 *--
 * TODO: Refactor/integrate #render, #render_utf8, and #render_unicode 
 *++
 */

/*  call-seq:
 *    render(string, aa, fg, bg)  ->  Surface
 *
 *  Renders a string to a Surface with the font's style and the given color(s).
 *
 *  This method takes these arguments:
 *  string:: the text string to render
 *  aa::     Use anti-aliasing if true. Enabling this makes the text
 *           look much nicer (smooth curves), but is much slower.
 *  fg::     the color to render the text, in the form [r,g,b]
 *  bg::     the color to use as a background for the text. This option can
 *           be omitted to have a transparent background.
 */
VALUE rbgm_ttf_render(int argc, VALUE *argv, VALUE self)
{
	SDL_Surface *surf;
	TTF_Font *font;
	SDL_Color fore, back; /* foreground and background colors */
	VALUE vstring, vaa, vfg, vbg;

	rb_scan_args(argc, argv, "31", &vstring, &vaa, &vfg, &vbg);

	Data_Get_Struct(self,TTF_Font,font);

	vfg = convert_to_array(vfg);
	fore.r = NUM2UINT(rb_ary_entry(vfg,0));
	fore.g = NUM2UINT(rb_ary_entry(vfg,1));
	fore.b = NUM2UINT(rb_ary_entry(vfg,2));

	if( RTEST(vbg) )
	{
		vbg = convert_to_array(vbg);
		back.r = NUM2UINT(rb_ary_entry(vbg,0));
		back.g = NUM2UINT(rb_ary_entry(vbg,1));
		back.b = NUM2UINT(rb_ary_entry(vbg,2));
	}

	if( RTEST(vaa) ) /* anti-aliasing enabled */
	{
		if( RTEST(vbg) ) /* background color provided */
			surf = TTF_RenderText_Shaded(font,StringValuePtr(vstring),fore,back);
		else /* no background color */
			surf = TTF_RenderText_Blended(font,StringValuePtr(vstring),fore);
	}
	else /* anti-aliasing not enabled */
	{
		if( RTEST(vbg) ) /* background color provided */	
		{
			/* remove colorkey, set color index 0 to background color */
			surf = TTF_RenderText_Solid(font,StringValuePtr(vstring),fore);
			SDL_SetColors(surf,&back,0,1);
			SDL_SetColorKey(surf,0,0);
		}
		else /* no background color */
		{
			surf = TTF_RenderText_Solid(font,StringValuePtr(vstring),fore);
		}
	}

	if(surf==NULL)
		rb_raise(eSDLError,"could not render font object: %s",TTF_GetError());
	return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,surf);
}

 
/*  call-seq:
 *    render_utf8(string, aa, fg, bg)  ->  Surface
 *
 *  Renders a string to a Surface with the font's style and the given color(s).
 *
 *  This method takes these arguments:
 *  string:: the text string to render
 *  aa::     Use anti-aliasing if true. Enabling this makes the text
 *           look much nicer (smooth curves), but is much slower.
 *  fg::     the color to render the text, in the form [r,g,b]
 *  bg::     the color to use as a background for the text. This option can
 *           be omitted to have a transparent background.
 */
VALUE rbgm_ttf_render_utf8(int argc, VALUE *argv, VALUE self)
{
 	SDL_Surface *surf;
 	TTF_Font *font;
 	SDL_Color fore, back; /* foreground and background colors */
	VALUE vstring, vaa, vfg, vbg;
 
	rb_scan_args(argc, argv, "31", &vstring, &vaa, &vfg, &vbg);
 
 	Data_Get_Struct(self,TTF_Font,font);
 
	vfg = convert_to_array(vfg);
	fore.r = NUM2UINT(rb_ary_entry(vfg,0));
	fore.g = NUM2UINT(rb_ary_entry(vfg,1));
	fore.b = NUM2UINT(rb_ary_entry(vfg,2));

	if( RTEST(vbg) )
	{
		vbg = convert_to_array(vbg);
		back.r = NUM2UINT(rb_ary_entry(vbg,0));
		back.g = NUM2UINT(rb_ary_entry(vbg,1));
		back.b = NUM2UINT(rb_ary_entry(vbg,2));
	}

	if( RTEST(vaa) ) /* anti-aliasing enabled */
 	{
 		if( RTEST(vbg) ) /* background color provided */
 			surf = TTF_RenderUTF8_Shaded(font,StringValuePtr(vstring),fore,back);
 		else /* no background color */
 			surf = TTF_RenderUTF8_Blended(font,StringValuePtr(vstring),fore);
 	}
 	else /* anti-aliasing not enabled */
 	{
 		if( RTEST(vbg) ) /* background color provided */	
 		{
 			/* remove colorkey, set color index 0 to background color */
 			surf = TTF_RenderUTF8_Solid(font,StringValuePtr(vstring),fore);
 			SDL_SetColors(surf,&back,0,1);
 			SDL_SetColorKey(surf,0,0);
 		}
 		else /* no background color */
 		{
 			surf = TTF_RenderUTF8_Solid(font,StringValuePtr(vstring),fore);
 		}
 	}
 
 	if(surf==NULL)
 		rb_raise(eSDLError,"could not render font object: %s",TTF_GetError());
 	return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,surf);
}
 
/*  call-seq:
 *    render_unicode(string, aa, fg, bg)  ->  Surface
 *
 *  Renders a string to a Surface with the font's style and the given color(s).
 *
 *  This method takes these arguments:
 *  string:: the text string to render
 *  aa::     Use anti-aliasing if true. Enabling this makes the text
 *           look much nicer (smooth curves), but is much slower.
 *  fg::     the color to render the text, in the form [r,g,b]
 *  bg::     the color to use as a background for the text. This option can
 *           be omitted to have a transparent background.
 */
VALUE rbgm_ttf_render_unicode(int argc, VALUE *argv, VALUE self)
{
	/* TODO:... ->unicode */
 	SDL_Surface *surf;
 	TTF_Font *font;
 	SDL_Color fore, back; /* foreground and background colors */
 	VALUE vstring, vaa, vfg, vbg;
 
	rb_scan_args(argc, argv, "31", &vstring, &vaa, &vfg, &vbg);
 
 	Data_Get_Struct(self,TTF_Font,font);
 
	vfg = convert_to_array(vfg);
	fore.r = NUM2UINT(rb_ary_entry(vfg,0));
	fore.g = NUM2UINT(rb_ary_entry(vfg,1));
	fore.b = NUM2UINT(rb_ary_entry(vfg,2));

	if( RTEST(vbg) )
	{
		vbg = convert_to_array(vbg);
		back.r = NUM2UINT(rb_ary_entry(vbg,0));
		back.g = NUM2UINT(rb_ary_entry(vbg,1));
		back.b = NUM2UINT(rb_ary_entry(vbg,2));
	}

	if( RTEST(vaa) ) /* anti-aliasing enabled */
 	{
 		if( RTEST(vbg) ) /* background color provided */
 			surf = TTF_RenderUNICODE_Shaded(font,(Uint16*)StringValuePtr(vstring),fore,back);
 		else /* no background color */
 			surf = TTF_RenderUNICODE_Blended(font,(Uint16*)StringValuePtr(vstring),fore);
 	}
 	else /* anti-aliasing not enabled */
 	{
 		if( RTEST(vbg) ) /* background color provided */	
 		{
 			/* remove colorkey, set color index 0 to background color */
 			surf = TTF_RenderUNICODE_Solid(font,(Uint16*)StringValuePtr(vstring),fore);
 			SDL_SetColors(surf,&back,0,1);
 			SDL_SetColorKey(surf,0,0);
 		}
 		else /* no background color */
 		{
 			surf = TTF_RenderUNICODE_Solid(font,(Uint16*)StringValuePtr(vstring),fore);
 		}
 	}
 
 	if(surf==NULL)
 		rb_raise(eSDLError,"could not render font object: %s",TTF_GetError());
 	return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,surf);
}

/*
 *  Document-class: Rubygame::TTF
 *
 *  TTF provides an interface to SDL_ttf, allowing TrueType Font files to be
 *  loaded and used to render text to Surfaces.
 *
 *  The TTF class *must* be initialized with the #setup method before any
 *  TTF objects can be created or used.
 *
 *  This class is only usable if Rubygame was compiled with the SDL_ttf
 *  library. You may test if this feature is available with the #usable?
 *  method. If you need more flexibility, you can check the library version
 *  that Rubygame was compiled against with the #version method.
 */
void Init_rubygame_ttf()
{
#if 0
	mRubygame = rb_define_module("Rubygame");
#endif

  Init_rubygame_shared();

  rb_hash_aset(rb_ivar_get(mRubygame,rb_intern("VERSIONS")),
               ID2SYM(rb_intern("sdl_ttf")),
               rb_ary_new3(3,
                           INT2NUM(SDL_TTF_MAJOR_VERSION),
                           INT2NUM(SDL_TTF_MINOR_VERSION),
                           INT2NUM(SDL_TTF_PATCHLEVEL)));


	cTTF = rb_define_class_under(mRubygame,"TTF",rb_cObject);

	rb_define_singleton_method(cTTF,"new",rbgm_ttf_new,2);
	rb_define_singleton_method(cTTF,"setup",rbgm_ttf_setup,0);
	rb_define_singleton_method(cTTF,"quit",rbgm_ttf_quit,0);
	
	rb_define_method(cTTF,"initialize",rbgm_ttf_initialize,-1);
	rb_define_method(cTTF,"bold",rbgm_ttf_getbold,0);
	rb_define_method(cTTF,"bold=",rbgm_ttf_setbold,1);
	rb_define_alias( cTTF,"b","bold");
	rb_define_alias( cTTF,"b=","bold=");
	rb_define_method(cTTF,"italic",rbgm_ttf_getitalic,0);
	rb_define_method(cTTF,"italic=",rbgm_ttf_setitalic,1);
	rb_define_alias( cTTF,"i","italic");
	rb_define_alias( cTTF,"i=","italic=");
	rb_define_method(cTTF,"underline",rbgm_ttf_getunderline,0);
	rb_define_method(cTTF,"underline=",rbgm_ttf_setunderline,1);
	rb_define_alias( cTTF,"u","underline");
	rb_define_alias( cTTF,"u=","underline=");
	rb_define_method(cTTF,"height",rbgm_ttf_height,0);
	rb_define_method(cTTF,"ascent",rbgm_ttf_ascent,0);
	rb_define_method(cTTF,"descent",rbgm_ttf_descent,0);
	rb_define_method(cTTF,"line_skip",rbgm_ttf_lineskip,0);
	rb_define_method(cTTF,"size_text",rbgm_ttf_sizetext,1);
	rb_define_method(cTTF,"size_utf8",rbgm_ttf_size_utf8, 1);
	rb_define_method(cTTF,"size_unicode",rbgm_ttf_size_unicode, 1);
	rb_define_method(cTTF,"render",rbgm_ttf_render,-1);
	rb_define_method(cTTF,"render_utf8",rbgm_ttf_render_utf8,-1);
	rb_define_method(cTTF,"render_unicode",rbgm_ttf_render_unicode,-1);

}
