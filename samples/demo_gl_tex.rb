#!/usr/bin/env ruby

# This demonstrates the use of ruby-opengl alongside rubygame to produce
# hardware-accelerated three-dimensional graphics. Additionally, it
# demonstrates the use of rubygame Surfaces as OpenGL textures.
#
# Please note that rubygame itself does not perform any OpenGL functions,
# it only allows ruby-opengl to use the Screen as its viewport. You MUST
# have ruby-opengl installed to run this demo!

require 'rubygame'

begin
  require 'opengl'
rescue LoadError
  puts "ATTENTION: This demo requires the opengl extension for ruby."
  raise
end

WIDE = 640
HIGH = 480
SCALE = 500.0
shadedCube=true
TEXTURE = "ruby.png"

Rubygame.init

Rubygame::GL.set_attrib(Rubygame::GL::RED_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::GREEN_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::BLUE_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::DEPTH_SIZE, 16)
Rubygame::GL.set_attrib(Rubygame::GL::DOUBLEBUFFER, 1)

Rubygame::Screen.set_mode([WIDE,HIGH], 16, [Rubygame::OPENGL])
queue = Rubygame::EventQueue.new()
clock = Rubygame::Time::Clock.new(60)

ObjectSpace.garbage_collect
GL::Viewport( 0, 0, WIDE, HIGH )

GL::MatrixMode( GL::PROJECTION )
GL::LoadIdentity( )
GLU::Perspective( 35, WIDE/(HIGH.to_f), 3, 10)

GL::MatrixMode( GL::MODELVIEW )
GL::LoadIdentity( )

GL::Enable(GL::DEPTH_TEST)
GL::DepthFunc(GL::LESS)

GL::ShadeModel(GL::FLAT)

surface = Rubygame::Image.load(TEXTURE)

tex_id = GL::GenTextures(1)
GL::BindTexture(GL::TEXTURE_2D, tex_id[0])
GL::TexImage2D(GL::TEXTURE_2D, 0, GL::RGB, surface.w, surface.h, 0, GL::RGB,
               GL::UNSIGNED_BYTE, surface.pixels)
GL::TexParameter(GL::TEXTURE_2D,GL::TEXTURE_MIN_FILTER,GL::NEAREST);
GL::TexParameter(GL::TEXTURE_2D,GL::TEXTURE_MAG_FILTER,GL::LINEAR);

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

cube_st =
  [[[ 1,  1], [ 1,  0], [ 0,  0], [ 0,  1]],
  [[ 1,  1], [ 1,  0], [ 0,  0], [ 0,  1]],
  [[ 1,  1], [ 1,  0], [ 0,  0], [ 0,  1]],
  [[ 1,  1], [ 1,  0], [ 0,  0], [ 0,  1]],
  [[ 1,  1], [ 1,  0], [ 0,  0], [ 0,  1]],
  [[ 1,  1], [ 1,  0], [ 0,  0], [ 0,  1]],
  [[ 1,  1], [ 1,  0], [ 0,  0], [ 0,  1]],
  [[ 1,  1], [ 1,  0], [ 0,  0], [ 0,  1]]]

cube_list = 1

GL::NewList(cube_list,GL::COMPILE_AND_EXECUTE)
  GL::PushMatrix()
		GL::Enable(GL::TEXTURE_2D)
		GL::BindTexture(GL::TEXTURE_2D, tex_id[0])

		GL::Begin(GL::QUADS) 

    GL::TexCoord(cube_st[0][0]);
    GL::Vertex(cube[0]);
    GL::TexCoord(cube_st[0][1]);
    GL::Vertex(cube[1]);
    GL::TexCoord(cube_st[0][2]);
    GL::Vertex(cube[2]);
    GL::TexCoord(cube_st[0][3]);
    GL::Vertex(cube[3]);
    
    GL::TexCoord(cube_st[1][0]);
    GL::Vertex(cube[3]);
    GL::TexCoord(cube_st[1][1]);
    GL::Vertex(cube[4]);
    GL::TexCoord(cube_st[1][2]);
    GL::Vertex(cube[7]);
    GL::TexCoord(cube_st[1][3]);
    GL::Vertex(cube[2]);
    
    GL::TexCoord(cube_st[2][0]);
    GL::Vertex(cube[0]);
    GL::TexCoord(cube_st[2][1]);
    GL::Vertex(cube[5]);
    GL::TexCoord(cube_st[2][2]);
    GL::Vertex(cube[6]);
    GL::TexCoord(cube_st[2][3]);
    GL::Vertex(cube[1]);
    
    GL::TexCoord(cube_st[3][0]);
    GL::Vertex(cube[5]);
    GL::TexCoord(cube_st[3][1]);
    GL::Vertex(cube[4]);
    GL::TexCoord(cube_st[3][2]);
    GL::Vertex(cube[7]);
    GL::TexCoord(cube_st[3][3]);
    GL::Vertex(cube[6]);
    
    GL::TexCoord(cube_st[4][0]);
    GL::Vertex(cube[5]);
    GL::TexCoord(cube_st[4][1]);
    GL::Vertex(cube[0]);
    GL::TexCoord(cube_st[4][2]);
    GL::Vertex(cube[3]);
    GL::TexCoord(cube_st[4][3]);
    GL::Vertex(cube[4]);
    
    GL::TexCoord(cube_st[5][0]);
    GL::Vertex(cube[6]);
    GL::TexCoord(cube_st[5][1]);
    GL::Vertex(cube[1]);
    GL::TexCoord(cube_st[5][2]);
    GL::Vertex(cube[2]);
    GL::TexCoord(cube_st[5][3]);
    GL::Vertex(cube[7]);
  GL::PopMatrix()
	GL::End()
GL::EndList()

angle = 0

catch(:rubygame_quit) do
	loop do
		queue.each do |event|
			case event
			when Rubygame::KeyDownEvent
				case event.key
				when Rubygame::K_ESCAPE
					throw :rubygame_quit 
				when Rubygame::K_Q
					throw :rubygame_quit 
        end
      when Rubygame::QuitEvent
        throw :rubygame_quit
      end
    end
  

    GL.ClearColor(0.0, 0.0, 0.0, 1.0);
		GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT);

		GL::MatrixMode(GL::MODELVIEW);
    GL::LoadIdentity( )
    GL::Translate(0, 0, -4)
    GL::Rotate(45, 0, 1, 0)
    GL::Rotate(45, 1, 0, 0)
    GL::Rotate(angle, 0.0, 0.0, 1.0)
    GL::Rotate(angle*2, 0.0, 1.0, 0.0)

    GL::CallList(cube_list)

		Rubygame::GL.swap_buffers()
		ObjectSpace.garbage_collect

    angle += clock.tick()/50.0
    angle -= 360 if angle >= 360

	end
end
