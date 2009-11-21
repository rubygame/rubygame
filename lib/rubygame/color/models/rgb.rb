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
			
			def to_s
				"#<#{self.class} [#{@r}, #{@g}, #{@b}, #{@a}]>"
			end
			alias :inspect :to_s
			
			def hash
				@hash ||= ((@r.hash << 4) +
				           (@g.hash << 3) +
				           (@b.hash << 2) +
				           (@a.hash << 1) +
				           self.class.hash)
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
