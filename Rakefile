


# The version number for Rubygame.
RUBYGAME_VERSION = [2,4,0]



require 'rubygems'
Gem::manage_gems

require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'

require "rbconfig"
include Config

require 'English'

class ShellCommandError < RuntimeError
end

# Execute the block (which is supposed to perform a shell command),
# then raise ShellCommandError if the command failed.
def try_shell( &block )
  result = yield
  
  unless $CHILD_STATUS.exitstatus == 0
    raise ShellCommandError, "Command failed. Aborting."
  end
  
  return result
end

def try_sdl_config( flag )
  begin
    if $options[:"sdl-config"]
      return try_shell { `sdl-config #{flag}`.chomp }
    else
      return String.new
    end
  rescue ShellCommandError
    warn "WARNING: 'sdl-config' failed."
    warn "Continuing anyway, but compile may fail."
    return String.new
  end
end

# Get a variable from ENV or CONFIG, with ENV having precedence.
# Returns "" if the variable didn't exist at all.
def from_env_or_config(string)
  ([ENV[string], CONFIG[string]] - ["", nil])[0] or ""
end

OBJEXT = from_env_or_config("OBJEXT")
DLEXT = from_env_or_config("DLEXT")

gem_spec = Gem::Specification.new do |s|
  s.name     = "rubygame"
  s.version  = RUBYGAME_VERSION.join(".")
  s.author   = "John Croisant"
  s.email    = "jacius@users.sourceforge.net"
  s.homepage = "http://rubygame.sourceforge.net/"
  s.summary  = "Clean and powerful library for game programming"
  s.has_rdoc = true

  s.files = FileList.new do |fl|
    fl.include("{lib,ext,samples,doc}/**/*")
    fl.exclude(/svn/)
    #fl.exclude(/\.#{OBJEXT}/)
  end

  s.require_paths = ["lib", "lib/rubygame/", "ext/rubygame/"]
  s.extensions = ["Rakefile"]

  s.extra_rdoc_files = FileList.new do |fl|
    fl.include "doc/*.rdoc"
    fl.include "README", "LICENSE", "CREDITS", "ROADMAP", "NEWS"
  end
end

task :binary do
	gem_spec.platform = Gem::Platform::CURRENT
end

Rake::GemPackageTask.new(gem_spec) do |pkg| 
  pkg.need_tar_bz2 = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.title = "Rubygame #{RUBYGAME_VERSION.join(".")} Docs"
  rd.rdoc_files.include("ext/rubygame/*.c",
                        "lib/rubygame/**/*.rb",
                        "doc/*.rdoc",
                        "README",
                        "LICENSE",
                        "CREDITS",
                        "ROADMAP",
                        "NEWS")
end

task :default => [:build]
desc "Compile all of the extensions"
task :build

require 'rake/clean'
task(:clean) { puts "Cleaning out temporary generated files" }
task(:clobber) { puts "Cleaning out final generated files" }

##############################
##      BUILD  OPTIONS      ##
##############################

$options = {
	:"sdl-gfx"    => true,
	:"sdl-image"  => true,
	:"sdl-ttf"    => true,
	:"sdl-mixer"  => true,
	:opengl       => true,
	:"sdl-config" => true,
	:universal    => false,
	:debug        => false,
	:verbose      => false,
	:sitearchdir  => CONFIG["sitearchdir"],
	:sitelibdir   => CONFIG["sitelibdir"]
}

# Default behavior for win32 is to skip sdl_config,
# since it's usually not available. It can still be
# enabled through the options, though.
if PLATFORM =~ /win32/
	$options[:"sdl-config"] = false
end

# Define tasks to enable and disable bool options.
# 
#     rake option
#     rake no-option
# 
#   task_name::   the task name to use
#   option_name:: the option name (if different from
#                 the task name)
#   desc::        a longer description, to fill
#                 "Enable ________.", if different
#                 from the task name.
# 
def bool_option( task_name, option_name=nil, desc=nil )
	option_name = task_name unless option_name
	option_name = option_name.intern if option_name.kind_of? String

	desc = task_name.to_s unless desc
  
	notask_name = "no-#{task_name.to_s}".intern

	is_true = $options[option_name]
	
	desc "Enable #{desc} #{'(default)' if is_true}"
	task(task_name)   { $options[option_name] = true  }

	desc "Disable #{desc} #{'(default)' unless is_true}"
	task(notask_name) { $options[option_name] = false }
end

# Gather a string option from an environment variable:
# 
#     rake option="the value of the option"
# 
#   task_name::   the task name to use
#   option_name:: the option name (if different from
#                 the task name)
# 
def string_option( task_name, option_name=nil )
	option_name = task_name unless option_name
	option_name = option_name.intern if option_name.kind_of? String

	$options[option_name] = ENV["#{task_name}"] if ENV["#{task_name}"]
end

