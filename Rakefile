# 
# This is the Rakefile for Rubygame. It's used for packaging,
# installing, generating the documentation, and running specs.
# 


# The version number for Rubygame.
RUBYGAME_VERSION = [2,6,2]



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

  s.require_paths = ["lib", "lib/rubygame/"]

  s.has_rdoc = true
  s.extra_rdoc_files = FileList.new do |fl|
    fl.include "doc/*.rdoc"
    fl.include "README", "LICENSE", "CREDITS", "ROADMAP", "NEWS"
  end

  s.required_ruby_version = ">= 1.8"
  s.add_dependency( "rake", ">=0.7.0" )
  s.add_dependency( "ruby-sdl-ffi", ">=0.1.0" )
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
  rd.main = "README"
  rd.title = "Rubygame #{RUBYGAME_VERSION.join(".")} Docs"
  rd.rdoc_files.include("lib/rubygame/**/*.rb",
                        "doc/*.rdoc",
                        "README",
                        "LICENSE",
                        "CREDITS",
                        "ROADMAP",
                        "NEWS")
end

desc "Generate RI-formatted docs."
task(:ri) do
  sh('rdoc --ri --threads=1 --force-update --output "./ri" ./lib')
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
