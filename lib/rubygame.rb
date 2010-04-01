#--
#
#  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#  Copyright (C) 2004-2009  John Croisant
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#++


this_dir = File.expand_path( File.dirname(__FILE__) )


# Require Rubygame files. If these fail, don't rescue.
# Note: screen.rb is intentionally loaded late.
%w{ main
    shared
    clock
    constants
    color
    event
    events
    event_handler
    gl
    joystick
    named_resource
    queue
    rect
    surface
    sprite
}.each do |f|
  require File.join( this_dir, "rubygame", f )
end


# SDL_gfx is optional, rescue if it fails.
begin
  require File.join( this_dir, "rubygame", "gfx" )
rescue LoadError => e
  puts( "Warning: Could not load SDL_gfx! " +
        "Continuing anyway, but some Surface methods will be missing.\n" +
        "Error message was: #{e.message.inspect}" )
end


# SDL_image is optional, rescue if it fails.
begin
  require File.join( this_dir, "rubygame", "image" )
rescue LoadError => e
  puts( "Warning: Could not load SDL_image! " +
        "Continuing anyway, but image loading will be missing.\n" +
        "Error message was: #{e.message.inspect}" )
end


# SDL_mixer is optional, rescue if it fails.
begin
  require File.join( this_dir, "rubygame", "mixer" )
rescue LoadError => e
  puts( "Warning: Could not load SDL_mixer! " +
        "Continuing anyway, but audio features will be missing.\n" +
        "Error message was: #{e.message.inspect}" )
end


# SDL_ttf is optional, rescue if it fails.
begin
  require File.join( this_dir, "rubygame", "ttf" )
rescue LoadError => e
  puts( "Warning: Could not load SDL_ttf! " +
        "Continuing anyway, but the TTF class will be missing.\n" +
        "Error message was: #{e.message.inspect}" )
end


# Loaded late so Screen can undefine some inherited Surface methods.
require File.join( this_dir, "rubygame", "screen" )


# Handle initialization automatically unless the RUBYGAME_NOINIT
# environmental variable is set to something truthy.
unless /^(1|t|true|y|yes)$/i =~ ENV["RUBYGAME_NOINIT"]
  Rubygame.init
  at_exit { Rubygame.quit }
end
