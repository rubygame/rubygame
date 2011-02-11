#!/usr/bin/env ruby

# This demonstrates the use of OpenGL alongside Rubygame to produce
# hardware-accelerated three-dimensional graphics. Additionally, it
# demonstrates the use of Rubygame Surfaces as OpenGL textures.
#
# Please note that Rubygame itself does not perform any OpenGL
# functions, it only allows OpenGL to use the Screen as its viewport.
# You MUST have either the ffi-opengl or ruby-opengl libraries
# installed to run this demo!
# 
# Controls:
# 
#   C - toggle colors
#   T - toggle textures
#   W - toggle wireframe mode
# 

require 'rubygame'

include Rubygame
include Rubygame::Events

# Load images from this directory
Surface.autoload_dirs << File.dirname( __FILE__ )



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


class App

  def initialize
    @screen = setup_screen( [640,480] )

    @queue = EventQueue.new{ |q|
      q.enable_new_style_events
    }

    @clock = Clock.new { |c|
      c.enable_tick_events
      c.target_framerate = 60
      c.calibrate
    }

    @cube = Cube.new( :image => Rubygame::Surface["rubygame.png"] )
  end


  def setup_screen( size=[640,480], fovy=35, clip=[3,10] )
    w, h = size

    Screen.set_opengl_attributes( :red_size     => 8,
                                  :green_size   => 8,
                                  :blue_size    => 8,
                                  :depth_size   => 16,
                                  :doublebuffer => true )

    screen = Screen.open([w,h], :depth => 24, :opengl => true)

    glViewport( 0, 0, w, h )

    glMatrixMode( GL_PROJECTION )
    glLoadIdentity()
    gluPerspective( fovy, w/(h.to_f), clip[0], clip[1])

    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LESS)

    glEnable(GL_TEXTURE_2D)

    return screen
  end


  # Main game loop
  def go
    catch(:rubygame_quit) do
      loop do

        @queue.each do |event|
          case event
          when KeyPressed
            case event.key
            when :escape, :q
              throw :rubygame_quit 
            when :c
              @cube.use_color   = !(@cube.use_color)
            when :t
              @cube.use_texture = !(@cube.use_texture)
            when :w
              @cube.wireframe   = !(@cube.wireframe)
            end
          when QuitRequested
            throw :rubygame_quit
          end
        end

        update( @clock.tick )
        draw

      end # loop
    end # catch
  end


  def update( tick )
    @cube.update( tick )
  end


  def draw
    glClearColor(0.0, 0.0, 0.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT)

    @cube.draw

    Rubygame::GL.swap_buffers()
  end

end



