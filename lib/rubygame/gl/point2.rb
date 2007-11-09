require 'rubygame/gl/vector2'
require 'rubygame/gl/transform2'

class Point2
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
		   Vector2.new( @x - other.x,   @y - other.y  )
	end
	
	def []( index )
		self.to_ary[index]
	end
	
	def projected_onto( v )
		self.class.new(  *(v * v.dot(self.to_v) * (1/v.magnitude**2) )  )
	end
	
	def to_ary
		[@x, @y]
	end
	
	def to_p
		self
	end
	
	def to_s
		"#{self.class.name}[#{x}, #{y}]"
	end
	
	def to_v
		Vector2.new( @x, @y )
	end
	
	def transformed( description = {} )
		Transform2.new( description ) * self
	end
end
