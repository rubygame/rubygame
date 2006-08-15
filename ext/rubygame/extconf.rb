#!/usr/bin/env ruby

require 'mkmf'
require 'getoptlong'

# You can pass several flags to this script:
# 
# FLAG              ARG       DESCRIPTION
# 
# --with-gfx        bool      Compile Rubygame with SDL_gfx library.
# --with-image      bool      Compile Rubygame with SDL_image library.
# --with-ttf        bool      Compile Rubygame with SDL_ttf library.
# --enable-opengl   bool      Enable OpenGL support.
# --library-path    path      Supplementary paths to check for libraries.
# --include-path    path      Supplementary paths to check for headers.
# --cflags          string    Supplementary flags to pass to C compiler.
# --libs            string    Supplementary flags to pass to C linker.
# --sdl-config      string    Command to use as 'sdl-config' (see below).
# --no-sdl-config   none      Do not attempt to use 'sdl-config'.
# --debug           none      Compile rubygame core with debugging symbols.
#
# Bool args can be t/true/y/yes to enable, or f/false/n/no to disable.
# Except for --no-sdl-config, all bools default to true if the flag is not
# given. If you give a bool flag with no argument, it will be taken as true.
#
# Path args are colon-separated filesystem paths.
#
# The argument to --sdl-config should be a command which behaves as the
# sdl-config utility does when given certain flags:
#   --cflags   Return flags to pass to the C compiler in order to use SDL.
#   --libs     Return flags to pass to the C linker in order to use SDL.
#
# If you don't give a different string via this flag, sdl-config itself will be
# used. If you don't have a utility like sdl-config, or don't want to use
# sdl-config, pass the --no-sdl-config flag. In such a case, you should use
# the --cflags and --libs flags to manually specify the compiler and linker
# flags.


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
  ['--enable-opengl',  GetoptLong::OPTIONAL_ARGUMENT],
  ['--library-path',   GetoptLong::REQUIRED_ARGUMENT],
  ['--include-path',   GetoptLong::REQUIRED_ARGUMENT],
  ['--cflags',         GetoptLong::REQUIRED_ARGUMENT],
  ['--libs',           GetoptLong::REQUIRED_ARGUMENT],
  ['--sdl-config',     GetoptLong::REQUIRED_ARGUMENT],
  ['--no-sdl-config',  GetoptLong::NO_ARGUMENT],
  ['--debug',          GetoptLong::NO_ARGUMENT]
)

# Option default values
OPTS = {
  :with_gfx      => true,
  :with_image    => true,
  :with_ttf      => true,
  :with_opengl   => true,
  :library_path  => nil,
  :include_path  => nil,
  :cflags        => "-Wall",
  :libs          => "",
  :no_sdl_config => false,
  :sdl_config    => "sdl-config",
  :debug         => false
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
	when '--libs'
		OPTS[:libs] = arg
	when '--no-sdl-config'
		OPTS[:no_sdl_config] = parse_truth(arg, true)
	when '--sdl-config'
		OPTS[:sdl_config] = arg
  when '--debug'
    OPTS[:debug] = true
	end
end

$CFLAGS += " %s "%[OPTS[:cflags]]
$LOCAL_LIBS += " %s "%[OPTS[:libs]]

if OPTS[:debug]
  $CFLAGS += " -g "
end

if PLATFORM =~ /win32/i
  have_library(SDL)
end

unless OPTS[:no_sdl_config]
	$CFLAGS += " %s"%`#{OPTS[:sdl_config]} --cflags`.chomp
	$LOCAL_LIBS += " %s"%`#{OPTS[:sdl_config]} --libs`.chomp
end

if OPTS[:include_path]
	$CFLAGS += parse_path(OPTS[:include_path], "-I")
end

if OPTS[:library_path]
	$LOCAL_LIBS += parse_path(OPTS[:library_path], "-L")
end

if OPTS[:with_gfx]
  have_library('SDL_gfx') and have_header("SDL_gfxPrimitives.h") and have_header("SDL_rotozoom.h")
end

if OPTS[:with_image]
  have_library("SDL_image") and have_header("SDL_image.h")
end

if OPTS[:with_ttf]
  have_library("SDL_ttf") and have_header("SDL_ttf.h")
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
