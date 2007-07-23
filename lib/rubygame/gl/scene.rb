require 'rubygame/gl/shared'
require 'rubygame/gl/sprite'
require 'rubygame/gl/camera'
require 'rubygame/gl/boundary'
require 'rubygame/gl/event_handler'

class Scene
	attr_accessor :cameras, :active_camera
	attr_accessor :event_handler
	attr_accessor :objects
	attr_accessor :screen	
	
	def initialize(size)
		Rubygame::GL.set_attrib(Rubygame::GL::RED_SIZE, 5)
		Rubygame::GL.set_attrib(Rubygame::GL::GREEN_SIZE, 5)
		Rubygame::GL.set_attrib(Rubygame::GL::BLUE_SIZE, 5)
		Rubygame::GL.set_attrib(Rubygame::GL::DEPTH_SIZE, 16)
		Rubygame::GL.set_attrib(Rubygame::GL::DOUBLEBUFFER, 1)
		@screen = Rubygame::Screen.new(size, 16, [Rubygame::OPENGL])
		
		@cameras = []
		@active_camera = nil
		@objects = GLGroup.new
		@event_handler = EventHandler.new()
	end

	def draw()
		@cameras.each do |camera|
			set_active_camera( camera )
			camera.draw( @objects )
		end
	end
	
	def make_default_camera
		region = Boundary.new(0, @screen.w, 0, @screen.h)		
		camera = Camera.new {
			@screen_region = region
			@world_region = region
		}
		@cameras << camera
		set_active_camera( camera )
	end

	def refresh
		Rubygame::GL.swap_buffers()
	end
	
	def set_active_camera( camera )
		@active_camera = camera
		@active_camera.activate
	end
	
	def update( *args )
		@objects.update( *args )
	end
end