class Cube

  def initialize( options={} )
    options = {
      :angle       => 0,
      :image       => Surface["rubygame.png"],
      :use_color   => true,
      :use_texture => true,
      :wireframe   => false,
    }.merge!(options)

    @angle       = options[:angle]
    @image       = options[:image]
    @use_color   = options[:use_color]
    @use_texture = options[:use_texture]
    @wireframe   = options[:wireframe]
    
    setup_texture
    setup_verts
    setup_display_list
  end


  def setup_texture
    @tex_id = 1
    glBindTexture(GL_TEXTURE_2D, @tex_id)

    params = @image.to_opengl
    glTexImage2D(GL_TEXTURE_2D, 0, params[:format],
                 @image.width, @image.height, 0, params[:format],
                 params[:type], params[:data])

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  end


  def setup_verts
    @colors =
      [[ 1.0,  1.0,  0.2], 
       [ 1.0,  0.2,  0.2],
       [ 0.2,  0.2,  0.2],
       [ 0.2,  1.0,  0.2],
       [ 0.2,  1.0,  1.0],
       [ 1.0,  1.0,  1.0],
       [ 1.0,  0.2,  1.0],
       [ 0.2,  0.2,  1.0]]

    @verts =
      [[ 0.5,  0.5, -0.5], 
       [ 0.5, -0.5, -0.5],
       [-0.5, -0.5, -0.5],
       [-0.5,  0.5, -0.5],
       [-0.5,  0.5,  0.5],
       [ 0.5,  0.5,  0.5],
       [ 0.5, -0.5,  0.5],
       [-0.5, -0.5,  0.5]]

    @texcoords =
      [[[ 1, 1], [ 1, 0], [ 0, 0], [ 0, 1]],
       [[ 1, 1], [ 1, 0], [ 0, 0], [ 0, 1]],
       [[ 1, 1], [ 1, 0], [ 0, 0], [ 0, 1]],
       [[ 1, 1], [ 1, 0], [ 0, 0], [ 0, 1]],
       [[ 1, 1], [ 1, 0], [ 0, 0], [ 0, 1]],
       [[ 1, 1], [ 1, 0], [ 0, 0], [ 0, 1]],
       [[ 1, 1], [ 1, 0], [ 0, 0], [ 0, 1]],
       [[ 1, 1], [ 1, 0], [ 0, 0], [ 0, 1]]]
  end


  def setup_display_list
    # Really, we should use glGenLists, but it works differently
    # between ruby-opengl and ffi-opengl, so we fake it.
    @display_list ||= 1

    glNewList(@display_list, GL_COMPILE)
      glPushMatrix()
        glBindTexture(GL_TEXTURE_2D, @tex_id) if @use_texture

        if @wireframe
          glPolygonMode(GL_FRONT, GL_LINE)
          glPolygonMode(GL_BACK,  GL_LINE)
        else
          glPolygonMode(GL_FRONT, GL_FILL)
          glPolygonMode(GL_BACK,  GL_FILL)
        end

        glBegin(GL_QUADS) 

          # Construct side 0
          glTexCoord2i( *@texcoords[0][0] ) if @use_texture
          glColor3f( *@colors[0] ) if @use_color
          glVertex3f( *@verts[0] )
          glTexCoord2i( *@texcoords[0][1] ) if @use_texture
          glColor3f( *@colors[1] ) if @use_color
          glVertex3f( *@verts[1] )
          glTexCoord2i( *@texcoords[0][2] ) if @use_texture
          glColor3f( *@colors[2] ) if @use_color
          glVertex3f( *@verts[2] )
          glTexCoord2i( *@texcoords[0][3] ) if @use_texture
          glColor3f( *@colors[3] ) if @use_color
          glVertex3f( *@verts[3] )

          # Construct side 1
          glTexCoord2i( *@texcoords[1][0] ) if @use_texture
          glColor3f( *@colors[3] ) if @use_color
          glVertex3f( *@verts[3] )
          glTexCoord2i( *@texcoords[1][1] ) if @use_texture
          glColor3f( *@colors[4] ) if @use_color
          glVertex3f( *@verts[4] )
          glTexCoord2i( *@texcoords[1][2] ) if @use_texture
          glColor3f( *@colors[7] ) if @use_color
          glVertex3f( *@verts[7] )
          glTexCoord2i( *@texcoords[1][3] ) if @use_texture
          glColor3f( *@colors[2] ) if @use_color
          glVertex3f( *@verts[2] )

          # Construct side 2
          glTexCoord2i( *@texcoords[2][0] ) if @use_texture
          glColor3f( *@colors[0] ) if @use_color
          glVertex3f( *@verts[0] )
          glTexCoord2i( *@texcoords[2][1] ) if @use_texture
          glColor3f( *@colors[5] ) if @use_color
          glVertex3f( *@verts[5] )
          glTexCoord2i( *@texcoords[2][2] ) if @use_texture
          glColor3f( *@colors[6] ) if @use_color
          glVertex3f( *@verts[6] )
          glTexCoord2i( *@texcoords[2][3] ) if @use_texture
          glColor3f( *@colors[1] ) if @use_color
          glVertex3f( *@verts[1] )

          # Construct side 3
          glTexCoord2i( *@texcoords[3][0] ) if @use_texture
          glColor3f( *@colors[5] ) if @use_color
          glVertex3f( *@verts[5] )
          glTexCoord2i( *@texcoords[3][1] ) if @use_texture
          glColor3f( *@colors[4] ) if @use_color
          glVertex3f( *@verts[4] )
          glTexCoord2i( *@texcoords[3][2] ) if @use_texture
          glColor3f( *@colors[7] ) if @use_color
          glVertex3f( *@verts[7] )
          glTexCoord2i( *@texcoords[3][3] ) if @use_texture
          glColor3f( *@colors[6] ) if @use_color
          glVertex3f( *@verts[6] )

          # Construct side 4
          glTexCoord2i( *@texcoords[4][0] ) if @use_texture
          glColor3f( *@colors[5] ) if @use_color
          glVertex3f( *@verts[5] )
          glTexCoord2i( *@texcoords[4][1] ) if @use_texture
          glColor3f( *@colors[0] ) if @use_color
          glVertex3f( *@verts[0] )
          glTexCoord2i( *@texcoords[4][2] ) if @use_texture
          glColor3f( *@colors[3] ) if @use_color
          glVertex3f( *@verts[3] )
          glTexCoord2i( *@texcoords[4][3] ) if @use_texture
          glColor3f( *@colors[4] ) if @use_color
          glVertex3f( *@verts[4] )

          # Construct side 5
          glTexCoord2i( *@texcoords[5][0] ) if @use_texture
          glColor3f( *@colors[6] ) if @use_color
          glVertex3f( *@verts[6] )
          glTexCoord2i( *@texcoords[5][1] ) if @use_texture
          glColor3f( *@colors[1] ) if @use_color
          glVertex3f( *@verts[1] )
          glTexCoord2i( *@texcoords[5][2] ) if @use_texture
          glColor3f( *@colors[2] ) if @use_color
          glVertex3f( *@verts[2] )
          glTexCoord2i( *@texcoords[5][3] ) if @use_texture
          glColor3f( *@colors[7] ) if @use_color
          glVertex3f( *@verts[7] )

          # Reset to white
          glColor3f( 1.0, 1.0, 1.0 )

        glEnd()

      glPopMatrix()
    glEndList()   
  end


  def update( tick )
    @angle += tick.seconds * 10
    @angle -= 360 if @angle >= 360
  end


  def draw
    glShadeModel(GL_SMOOTH)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()

    glTranslatef( 0.0, 0.0, -4.0 )

    glRotatef( 45.0,     0.0, 1.0, 0.0 )
    glRotatef( 45.0,     1.0, 0.0, 0.0 )
    glRotatef( @angle,   0.0, 0.0, 1.0 )
    glRotatef( @angle*2, 0.0, 1.0, 0.0 )

    glCallList(@display_list)
  end


  attr_reader :use_color

  def use_color=( bool )
    @use_color = bool
    setup_display_list
  end


  attr_reader :use_texture

  def use_texture=( bool )
    @use_texture = bool
    setup_display_list
  end


  attr_reader :wireframe

  def wireframe=( bool )
    @wireframe = bool
    setup_display_list
  end


end



App.new.go()
