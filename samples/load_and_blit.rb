#/usr/bin/env ruby

require "rubygame"

def wait_for_keypress(queue)
	catch :keypress do
		loop do
			queue.get.each do |event|
				case(event)
					when Rubygame::QuitEvent
						throw :rubygame_quit
					when Rubygame::KeyDownEvent
						if event.key == Rubygame::K_ESCAPE
							throw :rubygame_quit
						else
							throw :keypress
						end
				end
			end
		end
	end
end

screen = Rubygame::Display.set_mode([320,240])
queue = Rubygame::Queue.instance
image = Rubygame::Image.load("panda.png")
image.blit(screen,[0,0])
screen.update()
wait_for_keypress(queue)
