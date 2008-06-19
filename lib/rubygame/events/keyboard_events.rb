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

    module KeyboardEvent
      attr_reader :key, :modifiers

      def initialize( key, modifiers=[] )

        unless key.kind_of? Symbol
          raise ArgumentError, "key must be a :symbol"
        end

        unless modifiers.kind_of? Array
          raise ArgumentError, "modifiers must be an Array"
        end

        @key = key
        @modifiers = modifiers
      end
    end


    class KeyPressed
      include KeyboardEvent

      attr_reader :string

      def initialize( key, modifiers=[], string="" )
        super( key, modifiers )

        unless string.kind_of? String
          raise ArgumentError, "string must be a String"
        end

        @string = string
      end
    end


    class KeyReleased
      include KeyboardEvent
    end

  end
end
