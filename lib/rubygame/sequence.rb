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

module Rubygame
	class Sequence
		# 
		def self.glob(glob, delay=nil, position=nil, surface=nil)
			new(Dir[glob], delay, position, surface)
		end

		def self.rglob(glob, delay=nil, position=nil, surface=nil)
			new(Dir[glob].reverse, delay, position, surface)
		end

		def initialize(sequence, delay=nil, position=nil, surface=nil)
			@sequence = sequence.map { |path|
				Rubygame::Surface.load_image(path).to_display_alpha
			}
			@size     = sequence.size
			@index    = 0
			@on       = on
			@pos      = pos
		end
		
		
		
		def update(
		end
	
		def draw_next(on=nil, pos=nil)
			@index = (@index+1)%  @size
			@sequence[@index].blit(on||@on,pos||@pos)
			@index
		end
	
		def get_next(on=nil, pos=nil)
			@index = (@index+1)%  @size
			@sequence[@index]
		end
	end
end