require 'rubygems'
Gem::manage_gems

require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'

require "rbconfig"
include Config
OBJEXT = CONFIG["OBJEXT"]
DLEXT = CONFIG["DLEXT"]

spec = Gem::Specification.new do |s|
  s.name     = "rubygame"
  s.version  = "2.0.0"
  s.author   = "John Croisant"
  s.email    = "jacius@users.sourceforge.net"
  s.homepage = "http://rubygame.sourceforge.net/"
  s.platform = Gem::Platform::LINUX_586
  s.summary  = "Clean and powerful library for game programming"
  s.has_rdoc = true

  candidates = Dir.glob("{lib,ext,samples,doc}/**/*")
  s.files    = candidates.delete_if do |item|
    item.include?("svn")
  end

  s.require_paths = ["lib","ext"]
  s.autorequire = "rubygame.rb"
#  s.extensions = ["ext/rubygame/extconf.rb"]

  s.extra_rdoc_files = ["./README", "./LICENSE", "./TODO",\
    "./doc/getting_started.rdoc"]
end

Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar_gz = true
  pkg.need_tar_bz2 = true
end

Rake::RDocTask.new do |rd|
  rd.main = "Rubygame"
  rd.title = "Rubygame Documentation"
  rd.rdoc_files.include("lib/rubygame/*.rb",\
                        "ext/rubygame/*.c",\
                        "doc/*.rdoc")
end

task :default => [:build]
desc "Compile the C portion of rubygame from source."
task :build

EXTDIR = File.join('.', 'ext', 'rubygame', '')

require 'rake/clean'
CLEAN.include("#{EXTDIR}*.#{OBJEXT}")
CLOBBER.include("#{EXTDIR}*.#{DLEXT}")

# Options

require 'ostruct'
options = OpenStruct.new(:gfx         => true,
                         :image       => true,
                         :ttf         => true,
                         :mixer       => true,
                         :opengl      => true,
                         :cflags      => "-Wall",
                         :lflags      => "",
                         :sdl_config  => true,
                         :debug       => false,
                         :verbose     => false,
                         :sitearchdir => CONFIG["sitearchdir"],
                         :sitelibdir  => CONFIG["sitelibdir"]
                         )
require 'optparse'
optparse = OptionParser.new

optparse.banner = "Configure the rubygame build/install tasks."

optparse.on("-g", "--debug", 
            "Compile rubygame.#{DLEXT} with debug symbols.") do |val|
  options.debug = val
end
optparse.on("-v", "--verbose", "Display compiler commands when building.") do |val|
  options.verbose = val
end
optparse.on("--[no-]gfx", "Compile with SDL_gfx support or not.") do |val|
  options.gfx = val
end
optparse.on("--[no-]image", "Compile with SDL_image support or not.") do |val|
  options.image = val
end
optparse.on("--[no-]ttf", "Compile with SDL_ttf support or not.") do |val|
  options.ttf = val
end
optparse.on("--[no-]mixer", "Compile with SDL_mixer support or not.") do |val|
  options.mixer = val
end
optparse.on("--[no-]opengl", "Enable OpenGL support.") do |val|
  options.mixer = val
end
optparse.on("--cflags FLAGS", "Pass these FLAGS to the C compiler.") do |val|
  options.cflags = val
end
optparse.on("--lflags FLAGS", "Pass these FLAGS to the C linker.") do |val|
  options.lflags = val
end
optparse.on("--[no-]sdl-config",
            "Feed results from `sdl-config' to \\",
            "\tthe compiler and linker or not.") do |val|
  options.sdl_config = val
end
optparse.on("--sitearchdir PATH",
            "Install rubygame.#{DLEXT} into this PATH \\",
            "\tinstead of the usual sitearchdir.") do |val|
  options.sitearchdir = val
end
optparse.on("--sitelibdir PATH",
            "Install lib into this PATH \\",
            "\tinstead of the usual sitelibdir.") do |val|
  options.sitelibdir = val
end

# Rake is not very nice about letting us specify custom flags, so
# we'll go around it in this way.
optparse.parse( (ENV["RUBYGAME_CONFIG"] or "").split(" ") )


CFLAGS = [CONFIG["CFLAGS"],
          ENV["CFLAGS"],
          (`sdl-config --cflags`.chomp if options.sdl_config),
          "-I. -I#{CONFIG['topdir']}",
         ("-g" if options.debug) ].join(" ")

