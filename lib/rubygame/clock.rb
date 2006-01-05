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
		# Clock provides an interface to the Time module methods, yielding a
		# more convenient way to monitor and limit application framerate.
		# 
		class Clock
			attr_reader :start,:passed,:raw_passed,:ticks	# :nodoc:

			# call-seq: new(desired_fps=nil)  ->  Clock
			# 
			# Create a new Clock.
			# 
			# This method takes this argument:
			# desired_fps:: the desired frames per second, used to limit framerate; 
			#               if +false+ or +nil+ (default), no limiting will occur.
			#               Use the accessor @desired_fps to set or modify this value
			#               after the Clock has been initialized. See #tick
			def initialize(desired_fps=nil)
				@start = Rubygame::Time.get_ticks()
				@last_tick = @start	# time that last tick occured
				@passed = 0		# time (ms) since last tick
				@raw_passed = 0	# @passed, before applying delay to steady FPS
				@ticks = 0 # incremented every time Clock#tick is called
				@desired_fps=desired_fps # frames per second to delay for
			end

			# Access the desired number of frames per second. If this is set,
			# #tick will add a small delay to each frame to slow down
			# execution if it is running faster than this value.
			# If +nil+ or +false+, no slowdown will be made to execution.
			attr_accessor :desired_fps

			# call-seq: desired_mspf()  ->  Numeric
			#
			# Return the desired time (milliseconds) per frames. This is the same
			# as 1000.0/@desired_fps.
			def desired_mspf
				@desired_fps and (1000.0/@desired_fps)
			end

			# call-seq: desired_mspf=(dmspf)  ->  Numeric
			# 
			# Set the desired time (milliseconds) per frames. If this is 
			# set, #tick will add a small delay to each frame to slow 
			# down execution if the natural delay between frames is too small.
			# If +nil+ or +false+, no slowdown will be made to execution.
			# 
			# This is an alternative to setting @desired_fps directly. You can
			# get exactly the same effect by setting @desired_fps to 1000.0/dmspf.
			def desired_mspf=(dmspf)
				@desired_fps = (dmspf and 1000.0/dmspf)
			end

 			# call-seq: time()  ->  Numeric
			# 
			# Returns time in milliseconds since this Clock was initialized
			def time
				@last_tick - @start
			end

			# call-seq: fps()  ->  Numeric
			# 
			# Return frames per second (fps) recorded by the Clock
			def fps
				begin
					return 1000*@ticks / (@last_tick - @start)
				rescue ZeroDivisionError
					return 0
				end
			end

			# call-seq: tick()  ->  Numeric
			# 
			# Call this function once per frame to use framerate tracking.
			# Returns the number of milliseconds since the last time you
			# called the function.
			# 
			# If @desired_fps is set, this function will delay execution for a
			# certain amount of time so that (if you call this function once
			# per frame) the program will run at that framerate.
			# 
			# The accuracy of this method is less than perfect (for me, it runs
			# about 5-15 fps too quickly if the desired fps is less than 100 or so),
			# but it's still useful.
			# 
			# (Please note that no effort is made to correct a framerate
			# which is *slower* than the desired framerate, i.e. it can't
			# make your code run any faster, only slow it down if it is
			# running too quickly.)
			def tick()
				now = Rubygame::Time.get_ticks() # ms since init'd Rubygame
 				@passed = now - @last_tick # how long since the last tick?
 				@last_tick = now # update last tick time
				@ticks += 1		# increment ticks
				@raw_passed = @passed # save unadjusted @passed

				# Now we manually delay if we are too early, so the 
				# frames per second stays approx. at the desired rate.
				if @desired_fps and (self.fps() > @desired_fps)
					goal_delay = (1000.0/@desired_fps) - @passed
					unless goal_delay < 0 # which would mean we're too slow
						actual_delay = Rubygame::Time.delay(goal_delay)
						@passed += actual_delay	# why @raw_passed is different
					# else we are running too slow anyway, can't un-delay
					end
				end
				return @passed
			end

		end # class Clock
	end # module Time
end #module Rubygame
