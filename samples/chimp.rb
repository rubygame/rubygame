#!/usr/bin/env ruby

# This program is released to the PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# This is a translation of an example application from
# pygame (http://www.pygame.org), translated to Rubygame.
# The original application had this to say:
# 
#   This simple example is used for the line-by-line tutorial
#   that comes with pygame. It is based on a 'popular' web banner.
#   Note there are comments here, but for the full explanation, 
#   follow along in the tutorial.
# 
# The original tutorial could be found at this location as of 2005-04-17:
# 
#   http://pygame.org/docs/tut/chimp/ChimpLineByLine.html
# 
# As much as possible, this is a straight port of the pygame example,
# without any real improvements in style. Significant deviations are
# noted by comments. As such, this might serve as something of a
# Rosetta Stone for a pygame user switching to Rubygame.

require "rubygame"
include Rubygame

puts 'Warning, images disabled' unless 
  ($image_ok = (VERSIONS[:sdl_image] != nil))
puts 'Warning, font disabled' unless 
  ($font_ok = (VERSIONS[:sdl_ttf] != nil))
puts 'Warning, sound disabled' unless
  ($sound_ok = (VERSIONS[:sdl_mixer] != nil))


# Get the directory this script is in.
resources_dir = File.dirname(__FILE__)

# Set the directories to autoload images and sounds from.
# See the docs for Rubygame::NamedResource.
Surface.autoload_dirs = [ resources_dir ]
Sound.autoload_dirs = [ resources_dir ]


# Classes for our game objects:

# The fist object, which follows the mouse and punches on mouseclick
class Fist
	# It's a sprite (an image with location data).
	include Sprites::Sprite

	# Create and set up a new Fist object
	def initialize
		super					# initialize sprite

		# Autoload the image and set its colorkey
		@image = Surface['fist.bmp']
		@image.set_colorkey( @image.get_at([0,0]) )

		@rect = @image.make_rect()
		@punching = false		# whether the fist is punching
		@mpos = [0,0]			# mouse curson position
	end

	# This is a small departure from the pygame example. Instead
	# of polling the mouse for cursor position etc. (which Rubygame
	# doesn't do, as of February 2006), we receive notification
	# of mouse movements from a global event queue and store it
	# in @mpos for later use in Fist#update().
	def tell(ev)
		case ev
		when MouseMotionEvent
			# mouse cursor moved, remember its last location for #update()
			@mpos = ev.pos
		end
	end

	# Update the fist position
	def update
		# move the rect to the remembered position
		@rect.midtop = @mpos
		# apply offset (right and down) if we are punching
		if @punching
			@rect.move!(5,10)
		end
	end

	# Attempt to punch a target. Returns true if it hit or false if not.
	def punch(target)
		@punching = true
		# use a smaller rect to check if we collided with the target
		return @rect.inflate(-5, -5).collide_rect?(target.rect)
	end

	# Stop punching.
	def unpunch
		@punching = false
	end
end

# A chimpanzee which moves across the screen and spins when punched.
class Chimp
	# It's a sprite (an image with location data).
	include Sprites::Sprite

	# Create and set up a new Chimp object
	def initialize
		super					# initialize sprite

		# Autoload the image and set its colorkey
		@original = Surface['chimp.bmp']
		@original.set_colorkey( @original.get_at([0,0]) )
		@image = @original 		# store original image during rotation

		@rect = @image.make_rect()
		@rect.topleft = 10,10

		# @area is the area of the screen, which the chimp will walk across
		@area = Rubygame::Screen.get_surface().make_rect()
		@xvel = 9 # called self.move in the pygame example

		# In python, the integer 0 signifies false, while in ruby it does not.
		# The pygame example used self.dizzy to mean the angle
		# in degrees the monkey has rotated, and also as a boolean.
		# 
		# Our example will do the same, but a conditional must be introduced
		# to #update() where in the pygame example, 0 was condition enough.
		@dizzy = 0
	end

	# Walk or spin, depending on the monkey's state
	def update
		# This   (!= 0) is the added conditional referred to above.
		if @dizzy != 0
			spin()
		else
			walk()
		end
	end

	# Move the chimp across the screen, and turn at the left and right edges.
	def walk
		newpos = @rect.move(@xvel,0) # calculate chimp position for next frame

		# If the chimp starts to walk off the screen
		if (@rect.left < @area.left) or (@rect.right > @area.right)
			@xvel = -@xvel		# reverse direction of movement
			newpos = @rect.move(@xvel,0) # recalculate with changed velocity
			@image = @image.flip(true, false) # flip x
		end
		@rect = newpos
	end

	# spin the monkey image
	def spin
		center = @rect.center
		@dizzy += 12			# increment angle
		if @dizzy >= 360		# if we have spun full-circle, stop spinning.
			@dizzy = 0
			@image = @original
		else					# otherwise, spin some more!
			# Note that we rotate with @original, not the current @image.
			# This reduces cumulative blurring from the rotation process,
			# and is just as efficient as incremental rotations.
			@image = @original.rotozoom(@dizzy,1,true)
		end
		@rect = image.make_rect()
		@rect.center = center # re-center
	end

	# The pygame example used the mangled function names _walk and _spin
	# to indicate that they were privately used (as is python tradition).
	# We'll use a more explicit declaration (as is ruby tradition).
	private :walk, :spin

	# This will cause the chimp to start spinning
	def punched
		if (@dizzy == 0)
			@dizzy = 1
			@original = @image
		end
	end
