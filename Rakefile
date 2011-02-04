# 
# This is the Rakefile for Rubygame. It's used for packaging,
# installing, generating the documentation, and running specs.
# 


# The version number for Rubygame.
# If you update this, also update lib/rubygame/main.rb.
RUBYGAME_VERSION = [2,6,4]



require 'rubygems'

require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'

require "rbconfig"
include Config



#######
# GEM #
#######

gem_spec = Gem::Specification.new do |s|
  s.name     = "rubygame"
  s.version  = RUBYGAME_VERSION.join(".")
  s.author   = "John Croisant"
  s.email    = "jacius@gmail.com"
  s.homepage = "http://rubygame.org/"
  s.summary  = "Clean and powerful library for game programming"
  s.rubyforge_project = "rubygame"

  s.files = FileList.new do |fl|
    fl.include("{lib,samples,doc}/**/*")
  end

  s.require_paths = ["lib"]

  s.has_rdoc = true
  s.extra_rdoc_files = FileList.new do |fl|
    fl.include "doc/*.rdoc", "./*.rdoc", "LICENSE.txt"
  end

  s.required_ruby_version = ">= 1.8"
  s.add_dependency( "rake", ">=0.7.0" )
  s.add_dependency( "ruby-sdl-ffi", ">=0.4.0" )
  s.requirements = ["SDL       >= 1.2.7",
                    "SDL_gfx   >= 2.0.10 (optional)",
                    "SDL_image >= 1.2.3  (optional)",
                    "SDL_mixer >= 1.2.7  (optional)",
                    "SDL_ttf   >= 2.0.6  (optional)"]

end


Rake::GemPackageTask.new(gem_spec) do |pkg| 
  pkg.need_tar_bz2 = true
end



########
# RDOC #
########

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.title = "Rubygame #{RUBYGAME_VERSION.join(".")} Docs"
  rd.rdoc_files.include("lib/rubygame/**/*.rb",
                        "doc/*.rdoc",
                        "./*.rdoc",
                        "LICENSE.txt")
end

desc "Generate RI-formatted docs."
task(:ri) do
  sh('rdoc --ri --threads=1 --force-update --output "./ri" ./lib')
end


###########
# VERBOSE #
###########

desc "Run tasks more verbosely"
task :verbose do
  ENV["SPEC_OPTS"] = "--format documentation #{ENV["SPEC_OPTS"]}"
end


#########
# CLEAN #
#########

require 'rake/clean'
task(:clean) { puts "Cleaning out temporary generated files" }
task(:clobber) { puts "Cleaning out final generated files" }

CLOBBER.include("ri")


###########
# INSTALL #
###########

task :install do |task|
  sitelibdir = (ENV["RUBYLIBDIR"] or CONFIG["sitelibdir"])

  puts "Installing to #{sitelibdir}"

  files = FileList.new do |fl|
    fl.include("lib/**/*.rb")
  end

  files.each do |f|
    dir = File.join(sitelibdir, File.dirname(f).sub('lib',''), "")
    mkdir_p dir
    cp f, dir
  end
end



#########
# SPECS #
#########

begin
  require 'rspec/core/rake_task'

  rspec_opts = '-r spec/spec_helper.rb'

  desc "Run all specs"
  RSpec::Core::RakeTask.new do |t|
    ENV["RUBYGAME_NEWRECT"] = "true"
    t.pattern = 'spec/*_spec.rb'
    t.rspec_opts = rspec_opts
  end


  namespace :spec do
    desc "Run all specs"
    RSpec::Core::RakeTask.new(:all) do |t|
      ENV["RUBYGAME_NEWRECT"] = "true"
      t.pattern = 'spec/*_spec.rb'
      t.rspec_opts = rspec_opts
    end

    desc "Run spec/[name]_spec.rb (e.g. 'color')"
    task :name do
      puts( "This is just a stand-in spec.",
            "Run rake spec:[name] where [name] is e.g. 'color', 'music'." )
    end

    desc "Run specific examples from spec/[name]_spec.rb"
    task "name:\"example\"" do
      puts( "This is just a stand-in spec.",
            "Run rake spec:[name]:\"[example]\" where [name] is e.g."+
            "'color', and [example] is a pattern matching an example." )
    end
  end


  rule(/spec:.+/) do |t|

    # Matches e.g. 'spec:foo' and 'spec:foo:"Example pattern"'
    spec_regexp = /spec:([^:]+)(?::(.+))?/

    match = t.name.match(spec_regexp)

    unless match
      puts "Invalid spec task: #{t.name}"
      exit 1
    end

    name = match[1]
    example = match[2] # optional

    pattern = File.join('spec', '%s_spec.rb'%name)
    path = File.join( File.dirname(__FILE__), pattern )

    if File.exist? path
      RSpec::Core::RakeTask.new(name) do |t|
        t.pattern = pattern
        t.rspec_opts = rspec_opts
        if example
          t.rspec_opts += " -e #{example.inspect}"
        end
      end

      puts "\nRunning %s"%pattern

      Rake::Task[name].invoke
    else
      puts "File does not exist: %s"%pattern
    end

  end


  ########
  # RCOV #
  ########

  desc "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:rcov) do |t|
    ENV["RUBYGAME_NEWRECT"] = "true"
    t.pattern = 'spec/*_spec.rb'
    t.rcov = true
    t.rspec_opts = rspec_opts
  end


  namespace :rcov do
    desc "Run all specs with rcov"
    RSpec::Core::RakeTask.new(:all) do |t|
      ENV["RUBYGAME_NEWRECT"] = "true"
      t.pattern = 'spec/*_spec.rb'
      t.rcov = true
      t.rspec_opts = rspec_opts
    end

    desc "Run spec/[name]_spec.rb (e.g. 'color') with rcov"
    task :name do
      puts( "This is just a stand-in spec.",
            "Run rake rcov:[name] where [name] is e.g. 'color', 'music'." )
    end
  end


  rule(/rcov:.+/) do |t|
    name = t.name.gsub("rcov:","")

    pattern = File.join('spec', '%s_spec.rb'%name)
    path = File.join( pattern )

    if File.exist? path
      RSpec::Core::RakeTask.new(name) do |t|
        t.pattern = pattern
        t.rcov = true
        t.rspec_opts = rspec_opts
      end

      puts "\nRunning %s"%pattern

      Rake::Task[name].invoke
    else
      puts "File does not exist: %s"%pattern
    end

  end

rescue LoadError

  error = "ERROR: rspec >= 2.0 is not installed?"

  task :spec do 
    puts error
  end

  rule( /spec:.*/ ) do
    puts error
  end

  task :rcov do 
    puts error
  end

  rule( /rcov:.*/ ) do
    puts error
  end

end
