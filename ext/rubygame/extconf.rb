#!/usr/bin/env ruby

# Modified from Ruby/SDL's extconf.rb

require 'mkmf'

sdl_config = with_config('sdl-config', 'sdl-config')

$CFLAGS += ' ' + `#{sdl_config} --cflags`.chomp
$LOCAL_LIBS += ' ' + `#{sdl_config} --libs`.chomp

if have_library("SDL_gfx") then
  $CFLAGS+= " -D HAVE_SDL_GFX "
end
if have_library("SDL_image") then
  $CFLAGS+= " -D HAVE_SDL_IMAGE "
end
if have_library("SDL_ttf") then
  $CFLAGS+= " -D HAVE_SDL_TTF "
end

if enable_config("opengl",false) then
  dir_config('x11','/usr/X11R6')
  
  $CFLAGS+= " -D DEF_OPENGL "
  if arg_config("--linkoglmodule",false) then
    $CFLAGS+= " -D INIT_OGLMODULE_FROM_SDL "
  end

  if /linux/ =~ CONFIG["arch"] then
    have_library("GL","glVertex3d")
  elsif /mingw32/ =~ CONFIG["arch"] then
    have_library("opengl32","glVertex3d")
    have_library("glu32","gluGetString")
  end
end

create_makefile("rubygame")
