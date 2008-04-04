#!/usr/bin/env ruby

# This demonstrates the use of ruby-opengl alongside rubygame to produce
# hardware-accelerated three-dimensional graphics.
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

#{ $:.collect { |dir| "\t%s"%dir }.join("\n") }

EOF
  exit
end


WIDE = 640
HIGH = 480

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

cube_list = 1

Gl.glNewList(cube_list,Gl::GL_COMPILE_AND_EXECUTE)
  Gl.glPushMatrix()
    Gl.glBegin(Gl::GL_QUADS)
      Gl.glColor(1.0, 0.0, 0.0);
      Gl.glVertex(cube[0]);
      Gl.glVertex(cube[1]);
      Gl.glVertex(cube[2]);
      Gl.glVertex(cube[3]);

      Gl.glColor(0.0, 1.0, 0.0);
      Gl.glVertex(cube[3]);
      Gl.glVertex(cube[4]);
      Gl.glVertex(cube[7]);
      Gl.glVertex(cube[2]);

      Gl.glColor(0.0, 0.0, 1.0);
      Gl.glVertex(cube[0]);
      Gl.glVertex(cube[5]);
      Gl.glVertex(cube[6]);
      Gl.glVertex(cube[1]);

      Gl.glColor(0.0, 1.0, 1.0);
      Gl.glVertex(cube[5]);
      Gl.glVertex(cube[4]);
      Gl.glVertex(cube[7]);
      Gl.glVertex(cube[6]);

      Gl.glColor(1.0, 1.0, 0.0);
      Gl.glVertex(cube[5]);
      Gl.glVertex(cube[0]);
      Gl.glVertex(cube[3]);
      Gl.glVertex(cube[4]);

      Gl.glColor(1.0, 0.0, 1.0);
      Gl.glVertex(cube[6]);
      Gl.glVertex(cube[1]);
      Gl.glVertex(cube[2]);
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
