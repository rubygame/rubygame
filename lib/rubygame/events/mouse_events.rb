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

    module MouseButtonEvent
      attr_reader :button, :pos

      def initialize( pos, button )

        unless button.kind_of? Symbol
          raise ArgumentError, "button must be a :symbol"
        end

        unless pos.kind_of? Array
          raise ArgumentError, "pos must be an Array"
        end

        @button = button
        @pos = pos

      end
    end

    class MousePressed
      include MouseButtonEvent
    end

    class MouseReleased
      include MouseButtonEvent
    end


    class MouseMoved
      
      attr_reader :pos

      def initialize( pos )
        @pos = pos
      end
    end

  end
end
