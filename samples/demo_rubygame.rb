#!/usr/bin/env ruby

# This program is released to the PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


# 
# This demo shows a simple example of game structure.
# It demonstrates how to use (or, one of many ways to use):
# 
# * Clock to limit the maximum framerate (to keep CPU usage low)
# 
# * Sprites to display player characters on the screen
# 
# * EventQueue, EventHandler, and the HasEventHandler mixin to
#   receive events from the keyboard, joystick, etc.
# 
# * A custom Game class to integrate it all and provide the game
#   structure and main loop.
# 


require "rubygame"


# Include these modules so we can type "Surface" instead of
# "Rubygame::Surface", etc. Purely for convenience/readability.

include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers


# Make text we output appear on the console right away.
$stdout.sync = true


# Use smooth scaling/rotating? You can toggle this with S key
$smooth = false


# Make sure everything is set up properly.
Rubygame.init()


# SDL_gfx is required for rotating/zooming Surfaces.
$gfx_ok = [:rotozoom, :zoom, :zoom_to].all? { |method|
  Rubygame::Surface.new([1,1]).respond_to?( method )
}

unless ( $gfx_ok )
	raise "This demo requires Surface rotozoom and zoom support (SDL_gfx)"
end


# Activate all joysticks so that their button press
# events, etc. appear in the event queue.
Joystick.activate_all




########################
# CUSTOM EVENT CLASSES #
########################


# Signals sprites to draw themselves on the screen
class DrawSprites
	attr_accessor :screen
	def initialize( screen )
		@screen = screen
	end
end

# Signals sprites to erase themselves from the screen
class UndrawSprites
	attr_accessor :screen, :background
	def initialize( screen, background )
		@screen, @background = screen, background
	end
end




######################
# AUTOLOADING IMAGES #
######################


# Set up autoloading for Surfaces. Surfaces will be loaded automatically
# the first time you use Surface["filename"]. Check out the docs for
# Rubygame::NamedResource for more info about that.
#
Surface.autoload_dirs = [ File.dirname(__FILE__) ]




#################
# PANDA CLASSES #
#################


# Base class for our panda sprites. This provides the core
# logic for initialization and movement of the sprites.
class Panda
	include Sprites::Sprite
	include EventHandler::HasEventHandler

  def self.pandapic
    return @pandapic if @pandapic
    # Autoload the "panda.png" image and set its colorkey
    @pandapic = Surface["panda.png"]
    @pandapic.set_colorkey(@pandapic.get_at(0,0))
    @pandapic.to_display_alpha
  end


	attr_accessor :vx, :vy, :speed
	def initialize(x,y)
		super()
		@vx, @vy = 0,0
		@speed = 40
    @pandapic = self.class.pandapic
		@image = @pandapic
		@rect = Rect.new(x,y,*@pandapic.size)
	end

	def update_image(time)
		# do nothing in base class, rotate/zoom image in subs
	end

	def update( tick_event )
		x,y = @rect.center
		self.update_image( tick_event.seconds * 1000.0 )
		@rect.size = @image.size

		base = @speed * tick_event.seconds
		@rect.centerx = x + @vx * base
		@rect.centery = y + @vy * base
	end

end


# A panda that spins around and around. The update_image
# method is called once per frame to generate the new
# image (in this case by rotating the original image).
class SpinnyPanda < Panda
	attr_accessor :rate
	def initialize(x,y,rate=0.1)
		super(x,y)
		@rate = rate
		@angle = 0
	end

	def update_image(time)
		@angle += (@rate * time) % 360
		@image = @pandapic.rotozoom(@angle,1,$smooth)
	end
end


# A panda that grows and shrinks in size. Like the other
# panda classes, it updates its image every frame.
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
		@image = @pandapic.zoom(zoom,$smooth)
	end
end


# A panda that wobbles and jiggles. Like the other
# panda classes, it updates its image every frame.
class WobblyPanda < Panda
	attr_accessor :rate
	def initialize(x,y,rate=0.1)
		super(x,y)
		@rate = rate
		@delta = 0
	end

	def update_image(time)
		@delta = (@delta + time*@rate/36) % (Math::PI*2)
		zoomx = (1.5 + Math.sin(@delta)/6) * @pandapic.width
		zoomy = (1.5 + Math.cos(@delta)/5) * @pandapic.height
		@image = @pandapic.zoom_to(zoomx,zoomy,$smooth)
	end
end



##########
# SCREEN #
##########


# Some platforms require the icon be set *before* opening the window,
# while others require it be set *after*. So, we'll do both just to be
# sure.

Screen.icon = Surface["rubygame.png"]

# Create the SDL window
screen = Screen.open([320,240])

screen.icon = Surface["rubygame.png"]

screen.title = "Rubygame test"
screen.show_cursor = false;




###############
# BACKGROUND  #
###############


# Make the background surface. We'll draw on this, then blit (copy) it
# onto the screen. We'll also use it as the background for "erasing"
# the pandas from their old positions each frame.
background = Surface.new( screen.size )

# Fill the background with a nice blue color.
background.fill( Color::ColorRGB.new([0.1, 0.2, 0.35]) )


# Render instructions with TTF (TrueType Font)
TTF.setup()
ttfont_path = File.join(File.dirname(__FILE__),"FreeSans.ttf")
ttfont = TTF.new( ttfont_path, 14 )

ttfont.render( "Use arrow keys or joystick to move pandas.",
               true, [250,250,250] ).blit( background, [20,160] )

ttfont.render( "Press escape or q to quit.",
               true, [250,250,250] ).blit( background, [20,180] )




