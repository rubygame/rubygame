#!/usr/bin/env ruby

# This program is released to the PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# This script is messy, but it demonstrates almost all of
# Rubygame's features, so it acts as a test program to see
# whether your installation of Rubygame is working.

require "rubygame"
include Rubygame

$stdout.sync = true

# Use smooth scaling/rotating? You can toggle this with S key
$smooth = false                 

Rubygame.init()

queue = EventQueue.new() # new EventQueue with autofetch
queue.ignore = [MouseMotionEvent]
clock = Clock.new()
clock.target_framerate = 50

unless ($gfx_ok = (VERSIONS[:sdl_gfx] != nil))
  raise "SDL_gfx is not available. Bailing out." 
end


# Set up autoloading for Surfaces. Surfaces will be loaded automatically
# the first time you use Surface["filename"]. Check out the docs for
# Rubygame::NamedResource for more info about that.
#
Surface.autoload_dirs = [ File.dirname(__FILE__) ]


class Panda
	include Sprites::Sprite
  
  # Autoload the "panda.png" image and set its colorkey
	@@pandapic = Surface["panda.png"]
	@@pandapic.set_colorkey(@@pandapic.get_at(0,0))
  
	attr_accessor :vx, :vy, :speed
	def initialize(x,y)
		super()
		@vx, @vy = 0,0
		@speed = 40
		@image = @@pandapic
		@rect = Rect.new(x,y,*@@pandapic.size)
	end

	def update_image(time)
		# do nothing in base class, rotate/zoom image in subs
	end

	def update(time)
		x,y = @rect.center
		self.update_image(time)
		@rect.size = @image.size
		
		base = @speed * time/1000.0
		@rect.centerx = x + @vx * base
		@rect.centery = y + @vy * base
	end

end

class SpinnyPanda < Panda
	attr_accessor :rate
	def initialize(x,y,rate=0.1)
		super(x,y)
		@rate = rate
		@angle = 0
	end

	def update_image(time)
		@angle += (@rate * time) % 360
		@image = @@pandapic.rotozoom(@angle,1,$smooth)
	end
end

class ExpandaPanda < Panda
	attr_accessor :rate
	def initialize(x,y,rate=0.1)
		super(x,y)
		@rate = rate
		@delta = 0
	end

	def update_image(time)
		@delta = (@delta + time*@rate/36) % (Math::PI*2)
		zoom = 1 + Math.sin(@delta)/2
		@image = @@pandapic.zoom(zoom,$smooth)
	end
end

class WobblyPanda < Panda
	attr_accessor :rate
	def initialize(x,y,rate=0.1)
		super(x,y)
		@rate = rate
		@delta = 0
	end

	def update_image(time)
		@delta = (@delta + time*@rate/36) % (Math::PI*2)
		zoomx = (1.5 + Math.sin(@delta)/6) * @@pandapic.width
		zoomy = (1.5 + Math.cos(@delta)/5) * @@pandapic.height
		@image = @@pandapic.zoom_to(zoomx,zoomy,$smooth)
	end
end

pandas = Sprites::Group.new
pandas.extend(Sprites::UpdateGroup)
pandas.extend(Sprites::DepthSortGroup)

# Create the SDL window
screen = Screen.set_mode([320,240])
screen.title = "Rubygame test"
screen.show_cursor = false;

# Create the very cute panda objects!
panda1 = SpinnyPanda.new(100,50)
panda2 = ExpandaPanda.new(150,50)
panda3 = WobblyPanda.new(200,50,0.5)

panda1.depth = 0        # in between the others
panda2.depth = 10       # behind both of the others
panda3.depth = -10      # in front of both of the others

# Put the pandas in a sprite group
pandas.push(panda1,panda2,panda3)

# Make the background surface
background = Surface.new(screen.size)

# Filling with colors in a variety of ways
background.fill( Color::ColorRGB.new([0.1, 0.2, 0.35]) )
background.fill( :black, [70,120,80,80] )
background.fill( "dark red", [80,110,80,80] )

# Create and test a new surface
a = Surface.new([100,100])

# Draw a bunch of shapes on the new surface to try out the drawing module
a.fill([70,70,255])
rect1 = Rect.new([3,3,94,94])
a.fill([40,40,1500],rect1)
a.draw_box_s([30,30],[70,70],[0,0,0])
a.draw_box([31,31],[69,69],[255,255,255])
a.draw_circle_s([50,50],10,[100,150,200])
# Two diagonal white lines, the right anti-aliased, the left not.
a.draw_line([31,69],[49,31],[255,255,255])
a.draw_line_a([49,31],[69,69],[255,255,255])
# Finally, copy this interesting surface onto the background image 
a.blit(background,[50,50],[0,0,90,80])

