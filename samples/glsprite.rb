#!/usr/bin/env ruby

require 'rubygame'
require 'rubygame/gl/scene'
require 'rubygame/gl/view'
require 'rubygame/gl/sprite'

WIDTH = 640
HEIGHT = 480

def main()
	Rubygame.init()
	scene = Scene.new([WIDTH,HEIGHT])
	scene.make_default_camera

	queue = Rubygame::EventQueue.new()
	clock = Rubygame::Clock.new { |c| c.target_framerate = 60 }

	panda = GLImageSprite.new {
		@surface = Rubygame::Surface.load_image('big_panda.png')
		@has_alpha = true
		@pos = Point[WIDTH/2, HEIGHT/2]
		@angle = 0.4
#		@scale = Vector2[0.5,0.5]
		setup_texture()
	}

	class << panda
		def update( time )
			@t += time
			@angle = 0.4 * Math::sin(@t / 300.0)
#			@scale = Vector2[1.0 + 0.05*Math::sin(@t/85.0),
#			                 1.0 + 0.05*Math::cos(@t/83.0)]
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

# 	glEnable(GL_LINE_SMOOTH)
# 	glLineWidth(3)

	catch(:rubygame_quit) do
		loop do
			queue.each do |event|
				case event
				when Rubygame::MouseMotionEvent
					panda.pos = Vector2[event.pos[0], HEIGHT - event.pos[1]]
				when Rubygame::MouseDownEvent
					ruby.pos = Vector2[event.pos[0], HEIGHT - event.pos[1]]
				when Rubygame::KeyDownEvent
					case event.key
					when Rubygame::K_ESCAPE
						throw :rubygame_quit 
					when Rubygame::K_Q
						throw :rubygame_quit 
					end
				when Rubygame::QuitEvent
					throw :rubygame_quit
				end
			end

			# update everything
			time = clock.tick
			scene.update(time)

			# redraw everything

#  			glEnable(GL_TEXTURE_2D)
#  			glEnable(GL_DEPTH_TEST)
#  			glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
#  			glColor([255,255,255])

			scene.draw
			
# 			if panda.shape.collide ruby.shape
# 				glColor([255,0,0])
# 			else
# 				glColor([255,255,255])
# 			end
#
# 			glDisable(GL_TEXTURE_2D)
# 			glDisable(GL_DEPTH_TEST)
# 			glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
# 			group.draw()

			scene.refresh()

		end
	end
ensure
	Rubygame.quit()
end

main()
