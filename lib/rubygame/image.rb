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



require "ruby-sdl-ffi/image"

Rubygame::VERSIONS[:sdl_image] = SDL::Image.Linked_Version().to_ary


class Rubygame::Surface

  class << self

    # Searches each directory in Surface.autoload_dirs for a file with
    # the given filename. If it finds that file, loads it and returns
    # a Surface instance. If it doesn't find the file, returns nil.
    #
    # See Rubygame::NamedResource for more information about this
    # functionality.
    #
    def autoload( name )
      path = find_file( name )

      if( path )
        return load( path )
      else
        return nil
      end
    end


    # *IMPORTANT*: this method only exists if SDL_image is available!
    # Your code should check "defined?(Rubygame::Surface.load) != nil"
    # to see if you can use this method, or be prepared to rescue from
    # NoMethodError.
    # 
    # Load an image file from the disk to a Surface. If the image has an alpha
    # channel (e.g. PNG with transparency), the Surface will as well. If the
    # image cannot be loaded (for example if the image format is unsupported),
    # will raise SDLError.
    #
    # This method takes this argument:
    # filename:: a string containing the relative or absolute path to the
    #            image file. The file must have the proper file extension,
    #            as it is used to determine image format.
    #
    # These formats may be supported, but some may not be available on a
    # particular system.
    # BMP:: "Windows Bitmap" format.
    # GIF:: "Graphics Interchange Format."
    # JPG:: "Independent JPEG Group" format.
    # LBM:: "Linear Bitmap" format (?)
    # PCX:: "PC Paintbrush" format
    # PNG:: "Portable Network Graphics" format.
    # PNM:: "Portable Any Map" format. (i.e., PPM, PGM, or PBM)
    # TGA:: "Truevision TARGA" format.
    # TIF:: "Tagged Image File Format"
    # XCF:: "eXperimental Computing Facility" (GIMP native format).
    # XPM:: "XPixMap" format.
    # 
    def load( filename )
      surf = SDL::Image.Load( filename.to_s )

      if( surf.pointer.null? )
        raise( Rubygame::SDLError, "Couldn't load image \"%s\": %s"%\
               [filename, SDL.GetError()] )
      end

      return self.new(surf)
    end


    # Deprecated. Use Surface.load instead!
    def load_image( filename )
      Rubygame.deprecated( "Rubygame::Surface.load_image", "3.0" )
      load( filename )
    end


    # *IMPORTANT*: this method only exists if SDL_image is available!
    # Your code should check
    # "defined?(Rubygame::Surface.load_from_string) != nil" to see if
    # you can use this method, or be prepared to rescue from
    # NoMethodError.
    # 
    # Load an image file from memory (in the form of the given data)
    # to a Surface. If the image has an alpha channel (e.g. PNG with
    # transparency), the Surface will as well. If the image cannot be
    # loaded (for example if the image format is unsupported), will
    # raise SDLError.
    # 
    # This method takes these arguments:
    # data:: a string containing the data for the image, such as
    #        IO::read would return.
    # type:: The type of file that the image is (i.e. 'TGA'). Case is
    #        not important. If absent, the library will try to
    #        automatically detect the type.
    # 
    # See Surface.load for a list of possible supported file types.
    # 
    def load_from_string( data, type=nil )
      raw = FFI::MemoryPointer.new(:char, data.length)
      raw.put_bytes(0, data)

      rw = SDL.RWFromMem( raw, data.length )

      surf = if type
               SDL::Image.LoadTyped_RW(rw, 1, type)
             else
               SDL::Image.Load_RW(rw, 1)
             end
      
      if surf.pointer.null?
        raise( Rubygame::SDLError,
               "Couldn't load image from string: #{SDL.GetError()}" )
      end

      return new(surf)
    end

  end

end
