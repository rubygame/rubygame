module Collider
	def collide( other )
		collide_method = "collide_#{other.class.name.downcase}".to_sym
		send( collide_method, other )
	end
end
