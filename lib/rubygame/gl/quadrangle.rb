require 'matricks'
require 'sat'
require 'shape'
require 'boundary'

class Quadrangle
	include Shape

	attr_reader :a, :b, :c, :d
	attr_writer :a, :b, :c, :d

	def initialize( *points )
		@a, @b, @c, @d, junk = Point.ify(*points)
		super()
	end

	def initialize_copy( orig )
		@a, @b, @c, @d = orig.a, orig.b, orig.c, orig.d
		super
	end

	def bounds
		Boundary.envelope( *points )
	end

	def center
		sum = points.map { |p| p.to_v }.inject { |a,b| a + b }
		return (sum * 0.25).to_p
	end

	def collide_has_points(other)
		pointsA = self.points
		pointsB = other.points

		projection_overlap?( @b - @a, pointsA, pointsB ) and \
		projection_overlap?( @c - @b, pointsA, pointsB ) and \
		projection_overlap?( @d - @c, pointsA, pointsB ) and \
		projection_overlap?( @a - @d, pointsA, pointsB )		
	end

	alias :collide_boundary :collide_has_points
	alias :collide_triangle :collide_has_points
	alias :collide_quadrangle :collide_has_points

	def points
		[@a, @b, @c, @d].map { |point| @matrix*point }
	end

	def to_s
		"#<Quadrangle #{@a.to_s} #{@b.to_s} #{@c.to_s} #{@d.to_s}>"
	end

	def inspect
		"#<Quadrangle:%#0x #{@a.inspect} #{@b.inspect} #{@c.inspect} #{@d.inspect}>"%object_id
	end
end

