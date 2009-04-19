# 
# Common / utility methods.
# 
#--
# 
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
# 
#++


module Rubygame

  # Warn of a deprecated Rubygame feature.
  def self.deprecated( feature, version ) # :nodoc:
    if $VERBOSE
      warn( "warning: #{feature} is DEPRECATED and will be removed in " + \
            "Rubygame #{version}! Please see the docs for more information." )
    end
  end

end
