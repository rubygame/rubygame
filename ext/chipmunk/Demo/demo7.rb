

def demo7_update( ticks )
	
	steps = 3
	dt = 1.0/60.0/steps
	
	steps.times do |i|
		$chassis.reset_forces
		$wheel1.reset_forces
		$wheel2.reset_forces
		
		CP.damped_spring($chassis, $wheel1, vec2(40,15),  vec2(0,0), 50, 150, 10, dt)
		CP.damped_spring($chassis, $wheel2, vec2(-40,15), vec2(0,0), 50, 150, 10, dt)
		
		$space.step(dt)
	end
	
end

def make_box(x,y)
	
	verts = [ vec2(-15,-7), vec2(-15, 7), vec2( 15, 7), vec2( 15,-7) ]
	
	body = Body.new(1.0, CP.moment_for_poly(1.0, verts, vec2(0,0)) )
	body.p = vec2(x,y)
	$space.add_body(body)

	shape = Poly.new(body, verts, vec2(0,0))
	shape.e, shape.u = 0.0, 1.0
	$space.add_shape(shape)
	
	return body
	
end

def demo7_init
	
	$static_body = Body.new( INFINITY, INFINITY )

	$space = Space.new()
	$space.iterations = 10
	$space.resize_active_hash(50.0, 999)
	$space.resize_static_hash(50.0, 999)
	$space.gravity = vec2(0,-300)
	

	make_wall( vec2(-320,-240), vec2(-320, 240) )
	make_wall( vec2( 320,-240), vec2( 320, 240) )
	make_wall( vec2(-320,  70), vec2(   0,-240) )
	make_wall( vec2(   0,-240), vec2( 320,-200) )
	make_wall( vec2( 200,-240), vec2( 320,-100) )

	
	
	# Build first chain of boxes
	
	boxes = [make_box(-100, 100)]
	joint = Pivot.new($static_body, boxes[-1], vec2(boxes[-1].p.x - 20, 100))
	$space.add_joint( joint )
	
	6.times do |i|
		boxes << make_box(boxes[-1].p.x + 40, 100)
		joint = Pivot.new( boxes[-2], boxes[-1], vec2(boxes[-1].p.x - 20, 100) )
		$space.add_joint( joint )
	end

	joint = Pivot.new( boxes[-1], $static_body, vec2(boxes[-1].p.x + 20, 100) )
	$space.add_joint( joint )
	


	# Build second chain of boxes
	
	max = 25
	min = 10
	
 	boxes = [make_box(-100, 50)]
 	joint = Slide.new( $static_body, boxes[-1], 
 	                   vec2(boxes[-1].p.x - 25, 50), vec2(-15,0),
 	                   min, max )
 	$space.add_joint(joint)
	
 	6.times do |i|
 		boxes << make_box(boxes[-1].p.x + 40, 50)
 		joint = Slide.new( boxes[-2], boxes[-1],
 		                   vec2(15,0), vec2(-15,0),
 		                   min, max )
 		$space.add_joint(joint)
 	end
	
 	joint = Slide.new( boxes[-1], $static_body,
 	                   vec2(15,0), vec2(boxes[-1].p.x + 25, 50),
 	                   min, max )
 	$space.add_joint(joint)
	

	
	# Build third chain of boxes
	
 	boxes = [make_box(-100, 150)]
 	joint = Pin.new( $static_body, boxes[-1], 
 	                 vec2(boxes[-1].p.x - 25, 150), vec2(-15,0) )
 	$space.add_joint(joint)
	
 	6.times do |i|
 		boxes << make_box(boxes[-1].p.x + 40, 150)
 		joint = Pin.new( boxes[-2], boxes[-1], vec2(15,0), vec2(-15,0) )
 		$space.add_joint(joint)
 	end
	
 	joint = Pin.new( boxes[-1], $static_body,
 	                 vec2(15,0), vec2(boxes[-1].p.x + 25, 150) )
 	$space.add_joint(joint)
	

	# Add a lonely box floating in air
	
	body = make_box(190,200)
	joint = Groove.new( $static_body, body, vec2(0,195), vec2(250,200), vec2(-15,0) )
	$space.add_joint(joint)
	
	
	# Add car chassis (box)
	
	verts = [ vec2(-20,-15), vec2(-20, 15), vec2( 20, 15), vec2( 20,-15) ]
	
	$chassis = Body.new(10, CP.moment_for_poly(10, verts, vec2(0,0)) )
	$chassis.p = vec2(-200, 100)
	$space.add_body($chassis)

	shape = Poly.new( $chassis, verts, vec2(0,0) )
	shape.e, shape.u = 0.0, 1.0
	$space.add_shape(shape)
	

	# Add car wheels (circles)
	
	radius = 15
	wheel_mass = 0.3
	offset = vec2(radius + 30, -25)

	
	# Wheel 1
	
	$wheel1 = Body.new(wheel_mass, CP.moment_for_circle(wheel_mass, 0.0, radius, vec2(0,0)) )
	$wheel1.p = $chassis.p + offset
	$wheel1.v = $chassis.v
	$space.add_body($wheel1)
	
	shape = Circle.new( $wheel1, radius, vec2(0,0) )
	shape.e, shape.u = 0.0, 2.5
	$space.add_shape(shape)
	
	joint = Pin.new( $chassis, $wheel1, vec2(0,0), vec2(0,0) )
	$space.add_joint(joint)

	
	# Wheel 2
	
	$wheel2 = Body.new(wheel_mass, CP.moment_for_circle(wheel_mass, 0.0, radius, vec2(0,0)) )
	$wheel2.p = $chassis.p + vec2(-offset.x, offset.y)
	$wheel2.v = $chassis.v
	$space.add_body($wheel2)
	
	shape = Circle.new( $wheel2, radius, vec2(0,0) )
	shape.e, shape.u = 0.0, 2.5
	$space.add_shape(shape)
	
	joint = Pin.new( $chassis, $wheel2, vec2(0,0), vec2(0,0) )
	$space.add_joint(joint)
	
end
