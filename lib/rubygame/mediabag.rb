#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2007  John Croisant
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



#--
# MediaBag is DEPRECATED and will be removed in Rubygame 3.0!
# Warn the user when this file is loaded.
#++
Rubygame.deprecated("Rubygame::MediaBag", "3.0")


module Rubygame

  # *NOTE*: MediaBag is DEPRECATED and will be removed in Rubygame 3.0!
  # Use the NamedResource functionality of Music, Sound, and Surface instead.
  # 
  # *NOTE*: you must require 'rubygame/mediabag' manually to gain access to
  # Rubygame::MediaBag. It is not imported with Rubygame by default!
  # 
  # A Hash-like class which will load and retain media files (images and
  # sounds), so that the file can be loaded once, but used many times.
  # 
  # The first time a file is requested with the #[] method,that file will be
  # loaded into memory. All subsequent requests for the same file will return
  # a reference to the already-loaded version. Ideally, objects should not
  # have to know whether or not the image has been loaded or not.
  class MediaBag
    @@image_ext = %W{bmp gif jpg lbm pcx png pnm ppm pgm pbm tga tif xcf xpm}
    @@sound_ext = %W{wav}

    def initialize()
      @media = Hash.new
    end

    # Return a reference to the stored value for key. 
    # If there is no value for key, automatically attempt to load key
    # as a filename (guessing the file type based on its extension)
    # 
    def [](key)
      @media[key] or load(key)
    rescue Rubygame::SDLError
      nil
    end

    # Load the file, but only if it has not been previously loaded.
    def load(filename)
      @media[filename] or store( filename, load_file(filename) )
    end

    # Store value as key, but only if there is no previous value.
    def store(key,value)
      @media[key] ||= value
    end

    # Forcibly (re)load the file, replacing the previous version in memory 
    # (if any).
    def force_load(filename)
      force_store( filename, load_file(filename) )
    end

    # Forcibly store value as key, replacing the previous value (if any).
    def force_store(key,value)
      @media[key] = value
    end

    def load_file(filename)
      case File::extname(filename).downcase[1..-1]
      when *(@@image_ext)
        return load_image(filename)
      when *(@@sound_ext)
        return load_sound(filename)
      else
        raise(ArgumentError,"Unrecognized file extension `%s': %s"%
              [File::extname(filename), filename])
      end
    end

    def load_image(filename)
      return Rubygame::Surface.load_image(filename)
    end

    def load_sound(filename)
      return Rubygame::Mixer::Sample.load_audio(filename)
    end
  end

end
