
def demo6_init
	
	$static_body = CP::Body.new( INFINITY, INFINITY )

	$space = CP::Space.new()
	$space.resize_static_hash(20.0, 999)
	$space.gravity = vec2(0,-100)

	make_wall( vec2(-320,-240), vec2(-320, 240) )
	make_wall( vec2( 320,-240), vec2( 320, 240) )
	make_wall( vec2(-320,-240), vec2( 320,-240) )
	
	0.upto(49) do |i|
		j = i+1
		a = vec2(i*10 - 320, i*-10 + 240)
		b = vec2(j*10 - 320, i*-10 + 240)
		c = vec2(j*10 - 320, j*-10 + 240)
		
		make_wall( a, b )
		make_wall( b, c )
	end
	
	verts = [ vec2(-7,-15), vec2(-7, 15), vec2( 7, 15), vec2( 7,-15) ]
	
	moment = CP.moment_for_poly(1.0, verts, vec2(0,-15))
	moment += CP.moment_for_circle(1.0, 0.0, 25.0, vec2(0,15))
	body = CP::Body.new(1.0, moment)
	body.p = vec2(-280, 250)
	body.w = 1.0
	$space.add_body(body)
	
	shape = CP::Shape::Poly.new(body, verts, vec2(0,-15))
	shape.e, shape.u = 0.0, 1.5
	$space.add_shape(shape)
	
	shape = CP::Shape::Circle.new(body, 25.0, vec2(0,15))
	shape.e, shape.u = 0.9, 1.5
	$space.add_shape(shape)
	
end
