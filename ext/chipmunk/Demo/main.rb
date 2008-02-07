require 'chipmunk'
require 'rubygame'
require 'gl'

include Math
include Rubygame
include Gl

INFINITY =  10**100
PI = Math::PI

require 'demo1'
require 'demo2'
require 'demo3'
require 'demo4'

$width  = 640
$height = 480

$demo_index = 0
$ticks = 0
$space = CP::Space.new()

$screen = nil
$queue = EventQueue.new { |q| q.ignore = SDL_EVENTS - [KeyDownEvent, QuitEvent, ExposeEvent] }
$clock = Clock.new { |c| c.target_framerate = 60 }

def demo_destroy

end

def demo_update( ticks )
	steps = 2
	dt = 1.0/60.0/steps;
	0.upto(steps) do |i|
		$space.step(dt)
	end
end

$init_funcs = [:demo1_init, :demo2_init, :demo3_init, :demo4_init]
$update_funcs = [:demo_update, :demo_update, :demo3_update, :demo4_update]
$destroy_funcs = [:demo_destroy]*4

$shape_color = :black
$bg_color = :white

def xform( v )
	x, y = *(v.to_ary)
	x += $width / 2
	y = $height/2 - y
	return x,y
end

def drawCircleShape( circle )
	center = xform(circle.tc)
	edge = xform(circle.tc + vec2(circle.r,0).rotate(circle.body.rot))
	$screen.draw_circle_a( center, circle.r, $shape_color )
	$screen.draw_line_a( center, edge, $shape_color )
end

def drawSegmentShape( seg )
	$screen.draw_line_a( xform(seg.ta), xform(seg.tb), $shape_color )
end

def drawPolyShape( poly )
	$screen.draw_polygon_a( poly.tverts.collect { |v| xform(v) }, $shape_color )
end

def drawObject( shape )
	case shape
	when CP::Shape::Circle
		drawCircleShape(shape)
	when CP::Shape::Segment
		drawSegmentShape(shape)
	when CP::Shape::Poly
		drawPolyShape(shape)
	else
		puts "Bad shape in drawObject()."
	end
end

def display()
	$screen.fill($bg_color)

	$space.shapes.each { |shape| drawObject(shape) }
	$space.static_shapes.each { |shape| drawObject(shape) }
	
	$screen.update

	$ticks += 1;
		
	method($update_funcs[$demo_index]).call($ticks)
	
end

def main
	method($init_funcs[$demo_index]).call()
	
	Rubygame.init()
	
	$screen = Rubygame::Screen.set_mode([640,480], 16)
	$screen.title = "Press 1-7 to switch demos"
	
	#initGL()

	keys = [K_1, K_2, K_3, K_4]#, K_5, K_6, K_7]
	
	# Main loop
	catch :quit do 
		loop do 
			$queue.each do |event|
				case event
				when QuitEvent
					throw :quit
				when KeyDownEvent
					case event.key
					when K_Q, K_ESCAPE
						throw :quit
					when K_PRINT
						$screen.savebmp('screenshot.bmp')
					when *keys
						method($destroy_funcs[$demo_index]).call()
						$demo_index = keys.index(event.key)
						method($init_funcs[$demo_index]).call()
					end
				end
			end

			display()
			$clock.tick

		end		
	end
	
end

main()
