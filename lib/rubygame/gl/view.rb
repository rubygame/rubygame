require 'rubygame/gl/shared'

class View
	attr_accessor :x, :y, :w, :h

	def initialize(size)
		@w, @h = size
		self.setup_projection()
	end

	def setup_projection
		GL::MatrixMode( GL::PROJECTION )
		GL::LoadIdentity()
		GL::Ortho(0, @w, 0, @h, 0, 100)
	end

	def background_color=(color)
		r,g,b,a = color.to_a
		a = 0.0 unless a
		GL::ClearColor(r,g,b,a)
	end

	def clear
		GL::Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT);
	end
end
