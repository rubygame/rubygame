#!/usr/bin/env ruby

# Modified from Ruby/SDL's extconf.rb

require 'mkmf'

sdl_config = with_config('sdl-config', 'sdl-config')

$CFLAGS += ' -Wall ' + `#{sdl_config} --cflags`.chomp
$LOCAL_LIBS += ' ' + `#{sdl_config} --libs`.chomp

have_header("SDL_gfxPrimitives.h")
have_header("SDL_rotozoom.h")
have_header("SDL_image.h")
have_header("SDL_ttf.h")

#if enable_config("opengl",false) then
#	dir_config('x11','/usr/X11R6')
#  
#	$CFLAGS+= " -D DEF_OPENGL "
#	if arg_config("--linkoglmodule",false) then
#		$CFLAGS+= " -D INIT_OGLMODULE_FROM_SDL "
#	end
#
#	if /linux/ =~ CONFIG["arch"] then
#		have_library("GL","glVertex3d")
#	elsif /mingw32/ =~ CONFIG["arch"] then
#		have_library("opengl32","glVertex3d")
#		have_library("glu32","gluGetString")
#	end
#end

create_makefile("rubygame")
