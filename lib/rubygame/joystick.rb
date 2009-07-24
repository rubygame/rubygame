#--
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
#++



# The Joystick class interfaces with joysticks, gamepads, and other
# similar hardware devices used to play games. Each joystick may
# have zero or more #axes, #balls, #hats, and/or #buttons.
#
# After a Joystick object is successfully created, events for that
# Joystick will begin appearing on the EventQueue when a button is
# pressed or released, a control stick is moved, etc.
#
# You can use Joystick.activate_all to start receiving events for
# all joysticks (equivalent to creating them all individually with
# Joystick.new). You can use Joystick.deactivate_all to stop
# receiving events for all joysticks.
#
# As of Rubygame 2.4, these are the current, "new-style" Joystick
# event classes:
#
# * Events::JoystickAxisMoved
# * Events::JoystickButtonPressed
# * Events::JoystickButtonReleased
# * Events::JoystickBallMoved
# * Events::JoystickHatMoved
#
# These old Joystick-related events are deprecated and will be
# removed in Rubygame 3.0:
#
# * JoyAxisEvent
# * JoyBallEvent
# * JoyHatEvent
# * JoyDownEvent
# * JoyUpEvent
#
# For more information about "new-style" events, see
# EventQueue.enable_new_style_events.
#
class Rubygame::Joystick


  # Returns the total number of joysticks detected on the system.
  def self.num_joysticks
    SDL.NumJoysticks()
  end


  # Returns the name of Nth joystick on the system. The name is
  # implementation-dependent. See also #name.
  #
  def self.get_name( index )
    SDL.JoystickName( index )
  end


  # Activate all joysticks on the system, equivalent to calling
  # Joystick.new for every joystick available. This will allow
  # joystick-related events to be sent to the EventQueue for all
  # joysticks.
  #
  # Returns::   Array of zero or more Joysticks.
  # May raise:: SDLError, if the joystick system could not be
  #             initialized.
  #
  def self.activate_all
    # Initialize if it isn't already.
    if( SDL.WasInit(SDL::INIT_JOYSTICK) == 0 )
      if( SDL.Init(SDL::INIT_JOYSTICK) != 0 )
        raise Rubygame::SDLError, "Could not initialize SDL joysticks."
      end
    end

    # Collect Joystick instances in an Array
    joysticks = []

    num_joysticks.times do |i|
      joysticks << new( i )
    end

    return joysticks
  end


  # Deactivate all joysticks on the system. This will stop all
  # joystick-related events from being sent to the EventQueue.
  #
  def self.deactivate_all
    # Return right away if it isn't active
    return if( SDL.WasInit(SDL::INIT_JOYSTICK) == 0 )

    num_joysticks.times do |i|
      joy = SDL.JoystickOpen(i)
      unless( joy.pointer.nil? )
        SDL.JoystickClose( joy )
      end
    end

    return nil
  end


  # Create and initialize an interface to the Nth joystick on the
  # system. Raises SDLError if the joystick could not be opened.
  #
  def initialize( index )
    @struct = SDL.JoystickOpen( index )
    if( @struct.pointer.null? )
      raise( Rubygame::SDLError, "Could not open joystick %d: %s"%
             [index, SDL.GetError()] )
    end
  end


  # Returns the index number of the Joystick, i.e. the identifier
  # number of the joystick that this interface controls. This is the
  # same number that was given to Joystick.new.
  #
  def index
    SDL.JoystickIndex( @struct )
  end


  # Returns a String containing the name of the Joystick. The name is
  # implementation-dependent. See also Joystick.get_name.
  #
  def name
    SDL.JoystickName( self.index )
  end


  # Returns the number of axes (singular: axis) featured on the
  # Joystick. Each control stick generally has two axes (X and Y),
  # although there are other types of controls which are represented
  # as one or more axes.
  #
  def axes
    SDL.JoystickNumAxes( @struct )
  end


  # Returns the number of trackballs featured on the Joystick. A
  # trackball is usually a small sphere which can be rotated in-place
  # in any direction, registering relative movement along two axes.
  #
  def balls
    SDL.JoystickNumBalls( @struct )
  end


  # Returns the number of hats featured on the Joystick. A hat is a
  # switch which can be pushed in one of several directions, or
  # centered.
  #
  def hats
    SDL.JoystickNumHats( @struct )
  end


  # Returns the number of buttons featured on the Joystick. A button
  # can be in one of two states: neutral, or pushed.
  #
  def buttons
    SDL.JoystickNumButtons( @struct )
  end


end
