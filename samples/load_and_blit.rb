#/usr/bin/env ruby

require "rubygame"

Rubygame.init

def wait_for_keypress(queue)
	catch :keypress do
		loop do
			queue.get.each do |event|
				case(event)
				when Rubygame::QuitEvent
					throw :keypress
				when Rubygame::KeyDownEvent
					throw :keypress
				end
			end
			Rubygame::Time.wait(5)
		end
	end
end

screen = Rubygame::Screen.set_mode([320,240])
queue = Rubygame::Queue.instance
image = Rubygame::Image.load("panda.png")
puts "Size is: [%s,%s]"%image.size
image.blit(screen,[0,0])
screen.update()
wait_for_keypress(queue)
