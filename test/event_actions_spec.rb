require 'rubygame'
include Rubygame


describe "an event action", :shared => true do 

	it "should have a #perform method" do 
		@action.should respond_to(:perform)
	end
	
	it "should take 2 arguments to #perform" do 
		@action.method(:perform).arity.should == 2
	end
	
	it "should raise error if #perform gets too few arguments" do 
		lambda { @action.perform(1) }.should raise_error(ArgumentError)		
	end

	it "should raise error if #perform gets too many arguments" do 
		lambda { @action.perform(1,2,3) }.should raise_error(ArgumentError)
	end
	
end




describe BlockAction do 
	
	before :each do 
		@owner = mock("owner")
		@action = BlockAction.new { |owner,event| owner.foo(event) }
	end
	
	it_should_behave_like "an event action"
	
	it "#perform should execute the block" do 
		@owner.should_receive( :foo ).with( :event )
		@action.perform( @owner, :event )
	end
	
	it "should yield 2 parameters (owner and event) to the block" do 
		@action = BlockAction.new { |owner, event|
			owner.should == :owner
			event.should == :event
		}
		@action.perform( :owner, :event )
	end
	
end




describe MethodAction, "without pass_event" do 
	
	before :each do 
		@owner = mock("owner")
		@action = MethodAction.new( :foo, false )
	end
	
	it_should_behave_like "an event action"
	
	it "#perform should call the owner's method with no args" do 
		@owner.should_receive( :foo ).with( no_args )
		@action.perform( @owner, :event )
	end
	
end


describe MethodAction, "with pass_event" do 
	
	before :each do 
		@owner = mock("owner")
		@action = MethodAction.new( :foo, true )
	end
	
	it_should_behave_like "an event action"
	
	it "#perform should call the owner's method with 1 arg" do 
		@owner.should_receive( :foo ).with( :event )
		@action.perform( @owner, :event )
	end
	
end


describe MethodAction, "with pass_event to method that takes no args" do 
	
	before :each do 
		@owner = mock("owner")
		@action = MethodAction.new( :foo, true )
	end
	
	it_should_behave_like "an event action"

	it "#perform should call the method with arg (fails), then with no arg" do 
		@owner.should_receive( :foo ).with( :event ).ordered.and_raise( ArgumentError )
		@owner.should_receive( :foo ).with( no_args ).ordered
		@action.perform( @owner, :event )
	end
		
end




describe MultiAction do 
	
	before :each do 
		@owner = mock("owner")

		action1 = MethodAction.new( :foo, true )
		action2 = BlockAction.new { |owner,event| owner.bar(event) }
		@action = MultiAction.new( action1, action2 )
	end
	
	it_should_behave_like "an event action"
	
	it "#perform should perform all included actions in order" do 
		@owner.should_receive( :foo ).with( :event ).ordered
		@owner.should_receive( :bar ).with( :event ).ordered
		@action.perform( @owner, :event )
	end
	
end
