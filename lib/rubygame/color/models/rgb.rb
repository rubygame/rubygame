require 'rubygame/color_models/base'

module Rubygame
	module Color

		# Represents color in the RGB (Red, Green, Blue) color space.
		class ColorRGB
			include ColorBase
			
			attr_reader :r, :g, :b, :a

			# call-seq:
			#   new( [r,g,b,a] )  ->  ColorRGB
			#   new( [r,g,b] )  ->  ColorRGB
			#   new( color )  ->  ColorRGB
			# 
			# Create a new instance from an Array or an existing color
			# (of any type). If the alpha (opacity) component is omitted
			# from the array, full opacity will be used.
			# 
			# All color components range from 0.0 to 1.0.
			# 
			def initialize( color )
				if color.kind_of?(Array)
					@r, @g, @b, @a = color.collect { |i| i.to_f }
					@a = 1.0 unless @a
				elsif color.respond_to?(:to_rgba_ary)
					@r, @g, @b, @a = color.to_rgba_ary
				end
			end
			
			# Converts the color to an RGBA array of integers 
			# ranging from 0 to 255, as SDL wants.
			def to_sdl_rgba_ary
				self.to_rgba_ary.collect { |i| (i * 255).to_i }
			end
			
			def to_rgba_ary
				return [@r, @g, @b, @a]
			end
			
			class << self
				def new_from_rgba( rgba )
					new( rgba )
				end

				def new_from_sdl_rgba( rgba )
					new_from_rgba( rgba.collect { |i| i / 255.0 } )
				end
			end
			
		end
	end
end
