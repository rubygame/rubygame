#!/usr/bin/env ruby

#--
# This program is released to the PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#++
# 
# This is a simple demonstration of "framerate independence".
# The speed of gameplay is defined independently of the framerate
# of the game, i.e. as pixels per second instead of pixels per frame.
# 
# You can read more about framerate independence and how to use Clock
# in doc/managing_framerate.rdoc.
# 


require "rubygame"

# How fast the Mover moves. (pixels per second)
$mover_speed = 30

# How fast to run the app. (frames per second)
$framerate = 20

# How long to run the app. (seconds)
$run_time = 1.0



class Mover

  def initialize()

    # Define the Mover's speed.
    @speed = $mover_speed

    # Define the initial position of the Mover.
    @position = 0

  end


  # This method will be called once per frame to update the
  # Mover's position. tick_event will be a ClockTicked instance.
  # 
  def update( tick_event )

    # Calculate how far it moved this frame.
    # @speed is defined in pixels per second, so we use tick.seconds.
    change = @speed * tick_event.seconds

    # Apply the movement.
    move_by( change, tick_event.seconds )

  end


  # This method updates the Mover's position and outputs a
  # message to the user, for demonstration purposes.
  #   
  def move_by( change, seconds )

    # Temporarily store the old position, for the message.
    old_pos = @position

    # Update position.
    @position += change

    # Calculate the actual speed, for the message.
    actual_speed = change / seconds

    # Calculate the framerate (frames per second) for the message.
    framerate = 1.0 / seconds

    puts( "Moved from #{old_pos} to #{@position} " +
          "(diff: #{change}) in #{seconds} sec (#{framerate} FPS). " +
          "Speed: #{actual_speed}" )

  end

end # class Mover



def main_loop

  # Create and configure the Clock
  clock = Rubygame::Clock.new
  clock.target_framerate = $framerate
  clock.enable_tick_events

  puts "Calibrating..."
  clock.calibrate

  # Create the Mover
  mover = Mover.new


  puts "Go!"

  # Find out when the app should stop.
  stop_time = Time.now + $run_time

  until( Time.now >= stop_time )

    # Tick the clock. Returns a ClockTicked instance
    # telling us how long this frame was.
    tick_event = clock.tick

    # Update the Mover.
    mover.update( tick_event )

  end

end


main_loop()