bool_option :"sdl-gfx",    nil,  "SDL_gfx support"
bool_option :"sdl-image",  nil,  "SDL_image support"
bool_option :"sdl-mixer",  nil,  "SDL_mixer support"
bool_option :"sdl-ttf",    nil,  "SDL_ttf support"
bool_option :"sdl-config", nil,  "guess compiler flags for SDL"
bool_option :opengl,       nil,  "OpenGL support"
bool_option :debug,        nil,  "compile with debug symbols"
bool_option :verbose,      nil,  "show compiler commands"
bool_option :universal,    nil,  "universal binary (MacOS X Intel)"

string_option "RUBYARCHDIR", :sitearchdir
string_option :sitearchdir

string_option "RUBYLIBDIR", :sitelibdir
string_option :sitelibdir


CFLAGS = [from_env_or_config("CFLAGS"),
          try_sdl_config("--cflags"),
          "-I. -I#{CONFIG['topdir']}",
          ("-g" if $options[:debug]),
          "-DRUBYGAME_MAJOR_VERSION=#{RUBYGAME_VERSION[0]}",
          "-DRUBYGAME_MINOR_VERSION=#{RUBYGAME_VERSION[1]}",
          "-DRUBYGAME_PATCHLEVEL=#{RUBYGAME_VERSION[2]}"
         ].join(" ")

LINK_FLAGS = [from_env_or_config("LIBRUBYARG_SHARED"),
              from_env_or_config("LDFLAGS"),
              try_sdl_config("--libs")].join(" ")

DEFAULT_EXTDIR = File.join('ext','rubygame','')

class ExtensionModule
  @@libflag = " -l%s " # compiler flag for giving linked libraries
  attr_accessor :dynlib, :objs, :libs, :cflags, :lflags, :directory
  def initialize(&block)
    @directory = DEFAULT_EXTDIR
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

  def create_all_tasks()
    create_obj_task
    create_dl_task
    CLEAN.include("#{@directory}/*.#{OBJEXT}")
    CLOBBER.include("#{@directory}/*.#{DLEXT}")
  end

  # Create a file task for each dynamic library (.so) we want to generate.
  # 
  # The file task invokes another task which does the actual compiling, and
  # has the true prerequisites.
  # 
  # This is done so that the prerequisites don't have to be compiled when 
  # the final product already exists (such as in the precompiled win32 gem).
  # 
  def create_dl_task
    dynlib_full  = File.join( @directory, "#{dynlib}.#{DLEXT}" )
    objs_full = @objs.collect { |obj|
      File.join( @directory, "#{obj}.#{OBJEXT}" )
    }

    desc "Compile the #{@dynlib} extension"
    file dynlib_full => objs_full do |task|

      link_command = "#{from_env_or_config('LDSHARED')} #{LINK_FLAGS} #{@lflags} -o #{dynlib_full} #{task.prerequisites.join(' ')}"


      # If link command includes i386 arch, and we're not allowing universal
      if( /-arch i386/ === link_command and not $options[:universal] )
        # Strip "-arch ppc" to prevent building a universal binary.
        link_command.gsub!("-arch ppc","")
      end

      if( $options[:verbose] )
        try_shell { sh link_command }
      else
        puts "Linking compiled files to create #{File.basename(@directory)}/#{File.basename(dynlib_full)}"
        try_shell { `#{link_command}` }
      end
    end

    task :build => [dynlib_full]   # Add this as a prereq of the build
    task :install_ext => [dynlib_full] # ...and install_ext tasks
  end

  def create_obj_task
    # A rule for object files (".o" on linux).
    # This won't work for rake < 0.7.2, because the proc returns an Array.
    # If it raises an exception, we'll try a more compatible way.
    rule(/#{@directory}.+\.#{OBJEXT}$/ =>
         [
          # Generate dependencies for this .o file
          proc do |objfile|
            source = objfile.sub(".#{OBJEXT}", ".c") # the .c file
            [source] + depends_headers( source ) # Array of .c + .h dependencies
          end
         ])\
    do |t|

      compile_command = "#{from_env_or_config('CC')} -c #{CFLAGS} #{t.source} -o #{t.name}"

      # If compile command includes i386 arch, and we're not allowing universal
      if( /-arch i386/ === compile_command and not $options[:universal] )
        # Strip "-arch ppc" to prevent building a universal binary.
        compile_command.gsub!("-arch ppc","")
      end

      if( $options[:verbose] )
        try_shell { sh compile_command }
      else
        puts "Compiling #{File.basename(@directory)}/#{File.basename(t.source)}"
        try_shell { `#{compile_command}` }
      end
    end
  rescue
    # Generate a .o rule for each .c file in the directory.
    FileList.new("#{@directory}*.c").each do |source|
      object = source.sub(".c", ".#{OBJEXT}")
      file object => ([source] + depends_headers( source )) do |t|
        compile_command = "#{CONFIG['CC']} -c #{CFLAGS} #{source} -o #{t.name}"
        if( $options[:verbose] )
          try_shell { sh compile_command }
        else
          puts "Compiling #{File.basename(@directory)}/#{File.basename(source)}"
          try_shell { `#{compile_command}` }
        end
      end
    end
  end

  # Extracts the names of all the headers that the C file depends on.
  def depends_headers( filename )
    return []                   # workaround for a bug
    depends = []
    File.open(filename, "r") do |file|
      file.each_line do |line|
        if /#include\s+"(\w+\.h)"/ =~ line
          depends << @directory+$1
        end
      end
    end
    return depends
  end
