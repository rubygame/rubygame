require 'rubygems'
Gem::manage_gems

require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'

spec = Gem::Specification.new do |s|
  s.name     = "rubygame"
  s.version  = "1.1.0"
  s.author   = "John Croisant"
  s.email    = "rubygame@seul.org"
  s.homepage = "http://rubygame.seul.org/"
  s.platform = Gem::Platform::LINUX_586
  s.summary  = "pygame-like game development library and extension"
  s.has_rdoc = true

  candidates = Dir.glob("{lib,ext,samples,doc}/**/*")
  s.files    = candidates.delete_if do |item|
    item.include?("svn")
  end

  s.require_paths = ["lib","ext"]
  s.autorequire = "rubygame.rb"
  s.extensions = ["ext/rubygame/extconf.rb"]

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
                        "ext/rubygame/extconf.rb",\
                        "doc/*.rdoc")
end

desc "Configure the extension for compilation."
task :config do
  sh "ruby setup.rb config"
end

mf = File.join("ext", "rubygame", "Makefile")

file mf do
  Rake::Task[:config].invoke
end

desc "Compile extension."
task :build => [mf] do
  sh "ruby setup.rb setup"
end

desc "Install extension and library to system."
task :install => [:build] do
  sh "ruby setup.rb install"
end

task :clean do
  sh "ruby setup.rb clean"
end

require 'rake/clean'

CLEAN.include(File.join("ext", "rubygame", "Makefile"),
              File.join("ext", "rubygame", "mkmf.log"))

task :default => [:build]
