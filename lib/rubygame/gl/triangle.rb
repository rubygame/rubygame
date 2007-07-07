require 'matricks'
require 'sat'
require 'shape'
require 'boundary'

class Triangle
	include Shape

	attr_reader :a, :b, :c
	attr_writer :a, :b, :c

	def initialize( *points )
		@a, @b, @c, junk = Point.ify(*points)
		super()
	end

	def initialize_copy( orig )
		@a, @b, @c = orig.a, orig.b, orig.c
		super
	end

	def bounds
		Boundary.envelope( *points )
	end

	def center
		sum = points.map { |p| p.to_v }.inject { |a,b| a + b }
		return Point[*(sum * 1.quo(3).to_f)]
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
