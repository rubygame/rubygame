require 'rubygame/event_triggers'
require 'rubygame/event_actions'

class Hook
	attr_accessor :owner, :trigger, :action
	
	def initialize( owner, trigger=nil, action=nil, &block )
		@owner, @trigger, @action = owner, trigger, action
		instance_eval(&block) if block_given?
	end

	def matches?( event )
		@trigger.matches?( event )
	end
	
	def perform( event )
		@action.perform( owner, event )
	end
end
