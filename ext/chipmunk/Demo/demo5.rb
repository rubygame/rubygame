def demo5_init
	
	$static_body = CP::Body.new( INFINITY, INFINITY )

	$space = CP::Space.new()
	$space.iterations = 20
	$space.resize_active_hash(30.0, 2999)
	$space.resize_static_hash(40.0, 999)
	$space.gravity = vec2(0,-300)

	
	make_wall( vec2(-600,-240), vec2(600,-240) )
	
	verts = [ vec2(-3,-20), vec2(-3,20), vec2(3,20), vec2(3,-20) ]
	
	u = 0.6
	n = 9
	body = nil
	
	1.upto(9) do |i|
		
		offset = vec2(-i*60/2.0, (n - i)*52)
		
		0.upto(i-1) do |j|
			
			body = CP::Body.new(1.0, CP.moment_for_poly(1.0, verts, vec2(0,0)) )
			body.p = vec2(j*60, -220) + offset
			$space.add_body(body)
			
			shape = CP::Shape::Poly.new(body, verts, vec2(0,0))
			shape.e, shape.u = 0.0, u
			$space.add_shape(shape)
			

			body = CP::Body.new(1.0, CP.moment_for_poly(1.0, verts, vec2(0,0)) )
			body.p = vec2(j*60, -197) + offset
			body.a = PI/2
			$space.add_body(body)
			
			shape = CP::Shape::Poly.new(body, verts, vec2(0,0))
			shape.e, shape.u = 0.0, u
			$space.add_shape(shape)

			unless( j == (i - 1) )
				body = CP::Body.new(1.0, CP.moment_for_poly(1.0, verts, vec2(0,0)) )
				body.p = vec2(j*60+30, -191) + offset
				body.a = PI/2
				$space.add_body(body)
				
				shape = CP::Shape::Poly.new(body, verts, vec2(0,0))
				shape.e, shape.u = 0.0, u
				$space.add_shape(shape)
			end
			
		end
		
		body = CP::Body.new(1.0, CP.moment_for_poly(1.0, verts, vec2(0,0)) )
		body.p = vec2(-17, -174) + offset
		$space.add_body(body)
		
		shape = CP::Shape::Poly.new(body, verts, vec2(0,0))
		shape.e, shape.u = 0.0, u
		$space.add_shape(shape)
		
		body = CP::Body.new(1.0, CP.moment_for_poly(1.0, verts, vec2(0,0)) )
		body.p = vec2((i - 1)*60 + 17, -174) + offset
		$space.add_body(body)
		
		shape = CP::Shape::Poly.new(body, verts, vec2(0,0))
		shape.e, shape.u = 0.0, u
		$space.add_shape(shape)
		
	end

	body.w = -1
	body.v = vec2(-body.w*20, 0)
	
end
