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

#ifdef HAVE_OPENGL

VALUE rbgm_gl_getattrib(VALUE module, VALUE attr)
{
  int val;
  if(SDL_GL_GetAttribute(NUM2INT(attr),&val)==-1)
    rb_raise(eSDLError,"GL get attribute failed: %s",SDL_GetError());
  return INT2NUM(val);
}

VALUE rbgm_gl_setattrib(VALUE module,VALUE attr,VALUE val)
{
  if(SDL_GL_SetAttribute(NUM2INT(attr),NUM2INT(val))==-1)
    rb_raise(eSDLError,"GL set attribute failed: %s",SDL_GetError());
  return Qnil;
}

VALUE rbgm_gl_swapbuffers(VALUE module)
{
  SDL_GL_SwapBuffers();
  return Qnil;
}

#endif

void Rubygame_Init_GL()
{
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
