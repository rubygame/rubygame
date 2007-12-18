require 'rubygame/color_models/base'
require 'rubygame/color_models/rgb'
require 'rubygame/color_models/hsv'
require 'rubygame/color_models/hsl'

require 'rubygame/color_tables/palette'
require 'rubygame/color_tables/x11'
require 'rubygame/color_tables/css'

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

