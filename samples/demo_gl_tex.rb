#!/usr/bin/env ruby

# This demonstrates the use of OpenGL alongside Rubygame to produce
# hardware-accelerated three-dimensional graphics. Additionally, it
# demonstrates the use of Rubygame Surfaces as OpenGL textures.
#
# Please note that Rubygame itself does not perform any OpenGL
# functions, it only allows OpenGL to use the Screen as its viewport.
# You MUST have either the ffi-opengl or ruby-opengl libraries
# installed to run this demo!

require 'rubygame'

begin
  require 'ffi-opengl'
  $gl = :ffi_opengl
rescue LoadError
  begin
    require 'opengl'
    $gl = :ruby_opengl
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
SCALE = 500.0
shadedCube=true
TEXTURE = "rubygame.png"

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

surface = Rubygame::Surface.load_image(TEXTURE)

tex_id = 1
glBindTexture(GL_TEXTURE_2D, tex_id)
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, surface.w, surface.h, 0, GL_RGB,
             GL_UNSIGNED_BYTE, surface.pixels)
glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);

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

glNewList(cube_list,GL_COMPILE_AND_EXECUTE)
  glPushMatrix()
    glEnable(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D, tex_id)

    glBegin(GL_QUADS) 

    glTexCoord2i(*cube_st[0][0]);
    glVertex3f(*cube[0]);
    glTexCoord2i(*cube_st[0][1]);
    glVertex3f(*cube[1]);
    glTexCoord2i(*cube_st[0][2]);
    glVertex3f(*cube[2]);
    glTexCoord2i(*cube_st[0][3]);
    glVertex3f(*cube[3]);
    
    glTexCoord2i(*cube_st[1][0]);
    glVertex3f(*cube[3]);
    glTexCoord2i(*cube_st[1][1]);
    glVertex3f(*cube[4]);
    glTexCoord2i(*cube_st[1][2]);
    glVertex3f(*cube[7]);
    glTexCoord2i(*cube_st[1][3]);
    glVertex3f(*cube[2]);
    
    glTexCoord2i(*cube_st[2][0]);
    glVertex3f(*cube[0]);
    glTexCoord2i(*cube_st[2][1]);
    glVertex3f(*cube[5]);
    glTexCoord2i(*cube_st[2][2]);
    glVertex3f(*cube[6]);
    glTexCoord2i(*cube_st[2][3]);
    glVertex3f(*cube[1]);
    
    glTexCoord2i(*cube_st[3][0]);
    glVertex3f(*cube[5]);
    glTexCoord2i(*cube_st[3][1]);
    glVertex3f(*cube[4]);
    glTexCoord2i(*cube_st[3][2]);
    glVertex3f(*cube[7]);
    glTexCoord2i(*cube_st[3][3]);
    glVertex3f(*cube[6]);
    
    glTexCoord2i(*cube_st[4][0]);
    glVertex3f(*cube[5]);
    glTexCoord2i(*cube_st[4][1]);
    glVertex3f(*cube[0]);
    glTexCoord2i(*cube_st[4][2]);
    glVertex3f(*cube[3]);
    glTexCoord2i(*cube_st[4][3]);
    glVertex3f(*cube[4]);
    
    glTexCoord2i(*cube_st[5][0]);
    glVertex3f(*cube[6]);
    glTexCoord2i(*cube_st[5][1]);
    glVertex3f(*cube[1]);
    glTexCoord2i(*cube_st[5][2]);
    glVertex3f(*cube[2]);
    glTexCoord2i(*cube_st[5][3]);
    glVertex3f(*cube[7]);

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
