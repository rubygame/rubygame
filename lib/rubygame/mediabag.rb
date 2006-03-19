#--
#	Rubygame -- Ruby bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2006  John 'jacius' Croisant
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

require "rubygame"

module Rubygame

  # A Hash-like class which will load and retain media files (currently only
  # images), so that the file can be loaded once, but used many times.
  # 
  # The first time a file is requested with the #[] method,that file will be
  # loaded into memory. All subsequent requests for the same file will return
  # a reference to the already-loaded version. Ideally, objects should not
  # have to know whether or not the image has been loaded or not.
  class MediaBag
    def initialize()
      @media = Hash.new
    end

    # Return a reference to the stored value for key. If there is no value for
    # key, automatically attempt to load key as an image file name, and store the
    # loaded Surface as key.
    def [](key)
      @media[key] or load(key)
    rescue Rubygame::SDLError
      nil
    end

    # Load the file, but only if it has not been previously loaded.
    def load(filename)
      store(filename,Rubygame::Image.load(filename))
    end

    # Store value as key, but only if there is no previous value.
    def store(key,value)
      @media[key] ||= value
    end

    # Forcibly (re)load the file, replacing the previous version in memory 
    # (if any).
    def force_load(filename)
      force_store(filename,Rubygame::Image.load(filename))
    end

    # Forcibly store value as key, replacing the previous value (if any).
    def force_store(key,value)
      @media[key] = value
    end
  end

end
