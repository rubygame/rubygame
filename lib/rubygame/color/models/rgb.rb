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

		# Represents color in the RGB (Red, Green, Blue) color space,
		# with each color component as a float from 0.0 to 1.0.
		# 
		# See also ColorRGB255, where components are integers from 0 to 255.
		# 
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
				if color.kind_of?(Array) and color.size >= 3
					@r, @g, @b, @a = color.collect { |i| i.to_f }
					@a = 1.0 unless @a
				elsif color.instance_of?(self.class)
					@r, @g, @b, @a = color.to_ary
				elsif color.respond_to?(:to_rgba_ary)
					@r, @g, @b, @a = color.to_rgba_ary
				else
					raise ArgumentError, "Invalid color: #{color.inspect}"
				end
			end

			# Creates a new instance from an RGBA array of floats ranging
			# from 0.0 to 1.0.
			def self.new_from_rgba( rgba )
				new( rgba )
			end

			# Returns the color as an RGBA array of floats ranging from 0.0
			# to 1.0.
			def to_rgba_ary
				return [@r, @g, @b, @a]
			end

			# Same as #to_rgba_ary
			def to_ary
				return [@r, @g, @b, @a]
			end

		end
	end
end
