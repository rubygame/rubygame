require 'rubygame/gl/matricks'
require 'rubygame/gl/sat'
require 'rubygame/gl/shape'
require 'rubygame/gl/boundary'

class Ellipse
	include Shape

	attr_reader :rx, :ry
	attr_accessor :detail

	def initialize( center, rx, ry )
		@center, @rx, @ry = Point[*center], rx, ry
		@detail = 20
		super()
	end

	def initialize_copy( orig )
		@center, @rx, @ry = orig.raw_center, orig.rx, orig.ry
		super
	end

	def bounds
		Boundary.envelope( *points )
	end

	def center
		@matrix * @center
	end

	def collide_has_points(other)
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

	alias :collide_boundary :collide_has_points
	alias :collide_triangle :collide_has_points
	alias :collide_quadrangle :collide_has_points
	alias :collide_ellipse :collide_has_points

	def inspect
		"#<Ellipse:%#0x>"%object_id
	end

	def points
		raw_points.map { |point| @matrix * point }
	end

	def raw_center
		@center
	end

	def raw_points
		evaluate_regular(@detail)
	end

	def to_s
		"#<Ellipse>"
	end

#	private

	def evaluate(angle)
		@center + Vector2[Math.cos(angle)*@rx, Math.sin(angle)*@ry]
	end

	TWO_PI = Math::PI * 2

	def evaluate_regular(detail)
		p = []
		0.step(TWO_PI - TWO_PI/detail, TWO_PI/detail) do |angle|
			p << evaluate(angle)
		end
		return p
	end

end
