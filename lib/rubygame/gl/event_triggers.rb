require 'rubygame'

class AttrTrigger
	def initialize( attributes )
		@attributes = attributes
	end
	
	def match?( event )
		attrs = @attributes.dup
		klass = attrs.delete(:klass)
		if event.kind_of?(klass)
			attrs.all? { |key, value| event.send(key) == value }
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
	def initialize( button=:any )
		@button = button
	end
	
	def match?( event )
		if event.kind_of?( Rubygame::MouseDownEvent )
			if (@button == :any) or (event.button == @button)
				true
			end
		else
			false
		end
	end
end
