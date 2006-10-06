#!/usr/bin/env ruby


# This is a derivative work of an original copyrighted work;
# the original being distributed with Pygame, which is licensed
# under the GNU LGPL. If the original work was distributed under
# the GNU LGPL, then the following necessarily applies to this work:
# 
#	This program is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# If, however, the original was public domain, then the author of this
# derivative work places this work in the public domain as well.


# This is a shameless rip-off of an example application from
# pygame (http://www.pygame.org), translated to rubygame.
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
# noted in comments. As such, this might serve as something of a
# Rosetta Stone for a pygame user switching to rubygame, but is not to
# be taken as recommended rubygame program layout or style.

require "rubygame"

puts 'Warning, images disabled' unless 
  ($image_ok = (Rubygame::VERSIONS[:sdl_image] != nil))
puts 'Warning, font disabled' unless 
  ($font_ok = (Rubygame::VERSIONS[:sdl_ttf] != nil))

# Functions to create our resources:
def load_image(name, colorkey=nil)
	image = Rubygame::Image.load(name)
	if colorkey != nil
		if colorkey == -1
			colorkey = image.get_at([0,0])
		end
		image.set_colorkey(colorkey)
	end
	return image, Rubygame::Rect.new(0,0,*image.size)
end

# load_sound would go here, but rubygame can't do sound yet :(

# Classes for our game objects:

# The fist object, which follows the mouse and punches on mouseclick
class Fist
	# It's a sprite (an image with location data).
	include Rubygame::Sprites::Sprite

	# Create and set up a new Fist object
	def initialize
		super					# initialize sprite
		@image, @rect = load_image('fist.bmp', -1)
		@punching = false		# whether the fist is punching
		@mpos = [0,0]			# mouse curson position
	end

	# This is a small departure from the pygame example. Instead
	# of polling the mouse for cursor position etc. (which rubygame
	# doesn't do, as of February 2006), we receive notification
	# of mouse movements from a global event queue and store it
	# in @mpos for later use in Fist#update().
	def tell(ev)
		case ev
		when Rubygame::MouseMotionEvent
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
	include Rubygame::Sprites::Sprite

	# Create and set up a new Chimp object
	def initialize
		super					# initialize sprite
		@original, @rect = load_image('chimp.bmp', -1)
		@image = @original 		# store original image during rotation
		@rect.topleft = 10,10
		# @area is the area of the screen, which the chimp will walk across
		@area = Rubygame::Rect.new(0,0,
															 *Rubygame::Screen.get_surface().size())
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
			@image = Rubygame::Transform.flip(@image, true, false) # flip x
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
			@image = Rubygame::Transform.rotozoom(@original,@dizzy,1,true)
		end
		@rect = Rubygame::Rect.new(0,0,*@image.size)
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
	screen = Rubygame::Screen.set_mode([468, 60])
	screen.set_caption('Monkey Fever')
	screen.show_cursor = false;
	# In rubygame, you make an EventQueue object; pygame just uses functions
	queue = Rubygame::EventQueue.new()

	# Create The Background
	background = Rubygame::Surface.new(screen.size)
	background.fill([250,250,250])
	
	# Put Text On The Background, Centered
	# $font_ok was set at the very top. It tells us if it's ok to use TTF.
	if $font_ok
		# We have to setup the TTF class before we can make TTF objects
		Rubygame::TTF.setup()

		# Rubygame has no default font, so we must specify freesansbold.ttf
		# 
		# 25 is more or less the actual font size in the pygame example,
		# based on scaling factor (0.6875) pygame applies to its default font.
		font = Rubygame::TTF.new("freesansbold.ttf",25)
		text = font.render("Pummel The Chimp, And Win $$$", true, [10,10,10])
		textpos = Rubygame::Rect.new(0,0,*text.size)
		textpos.centerx = background.width/2
		# ATTENTION: Note that the "actor" is reversed from the pygame usage.
		# In pygame, a surface "pulls" another surface's data onto itself.
		# In rubygame, a surface "pushes" its own data onto another surface.
		text.blit(background,textpos)
	end

	#Display The Background
	# Again, note the reversal of actors in the blit function
	background.blit(screen, [0,0])
	screen.update()
	
	#Prepare Game Objects

	# This also differs from pygame. Rather than pass the desired framerate
	# when you call clock.tick, you set the framerate for the clock, either
	# when you create it, or afterwards with the desired_fps accessors.
	# 
	# Please note that at the moment, framerate limiting is not very accurate.
	clock = Rubygame::Time::Clock.new(30)

	#whiff_sound = load_sound('whiff.wav')
	#punch_sound = load_sound('punch.wav')
	chimp = Chimp.new()
	fist = Fist.new()
	allsprites = Rubygame::Sprites::Group.new()
	allsprites.push(fist, chimp)
	
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
			when Rubygame::QuitEvent
				return			# break out of the main function
			when Rubygame::KeyDownEvent
				case event.key 
				when Rubygame::K_ESCAPE
					return			# break out of the main function
				when Rubygame::K_SPACE
					sleep 1
				end
			when Rubygame::MouseMotionEvent
				fist.tell(event)
			when Rubygame::MouseDownEvent
				# can't play sound yet, we'll have to commentate
				if fist.punch(chimp)
					puts "Hit!"
					chimp.punched()
				else
					puts "Miss!"
				end
			when Rubygame::MouseUpEvent
				fist.unpunch()
			end
		end 					# end event handling

		allsprites.update()
		

    #Draw Everything
		background.blit(screen, [0, 0])
		allsprites.draw(screen)
		screen.update()

		screen.set_caption(clock.fps.to_s)
	end							# end loop

	#Game Over
end								# end main function


#this calls the 'main' function when this script is executed
if $0 == __FILE__
	main()
end
