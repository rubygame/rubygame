#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2008  John Croisant
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

require 'rubygame/event_triggers'
require 'rubygame/event_actions'

module Rubygame 
	
class EventHook
	attr_accessor :owner, :trigger, :action, :consumes
	
	def initialize( &block )
		@owner, @trigger, @action = nil
		@consumes = false
		yield self if block_given?
	end
	
	def match?( event )
		@trigger.match?( event ) if @trigger
	end
	
	def perform( event )
		@action.perform( owner, event ) if @action
	end
end

end
