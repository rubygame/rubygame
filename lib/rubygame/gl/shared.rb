require 'rubygame'
require 'rubygame/ftor'
require 'opengl'

Ftor = Rubygame::Ftor

def pushpop_matrix(&block)
	GL::PushMatrix()
	block.call()
	GL::PopMatrix()
end

def glbegin(type, &block)
	GL::Begin(type)
	block.call()
	GL::End()
end
