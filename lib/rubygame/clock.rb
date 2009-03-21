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


require "rubygame/events/clock_events"


module Rubygame


  # Clock provides class methods for tracking running time and delaying
  # execution of the program for specified time periods. This is used to
  # provide a consistent framerate, prevent the program from using
  # all the processor time, etc.
  # 
  # Clock also provides instance methods to make it convenient to
  # monitor and limit application framerate. See #tick.
  # 
  class Clock

    # The runtime when the Clock was initialized.
    attr_reader :start

    # The number of times #tick has been called.
    attr_reader :ticks


    # Granularity used for framerate limiting delays in #tick.
    # See #tick and Clock.delay. Default 12.
    attr_accessor :granularity

    # Yield time used for framerate limiting delays in #tick.
    # See #tick and Clock.delay. Default false.
    attr_accessor :yield


    # Create a new Clock instance.
    def initialize()
      @start = self.class.runtime()
      @last_tick = @start
      @ticks = 0

      @target_frametime = nil

      # Frametime samples for framerate calculation
      @samples = []
      @max_samples = 20

      @granularity = 12
      @yield = false

      # Should #tick return a ClockTicked event?
      @tick_events = false

      yield self if block_given?
    end


    # Calibrate @granularity to an appropriate value for this
    # computer, to minimize CPU usage without reducing accuracy.
    # See #tick and Clock.delay for more information about
    # granularity.
    # 
    # By default, the calibration process takes at most 0.5 seconds.
    # You can specify a different maximum test length changed by 
    # providing a different value for +max_time+.
    # In future versions, the process may complete earlier than the
    # max test time, but will not run longer.
    #
    # You usually only need to call this once, after you create the
    # clock at the start of your application. You should not run any
    # other ruby threads at the same time, as doing so will skew the
    # calibration.
    # 
    #--
    # 
    # I'm not 100% sure that this is a valid way to measure
    # granularity, or that the granularity of ruby sleep is
    # always the same as that of SDL_Delay. But it can be
    # improved later if needed...
    #
    #++
    def calibrate_granularity( max_time = 0.5 )
      samples = []

      end_time = Time.now + max_time

      while( Time.now < end_time )
        t = Time.now
        sleep 0.01
        samples << (Time.now - t - 0.01)
      end

      average = samples.inject{|sum,n| sum + n} / samples.length

      # convert to ms, add some padding
      gran = (average * 1000).to_i + 1

      @granularity = gran
    end


    # Enable tick events, so that #tick will return a ClockTicked
    # instance instead of a number of milliseconds. ClockTicked
    # 
    # 
    # This option is available starting in Rubygame 2.5, and will
    # become the default in Rubygame 3.0.
    # 
    def enable_tick_events
      @tick_events = true
    end


    # The target frametime (milliseconds/frame). See #tick
    attr_accessor :target_frametime


    # Returns the current target framerate (frames/second).
    # This is an alternate way to access @target_frametime.
    # Same as: 1000.0 / #target_frametime
    # 
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
    # This is an alternate way to access @target_frametime.
    # Same as: #target_frametime = 1000.0 / framerate
    # 
    def target_framerate=( framerate )
      if framerate
        @target_frametime = 1000.0 / framerate
      else
        @target_frametime = nil
      end
    rescue ZeroDivisionError
      @target_frametime = nil
    end


    # call-seq:
    #   lifetime  ->  Integer
    # 
    # Returns time in milliseconds since this Clock instance was created.
    # 
    def lifetime
      self.class.runtime() - @start
    end


    # call-seq:
    #   framerate  ->  Float
    # 
    # Return the actual framerate (frames per second) recorded by the
    # Clock. See #tick.
    # 
    def framerate
      1000.0 * @samples.length / @samples.inject(0){|sum, n| sum + n}
    rescue ZeroDivisionError
      0.0
    end


    # Returns the number of milliseconds since you last called this
    # method.
    # 
    # You must call this method once per frame (i.e. per iteration
    # of your main loop) if you want to use the framerate monitoring
    # and/or framerate limiting features.
    # 
    # Framerate monitoring allows you to check the framerate (frames
    # per second) with the #framerate method.
    # 
    # Framerate limiting allows you to prevent the application from
    # running too fast (and using 100% of processor time) by pausing
    # the program very briefly each frame. The pause duration is
    # calculated each frame to maintain a stable framerate.
    # 
    # Framerate limiting is only enabled if you have set the
    # #target_framerate= or #target_frametime=. If you have done that,
    # this method will automatically perform the delay each time you
    # call it.
    # 
    # There are two other attributes which affect framerate limiting,
    # #granularity and #yield. These are passed as parameters to
    # Clock.delay for the brief pause each frame. See Clock.delay for
    # the effects of those parameters on CPU usage and threading.
    # 
    # (Please note that no effort is made to correct a framerate which
    # is *slower* than the target framerate. Clock can't make your
    # code run faster, only slow it down if it is running too fast.)
    # 
    def tick()

      # how long since the last tick?
      passed = self.class.runtime() - @last_tick

      if @target_frametime
        passed += self.class.delay(@target_frametime - passed,
                                   @granularity,
                                   @yield)
      end

      if @tick_events
        return Rubygame::Events::ClockTicked.new( passed )
      else
        return passed
      end

    ensure
      @last_tick = self.class.runtime()
      @ticks += 1

      # Save the frametime for framerate calculation
      @samples.push(passed)
      @samples.shift if @samples.length > @max_samples
    end

  end

end
