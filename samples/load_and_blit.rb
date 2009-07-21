#/usr/bin/env ruby

# A very basic sample application.

require "rubygame"
include Rubygame

Rubygame.init

screen = Screen.open([320,240])

queue = EventQueue.new() { 
  |q| q.ignore = [MouseMotionEvent, ActiveEvent]
}

image = Surface.load_image("panda.png")
puts "Size is: [%s,%s]"%image.size
image.blit(screen,[0,0])

queue.wait() { screen.update() }

Rubygame.quit
