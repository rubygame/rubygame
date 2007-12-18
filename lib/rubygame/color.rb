#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2007  John Croisant
#
#	This library is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++

require 'rubygame/color/models/base'
require 'rubygame/color/models/rgb'
require 'rubygame/color/models/hsv'
require 'rubygame/color/models/hsl'

require 'rubygame/color/palettes/palette'
require 'rubygame/color/palettes/x11'
require 'rubygame/color/palettes/css'

module Rubygame
	module Color

		GLOBAL = Palette.new()
		GLOBAL.include CSS
		
		def self.[]( name )
			GLOBAL[name]
		end
		
		def self.[]=( name, color )
			GLOBAL[name] = color
		end
		
	end
end

