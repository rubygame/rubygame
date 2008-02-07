require "enumerator"

$num_verts = 5

$num_shapes = 200

def demo3_update( ticks )
	
	steps = 2
	dt = 1.0/60.0/steps;
	0.upto(steps) do |i|
		$space.step(dt)
	end
	
	$space.bodies.each do |body|
		if( body.p.y < -260 || body.p.x.abs > 350 )
			body.p = vec2( rand*640 - 320, 260 )
		end
	end
	
end

def demo3_init
	
	$static_body = CP::Body.new( INFINITY, INFINITY )
	
	$space = CP::Space.new()
	$space.iterations = 20

	$space.gravity = vec2(0,-100)
	
	$space.resize_static_hash(40.0, 999)
	$space.resize_active_hash(30.0, 2999)
	
	verts = []
	0.upto($num_verts - 1) do |i|
		angle = -2*PI*i/$num_verts
		verts << vec2( 10*Math.cos(angle), 10*Math.sin(angle) )
	end
	
	tris = [ vec2(-15,-15), vec2(0,10), vec2(15,-15) ]
	
	0.upto(8) do |i|
		0.upto(5) do |j|
			
			stagger = (j%2)*40
			offset = vec2(i*80 - 320 + stagger, j*70 - 240)
			
			shape = CP::Shape::Poly.new( $static_body, tris, offset)
			shape.e, shape.u = 1.0, 1.0
			$space.add_static_shape(shape)
			
		end
	end
	
	0.upto($num_shapes) do |i|
		
		body = CP::Body.new( 1.0, CP::moment_for_poly(1.0, verts, vec2(0,0)) )
		body.p = vec2(rand*640 - 320, 350)
		$space.add_body( body )

		shape = CP::Shape::Poly.new(body, verts, vec2(0,0))
		shape.e, shape.u = 0.0, 0.4
		$space.add_shape(shape)
		
	end
	
end
