def demo2_init
	
	$static_body = CP::Body.new( INFINITY, INFINITY )
	
	$space = CP::Space.new()
	$space.iterations = 20
	$space.resize_static_hash(40.0, 1000)
	$space.resize_active_hash(40.0, 1000)
	$space.gravity = vec2(0,-100)

	make_wall( vec2(-320,-240), vec2(-320, 240) )
	make_wall( vec2( 320,-240), vec2( 320, 240) )
	make_wall( vec2(-320,-240), vec2( 320,-240) )
	
	verts = [vec2(-15,-15), vec2(-15,15), vec2(15,15), vec2(15,-15)]

	0.upto(13) do |i|
		0.upto(i) do |j|
			body = CP::Body.new(1.0, CP.moment_for_poly(1.0, verts, vec2(0,0)) )
			body.p = vec2(j*32 - i*16, 300 - i*32);
			$space.add_body(body)
			
			shape = CP::Shape::Poly.new( body, verts, vec2(0,0) )
			shape.e, shape.u = 0.0, 0.8
			$space.add_shape(shape)
		end
	end
	
	radius = 15.0
	body = CP::Body.new( 10.0, CP.moment_for_circle(10.0, 0.0, radius, vec2(0,0)) )
	body.p = vec2(0, -240 + radius)
	$space.add_body(body)
	
	shape = CP::Shape::Circle.new( body, radius, vec2(0,0) )
	shape.e, shape.u = 0.0, 0.9
	$space.add_shape(shape)

	# Creating a second sphere, which hovers in mid air and spins
	
	body = CP::Body.new( 10.0, CP.moment_for_circle(10.0, 0.0, radius/2, vec2(0,0)) )
	body.p = vec2(220, -60)
	$space.add_body(body)
	
	shape = CP::Shape::Circle.new( body, radius, vec2(0,0) )
	shape.e, shape.u = 1.0, 0.9
	$space.add_shape(shape)
	
	body.apply_force( -$space.gravity * body.m, vec2(0,0) )
	body.w = 10*body.m
	
end
