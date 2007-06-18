require 'matricks'
require 'sat'
require 'shape'

class Triangle
	include Shape

	def initialize( *points )
		@a, @b, @c, junk = points
		super()
	end

	def parameters
		[@a, @b, @c]
	end

	def parameters=(params)
		@a, @b, @c = params
	end

	def collide_has_points(other)
		pointsA = self.points
		pointsB = other.points

		projection_overlap?( @b - @a, pointsA, pointsB ) and \
		projection_overlap?( @c - @b, pointsA, pointsB ) and \
		projection_overlap?( @a - @c, pointsA, pointsB )
	end

	alias :collide_boundary :collide_has_points
	alias :collide_triangle :collide_has_points

	def points
		[@a, @b, @c].map { |point| @matrix*point }
	end

	def to_s
		"#<Triangle #{@a.to_s} #{@b.to_s} #{@c.to_s}>"
	end

	def inspect
		"#<Triangle:%#0x #{@a.inspect} #{@b.inspect} #{@c.inspect}>"%object_id
	end
end