LINK_FLAGS = [CONFIG["LIBRUBYARG_SHARED"],
              ENV["LINK_FLAGS"],
              (`sdl-config --libs`.chomp if options.sdl_config)].join(" ")

LIBFLAG = " -l%s " # compiler flag for giving linked libraries

# Optional libraries
def optlib(lib, *inc)
  LINK_FLAGS << LIBFLAG%lib
  CFLAGS << inc.map { |header|
    " -DHAVE_#{header.upcase.gsub('.','_')} " }.join("")
end

# TODO: We should check if the libraries exist?

optlib('SDL_gfx',   'SDL_gfxPrimitives.h', 'SDL_rotozoom.h') if(options.gfx)
optlib('SDL_image', 'SDL_image.h') if(options.image)
optlib('SDL_mixer', 'SDL_mixer.h') if(options.mixer)
optlib('SDL_ttf',   'SDL_ttf.h') if(options.ttf)
CFLAGS << " -DHAVE_OPENGL " if(options.opengl)

DL_PREREQS = {
  'rubygame_core' => ['rubygame_main',
                      'rubygame_shared',
                      'constants', 
                      'rubygame_event',
                      'rubygame_gl',
                      'rubygame_joystick',
                      'rubygame_screen',
                      'rubygame_surface',
                      'rubygame_time',
                     ],

  'rubygame_gfx' =>   ['rubygame_shared', 'rubygame_gfx'],
  'rubygame_image' => ['rubygame_shared', 'rubygame_image'],
  'rubygame_ttf' =>   ['rubygame_shared', 'rubygame_ttf'],
  'rubygame_mixer' => ['rubygame_shared', 'rubygame_mixer']
}

# Extracts the names of all the headers that the C file depends on.
def depends_headers( filename )
  depends = []
  File.open(filename, "r") do |file|
    file.each_line do |line|
      if /#include\s+"(\w+\.h)"/ =~ line
        depends << EXTDIR+$1
      end
    end
  end
  return depends
end

begin
  # A rule for object files (".o" on linux).
  # This won't work for rake < 0.7.2, because the proc returns an Array.
  # If it raises an exception, we'll try a more compatible way.
  rule(/#{EXTDIR}.+\.#{OBJEXT}$/ =>
    [
     # Generate dependencies for this .o file
     proc do |objfile|
       source = objfile.sub(".#{OBJEXT}", ".c") # the .c file
       [source] + depends_headers( source ) # Array of .c + .h dependencies
     end
    ])\
  do |t|
    compile_command = "#{CONFIG['CC']} -c #{CFLAGS} #{t.source} -o #{t.name}"
    if( options.verbose )
      sh compile_command
    else
      puts "Compiling #{t.source}"
      `#{compile_command}`
    end
  end
rescue
  # Generate a .o rule for each .c file in the directory.
  FileList.new("#{EXTDIR}*.c").each do |source|
    object = source.sub(".c", ".#{OBJEXT}")
    file object => ([source] + depends_headers( source )) do |t|
      compile_command = "#{CONFIG['CC']} -c #{CFLAGS} #{source} -o #{t.name}"
      if( options.verbose )
        sh compile_command
      else
        puts "Compiling #{source}"
        `#{compile_command}`
      end
    end
  end
end

# Create a file task for each dynamic library (.so) we want to generate.
DL_PREREQS.each_pair do |key, value|
  dynlib  = "#{EXTDIR}#{key}.#{DLEXT}"
  objects = value.collect { |v| "#{EXTDIR}#{v}.#{OBJEXT}" }

  file dynlib => objects do |task|
    link_command = "#{CONFIG['LDSHARED']} #{LINK_FLAGS} -o #{task.name} #{task.prerequisites.join(' ')}"
    if( options.verbose )
      sh link_command
    else
      puts "Linking compiled files to create #{task.name}"
      `#{link_command}`
    end
  end

  task :build => [dynlib] # Add the dynlib as a prereq of the build task
  task :install_ext => [dynlib] # and the install_ext task
end

task :install_ext do |task|
  cp task.prerequisites.to_a, options.sitearchdir
end

task :install_lib do |task|
  cp "./lib/rubygame.rb", options.sitelibdir
  mkdir_p options.sitelibdir + "/rubygame/"
  cp FileList.new("./lib/rubygame/*.rb").to_a, options.sitelibdir+"/rubygame/"
end

task :install => [:install_ext, :install_lib]
