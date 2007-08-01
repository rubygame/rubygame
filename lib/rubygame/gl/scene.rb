require 'rubygame/gl/shared'
require 'rubygame/gl/sprite'
require 'rubygame/gl/camera'
require 'rubygame/gl/boundary'
require 'rubygame/gl/event_handler'

class DrawEvent
end

class Scene
	attr_accessor :cameras, :active_camera
	attr_accessor :event_handler
	attr_accessor :objects
	attr_accessor :screen	
	attr_accessor :clock
	
	def initialize(size)
		Rubygame::GL.set_attrib(Rubygame::GL::RED_SIZE, 5)
		Rubygame::GL.set_attrib(Rubygame::GL::GREEN_SIZE, 5)
		Rubygame::GL.set_attrib(Rubygame::GL::BLUE_SIZE, 5)
		Rubygame::GL.set_attrib(Rubygame::GL::DEPTH_SIZE, 16)
		Rubygame::GL.set_attrib(Rubygame::GL::DOUBLEBUFFER, 1)
		@screen = Rubygame::Screen.new(size, 16, [Rubygame::OPENGL])
		@clock = Rubygame::Clock.new { |c| c.target_framerate = 60 }
		
		@cameras = []
		@active_camera = nil
		@objects = GLGroup.new

		@event_handler = EventHandler.new()

		scene = self
		@event_handler.append_hook do 
			@owner = scene.objects
			@trigger = InstanceTrigger.new( TickEvent )
			@action = MethodAction.new( :update, true )
		end

	end

	def add_camera( camera )
		@cameras << camera
		scene = self
		@event_handler.append_hook do
			@owner = camera
			@trigger = InstanceTrigger.new( DrawEvent )
			@action = BlockAction.new do |owner, event| 
				scene.set_active_camera( owner )
				owner.draw( scene.objects )
			end 
		end
	end
	
	def add_object( object )
		@objects.add_child( object )
	end
	
	def draw
		@event_handler.handle( DrawEvent.new )
	end
	
	def make_default_camera
		region = Boundary.new(0, @screen.w, 0, @screen.h)		
		camera = Camera.new {
			@screen_region = region
			@world_region = region
		}
		add_camera( camera )
		set_active_camera( camera )
	end

	def refresh
		Rubygame::GL.swap_buffers()
	end
	
	def set_active_camera( camera )
		@active_camera = camera
		@active_camera.activate
	end
	
	def update
		@event_handler.handle( @clock.tick )
	end
end
