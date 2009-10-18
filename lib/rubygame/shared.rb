# 
# Common / utility methods.
# 
#--
# 
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2009  John Croisant
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
# 
#++


module Rubygame

  # Warn of a deprecated Rubygame feature.
  def self.deprecated( feature, version=nil ) # :nodoc:
    @deprec_warned ||= {}

    if $VERBOSE and not @deprec_warned[feature]
      if version
        warn( "warning: #{feature} is DEPRECATED and will be removed " +
              "in Rubygame #{version}! Please see the docs for more "  +
              "information." )
      else
        warn( "warning: #{feature} is DEPRECATED and will be removed " +
              "in a future version of Rubygame! Please see the docs "  +
              "for more information." )
      end
      @deprec_warned[feature] = true
    end
  end


  # Initialize the SDL video system if necessary.
  def self.init_video_system    # :nodoc:
    if( SDL::WasInit(SDL::INIT_VIDEO) == 0 )
      return SDL::Init(SDL::INIT_VIDEO)
    else
      return 0
    end
  end


  # Take nil, an integer, or an Array of integers. Returns an integer.
  def self.collapse_flags( flags ) # :nodoc:
    case flags
    when Array
      flags.inject(0){ |mem, flag|  mem|flag }
    when Numeric
      flags
    when nil
      0
    else
      raise( ArgumentError, "Wrong type for flags " +
             "(wanted integer, Array, or nil; got #{flags.class})." )
    end
  end

end
