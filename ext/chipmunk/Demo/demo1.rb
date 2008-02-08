def demo1_init()
	
	$static_body = CP::Body.new( INFINITY, INFINITY )

	$space = CP::Space.new()
	$space.resize_static_hash(20.0, 999)
	$space.gravity = vec2(0,-100)
	
	body = nil
	shape = nil

	# Create box
	
	verts = [vec2(-15,-15), vec2(-15,15), vec2(15,15), vec2(15,-15)]
	body = CP::Body.new(1.0, CP.moment_for_poly(1.0, verts, vec2(0.0,0.0)) )
	body.p = vec2(-280, 240)
	$space.add_body(body)
	
	shape = CP::Shape::Poly.new(body, verts, vec2(0.0,0.0))
	shape.e, shape.u = 0.0, 1.5
	shape.collision_type = 1
	$space.add_shape(shape)

	
	# Create circle
	
# 	body = CP::Body.new(1.0, CP.moment_for_circle(1.0, 0.0, 15.0, vec2(0.0,0.0)) )
# 	body.p = vec2(-280, 280)
# 	$space.add_body(body)
# 	shape = CP::Shape::Circle.new(body, 15.0, vec2(0.0,0.0))
# 	shape.e, shape.u = 0.1, 2.0
# 	shape.collision_type = 1
# 	$space.add_shape(shape)
	
	# Create walls / floor

	make_wall( vec2(-320,-240), vec2(-320, 240) )
	make_wall( vec2( 320,-240), vec2( 320, 240) )
	make_wall( vec2(-320,-240), vec2( 320,-240) )
	
	# Create stairs
	
	0.upto(50) do |i|
		j = i + 1
		a = vec2(i*10 - 320, i*-10 + 240)
		b = vec2(j*10 - 320, i*-10 + 240)
		c = vec2(j*10 - 320, j*-10 + 240)
		
		make_wall( a, b )
		make_wall( b, c )
	end
	
	# $space.add_collision_func( 1,0, method(:demo1_collide).to_proc )
	
end
