require 'rubygame'
require 'rubygame/event_types'

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

class InstanceOfTrigger
	def initialize( klass )
		@klass = klass
	end
	
	def match?( event )
		event.instance_of?( @klass )
	end
end

class KeyPressTrigger
	def initialize( key=:any, mods=:any )
		@key = key
		@mods = mods
	end
	
	def match?( event )
		if event.kind_of?( Rubygame::KeyDownEvent )
			((@key == :any) or (event.key == @key)) and \
			((@mods == :any) or (@mods == :none and event.mods == [])\
			                 or (event.mods == @mods))
		end
	end
end

class KeyReleaseTrigger
	def initialize( key=:any, mods=:any )
		@key = key
		@mods = mods
	end
	
	def match?( event )
		if event.kind_of?( Rubygame::KeyUpEvent )
			((@key == :any) or (event.key == @key)) and \
			((@mods == :any) or (@mods == :none and event.mods == [])\
			                 or (event.mods == @mods))
		end
	end
end

class KindOfTrigger
	def initialize( klass )
		@klass = klass
	end
	
	def match?( event )
		event.kind_of?( @klass )
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
