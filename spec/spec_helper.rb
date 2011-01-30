
# Prefer to load from ../lib before the system paths.
$:.unshift File.absolute_path(File.join(File.dirname(__FILE__),"..","lib"))
