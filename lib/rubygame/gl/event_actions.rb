
class BlockAction
	def initialize( &block )
		@block = block
	end
	
	def perform( owner, event )
		@block.call( owner, event )
	end
end

class MethodAction
	def initialize( method_name=:push, pass_event=false )
		@method_name = method_name
		@pass_event = pass_event
	end
	
	def perform( owner, event )
		args = @pass_event ? [@method_name, event] : [@method_name]
		owner.send( *args )
	end
end
