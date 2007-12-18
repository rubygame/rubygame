
# A mix-in module defining color arithmetic operations.
module ColorBase

	# Perform color addition with another color of any type.
	# The alpha of the new color will be equal to the alpha
	# of the receiver.
	def +(other)
		simple_operation(other) { |a,b| a + b }
	end
	
	# Perform color subtraction with another color of any type.
	# The alpha of the new color will be equal to the alpha
	# of the receiver.
	def -(other)
		simple_operation(other) { |a,b|  a - b }
	end

	# Perform color multiplication with another color of any type.
	# The alpha of the new color will be equal to the alpha
	# of the receiver.
	def *(other)
		simple_operation(other) { |a,b|  a * b }
	end
	
	# Perform color division with another color of any type.
	# The alpha of the new color will be equal to the alpha
	# of the receiver.
	def /(other)
		simple_operation(other) { |a,b|  a / b }
	end

	private
	
	def simple_operation(other, &block)
		c1, c2 = self.to_rgba_ary, other.to_rgba_ary
		a1, a2 = c1[3], c2[3]

		rgba = [0,1,2].collect do |i| 
			clamp( block.call( a1*c1.at(i),  a2*c2.at(i) ) )
		end

		rgba << a1

		return self.class.new_from_rgba( rgba )
	end
	
	def clamp(v, min=0.0, max=1.0)
		v = min if v < min
		v = max if v > max
		return v		
	end
end
