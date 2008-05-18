#!/usr/bin/env ruby

$stdout.sync = true

require 'rubygame'
require 'rubygame/gl/scene'
require 'rubygame/gl/sprite'
require 'rubygame/gl/event_hook'
require 'rubygame/gl/collision_handler'

include Rubygame

WIDTH = 640
HEIGHT = 480

def main()
	Rubygame.init()
	scene = Scene.new([WIDTH,HEIGHT])
	scene.make_default_camera
	scene.clock.target_framerate = 60

	pic_in_pic = Camera.new {
		bound = scene.cameras.first.screen_region
		@screen_region = bound.scale(0.25,0.25)
 		@screen_region = \
 			@screen_region.move(Vector2[WIDTH-@screen_region.right - 20,
 			                            HEIGHT-@screen_region.top - 20])
		@world_region = bound.scale(1,1)
		@clear_screen = true
		@background_color = [0.3, 0.3, 0.3, 0.5]
	}

	scene.add_camera pic_in_pic 

	queue = Rubygame::EventQueue.new()

	panda = GLImageSprite.new {
		@surface = Rubygame::Surface.load_image('big_panda.png')
		@has_alpha = true
		self.pos = Point2[WIDTH/2, HEIGHT/2]
		self.angle = 0.4
		setup_texture()
	}

	class << panda
		def update( tick )
			time = tick.seconds
			@t += time
			self.angle = 0.4 * Math::sin(@t / 0.3)
			self.scale = Vector2[1.0 + 0.05*Math::sin(@t/0.085),
			                     1.0 + 0.05*Math::cos(@t/0.083)]
			super
		end
	end

	ruby = GLImageSprite.new {
		@surface = Rubygame::Surface.load_image('ruby.png')
		setup_texture()
		self.pos = Vector2[100,300]
		self.depth = -0.1
		self.angle = -0.2
	}
	
	scene.add_objects(panda,ruby)

	handler = scene.event_handler
	collision = CollisionHandler.new()
	collision[:main] = [panda, ruby]

	set_pos_action = BlockAction.new do |owner, event|
		print "#{event.world_pos.inspect}      \r"
		owner.pos = event.world_pos
	end
	
	handler.append_hook do
		@owner = panda
		@trigger = MouseHoverTrigger.new
		@action = set_pos_action
	end
	
	handler.append_hook do
		@owner = ruby
		@trigger = MouseClickTrigger.new
		@action = set_pos_action
	end

	handler.append_hook do
		@owner = scene
		@trigger = AnyTrigger.new(KeyPressTrigger.new( :q ),
															KeyPressTrigger.new( :escape ),
															InstanceTrigger.new( QuitEvent ))
		@action = BlockAction.new { |owner, event| throw :quit }
	end
	
	handler.append_hook do
		@owner = scene.cameras[0]
		@trigger = InstanceTrigger.new( Rubygame::MouseDownEvent )
		@action = BlockAction.new do |owner, event|
			scene.event_handler.handle( owner.make_mouseclick(event) )
		end
	end
	
	handler.append_hook do
		@owner = scene.cameras[1]
		@trigger = InstanceTrigger.new( Rubygame::MouseMotionEvent )
		@action = BlockAction.new do |owner, event|
			scene.event_handler.handle( owner.make_mousehover(event) )
		end
	end
	
	handler.append_hook do
		@owner = scene
		@trigger = InstanceTrigger.new( CollisionStartEvent )
		@action = BlockAction.new do |owner, event|
			glColor([1,0,0])
		end
	end
	
	handler.append_hook do
		@owner = scene
		@trigger = InstanceTrigger.new( CollisionEndEvent )
		@action = BlockAction.new do |owner, event|
			glColor([1,1,1])
		end
	end
	
	handler.append_hook do
		@owner = scene
		@trigger = InstanceTrigger.new( CollisionEvent )
		@action = BlockAction.new do |owner, event|
			glColor([0.9+rand*0.1, rand*0.2, rand*0.2])
		end
	end
	
	catch(:quit) do
		loop do
			queue.each do |event|
				scene.event_handler.handle(event)
			end

			collision.handle.each do |event|
 				scene.event_handler.handle(event)
 			end
			
			# update everything
			scene.update()

			# redraw everything
			scene.draw()
			scene.refresh()

		end
	end
ensure
	Rubygame.quit()
	puts
end

main()
