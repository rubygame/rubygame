require 'rubygame/gl/event_triggers'
require 'rubygame/gl/event_actions'

class Hook
	attr_accessor :owner, :trigger, :action
	
	def initialize( owner, trigger=nil, action=nil, &block )
		@owner, @trigger, @action = owner, trigger, action
		instance_eval(&block) if block_given?
	end

	def match?( event )
		@trigger.match?( event )
	end
	
	def perform( event )
		@action.perform( owner, event )
	end
end
