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
		#  Clock provides class methods for tracking running time and delaying
		#  execution of the program for specified time periods. This is used to
		#  provide a consistent framerate, prevent the program from using
		#  all the processor time, etc.
		# 
		#  Clock also provides instance methods to make it convenient to
		#  monitor and limit application framerate. See #tick.
		class Clock
			# The runtime when the Clock was initialized.
			attr_reader :start        
			# The number of times #tick has been called.
			attr_reader :ticks        

			# Create a new Clock instance.
			def initialize()
				@start = Clock.runtime()
				@last_tick = @start
				@ticks = 0
				@target_frametime = nil
				yield self if block_given?
			end

			# The target frametime (milliseconds/frame). See #tick
			attr_accessor :target_frametime

			# Returns the current target framerate (frames/second).
			# This is an alternate way to access the #target_frametime.
			# Same as: 1000.0 / #target_frametime
			def target_framerate
				if @target_frametime
					1000.0 / @target_frametime
				else
					nil
				end
			rescue ZeroDivisionError
				return nil
			end

			# Sets the target number of frames per second to +framerate+.
			# This is an alternate way to access the #target_frametime.
			# Same as: #target_frametime = 1000.0 / framerate
			def target_framerate=( framerate )
				if framerate
					@target_frametime = 1000.0 / framerate
				else
					@target_frametime = nil
				end
			rescue ZeroDivisionError
				@target_frametime = nil
			end

			# call-seq: lifetime()  ->  Numeric
			# 
			# Returns time in milliseconds since this Clock instance was created.
			def lifetime
				@last_tick - @start
			end

			# call-seq: framerate()  ->  Numeric
			# 
			# Return the actual framerate (frames per second) recorded by the Clock.
			# See #tick.
			# 
			# TODO: sample only a few seconds in the past, instead of the
			# entire lifetime of the Clock. 
			def framerate
				# below is same as: return @ticks / (lifetime / 1000.0)
				return 1000.0 * @ticks / lifetime
			rescue ZeroDivisionError
				return 0
			end

			# Returns the number of milliseconds since you last called this method.
			# 
			# You must call this method once per frame (i.e. per iteration of
			# your main loop) if you want to use the framerate monitoring and/or
			# framerate limiting features.
			# 
			# Framerate monitoring allows you to check the framerate (frames per
			# second) with the #framerate method.
			# 
			# Framerate limiting allows you to prevent the application from running
			# too fast (and using 100% of processor time) by pausing the program
			# very briefly each frame. The pause duration is calculated each frame
			# to maintain a constant framerate.
			# 
			# Framerate limiting is only enabled if you have set the
			# #target_framerate= or #target_frametime=.
			# If you have done that, this method will automatically perform the
			# delay each time you call it.
			# 
			# (Please note that no effort is made to correct a framerate
			# which is *slower* than the target framerate. Clock can't
			# make your code run faster, only slow it down if it is
			# running too fast.)
			def tick()
				passed = Clock.runtime - @last_tick  # how long since the last tick?
				if @target_frametime
					return Clock.delay(@target_frametime - passed) + passed
				end
				return passed
			ensure
				@last_tick = Clock.runtime()
				@ticks += 1
			end

		end # class Clock
end #module Rubygame
