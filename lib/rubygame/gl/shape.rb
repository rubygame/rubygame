require 'matricks'

class NoCollisionHandler < NoMethodError
end

module Shape
	def collide( other )
		collide_method = "collide_#{other.class.name.downcase}".to_sym
		if respond_to? collide_method
			return send( collide_method, other )
		else
			raise NoCollisionHandler
		end
		
	end

	attr_reader :matrix

	def initialize(*args)
		@matrix = Matrix.identity(3)
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
