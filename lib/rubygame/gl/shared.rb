require 'rubygame'

require 'gl'
require 'glu'
include Gl
include Glu

alias :_glVertex :glVertex
def glVertex(point)
	_glVertex(point.to_ary)
end

def pushpop_matrix(&block)
	glPushMatrix()
	block.call()
	glPopMatrix()
end

def glbegin(type, &block)
	glBegin(type)
	block.call()
	glEnd()
end

class Numeric
	def nearly_equal?(other, threshold=0.00000000001 )
		return (self - other).abs <= threshold
	end
end
