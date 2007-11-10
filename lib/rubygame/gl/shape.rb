require 'rubygame/gl/collidable'
require 'rubygame/gl/matrix3'

module Shape
	include Collidable

	attr_reader :matrix
	attr_accessor :depth

	def initialize(*args)
		@matrix = Matrix3.identity
		@depth = 0
		super()
	end
	
	def initialize_copy( orig )
		@matrix = orig.matrix
		super
	end

	def transform( matrix )
		s = self.dup
		s.transform!( matrix )
	end

	def transform!( matrix )
		@matrix = matrix * @matrix
		return self
	end

	def translate( x, y )
		transform( Matrix3.translate(x,y) )
	end

	def translate!( x, y )
		transform!( Matrix3.translate(x,y) )
	end

	def rotate( theta )
		transform( Matrix3.rotate(theta) )
	end

	def rotate!( theta )
		transform!( Matrix3.rotate(theta) )
	end

	def scale( x, y=nil )
		transform( Matrix3.scale(x,y) )
	end

	def scale!( x, y=nil )
		transform!( Matrix3.scale(x,y) )
	end
end
