
# Prefer to load from ../lib before the system paths.
$:.unshift File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))

ENV["RUBYGAME_DEPRECATED"] = "quiet"
