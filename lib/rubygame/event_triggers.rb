require 'rubygame'
require 'rubygame/gl/event_types'

class AllTrigger
	def initialize( *triggers )
		@triggers = triggers
	end
	
	def match?( event )
		@triggers.all? { |trigger| trigger.match? event }
	end
end

class AnyTrigger
	def initialize( *triggers )
		@triggers = triggers
	end
	
	def match?( event )
		@triggers.any? { |trigger| trigger.match? event }
	end
end

class AttrTrigger
	def initialize( attributes )
		@attributes = attributes
	end
	
	def match?( event )
		@attributes.all? { |key, value| event.send(key) == value }
	end
end

class BlockTrigger
	def initialize( &block )
		@block = block
	end
	
	def match?( event )
		@block.call( event )
	end
end

class InstanceTrigger
	def initialize( klass, attributes={} )
		@klass = klass
		@attributes = attributes
	end
	
	def match?( event )
		if event.kind_of?( @klass )
			@attributes.all? { |key, value| event.send(key) == value }
		else
			false
		end
	end
end

class KeyPressTrigger
	def initialize( key=:any )
		@key = key
	end
	
	def match?( event )
		if event.kind_of?( Rubygame::KeyDownEvent )
			if (@key == :any) or (event.key == @key)
				true
			end
		else
			false
		end
	end
end

class MouseClickTrigger
	def initialize( button=:any, bounds=:anywhere )
		@button = button
		@bounds = bounds
	end
	
	def match?( event )
		if event.kind_of?( MouseClickEvent )
			((@button == :any) or (event.button == @button)) and \
			((@bounds == :anywhere) or (@bounds.collide( event.world_pos )))
		else
			false
		end
	end
end

class MouseHoverTrigger
	def initialize( button=:any, bounds=:anywhere )
		@button = button
		@bounds = bounds
	end
	
	def match?( event )
		if event.kind_of?( MouseHoverEvent )
			(@button == :any or event.buttons.include?(@button)) and \
			(@bounds == :anywhere or @bounds.collide( event.world_pos ))
		else
			false
		end
	end
end

class TickTrigger
	def match?( event )
		event.kind_of?( Rubygame::TickEvent )
	end
end

class YesTrigger
	def match?( event )
		true
	end
end
