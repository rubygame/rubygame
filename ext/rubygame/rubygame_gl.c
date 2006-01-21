/*
 *  GL module -- OpenGL attribute methods
 * --
 *  Rubygame -- Ruby classes and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004-2006  John 'jacius' Croisant
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
 * ++
 */

#include "rubygame.h"
#include "rubygame_gl.h"

/* --
 * Most code is directly from Ruby/SDL's rubysdl_opengl.c file.
 *
 * Many thanks for saving me some time. :)
 * ++
 */

VALUE mGL;
void Rubygame_Init_GL();
void Define_GL_Constants();

#ifdef HAVE_OPENGL

VALUE rbgm_gl_getattrib(VALUE, VALUE);
VALUE rbgm_gl_setattrib(VALUE,VALUE,VALUE);
VALUE rbgm_gl_swapbuffers(VALUE);

/*  call-seq:
 *    get_attrib( attrib )  ->  Integer
 *
 *  Return the value of the the SDL/OpenGL attribute identified by +attrib+,
 *  which should be one of the constants defined in the Rubygame::GL module.
 *  See #set_attrib for a list of attribute constants.
 *
 *  This method is useful after using #set_attrib and calling Screen#set_mode,
 *  to make sure the attribute is the expected value.
 */
VALUE rbgm_gl_getattrib(VALUE module, VALUE attr)
{
  int val;
  if(SDL_GL_GetAttribute(NUM2INT(attr),&val)==-1)
    rb_raise(eSDLError,"GL get attribute failed: %s",SDL_GetError());
  return INT2NUM(val);
}

/*  call-seq:
 *    set_attrib( attrib, value )  ->  nil
 *
 *  Set the SDL/OpenGL attribute +attrib+ to +value+. This should be called
 *  *before* you call Screen#set_mode with the OPENGL flag. You may wish to
 *  use #get_attrib after calling Screen#set_mode to confirm that the attribute
 *  is set to the desired value.
 *
 *  The full list of SDL/OpenGL attribute identifier constants (located under
 *  the Rubygame::GL module) is as follows:
 *
 *  RED_SIZE::         Size of framebuffer red component, in bits.
 *  GREEN_SIZE::       Size of framebuffer green component, in bits.
 *  BLUE_SIZE::        Size of framebuffer blue component, in bits.
 *  ALPHA_SIZE::       Size of framebuffer alpha (opacity) component, in bits.
 *  BUFFER_SIZE::      Size of framebuffer, in bits.
 *  DOUBLEBUFFER::     Enable or disable double-buffering.
 *  DEPTH_SIZE::       Size of depth buffer, in bits.
 *  STENCIL_SIZE::     Size of stencil buffer, in bits.
 *  ACCUM_RED_SIZE::   Size of accumulation buffer red component, in bits.
 *  ACCUM_GREEN_SIZE:: Size of accumulation buffer green component, in bits.
 *  ACCUM_BLUE_SIZE::  Size of accumulation buffer blue component, in bits.
 *  ACCUM_ALPHA_SIZE:: Size of accumulation buffer alpha component, in bits.
 *  
 */
VALUE rbgm_gl_setattrib(VALUE module,VALUE attr,VALUE val)
{
  if(SDL_GL_SetAttribute(NUM2INT(attr),NUM2INT(val))==-1)
    rb_raise(eSDLError,"GL set attribute failed: %s",SDL_GetError());
  return Qnil;
}

/*  call-seq:
 *    swap_buffers( )  ->  nil
 *
 *  Swap the back and front buffers, for double-buffered OpenGL displays.
 *  Should be safe to use (albeit with no effect) on single-buffered OpenGL 
 *  displays.
 */
VALUE rbgm_gl_swapbuffers(VALUE module)
{
  SDL_GL_SwapBuffers();
  return Qnil;
}

#endif

/*  Document-module: Rubygame::GL
 *
 *  The GL module provides an interface to SDL's OpenGL-related functions,
 *  allowing a Rubygame application to create hardware-accelerated 3D graphics
 *  with OpenGL.
 *
 *  Please note that Rubygame itself does not provide an interface to OpenGL
 *  functions -- only functions which allow Rubygame to work together with
 *  OpenGL. You will need to use another library, for example 
 *  ruby-opengl[http://www2.giganet.net/~yoshi/], to actually create graphics
 *  with OpenGL.
 *
 *  Users who wish to use Rubygame Surfaces as textures in OpenGL will want
 *  to see also the Surface#pixels method.
 */
void Rubygame_Init_GL()
{
#if 0
	/* Pretend to define Rubygame module, so RDoc knows about it: */
	mRubygame = rb_define_module("Rubygame");
#endif

  mGL = rb_define_module_under(mRubygame,"GL");
  Define_GL_Constants();

#ifdef HAVE_OPENGL
  rb_define_module_function(mGL,"usable?", rbgm_usable, 0);
  rb_define_module_function(mGL,"get_attrib", rbgm_gl_getattrib, 1);
  rb_define_module_function(mGL,"set_attrib", rbgm_gl_setattrib, 2);
  rb_define_module_function(mGL,"swap_buffers", rbgm_gl_swapbuffers, 0);
#else
  rb_define_module_function(mGL,"usable?", rbgm_unusable, 0);
  rb_define_module_function(mGL,"get_attrib", rbgm_dummy, -1);
  rb_define_module_function(mGL,"set_attrib", rbgm_dummy, -1);
  rb_define_module_function(mGL,"swap_buffers", rbgm_dummy, -1);
#endif

}

void Define_GL_Constants()
{
  rb_define_const(mGL,"RED_SIZE",INT2NUM(SDL_GL_RED_SIZE));
  rb_define_const(mGL,"GREEN_SIZE",INT2NUM(SDL_GL_GREEN_SIZE));
  rb_define_const(mGL,"BLUE_SIZE",INT2NUM(SDL_GL_BLUE_SIZE));
  rb_define_const(mGL,"ALPHA_SIZE",INT2NUM(SDL_GL_ALPHA_SIZE));
  rb_define_const(mGL,"BUFFER_SIZE",INT2NUM(SDL_GL_BUFFER_SIZE));
  rb_define_const(mGL,"DOUBLEBUFFER",INT2NUM(SDL_GL_DOUBLEBUFFER));
  rb_define_const(mGL,"DEPTH_SIZE",INT2NUM(SDL_GL_DEPTH_SIZE));
  rb_define_const(mGL,"STENCIL_SIZE",INT2NUM(SDL_GL_STENCIL_SIZE));
  rb_define_const(mGL,"ACCUM_RED_SIZE",INT2NUM(SDL_GL_ACCUM_RED_SIZE));
  rb_define_const(mGL,"ACCUM_GREEN_SIZE",INT2NUM(SDL_GL_ACCUM_GREEN_SIZE));
  rb_define_const(mGL,"ACCUM_BLUE_SIZE",INT2NUM(SDL_GL_ACCUM_BLUE_SIZE));
  rb_define_const(mGL,"ACCUM_ALPHA_SIZE",INT2NUM(SDL_GL_ACCUM_ALPHA_SIZE));
}
