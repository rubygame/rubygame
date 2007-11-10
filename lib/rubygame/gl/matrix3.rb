require 'rubygame/gl/point2'
require 'rubygame/gl/transform2'
require 'rubygame/gl/vector2'

# A 3x3 matrix class. Primarily used for representing 2D
# transformations. See also Transform.
# 
#   a  b  c
#   d  e  f
#   g  h  i
# 
class Matrix3
	attr_reader :a, :b, :c, :d, :e, :f, :g, :h, :i

	class << self
		# Another way to create a new Matrix3, besides
		# Matrix3.new.
		def []( *args )
			self.new( *args )
		end

		# Create an identity matrix.
		def identity
			self.new( [1,0,0], [0,1,0], [0,0,1] )
		end
		
		# Create a translation matrix.
		def translate(x,y)
			self.new( [1,0,x], [0,1,y], [0,0,1] )
		end
		
		# Create a rotation matrix.
		def rotate(angle)
			c = Math::cos(angle)
			s = Math::sin(angle)
			t = -s
			self.new( [c,t,0], [s,c,0], [0,0,1] )
		end
		
		# Create a scaling matrix.
		def scale(x,y)
			self.new( [x,0,0], [0,y,0], [0,0,1] )
		end
		
		# Create a shearing matrix.
		def shear(x,y)
			self.new( [1,x,0], [y,1,0], [0,0,1] )
		end
	end

	# Create a new Matrix3. See also Matrix3.[]
	def initialize( row1, row2, row3=[0,0,1] )
		@a, @b, @c = row1
		@d, @e, @f = row2
		@g, @h, @i = row3
	end

	def ==( other )
		self.to_ary == other.to_ary
	end
	
	# Multiply this Matrix3 with a Vector2, a Point2, or
	# another Matrix3.
	def *( other )
		case other
		when Vector2 
			x, y = other.x, other.y
			return (other.class)[ (@a*x + @b*y), (@d*x + @e*y) ]
		when Point2
			x, y = other.x, other.y
			return (other.class)[ (@a*x + @b*y + @c), (@d*x + @e*y + @f) ]
		when Matrix3, Transform2
			other = other.to_m

			a,b,c,\
			d,e,f,\
			g,h,i = other.to_ary.flatten!

			row1 = [@a*a + @b*d + @c*g,  @a*b + @b*e + @c*h, @a*c + @b*f + @c*i ]
			row2 = [@d*a + @e*d + @f*g,  @d*b + @e*e + @f*h, @d*c + @e*f + @f*i ]
			row3 = [@g*a + @h*d + @i*g,  @g*b + @h*e + @i*h, @g*c + @h*f + @i*i ]
			
			return (other.class)[row1, row2, row3]
		else
			raise ArgumentError, "Can't multiply Matrix3 with #{other.class}."
		end
	end
	
	# Convert to nested Arrays.
	def to_ary
		return [[@a, @b, @c], [@d, @e, @f], [@g, @h, @i]]
	end
	
	# Represent as a string.
	def to_s
		return "#<Matrix3 [[%f, %f, %f], [%f, %f, %f], [%f, %f, %f]]>"%self.to_ary.flatten!
	end
	
	def to_m
		return self
	end
	
	alias :inspect :to_s
end
