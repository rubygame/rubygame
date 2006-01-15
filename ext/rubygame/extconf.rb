#!/usr/bin/env ruby

require 'mkmf'
require 'getoptlong'

# Break up a colon-separated list into separate elements, prefix the given
# string, and put them together in a string, like this:
#   >> parse_path("/usr/local/lib:/usr/lib", "-L")
#   => " -L/usr/local/lib  -L/usr/lib "
def parse_path(path,prefix="")
	elts = path.split(":")
	s = ""
	elts.each { |e|
		s += " %s "%[prefix+e]
	}
	return s
end

VAL_FALSE = ["f","false","n","no"]
VAL_TRUE = ["t","true","y","yes"]

# Return true of false if +arg+ seems to be a bool-like string,
# otherwise return +default+
def parse_truth(arg,default=nil)
	if VAL_TRUE.include? arg
		return true
	elsif VAL_FALSE.include? arg
		return false
	else
		return default
	end
end

getopts = GetoptLong.new(
	['--with-gfx',       GetoptLong::OPTIONAL_ARGUMENT],
	['--with-image',     GetoptLong::OPTIONAL_ARGUMENT],
	['--with-ttf',       GetoptLong::OPTIONAL_ARGUMENT],
  ['--with-opengl',    GetoptLong::OPTIONAL_ARGUMENT],
	['--library-path',   GetoptLong::REQUIRED_ARGUMENT],
	['--include-path',   GetoptLong::REQUIRED_ARGUMENT],
	['--cflags',         GetoptLong::REQUIRED_ARGUMENT],
	['--no-sdl-config',  GetoptLong::NO_ARGUMENT] )

# Option values
OPTS = {
	:with_gfx      => true,
	:with_image    => true,
	:with_ttf      => true,
	:with_opengl    => true,
	:library_path  => "",
	:include_path  => "",
	:cflags        => "",
	:no_sdl_config => false,
}

# Parse options
getopts.each do |opt, arg|
	case(opt)
	when '--with-gfx'
		OPTS[:with_gfx] = parse_truth(arg, true)
	when '--with-image'
		OPTS[:with_image] = parse_truth(arg, true)
	when '--with-ttf'
		OPTS[:with_ttf] = parse_truth(arg, true)
	when '--with-opengl'
		OPTS[:with_opengl] = parse_truth(arg, true)
	when '--library-path'
		OPTS[:library_path] = arg
	when '--include-path'
		OPTS[:include_path] = arg
	when '--cflags'
		OPTS[:cflags] = arg
	when '--no-sdl-config'
		OPTS[:no_sdl_config] = parse_truth(arg, true)
	end
end

$CFLAGS += " -Wall %s "%[OPTS[:cflags]]

unless OPTS[:no_sdl_config]
	$CFLAGS += " %s"%`sdl-config --cflags`.chomp
	$LOCAL_LIBS += " %s"%`sdl-config --libs`.chomp
end

if OPTS[:include_path]
	$CFLAGS += parse_path(OPTS[:include_path], "-I")
end

if OPTS[:library_path]
	$LOCAL_LIBS += parse_path(OPTS[:library_path], "-L")
end

gfxincluded = false

if OPTS[:with_gfx]
	if have_header("SDL_gfxPrimitives.h")
		$libs = "-lSDL_gfx "+$libs unless gfxincluded
		gfxincluded = true
	end
	if have_header("SDL_rotozoom.h")
		$libs = "-lSDL_gfx "+$libs unless gfxincluded
		gfxincluded = true
	end
end

if OPTS[:with_image]
	$libs = "-lSDL_image "+$libs if have_header("SDL_image.h")
end

if OPTS[:with_ttf]
	$libs = "-lSDL_ttf "+$libs if have_header("SDL_ttf.h")
end

if OPTS[:with_opengl]
  # It might be good to have a test of capabilities here.
	$defs << " -DHAVE_OPENGL "
end

puts "CFLAGS: %s"%$CFLAGS.to_s
puts "INCFLAGS: %s"%$INCFLAGS.to_s
puts "LOCAL_LIBS: %s"%$LOCAL_LIBS.to_s
puts "defs: %s"%$defs.join(' ')

create_makefile("rubygame")
