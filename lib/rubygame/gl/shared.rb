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