#########################
# EVENT HOOKS FACTORIES #
#########################


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



###################
# PANDA INSTANCES #
###################


def make_pandas( game )

  # Create the very cute panda objects!
  panda1 = SpinnyPanda.new(100,50)
  panda2 = ExpandaPanda.new(150,50)
  panda3 = WobblyPanda.new(200,50,0.5)

  # Set their depths. This affects which one appears in front
  # of the other in case they overlap.
  panda1.depth = 0        # in between the others
  panda2.depth = 10       # behind both of the others
  panda3.depth = -10      # in front of both of the others


  # PANDA GROUP #

  # Create a spritegroup to manage the pandas.
  pandas = Sprites::Group.new
  pandas.extend(Sprites::UpdateGroup)
  pandas.extend(Sprites::DepthSortGroup)

  # Add the pandas to the group.
  pandas.push(panda1,panda2,panda3)


  # Extend the pandas group with event hooks.
  class << pandas
    include EventHandler::HasEventHandler

    # Draw all the sprites and refresh
    # those parts of the screen
    def do_draw( event )
      dirty_rects = draw( event.screen )
      event.screen.update_rects(dirty_rects)
    end

    # Erase the sprites from the screen by
    # drawing over them with the background.
    def do_undraw( event )
      undraw( event.screen, event.background )
    end
  end

  pandas.make_magic_hooks( :tick         => :update,
                           DrawSprites   => :do_draw,
                           UndrawSprites => :do_undraw )


  # PANDA 1 EVENT HOOKS #

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


  # PANDA 2 EVENT HOOKS #

  hooks = {
    # Move according to how far the joystick axis is moved
    joyaxis( 2 ) =>  proc { |owner, event| owner.vx = event.value },
    joyaxis( 3 ) =>  proc { |owner, event| owner.vy = event.value },

    # Fast speed when button is pressed, normal speed when released
    joypressed(  5 ) => proc { |owner, event| owner.speed *= 2.0 },
    joyreleased( 5 ) => proc { |owner, event| owner.speed *= 0.5 }
  }

  panda2.make_magic_hooks( hooks )


  game.register( pandas, panda1, panda2 )

end



##############
# GAME CLASS #
##############


# The Game class helps organize thing. It takes events
# from the queue and handles them, sometimes performing
# its own action (e.g. Escape key = quit), but also
# passing the events to the pandas to handle.
#
class Game
	include EventHandler::HasEventHandler

	attr_reader :clock, :queue

	def initialize( screen, background )

		@screen = screen
		@background = background

		setup_clock()
		setup_queue()
		setup_event_hooks()

		# Now blit the background onto the screen and update the screen
		# once. During the loop, we'll use 'dirty rect' updating to
		# refresh only the parts of the screen that have changed.
		@background.blit(screen,[0,0])
		@screen.update()

	end


	# The "main loop". Repeat the #step method
	# over and over and over until the user quits.
	def go
		catch(:quit) do
			loop do
				step
			end
		end
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


	private


	# Quit the game
	def quit
		puts "Quitting!"
		throw :quit
	end


	# Create a new Clock to manage the game framerate
	# so it doesn't use 100% of the CPU
	def setup_clock
		@clock = Clock.new()
		@clock.target_framerate = 50

    # Adjust the assumed granularity to match the system.
    # This helps minimize CPU usage on systems with clocks
    # that are more accurate than the default granularity.
		@clock.calibrate

    # Make Clock#tick return a ClockTicked event.
    @clock.enable_tick_events
	end


	# Set up the event hooks to perform actions in
	# response to certain events.
	def setup_event_hooks
		hooks = {
			:escape  =>  :quit,
			:q       =>  :quit,
			:s       =>  :toggle_smooth,

			QuitRequested     =>  :quit,

			# Tell the user where they clicked.
			MousePressed      => proc { |owner, event|
			                       puts "click: [%d,%d]"%event.pos
			                     },

			# These help to ensure everything is refreshed after the
			# Rubygame window has been covered up by a different window.
			InputFocusGained  => :update_screen,
			WindowUnminimized => :update_screen,
			WindowExposed     => :update_screen,

			# Refresh the window title.
			:tick             => :update_framerate
		}

		make_magic_hooks( hooks )
	end


	# Create an EventQueue to take events from the keyboard, etc.
	# The events are taken from the queue and passed to objects
	# as part of the main loop.
	def setup_queue
		# Create EventQueue with new-style events (added in Rubygame 2.4)
		@queue = EventQueue.new()
		@queue.enable_new_style_events

		# Don't care about mouse movement, so let's ignore it.
		@queue.ignore = [MouseMoved]
	end


	# Do everything needed for one frame.
	def step
		@queue << UndrawSprites.new( @screen, @background )
		@queue.fetch_sdl_events
		@queue << $game.clock.tick
		@queue << DrawSprites.new( @screen )
		@queue.each do |event|
			handle( event )
		end
	end


	# Toggle smooth effects
	def toggle_smooth
		$smooth = !$smooth
		puts "#{$smooth?'En':'Dis'}abling smooth scale/rotate."
	end


	# Update the window title to display the current framerate.
	def update_framerate( event )
    new_framerate = @clock.framerate.to_i
		unless @old_framerate == new_framerate
			@screen.title = "Rubygame test [%d fps]"%new_framerate
			@old_framerate = new_framerate
		end
	end


	# Refresh the whole screen.
	def update_screen
		@screen.update()
	end

end


$game = Game.new( screen, background )

make_pandas( $game )

# Start the main game loop. It will repeat forever
# until the user quits the game!
$game.go

# Make sure everything is cleaned up properly.
Rubygame.quit()