end

rubygame_core = ExtensionModule.new do |core|
  core.dynlib = 'rubygame_core'
  core.objs = ['rubygame_main',
               'rubygame_shared',
               'rubygame_event',
               'rubygame_event2',
               'rubygame_gl',
               'rubygame_joystick',
               'rubygame_screen',
               'rubygame_surface',
               'rubygame_time',
              ]
  core.create_all_tasks()
end

# TODO: We should check if the libraries exist?

rubygame_gfx = ExtensionModule.new do |gfx|
  gfx.dynlib = 'rubygame_gfx'
  gfx.objs = ['rubygame_shared', 'rubygame_gfx']
  gfx.add_lib( 'SDL_gfx' )
  gfx.add_header( 'SDL_gfxPrimitives.h')
  gfx.add_header( 'SDL_rotozoom.h' )
  gfx.create_all_tasks() if $options[:"sdl-gfx"]
end

rubygame_image = ExtensionModule.new do |image|
  image.dynlib = 'rubygame_image'
  image.objs = ['rubygame_shared', 'rubygame_image']
  image.add_lib('SDL_image')
  image.add_header('SDL_image.h')
  image.create_all_tasks() if $options[:"sdl-image"]
end

rubygame_mixer = ExtensionModule.new do |mixer|
  mixer.dynlib = 'rubygame_mixer'
  mixer.objs = ['rubygame_shared', 'rubygame_mixer', 'rubygame_sound', 'rubygame_music']
  mixer.add_lib('SDL_mixer')
  mixer.add_header('SDL_mixer.h')
  mixer.create_all_tasks() if $options[:"sdl-mixer"]
end

rubygame_ttf = ExtensionModule.new do |ttf|
  ttf.dynlib = 'rubygame_ttf'
  ttf.add_lib('SDL_ttf')
  ttf.objs = ['rubygame_shared', 'rubygame_ttf']
  ttf.add_header('SDL_ttf.h')
  ttf.create_all_tasks() if $options[:"sdl-ttf"]
end

if $options[:opengl]
  CFLAGS << " -DHAVE_OPENGL "
end

desc "(Called when installing via Rubygems)"
task :extension => [:fix_filenames, :build]

task :fix_filenames do
	unless DLEXT == 'so'
		Rake::Task[:install_ext].prerequisites.each do |prereq|
			prereq = prereq.ext('so')
			if File.exist? prereq
				mv prereq, prereq.ext(DLEXT)
			end
		end
	end
end

desc "Install just the extensions"
task :install_ext do |task|
  puts "Installing extensions to #{$options[:sitearchdir]}"
  mkdir_p $options[:sitearchdir]
  cp task.prerequisites.to_a, $options[:sitearchdir]
end

desc "Install just the library"
task :install_lib do |task|
  puts "Installing library to #{$options[:sitelibdir]}"

  files = FileList.new do |fl|
    fl.include("lib/**/*.rb")
    fl.exclude(/svn/)
  end

  files.each do |f|
    dir = File.join($options[:sitelibdir], File.dirname(f).sub('lib',''), "")
    mkdir_p dir
    cp f, dir
  end
end

desc "Install both the extensions and the library"
task :install => [:install_ext, :install_lib]



#########
# SPECS #
#########

begin
  require 'spec/rake/spectask'


  desc "Run all specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/*_spec.rb']
  end


  namespace :spec do
    desc "Run all specs"
    Spec::Rake::SpecTask.new(:all) do |t|
      t.spec_files = FileList['spec/*_spec.rb']
    end

    desc "Run spec/[name]_spec.rb (e.g. 'color')"
    task :name do
      puts( "This is just a stand-in spec.",
            "Run rake spec:[name] where [name] is e.g. 'color', 'music'." )
    end
  end


rule(/spec:.+/) do |t|
  name = t.name.gsub("spec:","")

  path = File.join( File.dirname(__FILE__),'spec','%s_spec.rb'%name )

  if File.exist? path
    Spec::Rake::SpecTask.new(name) do |t|
      t.spec_files = [path]
    end

    puts "\nRunning spec/%s_spec.rb"%name

    Rake::Task[name].invoke
  else
    puts "File does not exist: %s"%path
  end

end

rescue LoadError

  error = "ERROR: RSpec is not installed?"

  task :spec do 
    puts error
  end

  rule( /spec:.*/ ) do
    puts error
  end

end
