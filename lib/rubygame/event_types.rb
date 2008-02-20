class DrawEvent
end

class MouseClickEvent
	attr_accessor :button, :world_pos
	
	def initialize(button, world_pos)
		@button, @world_pos = button, world_pos
	end
end

class MouseHoverEvent
	attr_accessor :buttons, :world_pos, :world_rel
	
	def initialize(buttons, world_pos, world_rel)
		@buttons, @world_pos, @world_rel = buttons, world_pos, world_rel
	end
end
