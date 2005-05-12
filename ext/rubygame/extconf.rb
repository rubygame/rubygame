#!/usr/bin/env ruby

require 'mkmf'
require 'getoptlong'

VAL_FALSE = ["f","false","n","no"]
VAL_TRUE = ["t","true","y","yes"]

FLAG = GetoptLong::NO_ARGUMENT
OPT = GetoptLong::OPTIONAL_ARGUMENT
REQ = GetoptLong::REQUIRED_ARGUMENT

# OPT_INFO entry format:
#   :opt_name => [ key, args, short_describe, long_describe ]
# 
# :opt_name will be transformed into "--opt-name" for the command line string
# 
# args is an Array describing what sort of arguments the flag takes.
#
# The first value describes whether the arguments are required, and is one of:
#   FLAG (takes no additional arguments)
#   OPT (takes optional arguments)
#   REQ (takes required arguments)
#
# If the first value is FLAG, the rest of the values are ignored.
#
# The second value is an integer or nil, which indicates which, if any, of the
# following arguments is the default value. 1 refers to the first possible
# value, i.e. the third value in the Array. nil means there is no default.
#
# The rest of the arguments are possible values that the argument can be.
#
# e.g. [REQ 1,"yes","no"] indicates that the argument is required, is either
# "yes" or "no", and entry 1 ("yes") is the default.
OPT_INFO = {
	:with_gfx => [[OPT, 1, "yes","no"],
		"Compile Rubygame with SDL_gfx",
		"If no, Rubygame will not be compile with SDL_gfx, and the Draw and "\
		"Transform modules will be unusable."],
	:with_ttf => [[OPT, 1, "yes","no"],
		"Compile Rubygame with SDL_ttf",
		"If no, Rubygame will not be compile with SDL_ttf, and the Font::TTF"\
		"class will be unusable."],
	:with_image => [[OPT, 1, "yes","no"],
		"Compile Rubygame with SDL_image",
		"If no, Rubygame will not be compile with SDL_image, and the Image"\
		"module will be unusable."],
	:include_path => [[REQ, 1, ""],
		"Paths to check for C headers",
		"A colon-separated list of directories to check for C headers."\
		"The path listed by `sdl-config --cflags' will also be checked."],
	:library_path => [[REQ, 1, ""],
		"Paths to check for C libraries",
		"A colon-separated list of directories to check for C libraries."\
		"The path listed by `sdl-config --libs' will also be checked."],
}

# Convert :opt_name into "--opt-name"
def convert_opt_symbol(symbol)
	"--%s"%[symbol.to_s.gsub("_","-")]
end

# Convert "--opt-name" into :opt_name
def convert_opt_string(string)
	string[2..-1].gsub("-","_").intern
end

# Convert e.g. [REQ, 1, a, b, c] into "a"
def convert_values_short(values)
	if values[0] == FLAG
		return nil
	else
		return values[values[2]]
	end
end

# Convert e.g. [REQ, 1, a, b, c] into "a/b/c (default: a)"
# if there is no default, omit the "(default: )" part
def convert_values_long(values)
	if values[0] == FLAG
		return nil
	else
		v = values[1..-1]
		i = values[0] - 1
		default = v[i]
		return "%s%s"%[v.join("/"),
			(default and " (default: %s)"%[default])
		]
	end
end

# return string for pretty print short option description
def pprint_opt_short(symbol)
	name = convert_opt_symbol(symbol)
	info = OPT_INFO[symbol]
	unless info[0] == FLAG
		vals = convert_values_short(info[1])
	else
		vals = ""
	end
	desc = info[3]
	return "#{name} (#{vals}) #{desc}"
end

# return string for pretty print short option description
def pprint_opt_long(symbol)
	name = convert_opt_symbol(symbol)
	info = OPT_INFO[symbol]
	unless info[0] == FLAG
		vals = convert_values_long(info[1])
	else
		vals = ""
	end
	desc, longdesc = info[3..4]
	return "#{name} #{desc} \nCan be: #{values} \n#{longdesc}"
end

def generate_opts_list(info)
	list = []
	info.each{|k,v|
		# [--opt-name, FLAG||OPT||REQ]
		list.push([convert_opt_symbol(k),info[k][0][0]])
	}
	return list
end

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

OPTS = {}
opts = GetoptLong.new( *generate_opts_list(OPT_INFO) )

opts.each do |opt, arg|
	if VAL_TRUE.include? arg
		OPTS[convert_opt_string(opt)] = true
	elsif VAL_FALSE.include? arg
		OPTS[convert_opt_string(opt)] = false
	else
		OPTS[convert_opt_string(opt)] = arg
	end
end

$CFLAGS += ' -Wall ' + `sdl-config --cflags`.chomp
$LOCAL_LIBS += ' ' + `sdl-config --libs`.chomp

if OPTS[:include_path]
	$INCFLAGS += parse_path(OPTS[:include_path], "-I")
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
puts "INCFLAGS: %s"%$INCFLAGS.to_s
puts "LOCAL_LIBS: %s"%$LOCAL_LIBS.to_s
puts "defs: %s"%$defs.to_s

create_makefile("rubygame")
