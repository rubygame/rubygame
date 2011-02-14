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


# Require Rubygame files. If these fail, don't rescue.
# Note: screen.rb is intentionally loaded late.
require "rubygame/main"
require "rubygame/shared"
require "rubygame/clock"
require "rubygame/constants"
require "rubygame/color"
require "rubygame/event"
require "rubygame/events"
require "rubygame/event_handler"
require "rubygame/gl"
require "rubygame/imagefont"
require "rubygame/joystick"
require "rubygame/named_resource"
require "rubygame/queue"
require "rubygame/surface"
require "rubygame/sprite"
require "rubygame/vector2"


# If RUBYGAME_NEWRECT is set, load the new Rect class. Otherwise load
# the old Rect class, for backwards compatibility. The old Rect class
# will be removed in Rubygame 3.0.
if /^(1|t|true|y|yes)$/i =~ ENV["RUBYGAME_NEWRECT"]
  require "rubygame/new_rect"
else
  require "rubygame/rect"
end


# SDL_gfx is optional, rescue if it fails.
begin
  require "rubygame/gfx"
rescue LoadError => e
  puts( "Warning: Could not load SDL_gfx! " +
        "Continuing anyway, but some Surface methods will be missing.\n" +
        "Error message was: #{e.message.inspect}" )
end


# SDL_image is optional, rescue if it fails.
begin
  require "rubygame/image"
rescue LoadError => e
  puts( "Warning: Could not load SDL_image! " +
        "Continuing anyway, but image loading will be missing.\n" +
        "Error message was: #{e.message.inspect}" )
end


# SDL_mixer is optional, rescue if it fails.
begin
  require "rubygame/mixer"
rescue LoadError => e
  puts( "Warning: Could not load SDL_mixer! " +
        "Continuing anyway, but audio features will be missing.\n" +
        "Error message was: #{e.message.inspect}" )
end


# SDL_ttf is optional, rescue if it fails.
begin
  require "rubygame/ttf"
rescue LoadError => e
  puts( "Warning: Could not load SDL_ttf! " +
        "Continuing anyway, but the TTF class will be missing.\n" +
        "Error message was: #{e.message.inspect}" )
end


# Loaded late so Screen can undefine some inherited Surface methods.
require "rubygame/screen"


# Handle initialization automatically unless the RUBYGAME_NOINIT
# environmental variable is set to something truthy.
unless /^(1|t|true|y|yes)$/i =~ ENV["RUBYGAME_NOINIT"]
  Rubygame.init
  at_exit { Rubygame.quit }
end
