require 'matricks'

class Boundary
	attr_reader :left, :right, :bottom, :top
	def initialize( left, right, bottom, top )
		@left, @right, @bottom, @top = left, right, bottom, top
	end

	def self.envelope( *points )
		x_vals = points.collect { |p| p.x }
		y_vals = points.collect { |p| p.y }
		self.new( x_vals.min, x_vals.max,
							y_vals.min, y_vals.max )
	end

	def height
		@top - @bottom
	end

	def width
		@right - @left
	end

	def move( v )
		self.class.new( @left + v.x, @right + v.x,
										@bottom + v.y, @top + v.y )
	end

	def grow( x, y )
		self.class.new( @left - x, @right + x,
										@bottom - y, @top + y )
	end

	def intersect( bound )
		self.class.new( [@left, bound.left].max, [@right, bound.right].min,
										[@bottom, bound.bottom].max, [@top, bound.top].min )
	end

	def scale( x_factor, y_factor )
		x_grow = width * (x_factor - 1.0) * 0.5
		y_grow = height * (y_factor - 1.0) * 0.5
		grow( x_grow, y_grow )
	end

	def union( bound )
		self.class.new( [@left, bound.left].min, [@right, bound.right].max,
										[@bottom, bound.bottom].min, [@top, bound.top].max )
	end
end
