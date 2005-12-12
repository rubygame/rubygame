#!/usr/bin/env ruby

puts \
"This test is almost certainly not correct, and needs a lot of improvement.
Don't trust the results too much.
~~~~~~~~~~"

require "rubygame"

screen = Rubygame::Screen.set_mode([200,200])
surf = Rubygame::Surface.new([100,100]).fill([0,0,255])
widesurf = Rubygame::Surface.new([250,100]).fill([0,0,255])
tallsurf = Rubygame::Surface.new([100,250]).fill([0,0,255])
bigsurf = Rubygame::Surface.new([250,250]).fill([0,0,255])

tests = [
	[surf,[
			[50,50], # fully inside
			[-50,0], # off left
			[0,-50], # off top
			[150,0], # off right
			[0,150], # off bottom
			[-50,-50], # off top-left
			[150,-50], # off top-right
			[150,150], # off bottom-right
			[-50,150], # off bottom-left
		]],
	[widesurf,[[-25,50]],], # off left and right
	[tallsurf,[[50,-25]],], # off top and bottom
	[bigsurf,[[-25,-25]],], # off left, top, right, bottom
]

tests.each{ |test|
	test[1].each{ |pos|
		x = [0,pos[0]].max
		y = [0,pos[1]].max
		w = [pos[0]+test[0].w,200].min - x
		h = [pos[1]+test[0].h,200].min - y
		if (rect = test[0].blit(screen,pos)) == [x,y,w,h]
			puts "Correct! %s"%rect
		else
			puts "Incorrect! %s should have been [%d,%d,%d,%d]"%[rect,x,y,w,h]
		end
	}
}
