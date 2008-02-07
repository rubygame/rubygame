

def demo4_update( ticks )

	steps = 3
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
	
	verts = [ vec2(-30, -15), vec2(-30, 15), vec2(30, 15), vec2(30, -15) ]
	
	a = vec2(-200, -200)
	b = vec2(-200,  200)
	c = vec2( 200,  200)
	d = vec2( 200, -200)
	
	shape = CP::Shape::Segment.new($static_body, a, b, 0.0)
	shape.e, shape.u = 1.0, 1.0
	$space.add_static_shape(shape)
	
	shape = CP::Shape::Segment.new($static_body, b, c, 0.0)
	shape.e, shape.u = 1.0, 1.0
	$space.add_static_shape(shape)
	
	shape = CP::Shape::Segment.new($static_body, c, d, 0.0)
	shape.e, shape.u = 1.0, 1.0
	$space.add_static_shape(shape)
	
	shape = CP::Shape::Segment.new($static_body, d, a, 0.0)
	shape.e, shape.u = 1.0, 1.0
	$space.add_static_shape(shape)
	
	$static_body.w = 0.4
	
	0.upto(2) do |i|
		0.upto(6) do |j|
			
			body = CP::Body.new( 1.0, CP.moment_for_poly(1.0, verts, vec2(0,0)) )
			body.p = vec2(i*60 - 150, j*30 - 150)
			$space.add_body(body)
			
			shape = CP::Shape::Poly.new(body, verts, vec2(0,0))
			shape.e, shape.u = 0.0, 0.7
			$space.add_shape(shape)
			
		end
	end
	
end
