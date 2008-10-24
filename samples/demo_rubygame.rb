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
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers

$stdout.sync = true

# Use smooth scaling/rotating? You can toggle this with S key
$smooth = false                 

Rubygame.init()


# SDL_gfx is required for drawing shapes and rotating/zooming Surfaces.
$gfx_ok = (VERSIONS[:sdl_gfx] != nil)
unless ( $gfx_ok )
  raise "You must have SDL_gfx support to run this demo!" 
end


# Create EventQueue with autofetch (default) and new-style
# events (added in Rubygame 2.4)
queue = EventQueue.new()
queue.enable_new_style_events

# Don't care about mouse movement, so let's ignore it.
queue.ignore = [MouseMoved]


# Activate all joysticks so that their button press
# events, etc. appear in the event queue.
Joystick.activate_all


# Create a new Clock to manage the game framerate
# so it doesn't use 100% of the CPU
clock = Clock.new()
clock.target_framerate = 50


# Custom event class to hold information about the
# clock, created each frame.
class ClockTicked
	attr_reader :time, :framerate

	def initialize( ms, framerate )
		@time = ms / 1000.0
		@framerate = framerate
	end
end


# Set up autoloading for Surfaces. Surfaces will be loaded automatically
# the first time you use Surface["filename"]. Check out the docs for
# Rubygame::NamedResource for more info about that.
#
Surface.autoload_dirs = [ File.dirname(__FILE__) ]


class Panda
	include Sprites::Sprite
	include EventHandler::HasEventHandler

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

		make_magic_hooks( ClockTicked => :update )

	end

	def update_image(time)
		# do nothing in base class, rotate/zoom image in subs
	end

	def update( event )
		x,y = @rect.center
		self.update_image( event.time * 1000.0 )
		@rect.size = @image.size
		
		base = @speed * event.time
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

# Create the very cute panda objects!
panda1 = SpinnyPanda.new(100,50)
panda2 = ExpandaPanda.new(150,50)
panda3 = WobblyPanda.new(200,50,0.5)

panda1.depth = 0        # in between the others
panda2.depth = 10       # behind both of the others
panda3.depth = -10      # in front of both of the others

# Put the pandas in a sprite group
pandas.push(panda1,panda2,panda3)




##########
# SCREEN #
##########


# Create the SDL window
screen = Screen.set_mode([320,240])
screen.title = "Rubygame test"
screen.show_cursor = false;




#################################
# SURFACE DRAWING AND BLITTING  #
#################################


# Make the background surface. We'll draw on this, then blit (copy) it
# onto the screen. We'll also use it as the background for "erasing"
# the pandas from their old positions each frame.
background = Surface.new( screen.size )


# Filling with colors in a variety of ways.
# See the Rubygame::Color module for more info.
def fill_background( background )
	background.fill( Color::ColorRGB.new([0.1, 0.2, 0.35]) )
	background.fill( :black, [70,120,80,80] )
	background.fill( "dark red", [80,110,80,80] )
end


# Draw a bunch of shapes to try out the drawing methods
def draw_some_shapes( background )
	# Create a new surface
	a = Surface.new([100,100])

	# Fill it with blue
	a.fill([70,70,255])

	# Fill a specific part of it with a different blue
	rect1 = Rect.new([3,3,94,94])
	a.fill([40,40,150],rect1)

	# Draw a black box with white almost at the edges
	a.draw_box_s( [30,30], [70,70], [0,0,0] )
	a.draw_box(   [31,31], [69,69], [255,255,255] )

	# Draw a circle in the box
	a.draw_circle_s( [50,50], 10, [100,150,200] )

	# Two diagonal white lines, the right anti-aliased, the left not
	a.draw_line([31,69],[49,31],[255,255,255])
	a.draw_line_a([49,31],[69,69],[255,255,255])

	# Finally, blit (copy) this interesting surface onto
	# the background image
	a.blit(background,[50,50],[0,0,90,80])
end


# Draw a filled pentagon with a lighter border
def draw_pentagon( background )
	points = [ [50,150], [100,140], [150,160], [120,180], [60,170] ]
	background.draw_polygon_s( points, [100,100,100] )
	background.draw_polygon_a( points, [200,200,200] )
end


# Draw a pepperoni pizza! (Use your imagination...)
def draw_pizza( background )
	# Crust
	background.draw_arc_s( [250,200], 34, [210,150], [180,130,50])

	# Cheese -- similar to the crust, but different radius and color
	background.draw_arc_s( [250,200], 30, [210,150], [230,180,80])

	# Pepperonis
	background.draw_circle_s( [240,180], 4, :dark_red )
	background.draw_circle_s( [265,185], 4, :dark_red )
	background.draw_circle_s( [258,200], 4, :dark_red )
	background.draw_circle_s( [240,215], 4, :dark_red )
	background.draw_circle_s( [260,220], 4, :dark_red )
end


# _Try_ to draw an anti-aliased, solid ellipse, but it doesn't work
# well. If you look closely at the white ellipse, you can see that it
# isn't anti-aliased on the left and right side, and there are some
# black specks on the top and bottom where the two ellipses don't
# quite match.
#
# It sure would be nice if SDL_gfx had anti-aliased solid shapes...
# 
def draw_antialiased_filled_ellipse( background )
	background.draw_ellipse_s([200,150],[30,25], :beige )
	background.draw_ellipse_a([200,150],[30,25], :beige )
end


# Render some text with SFont (image-based font)
def render_sfont_text( background )
	require "rubygame/sfont"
	sfont = SFont.new( Surface["term16.png"] )
	result = sfont.render( "Arrow keys move the spinning panda!" )
	result.blit( background, [10,10] )
end


