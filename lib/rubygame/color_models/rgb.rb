require 'rubygame/color_models/base'

module Rubygame
	module Color

		# Represents color in the RGB (Red, Green, Blue) color space.
		class ColorRGB
			include ColorBase
			
			attr_reader :r, :g, :b, :a

			# call-seq:
			#   new( [r,g,b,a] )  ->  ColorHSV
			#   new( [r,g,b] )  ->  ColorHSV
			#   new( color )  ->  ColorHSV
			# 
			# Create a new instance from an Array or an existing color
			# (of any type). If the alpha (opacity) component is omitted
			# from the array, full opacity will be used.
			# 
			# r, g, b, a values are expected to range from 0.0 to 1.0.
			# 
			def initialize( color )
				if color.kind_of?(Array)
					@r, @g, @b, @a = color.collect { |i| i.to_f }
					@a = 1.0 unless @a
				elsif color.respond_to?(:to_rgba_ary)
					@r, @g, @b, @a = color.to_rgba_ary
				end
			end
			
			def to_rgba_ary
				return [@r, @g, @b, @a]
			end
			
			class << self
				def new_from_rgba( rgba )
					new( rgba )
				end
			end
			
		end
	end
end
