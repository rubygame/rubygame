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

  class DeprecationError < RuntimeError # :nodoc:
  end

  # Warn about a deprecated Rubygame feature. The behavior of this
  # method is influenced by the value of ENV["RUBYGAME_DEPRECATED"]:
  # 
  # (default):: Print a warning with Kernel.warn the first time each
  #             deprecated feature is used. Note that Kernel.warn is
  #             silent unless warnings are enabled (e.g. -W flag).
  # 
  # "warn"::    Print a warning on STDERR the first time each
  #             deprecated feature is used.
  # 
  # "warn!"::   Print a warning on STDERR every time a deprecated
  #             feature is used.
  # 
  # "error"::   Raise Rubygame::DeprecationError the first time each
  #             deprecated feature is used.
  # 
  # "error!"::  Raise Rubygame::DeprecationError every time a
  #             deprecated feature is used.
  # 
  # "quiet"::   Never warn when any deprecated feature is used.
  # 
  def self.deprecated( feature, version=nil, info=nil) # :nodoc:
    @deprec_warned ||= {}

    config = ENV["RUBYGAME_DEPRECATED"]
    return if /^quiet$/i =~ config

    if( /^(error!|warn!)$/i =~ config || !@deprec_warned[feature] )
      message =
        "#{feature} is DEPRECATED and will be removed in " +
        (version ? "Rubygame #{version}" : "a future version of Rubygame") +
        "! " + (info || "Please see the docs for more information.")

      case config
      when /^error!?$/i
        raise Rubygame::DeprecationError.new(message)
      when /^warn!?$/i
        STDERR.puts 'warning: ' + message
      else
        Kernel.warn 'warning: ' + message
      end

      @deprec_warned[feature] = true
    end

    nil
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
