require 'rubygame/color'
require 'rubygame/color/palettes/palette'
require 'rubygame/color/palettes/x11'

module Rubygame
	module Color

		# The CSS module contains all the colors in the CSS/HTML palette
		# by symbol name, e.g. :alice_blue, :dark_olive_green, etc.
		# 
		# NOTE: The CSS palette is identical to the X11 palette except for
		# four colors: gray, green, maroon, and purple. 
		# 
		# Differences between CSS and X11 derived from
		# http://en.wikipedia.org/wiki/X11_color_names
		# as accessed on 2007-12-17
		# 
		CSS = Palette.new({
			:gray =>                     ColorRGB.new( [0.50196, 0.50196, 0.50196] ),
			:green =>                    ColorRGB.new( [0.00000, 0.50196, 0.00000] ),
			:maroon =>                   ColorRGB.new( [0.50196, 0.00000, 0.00000] ),
			:purple =>                   ColorRGB.new( [0.50196, 0.00000, 0.50196] )
		})
		
		CSS.include X11
		
	end
end
