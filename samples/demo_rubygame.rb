#!/usr/bin/env ruby

# This program is PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# This script is very, very messy, but it demonstrates almost all of
# Rubygame's features, and thus served as something of a test program.

#puts "Loading rubygame..."
require "rubygame"
#puts "Rubygame loaded."

$stdout.sync = true

puts "Rubygame.Init()..."
Rubygame.init()
#puts "Rubygame::Time.Init()..."
#Rubygame::Time.init()

puts "Creating queue and clock..."
queue = Rubygame::Queue.instance()
queue.block Rubygame::MouseMotionEvent
clock = Rubygame::Time::Clock.new()
clock.desired_fps = 100

puts "Transform is usable? %s"%[Rubygame::Transform.usable?]
puts "Draw is usable? %s"%[Rubygame::Draw.usable?]

class Panda
	include Rubygame::Sprites::Sprite
	@@pandapic = Rubygame::Image.load("panda.png")
	@@pandapic.set_colorkey(@@pandapic.get_at([0,0]))
	attr_accessor :vx, :vy, :speed
	def initialize(x,y)
		super()
		@vx, @vy = 0,0
		@speed = 40
		@image = @@pandapic
		@rect = Rubygame::Rect.new(x,y,*@@pandapic.size)
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
		@image = Rubygame::Transform.rotozoom(@@pandapic,@angle,1,true)
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
		@image = Rubygame::Transform.rotozoom(@@pandapic,0,zoom,true)
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
		zoomx = 1.5 + Math.sin(@delta)/6
		zoomy = 1.5 + Math.cos(@delta)/5
		@image = Rubygame::Transform.zoom(@@pandapic,[zoomx,zoomy],true)
	end
end

class PandaGroup < Rubygame::Sprites::Group
	include Rubygame::Sprites::UpdateGroup
end

# Create the SDL window
screen = Rubygame::Screen.set_mode([320,240])
screen.set_caption("Rubygame test","This is the icon title")
puts "title: %s   icon title: %s"%screen.caption()
screen.show_cursor = false;
puts "cursor enabled?: %s"%screen.show_cursor?

# Create the very cute panda objects!
panda1 = SpinnyPanda.new(100,50)
panda2 = ExpandaPanda.new(150,50)
panda3 = WobblyPanda.new(200,50,0.5)

# Put the pandas in a group
pandas = PandaGroup.new
pandas.push(panda1,panda2,panda3)
puts "pandas: %s"%pandas.inspect

# Make the background surface
background = Rubygame::Surface.new(screen.size)
puts "default colorkey is nil?: %s"%[background.colorkey==nil]

# Create and test a new surface
a = Rubygame::Surface.new([100,100])
print "Surf(a): %dx%d, "%a.size
print "%d bpp. Flags: %d "%[a.depth,a.flags]
print "Masks: [%d, %d, %d, %d]\n"%a.masks

# Draw a bunch of shapes on it to test the drawing module
a.fill([70,70,255])
rect1 = Rubygame::Rect.new([3,3,94,94])
a.fill([40,40,1500],rect1)
Rubygame::Draw.filled_box(a,[30,30],[70,70],[0,0,0])
Rubygame::Draw.box(a,[31,31],[69,69],[255,255,255])
Rubygame::Draw.filled_circle(a,[50,50],10,[100,150,200])
# Two diagonal white lines, the right anti-aliased, the left not.
Rubygame::Draw.line(a,[31,69],[49,31],[255,255,255])
Rubygame::Draw.aaline(a,[49,31],[69,69],[255,255,255])
# Finally, copy this interesting surface onto the background image 
a.blit(background,[50,50],[0,0,90,80])

# Draw some shapes on the background for fun
# ... a filled pentagon with a lighter border
Rubygame::Draw.filled_polygon(background,\
	[[50,150],[100,140],[150,160],[120,180],[60,170]],\
	[100,100,100])
Rubygame::Draw.aapolygon(background,\
	[[50,150],[100,140],[150,160],[120,180],[60,170]],\
	[200,200,200])
