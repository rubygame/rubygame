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
  puts <<EOF

ATTENTION: This demo requires the ruby-opengl extension, but it was not found.
Please install the ruby-opengl gem:

    sudo gem install ruby-opengl

Or install ruby-opengl manually from < http://ruby-opengl.rubyforge.org >
and check that it is installed in one of the following directories:

#{ $:.collect { |dir| "    %s"%dir }.join("\n") }

EOF
  exit
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

Rubygame::Screen.set_mode([WIDE,HIGH], 16, [:opengl])
queue = Rubygame::EventQueue.new()
clock = Rubygame::Clock.new { |c| c.target_framerate = 60 }

ObjectSpace.garbage_collect
Gl.glViewport( 0, 0, WIDE, HIGH )

Gl.glMatrixMode( Gl::GL_PROJECTION )
Gl.glLoadIdentity( )
Glu::gluPerspective( 35, WIDE/(HIGH.to_f), 3, 10)

Gl.glMatrixMode( Gl::GL_MODELVIEW )
Gl.glLoadIdentity( )

Gl.glEnable(Gl::GL_DEPTH_TEST)
Gl.glDepthFunc(Gl::GL_LESS)

Gl.glShadeModel(Gl::GL_FLAT)

surface = Rubygame::Surface.load_image(TEXTURE)

tex_id = Gl.glGenTextures(1)
Gl.glBindTexture(Gl::GL_TEXTURE_2D, tex_id[0])
Gl.glTexImage2D(Gl::GL_TEXTURE_2D, 0, Gl::GL_RGB, surface.w, surface.h, 0, Gl::GL_RGB,
                Gl::GL_UNSIGNED_BYTE, surface.pixels)
Gl.glTexParameter(Gl::GL_TEXTURE_2D,Gl::GL_TEXTURE_MIN_FILTER,Gl::GL_NEAREST);
Gl.glTexParameter(Gl::GL_TEXTURE_2D,Gl::GL_TEXTURE_MAG_FILTER,Gl::GL_LINEAR);

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

Gl.glNewList(cube_list,Gl::GL_COMPILE_AND_EXECUTE)
  Gl.glPushMatrix()
    Gl.glEnable(Gl::GL_TEXTURE_2D)
    Gl.glBindTexture(Gl::GL_TEXTURE_2D, tex_id[0])

    Gl.glBegin(Gl::GL_QUADS)

      Gl.glTexCoord(cube_st[0][0]);
      Gl.glVertex(cube[0]);
      Gl.glTexCoord(cube_st[0][1]);
      Gl.glVertex(cube[1]);
      Gl.glTexCoord(cube_st[0][2]);
      Gl.glVertex(cube[2]);
      Gl.glTexCoord(cube_st[0][3]);
      Gl.glVertex(cube[3]);

      Gl.glTexCoord(cube_st[1][0]);
      Gl.glVertex(cube[3]);
      Gl.glTexCoord(cube_st[1][1]);
      Gl.glVertex(cube[4]);
      Gl.glTexCoord(cube_st[1][2]);
      Gl.glVertex(cube[7]);
      Gl.glTexCoord(cube_st[1][3]);
      Gl.glVertex(cube[2]);

      Gl.glTexCoord(cube_st[2][0]);
      Gl.glVertex(cube[0]);
      Gl.glTexCoord(cube_st[2][1]);
      Gl.glVertex(cube[5]);
      Gl.glTexCoord(cube_st[2][2]);
      Gl.glVertex(cube[6]);
      Gl.glTexCoord(cube_st[2][3]);
      Gl.glVertex(cube[1]);

      Gl.glTexCoord(cube_st[3][0]);
      Gl.glVertex(cube[5]);
      Gl.glTexCoord(cube_st[3][1]);
      Gl.glVertex(cube[4]);
      Gl.glTexCoord(cube_st[3][2]);
      Gl.glVertex(cube[7]);
      Gl.glTexCoord(cube_st[3][3]);
      Gl.glVertex(cube[6]);

      Gl.glTexCoord(cube_st[4][0]);
      Gl.glVertex(cube[5]);
      Gl.glTexCoord(cube_st[4][1]);
      Gl.glVertex(cube[0]);
      Gl.glTexCoord(cube_st[4][2]);
      Gl.glVertex(cube[3]);
      Gl.glTexCoord(cube_st[4][3]);
      Gl.glVertex(cube[4]);

      Gl.glTexCoord(cube_st[5][0]);
      Gl.glVertex(cube[6]);
      Gl.glTexCoord(cube_st[5][1]);
      Gl.glVertex(cube[1]);
      Gl.glTexCoord(cube_st[5][2]);
      Gl.glVertex(cube[2]);
      Gl.glTexCoord(cube_st[5][3]);
      Gl.glVertex(cube[7]);

    Gl.glEnd()
  Gl.glPopMatrix()
Gl.glEndList()

angle = 0

catch(:rubygame_quit) do
  loop do
    queue.each do |event|
      case event
      when Rubygame::KeyDownEvent
        case event.key
        when :escape, :q
          throw :rubygame_quit
        end
      when Rubygame::QuitEvent
        throw :rubygame_quit
      end
    end


    Gl.glClearColor(0.0, 0.0, 0.0, 1.0);
    Gl.glClear(Gl::GL_COLOR_BUFFER_BIT|Gl::GL_DEPTH_BUFFER_BIT);

    Gl.glMatrixMode(Gl::GL_MODELVIEW);
    Gl.glLoadIdentity( )
    Gl.glTranslate(0, 0, -4)
    Gl.glRotate(45, 0, 1, 0)
    Gl.glRotate(45, 1, 0, 0)
    Gl.glRotate(angle, 0.0, 0.0, 1.0)
    Gl.glRotate(angle*2, 0.0, 1.0, 0.0)

    Gl.glCallList(cube_list)

    Rubygame::GL.swap_buffers()
    ObjectSpace.garbage_collect

    angle += clock.tick.milliseconds/50.0
    angle -= 360 if angle >= 360

  end
end
