# Modify String#=== to match keydown events
# example: "ctrl+alt+delete" matches KeyDownEvent(K_DELETE,[K_CTRL,K_ALT])
# so you can use it with the case() statement

class String
	def ===(event)
		if [Rubygame::KeyDownEvent, Rubygame::KeyUpEvent].include? event.class
			# parse self
			all_mods = {
				Rubygame::K_LALT=>['alt','lalt','left_alt'],
				Rubygame::K_RALT=>['alt','ralt','right_alt'],
				Rubygame::K_LCTRL=>['ctrl','control','lctrl','lcontrol',\
					'left_ctrl','left_control'],
				Rubygame::K_RCTRL=>['ctrl','control','rctrl','rcontrol',\
					'right_ctrl','right_control'],
				Rubygame::K_LSHIFT=>['shift','lshift','left_shift'],
				Rubygame::K_RSHIFT=>['shift','rshift','right_shift'],
			}
			keys = self.downcase.split("+")
			possible = []
			event.mods.each{ |mod| possible += all_mods[mod] }
			possible << event.string.downcase
			keys.each { |key|
				unless possible.include? key
					return false
				end
			}
			return true
		end

		super
	end
end
