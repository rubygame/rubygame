class NoCollisionHandler < NoMethodError
end

module Collider
	def collide( other )
		collide_method = "collide_#{other.class.name.downcase}".to_sym
		if respond_to? collide_method
			return send( collide_method, other )
		else
			raise NoCollisionHandler
		end
	end
end
