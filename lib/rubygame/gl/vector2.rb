require 'rubygame/gl/shared'
require 'rubygame/gl/point2'
require 'rubygame/gl/transform2'

class Vector2
	attr_reader :x, :y
	
	class << self
		def []( x, y )
			self.new( x, y )
		end
		
		def ify( *pairs )
			pairs.collect { |pair| self.new(*pair) }
		end
	end
	
	def initialize( x, y )
		@x, @y = x, y
	end
	
	def +( vector )
		self.class.new( @x + vector.x,  @y + vector.y )
	end
	
	def -( other )
		self.class.new( @x - other.x,   @y - other.y  )
	end

	def -@
		self.class.new( -@x, -@y )
	end
	
	def *( scalar )
		self.class.new( @x * scalar,    @y * scalar   )
	end
	
	def ==( other )
		@x.nearly_equal?(other.x) and @y.nearly_equal?(other.y)
	end
	
	def []( index )
		self.to_ary[index]
	end
	
	def angle
		Math.atan2( @y, @x )
	end
	
	def angle_with( other )
		Math.acos( self.udot(other) )
	end
	
	def dot( other )
		(@x * other.x) + (@y * other.y)
	end
	
	def magnitude
		Math.hypot( @x, @y )
	end
	
	def perp
		self.class.new( -@y, @x )
	end
	
	def projected_onto( v )
		self.class.new(  *(v * v.dot(self) * (1/v.magnitude**2) )  )
	end
	
	def to_ary
		[@x, @y]
	end
	
	def to_p
		Point2.new( @x, @y)
	end
	
	def to_s
		"#{self.class.name}[#{x}, #{y}]"
	end
	
	def to_v
		self
	end
	
	def transformed( description = {} )
		Transform2.new( description ) * self
	end
	
	def udot( other )
		self.unit.dot( other.unit )
	end

	def unit
		self * (1/magnitude())
	end
end
