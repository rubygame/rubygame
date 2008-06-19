#--
#  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#  Copyright (C) 2004-2007, 2008  John Croisant
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
#++

# This file is loaded when you "require 'rubygame'".
# It loads up the compiled C extensions and the rest of
# the Rubygame library modules.

require "rbconfig"

require "rubygame_core"

%W{ rubygame_gfx rubygame_image rubygame_ttf rubygame_mixer }.each do |mod|
  begin
    require mod
  rescue LoadError
    warn( "Warning: Unable to require optional module: #{mod}.") if $VERBOSE
  end
end

require "rubygame/color"
require "rubygame/constants"

require "rubygame/event"
require "rubygame/queue"
require "rubygame/event_handler"

require "rubygame/rect"
require "rubygame/sprite"
require "rubygame/clock"
