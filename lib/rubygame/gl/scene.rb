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

		GL::Viewport( 0, 0, size.at(0), size.at(1) )
		GL::ShadeModel(GL::SMOOTH)
		GL::Enable(GL::TEXTURE_2D)
		GL::Enable(GL::DEPTH_TEST)
		GL::DepthFunc(GL::LESS)
		GL::Enable(GL::BLEND)
		GL::BlendFunc(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA)
	end

	def refresh()
		Rubygame::GL.swap_buffers()
	end
end
