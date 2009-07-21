#!/usr/bin/env ruby

# This program is released to the PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require "rubygame"
include Rubygame

$stdout.sync = true

Rubygame.init()


# SDL_gfx is required for drawing shapes and rotating/zooming Surfaces.
$gfx_ok = (VERSIONS[:sdl_gfx] != nil)

unless ( $gfx_ok )
	raise "You must have SDL_gfx support to run this demo!"
end



# Set up autoloading for Surfaces. Surfaces will be loaded automatically
# the first time you use Surface["filename"]. Check out the docs for
# Rubygame::NamedResource for more info about that.
#
Surface.autoload_dirs = [ File.dirname(__FILE__) ]



screen = Screen.open([320,240])
screen.title = "Drawing test"



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
	result = sfont.render( "This is some SFont text!" )
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



queue = EventQueue.new()
queue.ignore = [ActiveEvent,MouseMotionEvent,MouseUpEvent,MouseDownEvent]
queue.wait()