# ... a pepperoni pizza!! (if you use your imagination...)
Rubygame::Draw.filled_pie(background,[250,200],34,[210,150],[180,130,50])
Rubygame::Draw.filled_pie(background,[250,200],30,[210,150],[230,180,80])
Rubygame::Draw.filled_circle(background,[240,180],4,[200,50,10])
Rubygame::Draw.filled_circle(background,[265,185],4,[200,50,10])
Rubygame::Draw.filled_circle(background,[258,200],4,[200,50,10])
Rubygame::Draw.filled_circle(background,[240,215],4,[200,50,10])
Rubygame::Draw.filled_circle(background,[260,220],4,[200,50,10])

# _Try_ to make an anti-aliased, filled ellipse, but it doesn't work well.
# If you look closely at the white ellipse, you can see that it isn't
# AA on the left and right side, and there are some black specks on the top
# and bottom where the two ellipses don't quite match.
Rubygame::Draw.filled_ellipse(background,[200,150],[30,25],[250,250,250])
Rubygame::Draw.aaellipse(background,[200,150],[30,25],[250,250,250])

# Let's make some labels
sfont = Rubygame::SFont.new("term16.png")
sfont.render("Love pandas forever! <3").blit(background,[100,10])

Rubygame::TTF.setup()
ttfont = Rubygame::TTF.new("freesansbold.ttf",11)
ttfrndr = ttfont.render("(this is a pizza?!?) -->",true,[250,250,250],[0,0,0])
ttfrndr.blit(background,[100,200])


# Create another surface to test transparency blitting
b = Rubygame::Surface.new([200,50])
b.fill([150,20,40])
b.set_alpha(123)# approx. half transparent
b.blit(background,[20,40])
background.blit(screen,[0,0])

if Rubygame::Joystick.num_joysticks > 0
	joys = true
	joy = Rubygame::Joystick.new(0)
else
	joys = false
end

update_time = 0
fps = 0

catch(:rubygame_quit) do
	loop do
		queue.get().each do |event|
			case event
			when Rubygame::MouseDownEvent
				puts "click: [%d,%d]"%event.pos
			when Rubygame::JoyDownEvent
				case event.button
				when 4; panda1.speed = 80
				when 5; panda2.speed = 80
				end
				#puts "jdown: %d"%[event.button]
			when Rubygame::JoyUpEvent
				case event.button
				when 4; panda1.speed = 40
				when 5; panda2.speed = 40
				end
				#puts "jup: %d"%[event.button]
			when Rubygame::JoyAxisEvent
				# max = 32767
				case(event.axis)
				when 0; panda1.vx = event.value / 32767.0
				when 1; panda1.vy = event.value / 32767.0
				when 2; panda2.vx = event.value / 32767.0
				when 3; panda2.vy = event.value / 32767.0
				end
				#puts "jaxis: %d %d"%[event.axis,event.value]
			when Rubygame::JoyHatEvent
				puts "jhat: %d %d"%[event.hat,event.value]
			when Rubygame::KeyDownEvent
				case event.key
				when Rubygame::K_ESCAPE
					throw :rubygame_quit 
				when Rubygame::K_Q
					throw :rubygame_quit 
				when Rubygame::K_UP
					panda1.vy = -1
				when Rubygame::K_DOWN
					panda1.vy = 1
				when Rubygame::K_LEFT
					panda1.vx = -1
				when Rubygame::K_RIGHT
					panda1.vx = 1
				end
			when Rubygame::KeyUpEvent
				case event.key
				when Rubygame::K_UP
					panda1.vy = 0
				when Rubygame::K_DOWN
					panda1.vy = 0
				when Rubygame::K_LEFT
					panda1.vx = 0
				when Rubygame::K_RIGHT
					panda1.vx = 0
				end
				print "%s"%[event.string]
				#puts "Keydown: [%s, %d]"%[event.string,event.key]
			when Rubygame::QuitEvent
				puts "Quitting!"
				throw :rubygame_quit
			end
		end
		pandas.undraw(screen,background)
		pandas.update(update_time)
		# Rubygame::Draw.aaline(screen,panda1.rect.center, panda2.rect.center,[200,200,200])
		pandas.draw(screen)
		screen.update()
		update_time = clock.tick()
		# update_time = Rubygame::Time.delay(10)
		unless fps == clock.fps
			fps = clock.fps
			screen.set_caption("Rubygame test [%d fps]"%fps)
			# puts "tick: %d  fps: %d"%[update_time,fps]
		end
	end
end
