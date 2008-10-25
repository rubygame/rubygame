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
# ++


module Rubygame

  module Events

    # 
    # MouseButtonEvent is a mixin module included in the MousePressed
    # and MouseReleased classes. It defines the #button and #pos
    # attribute readers.
    # 
    module MouseButtonEvent
      attr_reader :button, :pos

      # 
      # Initialize the MouseButtonEvent.
      # 
      # button:: a symbol for the button that was pressed or
      #          released. (Symbol, required)
      # 
      # pos::    an Array for the position of the mouse cursor
      #          when the event occured. [0,0] is the top-left
      #          corner of the window (or the screen if running 
      #          full-screen). (Array, required)
      # 
      def initialize( pos, button )

        unless button.kind_of? Symbol
          raise ArgumentError, "button must be a :symbol"
        end

        @button = button

        @pos = pos.to_ary.dup
        @pos.freeze

      end
    end


    # 
    # MousePressed is an event class which occurs when a button
    # on the mouse is pressed down. 
    # 
    # This class gains #button and #pos attribute readers from
    # the MouseButtonEvent mixin module.
    # 
    class MousePressed
      include MouseButtonEvent

      # 
      # Create a new MousePressed instance.
      # 
      # button:: a symbol for the button that was pressed or
      #          released. (Symbol, required)
      # 
      # pos::    an Array for the position of the mouse cursor
      #          when the event occured. [0,0] is the top-left
      #          corner of the window (or the screen if running 
      #          full-screen). (Array, required)
      # 
      def initialize( pos, button )
        super
      end
    end


    # 
    # MouseReleased is an event class which occurs when a button
    # on the mouse is released (no longer being pressed). 
    # 
    # This class gains #button and #pos attribute readers from
    # the MouseButtonEvent mixin module.
    # 
    class MouseReleased
      include MouseButtonEvent

      # 
      # Create a new MouseReleased instance.
      # 
      # button:: a symbol for the button that was pressed or
      #          released. (Symbol, required)
      # 
      # pos::    an Array for the position of the mouse cursor
      #          when the event occured. [0,0] is the top-left
      #          corner of the window (or the screen if running 
      #          full-screen). (Array, required)
      # 
      def initialize( pos, button )
        super
      end
    end


    # 
    # MouseMoved is an event class which occurs when the mouse
    # cursor moves. It has attribute readers for #pos (new position),
    # #rel (change since the last MouseMoved event), and #buttons
    # (an Array of the mouse buttons that were held down while moving).
    # 
    class MouseMoved
      
      attr_reader :pos, :rel, :buttons

      # 
      # Create a new MouseReleased instance.
      # 
      # pos::     an Array for the new position of the mouse cursor.
      #           The point [0,0] is the top-left corner of the window
      #           (or the screen if running full-screen).
      #           (Array, required)
      # 
      # rel::     an Array for the position change since the last
      #           MouseMoved event, in pixels. (Array, required)
      # 
      # buttons:: an Array of symbols for the mouse buttons that were
      #           being held down while the mouse was moving. [] if
      #           no buttons were being held. (Array, optional)
      # 
      def initialize( pos, rel, buttons=[] )

        @pos = pos.to_ary.dup
        @pos.freeze

        @rel = rel.to_ary.dup
        @rel.freeze

        @buttons = buttons.to_ary.dup
        @buttons.freeze

      end
    end

  end
end
