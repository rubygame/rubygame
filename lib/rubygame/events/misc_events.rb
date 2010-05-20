#--
#  This file is one part of:
#  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#
#  Copyright (C) 2008-2010  John Croisant
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

    # FocusEvent is a mixin module that is included in the following
    # event classes:
    # 
    #  * InputFocusGained
    #  * InputFocusLost
    #  * MouseFocusGained
    #  * MouseFocusLost
    #  * WindowMinimized
    #  * WindowUnminimized
    # 
    # This module provides no functionality. It exists only to make it
    # easier to detect the above classes in a case statement, etc.
    # 
    # Examples:
    # 
    #   include Rubygame::Events
    #   
    #   case event
    #   when FocusEvent
    #     # ...
    #   end
    #   
    #   if event.is_a? FocusEvent
    #     # ...
    #   end
    # 
    module FocusEvent; end



    # InputFocusEvent is a mixin module that is included in the
    # following event classes:
    # 
    #  * InputFocusGained
    #  * InputFocusLost
    # 
    # This module provides no functionality. It exists only to make it
    # easier to detect the above classes in a case statement, etc.
    # 
    # Examples:
    # 
    #   include Rubygame::Events
    #   
    #   case event
    #   when InputFocusEvent
    #     # ...
    #   end
    #   
    #   if event.is_a? InputFocusEvent
    #     # ...
    #   end
    # 
    module InputFocusEvent
      include FocusEvent
    end

    # InputFocusGained is an event that occurs when
    # the Rubygame application gains input focus.
    # 
    # Input focus means that the app will receive events from
    # input devices, such as the keyboard and joysticks.
    # 
    # Usually, an application has input focus when it is the "active"
    # application (the one the user has clicked on or switched to most
    # recently).
    # 
    class InputFocusGained
      include InputFocusEvent
    end

    # InputFocusLost is an event that occurs when
    # the Rubygame application loses input focus.
    # 
    # See InputFocusGained for a description of "input focus".
    # 
    class InputFocusLost
      include InputFocusEvent
    end



    # MouseFocusEvent is a mixin module that is included in the
    # following event classes:
    # 
    #  * MouseFocusGained
    #  * MouseFocusLost
    # 
    # This module provides no functionality. It exists only to make it
    # easier to detect the above classes in a case statement, etc.
    # 
    # Examples:
    # 
    #   include Rubygame::Events
    #   
    #   case event
    #   when MouseFocusEvent
    #     # ...
    #   end
    #   
    #   if event.is_a? MouseFocusEvent
    #     # ...
    #   end
    # 
    module MouseFocusEvent
      include FocusEvent
    end

    # MouseFocusGained is an event that occurs when
    # the Rubygame application gains mouse focus.
    # 
    # Mouse focus means that the mouse cursor is inside the
    # app window. When the app has mouse focus, it will receive
    # mouse events, particularly MouseMoved.
    # 
    class MouseFocusGained
      include MouseFocusEvent
    end

    # MouseFocusLost is an event that occurs when
    # the Rubygame application loses mouse focus.
    # 
    # See MouseFocusGained for a description of "mouse focus".
    # 
    class MouseFocusLost
      include MouseFocusEvent
    end



    # MinimizeEvent is a mixin module that is included in the
    # following event classes:
    # 
    #  * WindowMinimized
    #  * WindowUnminimized
    # 
    # This module provides no functionality. It exists only to make it
    # easier to detect the above classes in a case statement, etc.
    # 
    # Examples:
    # 
    #   include Rubygame::Events
    #   
    #   case event
    #   when MinimizeEvent
    #     # ...
    #   end
    #   
    #   if event.is_a? MinimizeEvent
    #     # ...
    #   end
    # 
    module MinimizeEvent
      include FocusEvent
    end

    # WindowMinimized is an event that occurs when
    # the Rubygame application window becomes minimized (also
    # called 'iconified').
    # 
    class WindowMinimized
      include MinimizeEvent
    end

    # WindowUnminimized is an event that occurs when the
    # Rubygame application window is restored after it had been
    # minimized.
    # 
    class WindowUnminimized
      include MinimizeEvent
    end



    # WindowExposed is an event that occurs in
    # certain situations when the Rubygame application
    # window is exposed after being covered by another
    # application.
    # 
    # This event may not occur on all platforms, but
    # when it does occur, your app should refresh the
    # entire window via Screen#flip (or 
    # Rubygame::GL.swap_buffers, if using OpenGL).
    # 
    class WindowExposed; end



    # QuitRequested is an event that occurs when the
    # application receives a quit request, usually due to the
    # user clicking the "Close" button on the app window.
    # 
    # Almost always, your application should respond to this
    # event by quitting or by displaying a "Quit/Cancel"
    # dialog. If you ignore this event, the user may become
    # frustrated that your app won't close properly!
    # 
    class QuitRequested; end



    # WindowResized is an event that occurs when the
    # Rubygame application window is resized by the user.
    # This can only happen if the Screen mode was set with
    # the "resizable" flag.
    # 
    # Your application should respond to this event by
    # setting the Screen mode again with the new #size and
    # redrawing.
    # 
    # If you ignore this event, the "active" area of the
    # Screen will stay the same size, and the rest (if the
    # window was enlarged) will be black and won't receive
    # any changes (blits, drawing, etc.).
    # 
    class WindowResized
      attr_reader :size

      def initialize( size )

        @size = size.to_ary.dup
        @size.freeze

        unless @size.length == 2
          raise ArgumentError, "size must have exactly 2 parts (got %s)"%@size.length
        end

        @size.each do |part|
          if part <= 0
            raise ArgumentError, "size must be positive (got %s)"%part
          end
        end

      end
    end


  end
end
