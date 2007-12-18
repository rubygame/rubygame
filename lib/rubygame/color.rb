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

