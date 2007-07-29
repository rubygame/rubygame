#!/usr/bin/env ruby

require 'rubygame'
require 'rubygame/gl/scene'
require 'rubygame/gl/sprite'

include Rubygame

WIDTH = 640
HEIGHT = 480

def main()
	Rubygame.init()
	scene = Scene.new([WIDTH,HEIGHT])
	scene.make_default_camera

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
		@pos = Point[WIDTH/2, HEIGHT/2]
		@angle = 0.4
#		@scale = Vector2[0.5,0.5]
		setup_texture()
	}

	class << panda
		def update( tick )
			time = tick.passed
			@t += time
			@angle = 0.4 * Math::sin(@t / 300.0)
			@scale = Vector2[1.0 + 0.05*Math::sin(@t/85.0),
			                 1.0 + 0.05*Math::cos(@t/83.0)]
			super
		end
	end

	ruby = GLImageSprite.new {
		@surface = Rubygame::Surface.load_image('ruby.png')
		setup_texture()
		@pos = Vector2[100,300]
		@depth = -0.1
		@angle = -0.2
	}
	
	scene.objects.add_children(panda,ruby)

	handler = scene.event_handler

	handler.add_hook( MouseMotionEvent ) do |event|
		panda.pos = Vector2[event.pos[0], HEIGHT - event.pos[1]]
	end
	handler.add_hook( MouseDownEvent ) do |event|
		ruby.pos = Vector2[event.pos[0], HEIGHT - event.pos[1]]
	end

	throw_quit = Proc.new { |event| throw :quit }
	
	handler.add_hook( KeyDownEvent, :key => K_Q, &throw_quit )
	handler.add_hook( KeyDownEvent, :key => K_ESCAPE, &throw_quit )
	handler.add_hook( QuitEvent, &throw_quit )	
	
	catch(:quit) do
		loop do
			queue.each do |event|
				scene.event_handler.process_event(event)
			end

			# update everything
			scene.update()

			# redraw everything

			if panda.shape.collide ruby.shape
				glColor([255,0,0])
			else
				glColor([255,255,255])
			end

			scene.draw()
			scene.refresh()

		end
	end
ensure
	Rubygame.quit()
end

main()