# Draw some shapes on the background for fun
# ... a filled pentagon with a lighter border
background.draw_polygon_s(\
	[[50,150],[100,140],[150,160],[120,180],[60,170]],\
	[100,100,100])
background.draw_polygon_a(\
	[[50,150],[100,140],[150,160],[120,180],[60,170]],\
	[200,200,200])
# ... a pepperoni pizza!! (if you use your imagination...)
background.draw_arc_s([250,200],34,[210,150],[180,130,50])
background.draw_arc_s([250,200],30,[210,150],[230,180,80])
background.draw_circle_s( [240,180], 4, :dark_red )
background.draw_circle_s( [265,185], 4, :dark_red )
background.draw_circle_s( [258,200], 4, :dark_red )
background.draw_circle_s( [240,215], 4, :dark_red )
background.draw_circle_s( [260,220], 4, :dark_red )

# _Try_ to make an anti-aliased, filled ellipse, but it doesn't work well.
# If you look closely at the white ellipse, you can see that it isn't
# AA on the left and right side, and there are some black specks on the top
# and bottom where the two ellipses don't quite match.
background.draw_ellipse_s([200,150],[30,25], :beige )
background.draw_ellipse_a([200,150],[30,25], :beige )

# Let's make some labels
require "rubygame/sfont"
sfont = SFont.new( Surface["term16.png"] )
sfont.render("Arrow keys move the spinning panda!").blit(background,[10,10])

TTF.setup()
ttfont_path = File.join(File.dirname(__FILE__),"FreeSans.ttf")
ttfont = TTF.new( ttfont_path, 20 )
ttfont.render("This is some TTF text!",true,[250,250,250]).blit(background,[20,200])


# Create another surface to test transparency blitting
b = Surface.new([200,50])
b.fill([150,20,40])
b.set_alpha(123)# approx. half transparent
b.blit(background,[20,40])
background.blit(screen,[0,0])

# Refresh the screen once. During the loop, we'll use 'dirty rect' updating
# to refresh only the parts of the screen that have changed.
screen.update()

if Joystick.num_joysticks > 0
	Joystick.new(0)  # So that joystick events will appear on the queue
end

update_time = 0
framerate = 0

catch(:rubygame_quit) do
	loop do
		queue.each do |event|
			case event
			when KeyDownEvent
				case event.key
				when K_ESCAPE
					throw :rubygame_quit 
				when K_Q
					throw :rubygame_quit 
				when K_UP
					panda1.vy = -1
				when K_DOWN
					panda1.vy = 1
				when K_LEFT
					panda1.vx = -1
				when K_RIGHT
					panda1.vx = 1
				when K_S
					$smooth = !$smooth
					puts "#{$smooth?'En':'Dis'}abling smooth scale/rotate."
				else
					print "%s"%[event.string]
				end
			when KeyUpEvent
				case event.key
				when K_UP
					panda1.vy = 0
				when K_DOWN
					panda1.vy = 0
				when K_LEFT
					panda1.vx = 0
				when K_RIGHT
					panda1.vx = 0
				end
			when ActiveEvent
				# ActiveEvent appears when the window gains or loses focus.
				# This helps to ensure everything is refreshed after the Rubygame
				# window has been covered up by a different window.
				screen.update()
			when QuitEvent
				throw :rubygame_quit
			when MouseDownEvent
				puts "click: [%d,%d]"%event.pos
			when JoyDownEvent
				case event.button
				when 4; panda1.speed = 80
				when 5; panda2.speed = 80
				end
				#puts "jdown: %d"%[event.button]
			when JoyUpEvent
				case event.button
				when 4; panda1.speed = 40
				when 5; panda2.speed = 40
				end
				#puts "jup: %d"%[event.button]
			when JoyAxisEvent
				# max = 32767
				case(event.axis)
				when 0; panda1.vx = event.value / 32767.0
				when 1; panda1.vy = event.value / 32767.0
				when 2; panda2.vx = event.value / 32767.0
				when 3; panda2.vy = event.value / 32767.0
				end
				#puts "jaxis: %d %d"%[event.axis,event.value]
			end
		end

		pandas.undraw(screen,background)
		pandas.update(update_time)
		dirty_rects = pandas.draw(screen)
		screen.update_rects(dirty_rects)

		update_time = clock.tick()
		unless framerate == clock.framerate
			framerate = clock.framerate
			screen.title = "Rubygame test [%d fps]"%framerate
		end
	end
end

puts "Quitting!"
Rubygame.quit()
