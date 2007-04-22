require 'rubygems'
Gem::manage_gems

require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'

require "rbconfig"
include Config

# Get a variable from ENV or CONFIG, with ENV having precedence.
# Returns "" if the variable didn't exist at all.
def from_env_or_config(string)
  ([ENV[string], CONFIG[string]] - ["", nil])[0] or ""
end

OBJEXT = from_env_or_config("OBJEXT")
DLEXT = from_env_or_config("DLEXT")

RUBYGAME_VERSION = "2.0.0"

spec = Gem::Specification.new do |s|
  s.name     = "rubygame"
  s.version  = RUBYGAME_VERSION
  s.author   = "John Croisant"
  s.email    = "jacius@users.sourceforge.net"
  s.homepage = "http://rubygame.sourceforge.net/"
  s.summary  = "Clean and powerful library for game programming"
  s.has_rdoc = true

  candidates = Dir.glob("{lib,ext,samples,doc}/**/*")
  s.files    = candidates.delete_if do |item|
    item.include?("svn")
  end

  s.require_paths = ["lib", "lib/rubygame/", "ext/rubygame/"]
  s.autorequire = "rubygame.rb"
  s.extensions = ["Rakefile"]

  s.extra_rdoc_files = Dir.glob("./doc/*.rdoc")
  s.extra_rdoc_files += ["./README",
                        "./LICENSE",
                        "./CREDITS",
                        "./TODO",
                        "./Changelog"]
end

Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar_bz2 = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.title = "Rubygame #{RUBYGAME_VERSION} Docs"
  rd.rdoc_files.include("ext/rubygame/*.c",
                        "lib/rubygame/*.rb",
                        "doc/*.rdoc",
                        "./README",
                        "./LICENSE",
                        "./CREDITS",
                        "./TODO",
                        "./Changelog")
end

task :default => [:build]
task :extension => [:build]
desc "Compile all of the extensions"
task :build

EXTDIR = File.join('.', 'ext', 'rubygame', '')

require 'rake/clean'
CLEAN.include("#{EXTDIR}*.#{OBJEXT}")
CLOBBER.include("#{EXTDIR}*.#{DLEXT}")

task(:clean) { puts "Cleaning out temporary generated files" }
task(:clobber) { puts "Cleaning out final generated files" }

# Options

require 'ostruct'
$options = OpenStruct.new(:gfx         => true,
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
            "Compile extensions with debug symbols.") do |val|
  $options.debug = val
end
optparse.on("-v", "--verbose", "Show commands while compiling.") do |val|
  $options.verbose = val
end
optparse.on("--[no-]gfx", "Compile rubygame_gfx or not.") do |val|
  $options.gfx = val
end
optparse.on("--[no-]image", "Compile rubygame_image or not.") do |val|
  $options.image = val
end
optparse.on("--[no-]ttf", "Compile rubygame_ttf or not.") do |val|
  $options.ttf = val
end
optparse.on("--[no-]mixer", "Compile rubygame_mixer or not.") do |val|
  $options.mixer = val
end
optparse.on("--[no-]opengl", "Enable OpenGL support.") do |val|
  $options.opengl = val
end
optparse.on("--cflags FLAGS", "Pass these FLAGS to the C compiler.") do |val|
  $options.cflags = val
end
optparse.on("--lflags FLAGS", "Pass these FLAGS to the C linker.") do |val|
  $options.lflags = val
end
optparse.on("--[no-]sdl-config",
            "Feed results from `sdl-config' to \\",
            "\tthe compiler and linker or not.") do |val|
  $options.sdl_config = val
end
optparse.on("--sitearchdir PATH",
            "Install extensions into this PATH \\",
            "\tinstead of the usual sitearchdir.") do |val|
  $options.sitearchdir = val
end
optparse.on("--sitelibdir PATH",
            "Install library into this PATH \\",
            "\tinstead of the usual sitelibdir.") do |val|
  $options.sitelibdir = val
end

# Rake is not very nice about letting us specify custom flags, so
# we'll go around it in this way.
optparse.parse( (ENV["RUBYGAME_CONFIG"] or "").split(" ") )

# rubygem passes RUBYARCHDIR=/path/to/some/directory when building extension
rule( /RUBYARCHDIR/ ) do |t|
  $options.sitearchdir = t.name.split("=")[1]
end

# rubygem passes RUBYLIBDIR=/path/to/another/directory when building extension
rule( /RUBYLIBDIR/ ) do |t|
  $options.sitelibdir = t.name.split("=")[1]
end

CFLAGS = [from_env_or_config("CFLAGS"),
          (`sdl-config --cflags`.chomp if $options.sdl_config),
          "-I. -I#{CONFIG['topdir']}",
          ("-g" if $options.debug) ].join(" ")

LINK_FLAGS = [from_env_or_config("LIBRUBYARG_SHARED"),
              ENV["LINK_FLAGS"],
              (`sdl-config --libs`.chomp if $options.sdl_config)].join(" ")



