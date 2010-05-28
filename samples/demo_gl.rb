#!/usr/bin/env ruby

# This demonstrates the use of OpenGL alongside Rubygame to produce
# hardware-accelerated three-dimensional graphics. 
#
# Please note that Rubygame itself does not perform any OpenGL
# functions, it only allows OpenGL to use the Screen as its viewport.
# You MUST have either the ffi-opengl or ruby-opengl libraries
# installed to run this demo!

require 'rubygame'

begin
  require 'ffi-opengl'
rescue LoadError
  begin
    require 'opengl'
  rescue LoadError
    puts "You need ffi-opengl or ruby-opengl to run this demo.
  gem install ffi-opengl
  gem install ruby-opengl"
    raise
  end
end

include GL
include GLU

WIDE = 640
HIGH = 480

Rubygame.init

Rubygame::GL.set_attrib(Rubygame::GL::RED_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::GREEN_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::BLUE_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::DEPTH_SIZE, 16)
Rubygame::GL.set_attrib(Rubygame::GL::DOUBLEBUFFER, 1)

Rubygame::Screen.open([WIDE,HIGH], :depth => 16, :opengl => true)
queue = Rubygame::EventQueue.new()
clock = Rubygame::Clock.new { |c| c.target_framerate = 60 }

ObjectSpace.garbage_collect

glViewport( 0, 0, WIDE, HIGH )

glMatrixMode( GL_PROJECTION )
glLoadIdentity( )
gluPerspective( 35, WIDE/(HIGH.to_f), 3, 10)

glMatrixMode( GL_MODELVIEW )
glLoadIdentity( )

glEnable(GL_DEPTH_TEST)
glDepthFunc(GL_LESS)

glShadeModel(GL_FLAT)

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

glNewList(cube_list,GL_COMPILE_AND_EXECUTE)
  glPushMatrix()
    glBegin(GL_QUADS) 
      glColor3f(1.0, 0.0, 0.0)
      glVertex3f(*cube[0])
      glVertex3f(*cube[1])
      glVertex3f(*cube[2])
      glVertex3f(*cube[3])
      
      glColor3f(0.0, 1.0, 0.0)
      glVertex3f(*cube[3])
      glVertex3f(*cube[4])
      glVertex3f(*cube[7])
      glVertex3f(*cube[2])
      
      glColor3f(0.0, 0.0, 1.0)
      glVertex3f(*cube[0])
      glVertex3f(*cube[5])
      glVertex3f(*cube[6])
      glVertex3f(*cube[1])
      
      glColor3f(0.0, 1.0, 1.0)
      glVertex3f(*cube[5])
      glVertex3f(*cube[4])
      glVertex3f(*cube[7])
      glVertex3f(*cube[6])
      
      glColor3f(1.0, 1.0, 0.0)
      glVertex3f(*cube[5])
      glVertex3f(*cube[0])
      glVertex3f(*cube[3])
      glVertex3f(*cube[4])
      
      glColor3f(1.0, 0.0, 1.0)
      glVertex3f(*cube[6])
      glVertex3f(*cube[1])
      glVertex3f(*cube[2])
      glVertex3f(*cube[7])
    glEnd()
 glPopMatrix()
glEndList()

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

    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity( )
    glTranslatef(0, 0, -4)
    glRotatef(45, 0, 1, 0)
    glRotatef(45, 1, 0, 0)
    glRotatef(angle, 0.0, 0.0, 1.0)
    glRotatef(angle*2, 0.0, 1.0, 0.0)

    glCallList(cube_list)

    Rubygame::GL.swap_buffers()
    ObjectSpace.garbage_collect

    angle += clock.tick()/50.0
    angle -= 360 if angle >= 360

  end
end

Rubygame.quit
