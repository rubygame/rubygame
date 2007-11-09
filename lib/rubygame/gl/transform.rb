require 'rubygame/gl/matricks'

# Transform stores transformation information as attributes:
# 
# angle:: rotation about the forward axis. A Numeric.
# scale:: scaling factor on X and Y. A Vector2.
# shear:: shearing amount on X and Y. A Vector2.
# shift:: translation, i.e. movement, on X and Y. A Vector2.
# 
# It can (eventually) be applied to a Vector2 or Point as-is,
# composited with other Transforms,
# or converted to a 3x3 Matrix if needed.
# 
class Transform
	attr_accessor :angle, :scale, :shear, :shift
	
	def initialize( description = {} )
		@angle = (description[:angle] or 0)
		@scale = (description[:scale] or [1,1])
		@shear = (description[:shear] or [0,0])
		@shift = (description[:shift] or [0,0])
		
		# Scale is allowed to be 1 number for uniform scale,
		# or an Array of 2 numbers for nonuniform scale.
		case @scale
		when Numeric
			@scale = Vector2[@scale, @scale]
		when Array
			@scale = Vector2[*@scale]
		end
		
		@shear = Vector2[*@shear]
		@shift = Vector2[*@shift]
	end
	
	# Convert to 3x3 transformation matrix
	def to_m
		c = Math.cos(@angle)
		s = Math.sin(@angle)
		
		Matrix[[c*@scale.x          + -s*@scale.y*@shear.y,
						c*@scale.x*@shear.x + -s*@scale.y,
						@shift.x],
					 [s*@scale.x          + c*@scale.y*@shear.y,
						s*@scale.x*@shear.x + c*@scale.y,
						@shift.y],
					 [0, 0, 1]]
	end

	# Should be equivalent to #to_m
	def to_m2
		return Matrix.translate(*@shift) * Matrix.rotate(@angle) * Matrix.scale(*@scale) * Matrix.shear(*@shear)
	end
end
