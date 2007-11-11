require 'rubygame/gl/collidable'
require 'rubygame/gl/matrix3'
require 'rubygame/gl/transform2'

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

	def transform( transform )
		s = self.dup
		s.transform!( transform )
	end

	def transform!( transform )
		case transform
		when Transform2, Matrix3
			@matrix = transform * @matrix
		when Hash
			@matrix = Transform2.new(transform) * @matrix
		end
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
