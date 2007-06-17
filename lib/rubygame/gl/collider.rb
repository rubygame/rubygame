module Collider
	def collide( other )
		collide_method = "collide_#{other.class.name.downcase}".to_sym
		return send( collide_method, other )
	rescue NoMethodError => e
		begin
			collide_method = "collide_#{self.class.name.downcase}".to_sym
			return other.send( collide_method, self )
		rescue NoMethodError
			raise e
		end
	end
end
