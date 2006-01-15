#!/usr/bin/env ruby

require 'rubygame'
require__ 'opengl'

Rubygame.init
Rubygame::GL.set_attrib(Rubygame::GL::RED_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::GREEN_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::BLUE_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::DEPTH_SIZE, 16)
Rubygame::GL.set_attrib(Rubygame::GL::DOUBLEBUFFER, 1)

Rubygame::Screen.set_mode([640,400], 16, [Rubygame::OPENGL])
queue = Rubygame::Queue.instance

ObjectSpace.garbage_collect
GL::Viewport( 0, 0, 640, 400 );
GL::MatrixMode( GL::PROJECTION );
GL::LoadIdentity( );

GL::MatrixMode( GL::MODELVIEW );
GL::LoadIdentity( );

GL::Enable(GL::DEPTH_TEST);

GL::DepthFunc(GL::LESS);

GL::ShadeModel(GL::SMOOTH);

shadedCube=true

color =
  [[ 1.0,  1.0,  0.0], 
  [ 1.0,  0.0,  0.0],
  [ 0.0,  0.0,  0.0],
  [ 0.0,  1.0,  0.0],
  [ 0.0,  1.0,  1.0],
  [ 1.0,  1.0,  1.0],
  [ 1.0,  0.0,  1.0],
  [ 0.0,  0.0,  1.0]]

cube =
  [[ 0.5,  0.5, -0.5], 
  [ 0.5, -0.5, -0.5],
  [-0.5, -0.5, -0.5],
  [-0.5,  0.5, -0.5],
  [-0.5,  0.5,  0.5],
  [ 0.5,  0.5,  0.5],
  [ 0.5, -0.5,  0.5],
  [-0.5, -0.5,  0.5]]


catch(:rubygame_quit) do
	loop do
		queue.get().each do |event|
			case event
			when Rubygame::KeyDownEvent
				case event.key
				when Rubygame::K_ESCAPE
					throw :rubygame_quit 
				when Rubygame::K_Q
					throw :rubygame_quit 
				when Rubygame::QuitEvent
					puts "Quitting!"
					throw :rubygame_quit
				end
			end
		end

    GL.ClearColor(0.0, 0.0, 0.0, 1.0);
		GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT);


		GL::Begin(GL::QUADS) 

		if shadedCube then
			GL::Color(color[0]);
			GL::Vertex(cube[0]);
			GL::Color(color[1]);
			GL::Vertex(cube[1]);
			GL::Color(color[2]);
			GL::Vertex(cube[2]);
			GL::Color(color[3]);
			GL::Vertex(cube[3]);
			
			GL::Color(color[3]);
			GL::Vertex(cube[3]);
			GL::Color(color[4]);
			GL::Vertex(cube[4]);
			GL::Color(color[7]);
			GL::Vertex(cube[7]);
			GL::Color(color[2]);
			GL::Vertex(cube[2]);
			
			GL::Color(color[0]);
			GL::Vertex(cube[0]);
			GL::Color(color[5]);
			GL::Vertex(cube[5]);
			GL::Color(color[6]);
			GL::Vertex(cube[6]);
			GL::Color(color[1]);
			GL::Vertex(cube[1]);
			
			GL::Color(color[5]);
			GL::Vertex(cube[5]);
			GL::Color(color[4]);
			GL::Vertex(cube[4]);
			GL::Color(color[7]);
			GL::Vertex(cube[7]);
			GL::Color(color[6]);
			GL::Vertex(cube[6]);
			
			GL::Color(color[5]);
			GL::Vertex(cube[5]);
			GL::Color(color[0]);
			GL::Vertex(cube[0]);
			GL::Color(color[3]);
			GL::Vertex(cube[3]);
			GL::Color(color[4]);
			GL::Vertex(cube[4]);
			
			GL::Color(color[6]);
			GL::Vertex(cube[6]);
			GL::Color(color[1]);
			GL::Vertex(cube[1]);
			GL::Color(color[2]);
			GL::Vertex(cube[2]);
			GL::Color(color[7]);
			GL::Vertex(cube[7]);
			
		else
			GL::Color(1.0, 0.0, 0.0);
			GL::Vertex(cube[0]);
			GL::Vertex(cube[1]);
			GL::Vertex(cube[2]);
			GL::Vertex(cube[3]);
			
			GL::Color(0.0, 1.0, 0.0);
			GL::Vertex(cube[3]);
			GL::Vertex(cube[4]);
			GL::Vertex(cube[7]);
			GL::Vertex(cube[2]);
			
			GL::Color(0.0, 0.0, 1.0);
			GL::Vertex(cube[0]);
			GL::Vertex(cube[5]);
			GL::Vertex(cube[6]);
			GL::Vertex(cube[1]);
			
			GL::Color(0.0, 1.0, 1.0);
			GL::Vertex(cube[5]);
			GL::Vertex(cube[4]);
			GL::Vertex(cube[7]);
			GL::Vertex(cube[6]);
			
			GL::Color(1.0, 1.0, 0.0);
			GL::Vertex(cube[5]);
			GL::Vertex(cube[0]);
			GL::Vertex(cube[3]);
			GL::Vertex(cube[4]);
			
			GL::Color(1.0, 0.0, 1.0);
			GL::Vertex(cube[6]);
			GL::Vertex(cube[1]);
			GL::Vertex(cube[2]);
			GL::Vertex(cube[7]);
			
		end

		GL::End()
		
		GL::MatrixMode(GL::MODELVIEW);
		GL::Rotate(5.0, 1.0, 1.0, 1.0);
		
		Rubygame::GL.swap_buffers()
		ObjectSpace.garbage_collect

	end
end
