require 'rubygame/gl/matricks'
require 'rubygame/gl/collider'

module Shape
	include Collider

	attr_reader :matrix
	attr_accessor :depth

	def initialize(*args)
		@matrix = Matrix.identity(3)
		@depth = 0
		super
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

# 	def self.included(klass)
# 		puts "#{self} included in #{klass}"
# 		klass.instance_eval {
#
# 			# Defines a method to read named points (@a, @b, etc.) from the Shape,
# 			# 
# 			# Just like attr_reader, but factors in the transformation matrix.
# 			# 
# 			#   class Quadrangle
# 			#     include Shape
# 			#     point_reader :a, :b, :c, :d
# 			#     ...
# 			#   end
# 			#   
# 			#   q = Quadrangle.new( [0,0], [10,5], [10,8], [3,5] )
# 			#   q.translate!( 20, -10 )
# 			#   q.a  #  =>  Point[20,-10]
# 			#   q.b  #  =>  Point[30,-5]
# 			#   q.c  #  =>  Point[30,-2]
# 			#   q.d  #  =>  Point[23,-5]
# 			def point_reader( *symbols )
# 				symbols.each do |symbol|
# 					ivar = "@#{symbol.to_s}".to_sym # e.g. :@a
# 					block = Proc.new { @matrix * instance_variable_get(ivar) }
# 					define_method( symbol, block )
# 				end
# 			end
#
# 		}
# 	end
end
