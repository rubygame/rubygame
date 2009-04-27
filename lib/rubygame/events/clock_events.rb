#--
#  This file is one part of:
#  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#
#  Copyright (C) 2009  John Croisant
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
# ++


module Rubygame

  module Events

    # ClockTicked is an event returned by Clock#tick, if the Clock
    # has been configured with Clock#enable_tick_events.
    # 
    # ClockTicked stores the time that has passed since the previous
    # tick. You can access that information with #seconds or
    # #milliseconds. This is useful to calculate how far a character
    # should move during the current frame, for example.
    # 
    class ClockTicked

      # Create a new ClockTicked event.
      # 
      # milliseconds::  The time since the last tick,
      #                 in milliseconds. (Numeric, required)
      # 
      def initialize( milliseconds )
        @milliseconds = milliseconds
      end

      # Return the time since the last tick, in milliseconds.
      def milliseconds
        @milliseconds
      end

      # Return the time since the last tick, in seconds.
      def seconds
        @seconds or (@seconds = @milliseconds * 0.001)
      end
    end

  end
end
