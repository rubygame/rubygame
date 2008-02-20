require 'rubygame/event_triggers'
require 'rubygame/event_actions'

class Hook
	attr_accessor :owner, :trigger, :action, :consumes
	
	def initialize( &block )
		@owner, @trigger, @action = nil
		@consumes = false
		instance_eval(&block)
		unless (@trigger and @action)
			# @owner is allowed to be nil, I think
			raise( ArgumentError, "must set @trigger and @action")
		end
	end

	def match?( event )
		@trigger.match?( event )
	end
	
	def perform( event )
		@action.perform( owner, event )
	end
end
