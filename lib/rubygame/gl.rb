#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2009  John Croisant
#
#	This library is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++



# The GL module provides an interface to SDL's OpenGL-related functions,
# allowing a Rubygame application to create hardware-accelerated 3D graphics
# with OpenGL.
#
# Please note that Rubygame itself does not provide an interface to OpenGL
# functions -- only functions which allow Rubygame to work together with
# OpenGL. You will need to use another library, for example
# ruby-opengl[http://ruby-opengl.rubyforge.org/],
# to actually create graphics with OpenGL.
#
# Users who wish to use Rubygame Surfaces as textures in OpenGL should
# see also the Surface#pixels method.
#
module Rubygame::GL


  # Return the value of the the SDL/OpenGL attribute identified by +attrib+,
  # which should be one of the constants defined in the Rubygame::GL module.
  # See #set_attrib for a list of attribute constants.
  #
  # This method is useful after using #set_attrib and calling Screen#set_mode,
  # to make sure the attribute is the expected value.
  #
  def self.get_attrib( attrib )
    result = SDL.GL_GetAttribute(attrib)
    if( result.nil? )
      raise Rubygame::SDLError, "GL get attribute failed: #{SDL.GetError()}"
    end
  end



  # Set the SDL/OpenGL attribute +attrib+ to +value+. This should be called
  # *before* you call Screen#set_mode with the OPENGL flag. You may wish to
  # use #get_attrib after calling Screen#set_mode to confirm that the attribute
  # is set to the desired value.
  #
  # The full list of SDL/OpenGL attribute identifier constants (located under
  # the Rubygame::GL module) is as follows:
  #
  # RED_SIZE::         Size of framebuffer red component, in bits.
  # GREEN_SIZE::       Size of framebuffer green component, in bits.
  # BLUE_SIZE::        Size of framebuffer blue component, in bits.
  # ALPHA_SIZE::       Size of framebuffer alpha (opacity) component, in bits.
  # BUFFER_SIZE::      Size of framebuffer, in bits.
  # DOUBLEBUFFER::     Enable or disable double-buffering.
  # DEPTH_SIZE::       Size of depth buffer, in bits.
  # STENCIL_SIZE::     Size of stencil buffer, in bits.
  # ACCUM_RED_SIZE::   Size of accumulation buffer red component, in bits.
  # ACCUM_GREEN_SIZE:: Size of accumulation buffer green component, in bits.
  # ACCUM_BLUE_SIZE::  Size of accumulation buffer blue component, in bits.
  # ACCUM_ALPHA_SIZE:: Size of accumulation buffer alpha component, in bits.
  #
  def self.set_attrib( attrib, value )
    result = SDL.GL_SetAttribute( attrib, value )
    if( result == -1 )
      raise Rubygame::SDLError, "GL set attribute failed: #{SDL.GetError()}"
    end
  end



  # Swap the back and front buffers, for double-buffered OpenGL displays.
  # Should be safe to use (albeit with no effect) on single-buffered OpenGL
  # displays.
  #
  def self.swap_buffers
    SDL.GL_SwapBuffers()
  end


  RED_SIZE         = SDL::GL_RED_SIZE
  GREEN_SIZE       = SDL::GL_GREEN_SIZE
  BLUE_SIZE        = SDL::GL_BLUE_SIZE
  ALPHA_SIZE       = SDL::GL_ALPHA_SIZE
  BUFFER_SIZE      = SDL::GL_BUFFER_SIZE
  DOUBLEBUFFER     = SDL::GL_DOUBLEBUFFER
  DEPTH_SIZE       = SDL::GL_DEPTH_SIZE
  STENCIL_SIZE     = SDL::GL_STENCIL_SIZE
  ACCUM_RED_SIZE   = SDL::GL_ACCUM_RED_SIZE
  ACCUM_GREEN_SIZE = SDL::GL_ACCUM_GREEN_SIZE
  ACCUM_BLUE_SIZE  = SDL::GL_ACCUM_BLUE_SIZE
  ACCUM_ALPHA_SIZE = SDL::GL_ACCUM_ALPHA_SIZE


end
