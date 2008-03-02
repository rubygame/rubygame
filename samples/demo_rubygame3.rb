#!/usr/bin/env ruby

# This program is released to the PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# This script is messy, but it demonstrates almost all of
# Rubygame's features, so it acts as a test program to see
# whether your installation of Rubygame is working.

require "rubygame"
require "rubygame/mediabag"
include Rubygame

$stdout.sync = true


Rubygame.init()


unless ($gfx_ok = (VERSIONS[:sdl_gfx] != nil))
  raise "SDL_gfx is not available. Bailing out." 
end



$media = MediaBag.new()

panda_pic = Surface.load_image("panda.png")
panda_pic.set_colorkey(panda_pic.get_at(0,0))
$media.store("panda.png", panda_pic)

class Panda < Sprite
	attr_accessor :vx, :vy, :speed
	def initialize(scene,pos)
		super(scene)
		@speed = 40
		@image = $media["panda.png"]
		@body.p = pos
	end
end

class SpinnyPanda < Panda
	attr_accessor :rate
	def initialize(scene,pos,rate=1)
		super(scene,pos)
		@body.w = rate
	end
	
	def draw( event )
		super
		
		camera = event.camera
		scale = camera.zoom
		center = ((@body.p * camera.zoom) - camera.position).to_ary
		camera.mode.surface.draw_circle_a(center, 22, :black)

	end
end



# Create the SDL window
screen = Screen.set_mode([320,240])
screen.show_cursor = false;

# Make the background surface
background = Surface.new(screen.size)

camera_mode = Camera::RenderModeSDL.new(screen, background, screen.make_rect, 1.0)
scene = Scene.new( camera_mode )
scene.camera.zoom = 1
scene.camera.position = vect(0,0)

scene.event_queue.ignore = [MouseMotionEvent]
scene.space.gravity = vect(0,100)

scene.append_hook(
	:trigger => AnyTrigger.new( KeyPressTrigger.new( :q ),
	                            KeyPressTrigger.new( :escape ) ,
	                            InstanceOfTrigger.new(QuitEvent) ),
	:action => BlockAction.new { |o,e| throw :rubygame_quit }
)

scene.append_hook(
	:trigger => KeyPressTrigger.new(K_PRINT),
	:action => BlockAction.new { |o,e|
		o.camera.mode.surface.savebmp("rubygame3-sprite-test.bmp")
	}
)

# 
# PANDAAAAAAAAAA!!!
# 

panda1 = SpinnyPanda.new( scene, vect(100,50), 2 ) {
	
	# size = vect(*$media['panda.png'].size)
	# $square = [vect(-0.5,-0.5), vect(0.5,-0.5), vect(0.5,0.5), vect(-0.5,0.5)].reverse
	# verts = $square.collect { |v| vect(v.x*size.x, v.y*size.y) }
	# shape = CP::Shape::Poly.new( @body, verts, vect(0,0) )
	
	shape = CP::Shape::Circle.new( @body, 22.0, vect(0,0) )
	shape.e = 0.3
	shape.u = 0.6
	shape.mass = 10.0
	shape.offset = vect(0,0)
	add_shape( shape )
	recalc_mi()
	
	self.static = false
}

panda1.append_hook(
	:trigger => KeyPressTrigger.new( :up ),
	:action => BlockAction.new { |o,e| o.body.f.x = -10 }
)

panda1.append_hook(
	:trigger => KeyPressTrigger.new( :down ),
	:action => BlockAction.new { |o,e| o.body.f.y = 10 }
)

panda1.append_hook(
	:trigger => KeyPressTrigger.new( :left ),
	:action => BlockAction.new { |o,e| o.body.f.x = -10 }
)

panda1.append_hook(
	:trigger => KeyPressTrigger.new( :right ),
	:action => BlockAction.new { |o,e| o.body.f.y = 10 }
)

panda1.append_hook(
	:trigger => AnyTrigger.new( KeyReleaseTrigger.new( :up   ),
	                            KeyReleaseTrigger.new( :down ) ),
	:action => BlockAction.new { |o,e| o.body.v.y = 0 }
)

panda1.append_hook(
	:trigger => AnyTrigger.new( KeyReleaseTrigger.new( :up   ),
	                            KeyReleaseTrigger.new( :down ) ),
	:action => BlockAction.new { |o,e| o.body.v.x = 0 }
)





INFINITY = 10**100

floor = Sprite.new( scene ) {
	@body.m, @body.i = INFINITY, INFINITY
	
	shape = CP::Shape::Segment.new(@body, vect(0,120), vect(260,220), 1.0)
	shape.e = 0.8
	shape.u = 0.4
	shape.mass = INFINITY
	add_shape( shape )
	
	shape = CP::Shape::Segment.new(@body, vect(260,220), vect(320,120), 1.0)
	shape.e = 0.8
	shape.u = 0.4
	shape.mass = INFINITY
	add_shape( shape )
}


# Filling with colors in a variety of ways
background.fill( Color::ColorRGB.new([0.1, 0.2, 0.35]) )
background.fill( :black, [70,120,80,80] )
background.fill( "dark red", [80,110,80,80] )


floor.shapes.each { |s|
	background.draw_line_a( s.ta, s.tb, :black )
}

# Refresh the screen once. During the loop, we'll use 'dirty rect' updating
# to refresh only the parts of the screen that have changed.
background.blit(screen,[0,0])
screen.update()



update_time = 0
framerate = 0

catch(:rubygame_quit) do
	loop do
		scene.step
		scene.camera.refresh()
		screen.title = "Rubygame3 test [%.1f fps]"%[scene.clock.framerate]
	end
end

puts "Quitting!"
Rubygame.quit()
