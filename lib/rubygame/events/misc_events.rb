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

    # InputFocusGained is an event class which occurs when
    # the Rubygame application gains input focus.
    # 
    # Input focus means that the app will receive events from
    # input devices, such as the keyboard and joysticks.
    # 
    # Usually, an application has input focus when it is the "active"
    # application (the one the user has clicked on or switched to most
    # recently).
    # 
    class InputFocusGained; end

    # InputFocusLost is an event class which occurs when
    # the Rubygame application loses input focus.
    # 
    # See InputFocusGained for a description of "input focus".
    # 
    class InputFocusLost; end



    # MouseFocusGained is an event class which occurs when
    # the Rubygame application gains mouse focus.
    # 
    # Mouse focus means that the mouse cursor is inside the
    # app window. When the app has mouse focus, it will receive
    # mouse events, particularly MouseMoved.
    # 
    class MouseFocusGained; end

    # MouseFocusLost is an event class which occurs when
    # the Rubygame application loses mouse focus.
    # 
    # See MouseFocusGained for a description of "mouse focus".
    # 
    class MouseFocusLost; end

  end
end
