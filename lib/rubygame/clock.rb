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

	class TickEvent
		attr_accessor :seconds, :created_at
		def initialize( seconds )
			@seconds = seconds
			@created_at = Time.now
		end
		
		def milliseconds
			@seconds * 1000.0
		end
		
		def milliseconds=( milliseconds )
			@seconds = milliseconds / 1000.0
		end
	end
	
		#  Clock provides class methods for tracking running time and delaying
		#  execution of the program for specified time periods. This is used to
		#  provide a consistent framerate, prevent the program from using
		#  all the processor time, etc.
		# 
		#  Clock also provides instance methods to make it convenient to
		#  monitor and limit application framerate. See #tick.
		class Clock


			#  call-seq:
			#    Clock.wait( delay )  ->  actual_delay
			# 
			#  delay::   [required Numeric]
			#            how many seconds it should try to pause for
			#  Returns:: [Float]
			#            how many seconds it actually did pause for
			#
			#  Pauses execution of the current thread for approximately +delay+
			#  seconds. Because of processor scheduling, it will pause for slightly
			#  longer than asked (by a few milliseconds or so).
			# 
			#  See Clock.delay for a more precise (but slightly more CPU-expensive)
			#  method.
			def self.wait(time)
				return 0.0 if time < 0.0
				start = Time.now
				sleep(time)
				return Time.now - start
			end

			#  call-seq:
			#    Clock.delay( delay )  ->  actual_delay
			# 
			#  delay::   [required Numeric]
			#            how many seconds it should try to pause for
			#  Returns:: [Float]
			#            how many seconds it actually did pause for
			#
			#  Pauses execution of the current thread for approximately +delay+
			#  seconds.
			# 
			#  This method achieves greater precision than Clock.wait by
			#  using 'busy waiting' (spinlock) for the final part of the delay.
			#  Because of that, this method uses slightly more CPU time than
			#  Clock.wait.
			def self.delay(time)
				return 0.0 if time < 0.0
				start = Time.now
				sleep( time - (time % 0.001) )
				while (Time.now - start) < time;
				end
				return Time.now - start
			end

			# The runtime when the Clock was initialized.
			attr_reader :start
			# The number of times #tick has been called.
			attr_reader :ticks
			# The time #tick has been called the last time.
			attr_reader :last_tick        
			# The target frametime (seconds/frame). See #tick
			attr_accessor :target_frametime

			# Create a new Clock instance.
			def initialize()
				@start = Time.now
				@last_tick = @start
				@ticks = 0
				@samples = [0.0]*20
				@target_frametime = nil
				yield self if block_given?
			end


			# Returns the current target framerate (frames/second).
			# This is an alternate way to access @target_frametime.
			# Same as: 1.0 / #target_frametime
			def target_framerate
				if @target_frametime
					1.0 / @target_frametime
				else
					nil
				end
			rescue ZeroDivisionError
				return nil
			end

			# Sets the target number of frames per second to +framerate+.
			# This is an alternate way to access @target_frametime.
			# Same as: #target_frametime = 1.0 / framerate
			def target_framerate=( framerate )
				if framerate
					@target_frametime = 1.0 / framerate
				else
					@target_frametime = nil
				end
			rescue ZeroDivisionError
				@target_frametime = nil
			end

			# call-seq: lifetime()  ->  Numeric
			# 
			# Returns time in seconds since this Clock instance was created.
			def lifetime
				Time.now - @start
			end

			# call-seq: framerate()  ->  Numeric
			# 
			# Return the actual framerate (frames per second) recorded by the Clock.
			# See #tick.
			def framerate
				@samples.length / @samples.inject(0) {|sum, n| sum + n} 
			end

			# Returns the number of seconds since you last called this method.
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
				# how long since the last tick?
				passed = Time.now - @last_tick
				if @target_frametime
					passed += Clock.delay(@target_frametime - passed)
				end
				return TickEvent.new(passed)
			ensure
				@last_tick = Time.now
				@ticks += 1
				@samples.shift
				@samples.push(passed)
			end

			# A global Clock, useful for default values as most timings are global.
			World = Clock.new
		end # class Clock
end #module Rubygame
