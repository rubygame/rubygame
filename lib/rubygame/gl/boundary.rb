require 'rubygame/gl/matricks'
require 'rubygame/gl/collidable'
require 'rubygame/gl/sat'


#  Boundary implements 2D axis-aligned bounding boxes. They are used for:
# 
#  1. representing a rectangular region of pixels on the screen; and
#  2. performing fast first-pass collision checks for more complex shapes.
# 
#  Boundaries are defined by their left, right, bottom, and top edges,
#  which are x or y values, measured in pixels.
# 
#  Boundaries are cannot be rotated; they are always aligned to the screen's
#  horizontal and vertical axes.
# 
class Boundary
	include Collidable

	attr_reader :left, :right, :bottom, :top
	
	#  call-seq:
	#    Boundary.new( left, right, bottom, top )  ->  new_boundary
	# 
	#  Create a new Boundary object.
	#  
	#  left::    x value of the Boundary's left edge. (Integer, required)
	#  right::   x value of the Boundary's right edge. (Integer, required)
	#  bottom::  y value of the Boundary's bottom edge. (Integer, required)
	#  top::     y value of the Boundary's top edge. (Integer, required)
	# 
	#  Returns:: The newly-created Boundary object. (Boundary)
	# 
	#  Example:
	#    b = Boundary.new( 0, 640, 0, 480 )
	# 
	def initialize( left, right, bottom, top )
		@left, @right, @bottom, @top = left, right, bottom, top
	end

	# Used by e.g. #dup
	def initialize_copy( orig )	# :nodoc:
		@left, @right, @bottom, @top = 
			orig.left, orig.right, orig.bottom, orig.top
	end

	#  call-seq:
	#    Boundary.envelope( point1, point2, ..., pointN )  ->  new_boundary
	# 
	#  Create a new Boundary which surrounds all of the given points.
	# 
	#  *points:: The points that the new Boundary should cover. (many Points, required)
	# 
	#  Returns:: The newly-created Boundary object. (Boundary)
	#  
	#  This constructor is useful for creating a bounding box for a Polygon.
	#  See Polygon#bounds.
	# 
	#  Example:
	#    p = Polygon.new( [0,0], [20,5], [3,40] )
	#    b = Boundary.envelope( *p.points )   # => #<Boundary (0, 20, 0, 40)>
	# 
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

	#  call-seq: 
	#    size  ->  [width, height]
	# 
	#  Return the width and height of the Boundary in an Array.
	# 
	#  Returns::  The dimensions of the Boundary. (Array)
	# 
	def size
		[width, height]
	end

	#  call-seq:
	#    collide_boundary( other )
	# 
	#  Perform a collision check between this Boundary and another Boundary.
	#  See Collidable#collide.
	#  
	#  other::    The other Boundary to check collision with. (Boundary, required)
	# 
	#  Returns::  true iff this Boundary overlaps or touches the other. (boolean)
	#  
	#  Example:
	#    a = Boundary.new( 10, 50, 10, 30 )
	#    b = Boundary.new( 10, 25,  0, 15 )
	#    a.collide_boundary( b )            # => true
	# 
	def collide_boundary( other )
		overlap?(@left, @right, other.left, other.right) and \
		overlap?(@bottom, @top, other.bottom, other.top)
	end

	#  call-seq:
	#    collide_point( other )
	# 
	#  Perform a collision check between this Boundary and a Point.
	#  See Collidable#collide.
	#  
	#  other::    The Point to check collision with. (Point, required)
	# 
	#  Returns::  true iff this Boundary overlaps or touches the Point. (boolean)
	#  
	#  Example:
	#    a = Boundary.new( 10, 50, 10, 30 )
	#    b = Point[15,20]
	#    a.collide_point( b )               # => true
	# 	
	def collide_point( other )
		overlap?( @left, @right, other.x, other.x ) and \
		overlap?( @bottom, @top, other.y, other.y )
	end
	
	#  call-seq:
	#    collide_polygon( other )
	# 
	#  Perform a collision check between this Boundary and a Polygon.
	#  See Collidable#collide.	
	#  
	#  other::    The Polygon to check collision with. (Polygon, required)
	# 
	#  Returns::  true iff this Boundary overlaps or touches the Polygon. (boolean)
	#  
	#  Example:	
	#    a = Boundary.new( 10, 50, 10, 30 )
	#    p = Polygon.new( [0,0], [25,0], [25,25], [0,25] )
	#    a.collide_polygon( p )             # => true
	# 
	def collide_polygon( other )
		pointsB = other.points
		x_values = pointsB.map { |point| point.x }
		y_values = pointsB.map { |point| point.y }
		
		overlap?(@left, @right, x_values.min, x_values.max) and \
		overlap?(@bottom, @top, y_values.min, y_values.max)
	end

	#  call-seq:
	#    move( offset )  ->  new_boundary
	# 
	#  Move the Boundary by the Vector2 offset.
	#  
	#  offset::   How much to move the Boundary. (Vector2, required)
	# 
	#  Returns::  The resulting Boundary. (Boundary)
	#             
	#  This method is non-destructive: it returns a new object,
	#  without changing the original.
	# 
	#  Example:
	#    a = Boundary.new( 10, 50, 10, 30 )
	#    b = a.move( Vector2[6, 32] )       # => #<Boundary (16, 56, 42, 62)>
	# 
	def move( v )
		self.class.new( @left + v.x, @right + v.x,
										@bottom + v.y, @top + v.y )
	end

	#  call-seq:
	#    grow( x, y )  ->  new_boundary
	# 
	#  Expand the Boundary outward from its center by some number
	#  of pixels on each side.
	# 
	#  x::        horizontal expansion, in pixels. (Integer, required)
	#  y::        vertical expansion, in pixels. (Integer, required)
	# 
	#  Returns::  The resulting Boundary object. (Boundary)
	#             
	#  Passing a negative number will cause it to shrink instead of grow.
	# 
	#  Contrast this method with #scale, which multiplies the size by
	#  a scaling factor.
	# 
	#  This method is non-destructive: it returns a new object,
	#  without changing the original.
	# 
	#  Example:
	#    a = Boundary.new( 10, 50, 10, 30 )
	#    a.size                             # => [40, 20]
	#    b = a.grow( 15, -5 )               # => #<Boundary (-5, 65, 15, 25)>
	#    b.size                             # => [70, 10]
	# 
	def grow( x, y )
		self.class.new( @left - x, @right + x,
										@bottom - y, @top + y )
	end

	def inspect
		"#<#{self.class}:%#0x (%d, %d, %d, %d)>"%[self.object_id,
																						left,right,bottom,top]
	end

	#  call-seq:
	#    intersect( other )  ->  new_boundary or nil
	# 
	#  Create a Boundary which covers the area where this Boundary
	#  overlaps with the other Boundary.
	# 
	#  other::    The other Boundary to intersect with. (Boundary, required)
	#  Returns::  The resulting Boundary object, or nil if the Boundaries
	#             do not intersect. (Boundary or nil)
	# 
	#  Contrast this method with #union, which creates a Boundary
	#  surrounding both objects completely.
	# 
	#  This method is non-destructive: it returns a new object,
	#  without changing the original.
	# 
	#  Example:
	#    a = Boundary.new( 10, 50, 10, 30 )
	#    b = Boundary.new( 10, 25,  0, 15 )
	#    c = Boundary.new( 210, 225, 200, 215 )
	#    a.intersect( b )                   # => #<Boundary (10, 25, 10, 15)>
	#    a.intersect( c )                   # => nil
	# 
	def intersect( bound )
		return nil unless self.collide_boundary( bound )

		self.class.new( [@left, bound.left].max, [@right, bound.right].min,
		                [@bottom, bound.bottom].max, [@top, bound.top].min )
	end

	def points
		[Point[@left,@bottom], Point[@right,@bottom],
		 Point[@right,@top], Point[@left, @top]]
	end

	def to_s
		"#<#{self.class} (%d, %d, %d, %d)>"%[left,right,bottom,top]
	end
	
	#  call-seq:
	#    scale( x, y )  ->  new_boundary
	# 
	#  Scale the Boundary outward from its center by a scaling factor.
	# 
	#  x::        horizontal scale factor. (Integer, required)
	#  y::        vertical scale factor. (Integer, required)
	# 
	#  Returns::  The resulting Boundary object. (Boundary)
	# 	
	#  Factors greater than 1.0 will increase the size, and factors
	#  less than 1.0 (but greater than 0.0) will decrease the size.
	#  The behavior for negative values is undefined.
	# 
	#  Contrast this method with #grow, which adjusts the size by a
	#  number of pixels.
	# 
	#  This method is non-destructive: it returns a new object,
	#  without changing the original.
	# 
	#  Example:
	#    a = Boundary.new( 10, 50, 10, 30 )
	#    a.size                             # => [40, 20]
	#    b = a.scale( 2.0, 0.5 )            # => #<Boundary (-5, 65, 15, 25)>
	#    b.size                             # => [80, 10]	
	# 
	def scale( x, y )
		x_grow = width * (x - 1.0) * 0.5
		y_grow = height * (y - 1.0) * 0.5
		grow( x_grow, y_grow )
	end

	#  call-seq:
	#    union( other )  ->  new_boundary
	# 
	#  Create a Boundary which surrounds both this Boundary and the other
	#  Boundary.
	# 
	#  other::    The other Boundary to union with. (Boundary, required)
	#  Returns::  The resulting Boundary object. (Boundary)
	# 
	#  Contrast this method with #intersect, which creates a Boundary
	#  covering the area where the two objects overlap.
	# 
	#  This method is non-destructive: it returns a new object,
	#  without changing the original.
	# 
	#  Example:
	#    a = Boundary.new( 10, 50, 10, 30 )
	#    b = Boundary.new( 10, 25,  0, 15 )
	#    a.union( b )                       # => #<Boundary (10, 50, 0, 30)>
	# 
	def union( bound )
		self.class.new( [@left, bound.left].min, [@right, bound.right].max,
										[@bottom, bound.bottom].min, [@top, bound.top].max )
	end
end
