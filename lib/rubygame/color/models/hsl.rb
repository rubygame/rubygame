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



module Rubygame
	module Color

		# Represents color in the HSL (Hue, Saturation, Luminosity) color space.
		class ColorHSL
			include ColorBase
			
			attr_reader :h, :s, :l, :a

			# call-seq:
			#   new( [h,s,l,a] )  ->  ColorHSL
			#   new( [h,s,l] )  ->  ColorHSL
			#   new( color )  ->  ColorHSL
			# 
			# Create a new instance from an Array or an existing color
			# (of any type). If the alpha (opacity) component is omitted
			# from the array, full opacity will be used.
			# 
			# All color components range from 0.0 to 1.0.
			# 
			def initialize( color )
				if color.kind_of?(Array)
					@h, @s, @l, @a = color.collect { |i| i.to_f }
					@a = 1.0 unless @a
				elsif color.respond_to?(:to_rgba_ary)
					@h, @s, @l, @a = self.class.rgba_to_hsla( *color.to_rgba_ary )
				end
			end

			# Return an Array with the red, green, blue, and alpha components
			# of the color (converting the color to the RGBA model first).
			def to_rgba_ary
				return self.class.hsla_to_rgba( @h, @s, @l, @a )
			end
			
			def to_s
				"#<#{self.class} [#{@h}, #{@s}, #{@l}, #{@a}]>"
			end
			alias :inspect :to_s
			
			def hash
				@hash ||= ((@h.hash << 4) +
				           (@s.hash << 3) +
				           (@l.hash << 2) +
				           (@a.hash << 1) +
				           self.class.hash)
			end

			class << self

				def new_from_rgba( rgba )
					new( rgba_to_hsla(*rgba) )
				end
				
				def new_from_sdl_rgba( rgba )
					new_from_rgba( rgba.collect { |i| i / 255.0 } )
				end
				
				# Convert the red, green, blue, and alpha to the
				# equivalent hue, saturation, luminosity, and alpha.
				def rgba_to_hsla( r, g, b, a ) # :nodoc:
					rgb_arr = [r, g, b]
					max     = rgb_arr.max
					min     = rgb_arr.min

					# Calculate lightness.
					l = (max + min) / 2.0

					# Calculate saturation.
					if l == 0.0 or max == min
						s = 0
					elsif 0 < l and l <= 0.5 
						s = (max - min) / (max + min)
					else # l > 0.5
						s = (max - min) / (2 - (max + min))
					end
					
					# Calculate hue.
					if min == max 
						h = 0 
						# Undefined in this case, but set it to zero
					elsif max == r and g >= b
						h = (1.quo(6) * (g - b) / (max - min)) + 0
					elsif max == r and g < b
						h = (1.quo(6) * (g - b) / (max - min)) + 1.0
					elsif max == g
						h = (1.quo(6) * (b - r) / (max - min)) + 1.quo(3)
					elsif max == b
						h = (1.quo(6) * (r - g) / (max - min)) + 2.quo(3)
					else 
						raise "Should never happen"
					end 
					
					return [h,s,l,a]
				end
				
				# Convert the hue, saturation, luminosity, and alpha
				# to the equivalent red, green, blue, and alpha.
				def hsla_to_rgba( h, s, l, a ) # :nodoc:
					# If the color is achromatic, return already with the lightness value for all components
					if s == 0.0
						return [l, l, l, a]
					end

					# Otherwise, we have to do the long, hard calculation

					# q helper value
					q = (l < 0.5) ? (l * (1.0 + s)) : (l + s - l * s)

					# p helper value
					p = (2.0 * l) - q

					r = calculate_component( p, q, h + 1.quo(3) )
					g = calculate_component( p, q, h            )
					b = calculate_component( p, q, h - 1.quo(3) )

					return [r,g,b,a]
				end

				private
				
				# Perform some arcane math to calculate a color component.
				def calculate_component(p, q, tc) # :nodoc:
					tc %= 1.0
					if tc < 1.quo(6)
						p + (q - p) * tc * 6.0
					elsif tc < 0.5
						q
					elsif tc < 2.quo(3)
						p + (q - p) * (2.quo(3) - tc) * 6.0
					else
						p 
					end
				end
				
			end

		end
	end
end
