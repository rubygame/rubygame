require 'matricks'
require 'shape'
require 'collidable'

class Group
	include Shape
	include Collidable

	attr_accessor :members
	attr_accessor :pos, :angle, :scale

	def initialize( *members )
		@members = members
		@pos = Vector2[0,0]
		@angle = 0
		@scale = Vector2[1,1]
		@temp_matrix = Matrix.identity(3)
		super()
	end

	def initialize_copy( orig )
		@members = orig.members
		@pos, @angle, @scale = orig.pos, orig.angle, orig.scale
		super
	end

	def add_members(*members)
		@members |= members
		sort_members()
		return self
	end

	def bounds
		members = evaluate_members
		initial = members[0].bounds
		evaluate_members[1..-1].inject(initial) do |bounds, member|
			bounds.union(member.bounds)
		end
	end

	def evaluate_members
		mat = _compose_matrix()
		@members.map { |member| member.transform( mat ) }
	end

	def sort_members()
		@members.sort!{ |a,b| a.depth <=> b.depth }
	end

	def per_members_collide( other )
		evaluate_members.any? do |member|
			member.collide( other )
		end
	end

	alias :collide_group :per_members_collide
	alias :collide_triangle :per_members_collide

	#private

	def _generate_matrix
		Matrix.translate( *@pos ) *
			Matrix.rotate( @angle ) *
			Matrix.scale( *@scale )
	end

	def _compose_matrix
		@matrix * _generate_matrix
	end
end
