require 'rubygame/event_triggers'
require 'rubygame/event_actions'

class Hook
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