end

# This function is called when the program starts.It initializes
# everything it needs, then runs in a loop until the user closes
# the window or presses ESCAPE.
def main
	
	# Initialize Everything
	Rubygame.init()
	screen = Screen.new([468, 60])
	screen.title = 'Monkey Fever'
	screen.show_cursor = false;
	# In Rubygame, you make an EventQueue object; pygame just uses functions
	queue = EventQueue.new()

	# Create The Background
	background = Surface.new(screen.size)
	background.fill([250,250,250])
	
	# Put Text On The Background, Centered
	# $font_ok was set at the very top. It tells us if it's ok to use TTF.
	if $font_ok
		# We have to setup the TTF class before we can make TTF objects
		Rubygame::TTF.setup()

		# Rubygame has no default font, so we must specify FreeSans.ttf
		# 
		# 25 is more or less the actual font size in the pygame example,
		# based on scaling factor (0.6875) pygame applies to its default font.
		font = TTF.new("FreeSans.ttf",25)
		text = font.render("Pummel The Chimp, And Win $$$", true, [10,10,10])
		textpos = text.make_rect()
		textpos.centerx = background.width/2
		# ATTENTION: Note that the "actor" is reversed from the pygame usage.
		# In pygame, a surface "pulls" another surface's data onto itself.
		# In Rubygame, a surface "pushes" its own data onto another surface.
		text.blit(background,textpos)
	end

	#Display The Background
	# Again, note the reversal of actors in the blit function
	background.blit(screen, [0,0])
	screen.update()
	
	#Prepare Game Objects

	# This also differs from pygame. Rather than pass the desired framerate
	# when you call clock.tick, you set the framerate for the clock, either
	# when you create it, or afterwards with the target_framerate accessor.
	clock = Clock.new
	clock.target_framerate = 30

	# Autoload the sound effects
	whiff_sound = Sound['whiff.wav']
	punch_sound = Sound['punch.wav']
	
	chimp = Chimp.new()
	fist = Fist.new()
	
	allsprites = Sprites::Group.new()
	allsprites.push(chimp, fist)
	
	#Main Loop
	loop do
		clock.tick()
		
		#Handle Input Events
		# Iterate through all the events the Queue has caught
		queue.each do |event|
			# Python doesn't have a case statement like Ruby does! :)
			# Here, we implicitly "switch" based on the event's class.
			# Unlike in pygame, each event is detected by class, not
			# by an integer type identifier.
			case(event)
			when QuitEvent
				return			# break out of the main function
			when KeyDownEvent
				case event.key 
				when K_ESCAPE
					return			# break out of the main function
				end
			when MouseMotionEvent
				fist.tell(event)
			when MouseDownEvent
				if fist.punch(chimp)
					chimp.punched()
					# Only try to play the sound if it isn't nil
					punch_sound.play if punch_sound
				else
					# Only try to play the sound if it isn't nil
					whiff_sound.play if whiff_sound
				end
			when MouseUpEvent
				fist.unpunch()
			end
		end 					# end event handling

		allsprites.update()
		

    #Draw Everything
		background.blit(screen, [0, 0])
		allsprites.draw(screen)
		screen.update()

		screen.title = '%d'%clock.framerate
	end							# end loop

	#Game Over
ensure
  # This ensures that we properly close and clean up everything at the end
  # of the game.
	Rubygame.quit()
end								# end main function


#this calls the 'main' function when this script is executed
if $0 == __FILE__
	main()
end
