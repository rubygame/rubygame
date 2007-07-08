require 'rubygame/gl/matricks'
require 'rubygame/gl/sat'
require 'rubygame/gl/shape'
require 'rubygame/gl/boundary'

class Quadrangle
	include Shape

	def initialize( *points )
		@points = Point.ify(*points)[0,4]
		super()
	end

	def initialize_copy( orig )
		@points = orig.raw_points
		super
	end

	def [](index)
		@matrix * @points[index]
	end

	def bounds
		Boundary.envelope( *points )
	end

	def center
		sum = points.map { |p| p.to_v }.inject { |a,b| a + b }
		return Point[*(sum * 0.25)]
	end

	def collide_has_points(other)
		pointsA = self.points
		pointsB = other.points

		[pointsA, pointsB].all? do |points|
			a,b,c,d = points
			projection_overlap?( b - a, pointsA, pointsB ) and \
			projection_overlap?( c - b, pointsA, pointsB ) and \
			projection_overlap?( d - c, pointsA, pointsB ) and \
			projection_overlap?( a - d, pointsA, pointsB )		
		end
	end

	alias :collide_boundary :collide_has_points
	alias :collide_triangle :collide_has_points
	alias :collide_quadrangle :collide_has_points

	def inspect
		"#<Quadrangle:%#0x #{points.join(" ")}>"%object_id
	end

	def points
		@points.map { |point| @matrix * point }
	end

	def raw_points
		@points
	end

	def to_s
		"#<Quadrangle #{points.join(" ")}>"
	end
end

