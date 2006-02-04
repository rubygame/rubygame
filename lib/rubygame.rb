#--
#  Rubygame -- Ruby bindings to SDL to facilitate game creation
#  Copyright (C) 2004-2005  John 'jacius' Croisant
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++

# This is the file that should be imported, it in turn imports rubygame.so
# (which has all of the C code for rubygame) and all the other rubygame modules

require "rbconfig"

require "rubygame.%s"%[Config::CONFIG["DLEXT"]]

require "rubygame/constants"
require "rubygame/event"
require "rubygame/queue"
require "rubygame/rect"
require "rubygame/sprite"
require "rubygame/clock"
require "rubygame/sfont"
require "rubygame/string"
