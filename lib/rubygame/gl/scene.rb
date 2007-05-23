require 'rubygame/gl/shared'

class Scene
	attr_accessor :screen
	def initialize(size)
		Rubygame::GL.set_attrib(Rubygame::GL::RED_SIZE, 5)
		Rubygame::GL.set_attrib(Rubygame::GL::GREEN_SIZE, 5)
		Rubygame::GL.set_attrib(Rubygame::GL::BLUE_SIZE, 5)
		Rubygame::GL.set_attrib(Rubygame::GL::DEPTH_SIZE, 16)
		Rubygame::GL.set_attrib(Rubygame::GL::DOUBLEBUFFER, 1)
		@screen = Rubygame::Screen.new(size, 16, [Rubygame::OPENGL])

		glViewport( 0, 0, size.at(0), size.at(1) )
		glShadeModel(GL_SMOOTH)
		glEnable(GL_TEXTURE_2D)
		glEnable(GL_DEPTH_TEST)
		glDepthFunc(GL_LESS)
		glEnable(GL_BLEND)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	end

	def refresh()
		Rubygame::GL.swap_buffers()
	end
end
