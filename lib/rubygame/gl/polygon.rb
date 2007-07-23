require 'rubygame/gl/matricks'
require 'rubygame/gl/sat'
require 'rubygame/gl/shape'
require 'rubygame/gl/boundary'


class Polygon
	include Shape

	TWO_PI = Math::PI * 2
	HALF_PI = Math::PI / 2
	
	def self.regular( sides, radius = 0.5 )
		points = []
		0.upto( sides - 1 ) do |n| 
			a = TWO_PI * n / sides
			a += HALF_PI							# 90 degree rotation
			points << [ radius * Math.cos(a), radius * Math.sin(a) ]
		end
		return Polygon.new( *points )
	end
	
	def initialize( *points )
		@points = Point.ify(*points)
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
		return Point[*(sum * 1.quo(@points.length).to_f)]
	end

	def collide_polygon(other)
		pointsA = self.points
		pointsB = other.points

		[pointsA, pointsB].all? do |points|
			collides = true
			points.each_index do |i|
				q, p = points[i], points[i-1]
				collides &= projection_overlap?( q - p, pointsA, pointsB )
			end
			collides
		end
	end

	def inspect
		"#<#{self.class}:%#0x #{points.join(" ")}>"%object_id
	end

	def points
		raw_points.map { |point| @matrix * point }
	end

	def raw_points
		@points
	end

	def to_s
		"#<#{self.class} #{points.join(" ")}>"
	end
end

class Polygon
	TRIANGLE = Polygon.regular( 3 )
	TRIGON = TRIANGLE
	QUADRANGLE = Polygon.regular( 4 )
	PENTAGON = Polygon.regular( 5 )
	HEXAGON = Polygon.regular( 6 )
	OCTAGON = Polygon.regular( 8 )
	ICOSAGON = Polygon.regular( 20 )
	CENTAGON = Polygon.regular( 100 )
	HECTAGON = CENTAGON
	
	UNIT_SQUARE = Polygon.new([-0.5, -0.5], [ 0.5, -0.5],
														[ 0.5,  0.5], [-0.5,  0.5])	
end
