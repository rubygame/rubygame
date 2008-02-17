
# How large the changes to the crazy poly will be
$jitter = 3

def demo4_update( ticks )

	# Occasionally change the shape of the crazy poly
	if( rand < 0.01 )
		size = 0.5 + (rand * ($jitter - 0.5))
		new_verts = $base_verts.collect { |v|
			v * size
		}
		
		$crazy_poly.set_verts( new_verts, vec2(0,0) )
		$crazy_body.i = CP.moment_for_poly(1.0, new_verts, vec2(0,0))
	end
	
	steps = 5
	dt = 1.0/60.0/steps;
	0.upto(steps) do |i|
		$space.step(dt)
		$static_body.update_position(dt)
		$space.rehash_static
	end
	
end

def demo4_init

	$static_body = CP::Body.new( INFINITY, INFINITY )

	$space = CP::Space.new()
	$space.resize_active_hash( 30.0, 999)
	$space.resize_static_hash(200.0, 99)
	$space.gravity = vec2(0,-600)
	
	$base_verts = [ vec2(-30, -15), vec2(-30, 15), vec2(30, 15), vec2(30, -15) ]
	
	a = vec2(-200, -200)
	b = vec2(-200,  200)
	c = vec2( 200,  200)
	d = vec2( 200, -200)

	make_wall( a, b )
	make_wall( b, c )
	make_wall( c, d )
	make_wall( d, a )

	$static_body.w = 0.4
	
	0.upto(2) do |i|
		0.upto(6) do |j|
			
			body = CP::Body.new( 1.0, CP.moment_for_poly(1.0, $base_verts, vec2(0,0)) )
			body.p = vec2(i*60 - 150, j*30 - 150)
			$space.add_body(body)
			
			shape = CP::Shape::Poly.new(body, $base_verts, vec2(0,0))
			shape.e, shape.u = 0.2, 0.7
			$space.add_shape(shape)
			
		end
	end
	
	body = CP::Body.new( 1.0, CP.moment_for_poly(1.0, $base_verts, vec2(0,0)) )
	body.p = vec2(-100, 100)
	$space.add_body(body)
	$crazy_body = body
	
	shape = CP::Shape::Poly.new(body, $base_verts, vec2(0,0))
	shape.e, shape.u = 0.2, 0.7
	$space.add_shape(shape)
	$crazy_poly = shape
	
end
