#--
#  This file is one part of:
#  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
# 
#  Copyright (C) 2008  John Croisant
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
#++


module Rubygame

  # The Events module contains classes representing various
  # hardware events (e.g. keyboard presses, mouse clicks)
  # and software events (e.g. clock tick, window becomes active)
  # 
  # This event classes are meant as a full replacement for
  # the older event classes defined in the Rubygame module 
  # (e.g. KeyDownEvent, QuitEvent). The old classes are
  # deprecated and should not be used anymore.
  # 
  module Events

    private


    # Convert SDL's ACTIVEEVENT into zero or more of:
    #
    #  InputFocusGained   or  InputFocusLost
    #  MouseFocusGained   or  MouseFocusLost
    #  WindowUnminimized  or  WindowMinimized
    #
    # Returns a ruby Array of the events it generated.
    #
    def self._convert_activeevent( ev )
      
      state = ev.active.state
      gain  = ev.active.gain

      # any_state = SDL::APPACTIVE | SDL::APPINPUTFOCUS | SDL::APPMOUSEFOCUS
      # if( state & any_state == 0 )
      #   raise( Rubygame::SDLError, "Unknown ACTIVEEVENT state #{state}. "+
      #          "This is a bug in Rubygame." )
      # end

      events = []

      if( SDL::APPACTIVE & state )
        if( gain == 1 )
          events << WindowUnminimized.new
        else
          events << WindowMinimized.new
        end
      end

      if( SDL::APPINPUTFOCUS & state )
        if( gain == 1 )
          events << InputFocusGained.new
        else
          events << InputFocusLost.new
        end
      end

      if( SDL::APPMOUSEFOCUS & state )
        if( gain == 1 )
          events << MouseFocusGained.new
        else
          events << MouseFocusLost.new
        end
      end

      return events

    end



    # Convert SDL's joystick axis events into JoystickAxisMoved.
    #
    def self._convert_joyaxisevent( ev )
      joy_id = ev.jaxis.which
      axis   = ev.jaxis.axis
      value  = ev.jaxis.value

      # Convert value to the -1.0 .. 1.0 range
      value = if( value > 0 )
                value / 32767.0
              else
                value / 32768.0
              end

      return JoystickAxismoved.new( joy_id, axis, value )
    end



    # Convert SDL's joystick ball events into JoystickBallMoved.
    #
    def self._convert_joyballevent( ev )
      return JoystickBallmoved.new( ev.jball.which, ev.jball.ball,
                                    [ev.jball.xrel, ev.jball.xrel] )
    end



    # Convert SDL's joystick button events into JoystickButtonPressed or
    # JoystickButtonReleased.
    #
    def self._convert_joybuttonevent( ev )
      case ev.jbutton.state
      when SDL::PRESSED
        JoystickButtonPressed.new( ev.jbutton.which, ev.jbutton.button )
      when SDL::RELEASED
        JoystickButtonReleased.new( ev.jbutton.which, ev.jbutton.button )
      else
        raise( Rubygame::SDLError, "Unknown joystick button state "+
               "#{ev.jbutton.state}. This is a bug in Rubygame." )
      end
    end



    # Convert SDL's joystick hat events into JoystickHatMoved.
    #
    def self._convert_joyhatevent( ev )
      dir = case ev.jhat.value
            when SDL::HAT_RIGHTUP;    :up_right
            when SDL::HAT_RIGHTDOWN;  :down_right
            when SDL::HAT_LEFTUP;     :up_left
            when SDL::HAT_LEFTDOWN;   :down_left
            when SDL::HAT_UP;         :up
            when SDL::HAT_RIGHT;      :right
            when SDL::HAT_DOWN;       :down
            when SDL::HAT_LEFT;       :left
            else;                     nil
            end

      return JoystickHatmoved.new( ev.jhat.which, ev.jhat.hat, dir )
    end



  end

end


# Load all the ruby files in events/
glob = File.join( File.dirname(__FILE__), "events", "*.rb" )
Dir.glob( glob ).each do |path|
  require path
end