class ExtensionModule
  @@libflag = " -l%s " # compiler flag for giving linked libraries
  attr_accessor :dynlib, :objs, :libs, :cflags, :lflags
  def initialize(&block)
    @dynlib = ""
    @objs = []
    @libs = []
    @lflags = ""
    yield self if block_given?
  end

  def add_lib( lib )
    @lflags << @@libflag%lib
  end

  def add_header( header )
    #CFLAGS << " -DHAVE_#{header.upcase.gsub('.','_')} "
  end

  # Create a file task for each dynamic library (.so) we want to generate.
  def create_dl_task
    dynlib_full  = "#{EXTDIR}#{@dynlib}.#{DLEXT}"
    objs_full = @objs.collect { |obj| "#{EXTDIR}#{obj}.#{OBJEXT}" }

    file dynlib_full => objs_full do |task|
      link_command = "#{from_env_or_config('LDSHARED')} #{LINK_FLAGS} #{@lflags} -o #{task.name} #{task.prerequisites.join(' ')}"
      if( $options.verbose )
        sh link_command
      else
        puts "Linking compiled files to create #{File.basename(task.name)}"
        `#{link_command}`
      end
    end
    taskname = @dynlib.gsub('rubygame_','').intern
    desc "Compile the #{@dynlib} extension"
    task  taskname => [dynlib_full]
    task :build => [taskname]   # Add this as a prereq of the build
    task :install_ext => [dynlib_full] # ...and install_ext tasks
  end
end

rubygame_core = ExtensionModule.new do |core|
  core.dynlib = 'rubygame_core'
  core.objs = ['rubygame_main',
               'rubygame_shared',
               'rubygame_event',
               'rubygame_gl',
               'rubygame_joystick',
               'rubygame_screen',
               'rubygame_surface',
               'rubygame_time',
              ]
  core.create_dl_task()
end

# TODO: We should check if the libraries exist?

rubygame_gfx = ExtensionModule.new do |gfx|
  gfx.dynlib = 'rubygame_gfx'
  gfx.objs = ['rubygame_shared', 'rubygame_gfx']
  gfx.add_lib( 'SDL_gfx' )
  gfx.add_header( 'SDL_gfxPrimitives.h')
  gfx.add_header( 'SDL_rotozoom.h' )
  gfx.create_dl_task() if $options.gfx
end

rubygame_image = ExtensionModule.new do |image|
  image.dynlib = 'rubygame_image'
  image.objs = ['rubygame_shared', 'rubygame_image']
  image.add_lib('SDL_image')
  image.add_header('SDL_image.h')
  image.create_dl_task() if $options.image
end

rubygame_mixer = ExtensionModule.new do |mixer|
  mixer.dynlib = 'rubygame_mixer'
  mixer.objs = ['rubygame_shared', 'rubygame_mixer']
  mixer.add_lib('SDL_mixer')
  mixer.add_header('SDL_mixer.h')
  mixer.create_dl_task() if $options.mixer
end

rubygame_ttf = ExtensionModule.new do |ttf|
  ttf.dynlib = 'rubygame_ttf'
  ttf.add_lib('SDL_ttf')
  ttf.objs = ['rubygame_shared', 'rubygame_ttf']
  ttf.add_header('SDL_ttf.h')
  ttf.create_dl_task() if $options.ttf
end

if $options.opengl
  CFLAGS << " -DHAVE_OPENGL "
end

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
    compile_command = "#{from_env_or_config('CC')} -c #{CFLAGS} #{t.source} -o #{t.name}"
    if( $options.verbose )
      sh compile_command
    else
      puts "Compiling #{File.basename(t.source)}"
      `#{compile_command}`
    end
  end
rescue
  # Generate a .o rule for each .c file in the directory.
  FileList.new("#{EXTDIR}*.c").each do |source|
    object = source.sub(".c", ".#{OBJEXT}")
    file object => ([source] + depends_headers( source )) do |t|
      compile_command = "#{CONFIG['CC']} -c #{CFLAGS} #{source} -o #{t.name}"
      if( $options.verbose )
        sh compile_command
      else
        puts "Compiling #{File.basename(source)}"
        `#{compile_command}`
      end
    end
  end
end

desc "Install only the extensions"
task :install_ext do |task|
  puts "Installing extensions to #{$options.sitearchdir}"
  cp task.prerequisites.to_a, $options.sitearchdir
end

desc "Install only the library"
task :install_lib do |task|
  puts "Installing library to #{$options.sitelibdir}"
  cp "./lib/rubygame.rb", $options.sitelibdir
  mkdir_p $options.sitelibdir + "/rubygame/"
  cp FileList.new("./lib/rubygame/*.rb").to_a, $options.sitelibdir+"/rubygame/"
end

desc "Install both the extensions and the library"
task :install => [:install_ext, :install_lib]
