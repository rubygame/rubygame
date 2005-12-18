# class String
# 	# (This is a work in progress. It does not yet work.)
# 	# 
# 	# Modified version of String.===() to match keydown events
# 	# example: the string, "ctrl+alt+delete" should matche
# 	# KeyDownEvent.new(K_DELETE,[K_LCTRL,K_LALT])
# 	# so you can case() on a keypress event, like this:
# 	# 
# 	# case(ev)
# 	# when "w"; player.go_up();
# 	# when "a"; player.go_left();
# 	# when "s"; player.go_down();
# 	# when "d"; player.go_right();
# 	# end
# 	def ===(event)
# 		if [Rubygame::KeyDownEvent, Rubygame::KeyUpEvent].include? event.class
# 			# parse self
# 			all_mods = {
# 				Rubygame::K_LALT=>['alt','lalt','left_alt'],
# 				Rubygame::K_RALT=>['alt','ralt','right_alt'],
# 				Rubygame::K_LCTRL=>['ctrl','control','lctrl','lcontrol',\
# 					'left_ctrl','left_control'],
# 				Rubygame::K_RCTRL=>['ctrl','control','rctrl','rcontrol',\
# 					'right_ctrl','right_control'],
# 				Rubygame::K_LSHIFT=>['shift','lshift','left_shift'],
# 				Rubygame::K_RSHIFT=>['shift','rshift','right_shift'],
# 			}

# 			# split string into seperate keys
# 			keys = self.downcase.split("+")

# 			# we will store string versions of the keys from the event here
# 			possible = []

# 			# add modifier keys
# 			event.mods.each{ |mod| possible += all_mods[mod] }
# 			possible << event.string.downcase
# 			keys.each { |key|
# 				unless possible.include? key
# 					return false
# 				end
# 			}
# 			return true
# 		end

# 		super
# 	end
# end
