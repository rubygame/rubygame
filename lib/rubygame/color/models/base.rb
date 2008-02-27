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

# A mix-in module defining color arithmetic operations.
module ColorBase

	# Perform color addition with another color of any type.
	# The alpha of the new color will be equal to the alpha
	# of the receiver.
	def +(other)
		wrap( simple_op(other)  { |a,b| a + b } )
	end
	
	# Perform color subtraction with another color of any type.
	# The alpha of the new color will be equal to the alpha
	# of the receiver.
	def -(other)
		wrap( simple_op(other)  { |a,b|  a - b } )
	end

	# Perform color multiplication with another color of any type.
	# The alpha of the new color will be equal to the alpha
	# of the receiver.
	def *(other)
		wrap( simple_op(other)  { |a,b|  a * b } )
	end
	
	# Perform color division with another color of any type.
	# The alpha of the new color will be equal to the alpha
	# of the receiver.
	def /(other)
		wrap( simple_op(other)  { |a,b|  a / b } )
	end
	
	# Layer this color over another color.
	def over(other)
		c1, c2 = self.to_rgba_ary, other.to_rgba_ary
		a1, a2 = c1[3], c2[3]

		rgba = [0,1,2].collect do |i| 
			clamp( a1*c1.at(i) + a2*c2.at(i)*(1-a1) )
		end
		
		rgba << ( a1 + a2*(1-a1) )
		
		wrap( rgba )
	end
	
	# Average this color with another color. (Linear weighted average)
	# 
	# A weight of 0.0 means 0% of this color, 100% of the other.
	# A weight of 1.0 means 100% of this color, 0% of the other.
	# A weight of 0.5 means 50% of each color.
	# 
	def average(other, weight=0.5)
		c1, c2 = self.to_rgba_ary, other.to_rgba_ary

		rgba = [0,1,2,3].collect do |i| 
			clamp( c1.at(i)*weight + c2.at(i)*(1-weight) )
		end
		
		wrap( rgba )
	end

	private
	
	def wrap( rgba )
		self.class.new_from_rgba( rgba )
	end
	
	def simple_op(other, &block)
		c1, c2 = self.to_rgba_ary, other.to_rgba_ary
		a1, a2 = c1[3], c2[3]

		rgba = [0,1,2].collect do |i| 
			clamp( block.call( a1*c1.at(i),  a2*c2.at(i) ) )
		end

		rgba << a1

		return rgba
	end
	
	def clamp(v, min=0.0, max=1.0)
		v = min if v < min
		v = max if v > max
		return v		
	end
end

end
end
