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



    # Returns a sanitized symbol for the given key.
    #
    def self._convert_key_symbol( key )
      init_video_system

      name = case key
             when SDL::K_1;             "number 1"
             when SDL::K_2;             "number 2"
             when SDL::K_3;             "number 3"
             when SDL::K_4;             "number 4"
             when SDL::K_5;             "number 5"
             when SDL::K_6;             "number 6"
             when SDL::K_7;             "number 7"
             when SDL::K_8;             "number 8"
             when SDL::K_9;             "number 9"
             when SDL::K_0;             "number 0"
             when SDL::K_EXCLAIM;       "exclamation mark"
             when SDL::K_QUOTEDBL;      "double quote"
             when SDL::K_HASH;          "hash"
             when SDL::K_DOLLAR;        "dollar"
             when SDL::K_AMPERSAND;     "ampersand"
             when SDL::K_QUOTE;         "quote"
             when SDL::K_LEFTPAREN;     "left parenthesis"
             when SDL::K_RIGHTPAREN;    "right parenthesis"
             when SDL::K_ASTERISK;      "asterisk"
             when SDL::K_PLUS;          "plus"
             when SDL::K_MINUS;         "minus"
             when SDL::K_PERIOD;        "period"
             when SDL::K_COMMA;         "comma"
             when SDL::K_SLASH;         "slash"
             when SDL::K_SEMICOLON;     "semicolon"
             when SDL::K_LESS;          "less than"
             when SDL::K_EQUALS;        "equals"
             when SDL::K_GREATER;       "greater than"
             when SDL::K_QUESTION;      "question mark"
             when SDL::K_AT;            "at"
             when SDL::K_LEFTBRACKET;   "left bracket"
             when SDL::K_BACKSLASH;     "backslash"
             when SDL::K_RIGHTBRACKET;  "right bracket"
             when SDL::K_CARET;         "caret"
             when SDL::K_UNDERSCORE;    "underscore"
             when SDL::K_BACKQUOTE;     "backquote"
             when SDL::K_KP1;           "keypad 1"
             when SDL::K_KP2;           "keypad 2"
             when SDL::K_KP3;           "keypad 3"
             when SDL::K_KP4;           "keypad 4"
             when SDL::K_KP5;           "keypad 5"
             when SDL::K_KP6;           "keypad 6"
             when SDL::K_KP7;           "keypad 7"
             when SDL::K_KP8;           "keypad 8"
             when SDL::K_KP9;           "keypad 9"
             when SDL::K_KP0;           "keypad 0"
             when SDL::K_KP_PERIOD;     "keypad period"
             when SDL::K_KP_DIVIDE;     "keypad divide"
             when SDL::K_KP_MULTIPLY;   "keypad multiply"
             when SDL::K_KP_MINUS;      "keypad minus"
             when SDL::K_KP_PLUS;       "keypad plus"
             when SDL::K_KP_EQUALS;     "keypad equals"
             when SDL::K_KP_ENTER;      "keypad enter"
             else;                      SDL::GetKeyName( key )
             end

      name.downcase!
      name.gsub!(/[- ]/, "_")
      return name.to_sym
    end



    # Convert an OR'd list of KMODs into an Array of symbols.
    #
    def self._convert_keymods( mods )
      return [] if mods == 0

      array = []
      array << :left_shift   if( mods & SDL::KMOD_LSHIFT )
      array << :right_shift  if( mods & SDL::KMOD_RSHIFT )
      array << :left_ctrl    if( mods & SDL::KMOD_LCTRL  )
      array << :right_ctrl   if( mods & SDL::KMOD_RCTRL  )
      array << :left_alt     if( mods & SDL::KMOD_LALT   )
      array << :right_alt    if( mods & SDL::KMOD_RALT   )
      array << :left_meta    if( mods & SDL::KMOD_LMETA  )
      array << :right_meta   if( mods & SDL::KMOD_RMETA  )
      array << :numlock      if( mods & SDL::KMOD_NUM    )
      array << :capslock     if( mods & SDL::KMOD_CAPS   )
      array << :mode         if( mods & SDL::KMOD_MODE   )

      return array
    end



    # Convert a Unicode char into a UTF8 ruby byte-string.
    #
    def self._convert_unicode( int )
      if( int > 0 )
        [int].pack('U')
      else
        ""
      end
    end



    # Convert SDL's keyboard events into KeyPressed / KeyReleased.
    #
    def self._convert_keyboardevent( ev )
      key  = _convert_key_symbol( ev.key.keysym.sym );
      mods = _convert_keymods( ev.key.keysym.mod );

      case ev.key.state
      when SDL::PRESSED
        unicode = _convert_unicode( ev.key.keysym.unicode )
        KeyPressed.new( key, mods, unicode )
      when SDL::RELEASED
        KeyReleased.new( key, mods )
      else
        raise( Rubygame::SDLError, "Unknown keyboard event state "+
               "#{ev.key.state}. This is a bug in Rubygame." )
      end
    end



  end

end


# Load all the ruby files in events/
glob = File.join( File.dirname(__FILE__), "events", "*.rb" )
Dir.glob( glob ).each do |path|
  require path
end
