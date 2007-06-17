require 'matricks'
require 'sat'

class Triangle
	def initialize( *points )
		@a, @b, @c, junk = points
	end

	def points
		[@a, @b, @c]
	end

	def collide_tri( other_triangle )
		pointsA = self.points
		pointsB = other_triangle.points

		projection_overlap?( @b - @a, pointsA, pointsB ) and \
		projection_overlap?( @c - @b, pointsA, pointsB ) and \
		projection_overlap?( @a - @c, pointsA, pointsB )
	end

	def apply_matrix(m)
		Triangle.new( m*@a, m*@b, m*@c )
	end

	def to_s
		"#<Triangle #{@a.to_s} #{@b.to_s} #{@c.to_s}>"
	end

	def inspect
		"#<Triangle:%#0x #{@a.inspect} #{@b.inspect} #{@c.inspect}>"%object_id
	end
end