# Render some text with TTF (vector-based font)
def render_ttf_text( background )
	TTF.setup()
	ttfont_path = File.join(File.dirname(__FILE__),"FreeSans.ttf")
	ttfont = TTF.new( ttfont_path, 20 )

	result = ttfont.render( "This is some TTF text!", true, [250,250,250] )
	result.blit( background, [20,200] )
end


# Create another surface to test transparency blitting
def do_transparent_blit( background )
	b = Surface.new([200,50])
	b.fill([150,20,40])
	b.set_alpha(123)# approx. half transparent
	b.blit(background,[20,40])
end


# Call all those functions to draw on the background.
# Try commenting some of these out or reordering them to
# see what happens!

fill_background( background )
draw_some_shapes( background )
draw_pentagon( background )
draw_pizza( background )
draw_antialiased_filled_ellipse( background )
render_sfont_text( background )
render_ttf_text( background )
do_transparent_blit( background )


# Now blit the background onto the screen and update the screen once.
# During the loop, we'll use 'dirty rect' updating to refresh only the
# parts of the screen that have changed.
background.blit(screen,[0,0])
screen.update()




# Factory methods for creating event triggers

# Returns a trigger that matches the released key event
def released( key )
	return KeyReleaseTrigger.new( key )
end


# Returns a trigger that matches the joystick axis event.
# There are no built-in joystick event triggers in Rubygame
# yet, sorry.
def joyaxis( axis )
	return AndTrigger.new( InstanceOfTrigger.new( JoystickAxisMoved ),
	                       AttrTrigger.new(:joystick_id => 0,
	                                       :axis => axis))
end


# Returns a trigger that matches the joystick button press event.
def joypressed( button )
	return AndTrigger.new( InstanceOfTrigger.new( JoystickButtonPressed ),
	                       AttrTrigger.new(:joystick_id => 0,
	                                       :button => button))
end


# Returns a trigger that matches the joystick button press event.
def joyreleased( button )
	return AndTrigger.new( InstanceOfTrigger.new( JoystickButtonReleased ),
	                       AttrTrigger.new(:joystick_id => 0,
	                                       :button => button))
end


#######################
# PANDA 1 EVENT HOOKS #
#######################

hooks = {
	# Start moving when an arrow key is pressed
	:up    =>  proc { |owner, event| owner.vy = -1 },
	:down  =>  proc { |owner, event| owner.vy =  1 },
	:left  =>  proc { |owner, event| owner.vx = -1 },
	:right =>  proc { |owner, event| owner.vx =  1 },

	# Stop moving when the arrow key is released
	released( :up    ) =>  proc { |owner, event| owner.vy = 0 },
	released( :down  ) =>  proc { |owner, event| owner.vy = 0 },
	released( :left  ) =>  proc { |owner, event| owner.vx = 0 },
	released( :right ) =>  proc { |owner, event| owner.vx = 0 },

	# Move according to how far the joystick axis is moved
	joyaxis( 0 ) =>  proc { |owner, event| owner.vx = event.value },
	joyaxis( 1 ) =>  proc { |owner, event| owner.vy = event.value },

	# Fast speed when button is pressed, normal speed when released
	joypressed(  4 ) => proc { |owner, event| owner.speed *= 2.0 },
	joyreleased( 4 ) => proc { |owner, event| owner.speed *= 0.5 }
}

panda1.make_magic_hooks( hooks )


#######################
# PANDA 2 EVENT HOOKS #
#######################

hooks = {
	# Move according to how far the joystick axis is moved
	joyaxis( 2 ) =>  proc { |owner, event| owner.vx = event.value },
	joyaxis( 3 ) =>  proc { |owner, event| owner.vy = event.value },

	# Fast speed when button is pressed, normal speed when released
	joypressed(  5 ) => proc { |owner, event| owner.speed *= 2.0 },
	joyreleased( 5 ) => proc { |owner, event| owner.speed *= 0.5 }
}

panda2.make_magic_hooks( hooks )



class Game
	include EventHandler::HasEventHandler

	def initialize( screen )

		@screen = screen

		hooks = {
			:escape  =>  :quit,
			:q       =>  :quit,
			:s       =>  :toggle_smooth,

			QuitRequested     =>  :quit,

			MousePressed      => proc { |owner, event|
			                       puts "click: [%d,%d]"%event.pos
			                     },

			# These help to ensure everything is refreshed after the
			# Rubygame window has been covered up by a different window.
			InputFocusGained  => :update_screen,
			WindowUnminimized => :update_screen,
			WindowExposed     => :update_screen,

			ClockTicked       => :update_framerate
		}

		make_magic_hooks( hooks )

	end

	# Register the object to receive all events.
	# Events will be passed to the object's #handle method.
	def register( *objects )
		objects.each do |object|
			append_hook( :owner   => object,
									 :trigger => YesTrigger.new,
									 :action  => MethodAction.new(:handle) )
		end
	end

	# Quit the game
	def quit( event )
		throw :rubygame_quit
	end

	# Toggle smooth effects
	def toggle_smooth( event )
		$smooth = !$smooth
		puts "#{$smooth?'En':'Dis'}abling smooth scale/rotate."
	end

	def update_framerate( event )
		unless @old_framerate == event.framerate
			@screen.title = "Rubygame test [%d fps]"%event.framerate
			@old_framerate = event.framerate
		end
	end

	def update_screen( event )
		@screen.update()
	end

end


$game = Game.new( screen )
$game.register( panda1, panda2, panda3 )


catch(:rubygame_quit) do
	loop do

		pandas.undraw(screen,background)

		queue.each do |event|

			$game.handle( event )

		end

		dirty_rects = pandas.draw(screen)
		screen.update_rects(dirty_rects)

		queue << ClockTicked.new( clock.tick, clock.framerate )

	end
end

puts "Quitting!"
Rubygame.quit()
