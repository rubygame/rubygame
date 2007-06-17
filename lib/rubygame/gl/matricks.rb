require 'matrix'

RAD2DEG = 180 / Math::PI

class Matrix

	# Translation matrix factory
	def self.translate(x,y)
		return Matrix[[ 1, 0, x ],
									[ 0, 1, y ],
									[ 0, 0, 1 ]]
	end

	# Rotation matrix factory
	def self.rotate(theta)
		c = Math.cos(theta)
		s = Math.sin(theta)
		return Matrix[[ c,-s, 0 ],
									[ s, c, 0 ],
									[ 0, 0, 1 ]]
	end

	# Scale matrix factory
	def self.scale(x,y=nil)
		y = x unless y
		return Matrix[[ x, 0, 0 ],
									[ 0, y, 0 ],
									[ 0, 0, 1 ]]
	end

	alias :old_mult :*

	def *(v)
		case v
		when Vector
			v.class.[](*old_mult(v))
		else
			old_mult(v)
		end
	end
	
end


class Vector #:nodoc:
	# More inheritance-friendly.
	def to_s
    "#{self.class.name}[" + @elements.join(", ") + "]"
  end

	# More inheritance-friendly.
  def inspect
    "#{self.class.name}" + @elements.inspect
  end

	def x; @elements.at(0); end
	def y; @elements.at(1); end
end

class Vector2 < Vector
	alias :to_ary :to_a
	alias :magnitude :r
	alias :dot :inner_product

	def self.[](x,y,*junk)
		super(x,y,0)
	end

	def to_p
		Point[x,y]
	end

	def to_v
		return self
	end

	def udot()
		self.unit.dot( other.unit )
	end

	def unit
		self * (1/magnitude())
	end

	def angle
		Math.atan2(y(),x())
	end

	def angle_deg
		angle() * RAD2DEG
	end

	def angle_with(other)
		Math.acos( self.udot(other) )
	end

	def projected_onto(v)
		Vector2[*((v * v.dot(self) * (1/v.magnitude**2))[0..1])]
	end

	def +(v)
		case p
		when Vector2
			Vector2[x + v.x, y + v.y]
		else
			raise ArgumentError
		end
	end

	def -(v)
		case p
		when Vector2
			Vector2[x - v.x, y - v.y]
		else
			raise ArgumentError
		end
	end
end

class Point < Vector
	def self.[](x,y,*junk)
		super(x,y,1)
	end

	def to_p
		return self
	end

	def to_v
		Vector2[x,y]
	end

	def projected_onto(v)
		Point[*((v * v.dot(self) * (1/v.magnitude**2))[0..1])]
	end

	def *(m)
		case m
		when Numeric
			raise ArgumentError
		end
	end

	def +(v)
		case p
		when Vector2
			Point[x + v.x, y + v.y]
		else
			raise ArgumentError
		end
	end

	def -(p)
		case p
		when Point
			Vector2[x - p.x, y - p.y]
		when Vector2
			Point[x - p.x, y - p.y]
		else
			raise ArgumentError
		end
	end
end
