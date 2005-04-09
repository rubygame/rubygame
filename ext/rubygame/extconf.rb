#!/usr/bin/env ruby

# Modified from Ruby/SDL's extconf.rb

require 'mkmf'

sdl_config = with_config('sdl-config', 'sdl-config')

$CFLAGS += ' -Wall ' + `#{sdl_config} --cflags`.chomp
$LOCAL_LIBS += ' ' + `#{sdl_config} --libs`.chomp

gfxincluded = false

if have_header("SDL_gfxPrimitives.h")
	$libs = "-lSDL_gfx "+$libs unless gfxincluded
	gfxincluded = true
end
if have_header("SDL_rotozoom.h")
	$libs = "-lSDL_gfx "+$libs unless gfxincluded
	gfxincluded = true
end

$libs = "-lSDL_image "+$libs if have_header("SDL_image.h")
$libs = "-lSDL_ttf "+$libs if have_header("SDL_ttf.h")

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

puts "CFLAGS: %s"%$CFLAGS.to_s
puts "LOCAL_LIBS: %s"%$LOCAL_LIBS.to_s
puts "defs: %s"%$defs.to_s

create_makefile("rubygame")
