#
#	Rubygame -- Ruby bindings to SDL to facilitate game creation
#	Copyright (C) 2004  John 'jacius' Croisant
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

module Rubygame
	module Time
		class Clock
			def initialize
				@last_tick = Rubygame::Time.get_ticks()
				@passed = 0
				@raw_passed = 0
				@ticks = 0
				@time = 0
			end

			def fps
				begin
					return 1000*@ticks/@time
				rescue ZeroDivisionError
					return 0
				end
			end

			def tick(fps_limit=nil)
				now = Rubygame::Time.get_ticks()
				@passed = now - @last_tick
				@last_tick = now
				@ticks += 1
				@time += @passed
				@raw_passed = @passed
				fps = self.fps
				extra = 0
				if fps_limit and fps > fps_limit
					#print "before: %d "%[@passed]

					extra = 1000.0/fps_limit - @passed
					if extra < 0 or extra > 100
						raise(StandardError,"whoa, that's a weird extra! (%d)"%extra)
					else
						extra = Rubygame::Time.delay( extra)
					end
					@passed += extra
					@time += extra

					# old, bad way:
					#@passed = Rubygame::Time.delay( (fps/limit - 1) * @passed)

					#print "after: %d\n"%[@passed]
				end
				#puts "%d, time: %5.2f, passed: %d (%d + %d)"%[@ticks,@time,@passed,@raw_passed,extra]
				return @passed
			end
		end # class Clock
	end # module Time
end #module Rubygame
