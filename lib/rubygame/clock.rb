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
    # You can calibrate this easily with #calibrate_granularity.
    # See also #tick and Clock.delay. Default 12.
    attr_accessor :granularity

    # Whether to try to let other ruby threads run during framerate
    # limiting delays in #tick. See #tick and Clock.delay.
    # Default false.
    attr_accessor :nice


    # Create a new Clock instance.
    def initialize()
      @start = self.class.runtime()
      @last_tick = nil
      @ticks = 0

      @target_frametime = nil

      # Frametime samples for framerate calculation
      @samples = []
      @max_samples = 20

      @granularity = 12
      @nice = false

      # Should #tick return a ClockTicked event?
      @tick_events = false

      # Cache for past tick events with specific ms values
      @tick_cache = {}

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
    # max test time, but will not run longer. Also, the default
    # max_time may be lowered in future versions, but will not be
    # raised.
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
    # instance instead of a number of milliseconds.
    # 
    # This option is available starting in Rubygame 2.5, and will
    # become the default in Rubygame 3.0.
    # 
    def enable_tick_events
      @tick_events = true
    end


    # Returns the current target frametime (milliseconds/frame),
    # or nil if there is no target.
    # 
    # This is another way to access #target_framerate.
    # Same as: 1000.0 / #target_framerate
    # 
    def target_frametime
      @target_frametime
    end


    # Sets the target milliseconds per frame to +frametime+.
    # If +frametime+ is nil, the target is unset, and #tick
    # will no longer apply any delay.
    # 
    # This is another way to access #target_framerate.
    # Same as: #target_framerate = 1000.0 / frametime
    # 
    def target_frametime=( frametime )
      @target_frametime = frametime
    end


    # Returns the current target framerate (frames/second),
    # or nil if there is no target.
    # 
    # This is another to access #target_frametime.
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
    # If +framerate+ is nil, the target is unset, and #tick
    # will no longer apply any delay.
    # 
    # This is another way to access #target_frametime.
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


    # call-seq:
    #   frametime  ->  Float
    # 
    # Return the actual frametime (milliseconds per frame) recorded by
    # the Clock. See #tick.
    # 
    def frametime
      @samples.inject(0){|sum, n| sum + n} / (@samples.length)
    rescue ZeroDivisionError
      0.0
    end


    # Returns the number of milliseconds since you last called this
    # method. Or, if you have called #enable_tick_events, this returns
    # a ClockTicked event representing the time since you last called
    # this method. (ClockTicked was added in Rubygame 2.5, and will
    # become the default and only option in Rubygame 3.0.)
    # 
    # You must call this method once per frame (i.e. per iteration
    # of your main loop) if you want to use the framerate monitoring
    # and/or framerate limiting features.
    # 
    # Framerate monitoring allows you to check the #framerate (frames
    # per second) or #frametime (milliseconds per frame) of your game.
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
    # #granularity and #nice. These are passed as parameters to
    # Clock.delay for the brief pause each frame. See Clock.delay for
    # the effects of those parameters on CPU usage and threading.
    # 
    # (Please note that no effort is made to correct a framerate which
    # is *slower* than the target framerate. Clock can't make your
    # code run faster, only slow it down if it is running too fast.)
    # 
    def tick()

      # how long since the last tick?
      passed = 0
      if @last_tick
        passed += self.class.runtime() - @last_tick
      end

      if @target_frametime
        extra = @target_frametime - passed
        if( extra > 0 )
          passed += self.class.delay( extra, @granularity, @nice )
        end
      end

      if @tick_events
        return (@tick_cache[passed] or 
                 (@tick_cache[passed] =
                  Rubygame::Events::ClockTicked.new( passed ) ))
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
