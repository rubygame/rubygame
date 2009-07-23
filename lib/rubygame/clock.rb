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
  # An in-depth tutorial on using Clock is available. See
  # doc/managing_framerate.rdoc[link:files/doc/managing_framerate_rdoc.html]
  # in the Rubygame source distribution or in the online
  # documentation.
  # 
  class Clock

    class << self

      # time::  The target delay time, in milliseconds.
      #         (Non-negative integer. Required.)
      # gran::  The assumed granularity (in ms) of the system clock.
      #         (Non-negative integer. Optional. Default: 12.)
      # nice::  If true, try to let other ruby threads run during the delay.
      #         (true or false. Optional. Default: false.)
      #
      # Returns:: The actual delay time, in milliseconds.
      #
      # Pause the program for +time+ milliseconds. This function is more
      # accurate than Clock.wait, but uses slightly more CPU time. Both
      # this function and Clock.wait can be used to slow down the
      # framerate so that the application doesn't use too much CPU time.
      # See also Clock#tick for a good and easy way to limit the
      # framerate.
      #
      # This function uses "busy waiting" during the last part
      # of the delay, for increased accuracy. The value of +gran+ affects
      # how many milliseconds of the delay are spent in busy waiting, and thus
      # how much CPU it uses. A smaller +gran+ value uses less CPU, but if
      # it's smaller than the true system granularity, this function may
      # delay a few milliseconds too long. The default value (12ms) is very
      # safe, but a value of approximately 5ms would give a better balance
      # between accuracy and CPU usage on most modern computers.
      # A granularity of 0ms makes this method act the same as Clock.wait
      # (i.e. no busy waiting at all, very low CPU usage).
      #
      # If +nice+ is true, this function will try to allow other ruby
      # threads to run during this function. Otherwise, other ruby threads
      # will probably also be paused. Setting +nice+ to true is only
      # useful if your application is multithreaded. It's safe (but
      # pointless) to use this feature for single threaded applications.
      #
      # The Rubygame timer system will be initialized when you call this
      # function, if it has not been already. See Clock.runtime.
      #
      def delay( time, gran=12, nice=false )
        _init_sdl_timer
        time = 0 if time < 0
        gran = 0 if gran < 0
        _accurate_delay( time, gran, nice )
      end


      # time::  The target wait time, in milliseconds.
      #         (Non-negative Integer. Required.)
      # nice::  If true, try to let other ruby threads run during the delay.
      #         (true or false. Optional.)
      #
      # Returns:: The actual wait time, in milliseconds.
      #
      # Pause the program for approximately +time+ milliseconds. Both this
      # function and Clock.delay can be used to slow down the framerate so
      # that the application doesn't use too much CPU time. See also
      # Clock#tick for a good and easy way to limit the framerate.
      #
      # The accuracy of this function depends on processor scheduling,
      # which varies with operating system and hardware. The actual delay
      # time may be up to 10ms longer than +time+. If you need more
      # accuracy use Clock.delay, which is more accurate but uses slightly
      # more CPU time.
      #
      # If +nice+ is true, this function will try to allow other ruby
      # threads to run during this function. Otherwise, other ruby threads
      # will probably also be paused. Setting +nice+ to true is only
      # useful if your application is multithreaded. It's safe (but
      # pointless) to use this feature for single threaded applications.
      #
      # The Rubygame timer system will be initialized when you call this
      # function, if it has not been already. See Clock.runtime.
      #
      def wait( time, nice=false )
        _init_sdl_timer
        time = 0 if time < 0
        _threaded_delay( time, nice )
      end


      # Return the number of milliseconds since the Rubygame timer
      # system was initialized.
      #
      # The Rubygame timer system will be initialized when you call
      # this function, if it has not been already.
      #
      def runtime
        SDL.GetTicks().to_i
      end



      private


      # Initialize the SDL timer system, if it hasn't been already.
      def _init_sdl_timer
        if( SDL.WasInit( SDL::INIT_TIMER ) == 0 )
          if( SDL.InitSubSystem( SDL::INIT_TIMER ) != 0)
            raise( Rubygame::SDLError,
                   "Could not initialize timer system: #{SDL.GetError()}" )
          end
        end
      end


      # Delays for the given amount of time, but possibly split into
      # small parts. Control is given to ruby between each part, so
      # that other threads can run.
      #
      # delay: How many milliseconds to delay.
      # nice:  If true, split the delay into smaller parts and
      #        allow other ruby threads to run between each part.
      #
      def _threaded_delay( delay, nice )
        start = SDL.GetTicks()
        stop = start + delay

        if nice
          while( SDL.GetTicks() < stop )
            SDL.Delay(1)
          end
        else
          SDL.Delay( delay.to_i )
        end

        return (SDL.GetTicks() - start).to_i
      end


      # Based on pygame code, with a few modifications:
      #   - takes 'accuracy' argument
      #   - ruby syntax for raising exceptions
      #   - uses rg_threaded_delay
      #
      def _accurate_delay( ticks, accuracy, nice )
        return _threaded_delay( ticks, nice ) if( accuracy <= 0 )

        start = SDL.GetTicks()

        if( ticks >= accuracy )
          delay = ticks - (ticks % accuracy)
          delay -= 2  # Aim low so we don't overshoot.

          if( delay >= accuracy and delay > 0 )
            _threaded_delay( delay, nice )
          end
        end

        delay = ticks - (SDL.GetTicks() - start)
        while( delay > 0 )
          delay = ticks - (SDL.GetTicks() - start)
        end

        return (SDL.GetTicks() - start).to_i
      end

    end




    # The runtime when the Clock was initialized.
    attr_reader :start

    # The number of times #tick has been called.
    attr_reader :ticks


    # Granularity used for framerate limiting delays in #tick.
    # You can calibrate this easily with #calibrate.
    # See also #tick and Clock.delay.
    # (Non-negative integer. Default: 12.)
    attr_accessor :granularity

    # Whether to try to let other ruby threads run during framerate
    # limiting delays in #tick. See #tick and Clock.delay.
    # (true or false. Default: false.)
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


    # Calibrate some Clock settings to match the current computer.
    # This improves efficiency and minimizes CPU usage without
    # reducing accuracy.
    # 
    # As of Rubygame 2.5, this method calibrates @granularity. See
    # #tick and Clock.delay for more information about the effect of
    # setting granularity. In future versions of Rubygame, this
    # method may also calibrate additional Clock attributes.
    # 
    # By default, the calibration takes a maximum of 0.5 seconds to
    # complete. You can specify a different maximum length by passing
    # a different value for +max_time+. In future versions of
    # Rubygame, calibration may take less than max_time, but will
    # not take more. Also, the default max_time may be lowered in
    # future versions, but will not be raised.
    # 
    # You usually only need to call this once, after you create the
    # Clock instance at the start of your application. You should not
    # run any other ruby threads at the same time, as doing so will
    # skew the calibration.
    # 
    #--
    # 
    # I'm not 100% sure that this is a valid way to measure
    # granularity, or that the granularity of ruby sleep is
    # always the same as that of SDL_Delay. But it can be
    # improved later if needed...
    #
    #++
    def calibrate( max_time = 0.5 )
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

      return nil
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
      sum = @samples.inject(0){|sum, n| sum + n}
      if sum == 0
        return 0.0
      else
        1000.0 * @samples.length / sum
      end
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
