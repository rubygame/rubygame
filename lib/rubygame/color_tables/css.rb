require 'rubygame/color'
require 'rubygame/color_tables/x11'

module Rubygame
	module Color

		# The X11 module contains all the colors in the CSS/HTML palette
		# by symbol name, e.g. :alice_blue, :dark_olive_green, etc.
		# 
		# The CSS palette is identical to the X11 palette, except for
		# four colors: GRAY, GREEN, MAROON, and PURPLE. 
		# 
		# Differences between CSS and X11, derived from
		# http://en.wikipedia.org/wiki/X11_color_names
		# as accessed on 2007-12-17
		# 
		module CSS
			include X11
			
			# See Rubygame::Color#[]
			def self.[]( name )
				self.const_get( name.to_s.gsub(' ','_').upcase.intern )
			rescue NameError
				return nil
			end
			
			GRAY =                     ColorRGB.new( [0.50196, 0.50196, 0.50196] )
			GREEN =                    ColorRGB.new( [0.00000, 0.50196, 0.00000] )
			MAROON =                   ColorRGB.new( [0.50196, 0.00000, 0.00000] )
			PURPLE =                   ColorRGB.new( [0.50196, 0.00000, 0.50196] )
			
		end

	end
end
