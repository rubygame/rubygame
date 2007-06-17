require 'matricks'
require 'collider'

module Shape
	include Collider

	attr_reader :matrix
	attr_accessor :depth

	def initialize(*args)
		@matrix = Matrix.identity(3)
		@depth = 0
		super
	end
	
	# subclass provides initialize

	# subclass provides parameters

	# subclass provides parameters=

	def initialize_copy( orig )
		self.parameters = orig.parameters
		@matrix = orig.matrix
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
		transform( Matrix.translate(x,y) )
	end

	def translate!( x, y )
		transform!( Matrix.translate(x,y) )
	end

	def rotate( theta )
		transform( Matrix.rotate(theta) )
	end

	def rotate!( theta )
		transform!( Matrix.rotate(theta) )
	end

	def scale( x, y=nil )
		transform( Matrix.scale(x,y) )
	end

	def scale!( x, y=nil )
		transform!( Matrix.scale(x,y) )
	end

end
