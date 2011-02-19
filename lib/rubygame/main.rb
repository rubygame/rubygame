#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2010  John Croisant
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



require "ruby-sdl-ffi/sdl"


module Rubygame

  VERSIONS = {
    :rubygame => [2, 6, 4],
    :sdl      => SDL.Linked_Version().to_ary
  }


  # Initialize Rubygame. This should be called soon after you
  # +require+ Rubygame, so that everything will work properly.
  #
  def self.init
    if( SDL.Init(SDL::INIT_EVERYTHING) == 0 )
      SDL.EnableUNICODE(1)
    else
      raise Rubygame::SDLError, "Could not initialize SDL: #{SDL.GetError()}"
    end
  end


  # Quit Rubygame. This should be used before your program terminates,
  # especially if you have been using a fullscreen Screen! (Otherwise,
  # the desktop resolution might not revert to its previous setting on
  # some platforms, and your users will be frustrated and confused!)
  #
  def self.quit
    SDL.Quit
  end



  # Indicates that an SDL function failed.
  class SDLError < RuntimeError
  end



  SWSURFACE   = SDL::SWSURFACE
  HWSURFACE   = SDL::HWSURFACE
  ASYNCBLIT   = SDL::ASYNCBLIT
  ANYFORMAT   = SDL::ANYFORMAT
  HWPALETTE   = SDL::HWPALETTE
  HWACCEL     = SDL::HWACCEL
  SRCCOLORKEY = SDL::SRCCOLORKEY
  RLEACCELOK  = SDL::RLEACCELOK
  RLEACCEL    = SDL::RLEACCEL
  SRCALPHA    = SDL::SRCALPHA
  PREALLOC    = SDL::PREALLOC

  DOUBLEBUF   = SDL::DOUBLEBUF
  FULLSCREEN  = SDL::FULLSCREEN
  OPENGL      = SDL::OPENGL
  OPENGLBLIT  = SDL::OPENGLBLIT
  RESIZABLE   = SDL::RESIZABLE
  NOFRAME     = SDL::NOFRAME


end
