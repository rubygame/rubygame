

require 'rubygame'
include Rubygame
include Rubygame::EventTriggers
include Rubygame::Events

FakeEvent = Struct.new(:a)



shared_examples_for "an event trigger" do 
	
	it "should have a #match? method" do 
		@trigger.should respond_to(:match?)
	end
	
	it "should take 1 arguments to #match?" do 
		@trigger.method(:match?).arity.should == 1
	end
	
	it "should raise error if #match? gets too few arguments" do 
		lambda { @trigger.match? }.should raise_error(ArgumentError)		
	end

	it "should raise error if #match? gets too many arguments" do 
		lambda { @trigger.match?(1,2) }.should raise_error(ArgumentError)
	end
	
end



describe AndTrigger do 
	
	before :each do 
		trigger1 = InstanceOfTrigger.new(FakeEvent)
		trigger2 = AttrTrigger.new( :a => 0.5 )
		@trigger = AndTrigger.new( trigger1, trigger2 )
	end
	
	it_should_behave_like "an event trigger"

	it "should match if all included triggers match" do 
		@trigger.match?( FakeEvent.new(0.5) ).should be_true
	end
	
	it "should not match if any of the included triggers does not match" do 
		@trigger.match?( FakeEvent.new(0.1) ).should be_false
	end
	
	it "should not match if none of the included triggers matches" do 
		@trigger.match?( QuitEvent.new() ).should be_false
	end
	
end



describe OrTrigger do 
	
	before :each do 
		trigger1 = InstanceOfTrigger.new(FakeEvent)
		trigger2 = AttrTrigger.new( :a => 0.5 )
		@trigger = OrTrigger.new( trigger1, trigger2 )
	end
	
	it_should_behave_like "an event trigger"

	it "should match if all included triggers match" do 
		@trigger.match?( FakeEvent.new(0.5) ).should be_true
	end
	
	it "should match if any of the included triggers match" do 
		@trigger.match?( FakeEvent.new(0.1) ).should be_true
	end

	it "should not match if none of the included triggers matches" do 
		@trigger.match?( QuitEvent.new() ).should be_false
	end

end



describe AttrTrigger do 
	
	before :each do 
		@rt = :respond_to?
		@event = mock("event")
		@trigger = AttrTrigger.new( :foo => true, :zab => 3 )
	end
	
	it_should_behave_like "an event trigger"

	it "should match if all the attribute have the expected values" do 
		@event.should_receive(@rt).with(:foo).and_return( true )
		@event.should_receive(@rt).with(:zab).and_return( true )
		@event.should_receive(:foo).and_return( true )
		@event.should_receive(:zab).and_return( 3 )
		
		@trigger.match?(@event).should be_true
	end
	
	it "should not match if any attribute has an unexpected value" do 
		@event.should_receive(@rt).with(:foo).at_most(:once).and_return( true )
		@event.should_receive(@rt).with(:zab).at_most(:once).and_return( true )
		@event.should_receive(:foo).at_most(:once).and_return( true )
		@event.should_receive(:zab).at_most(:once).and_return( 11 )
		
		@trigger.match?(@event).should be_false
	end
	
	it "should not match if any attribute does not exist" do 
		@event.should_receive( @rt ).with(:foo).at_most(:once).and_return( false )
		@event.should_receive( @rt ).with(:zab).at_most(:once).and_return( true )
		@event.should_not_receive(:foo)
		@event.should_receive(:zab).at_most(:once)
		
		@trigger.match?(@event).should be_false
	end
	
end



describe BlockTrigger do 
	
	before :each do 
		@trigger = BlockTrigger.new { |event| event }
	end
	
	it_should_behave_like "an event trigger"

	it "should fail if not given a block at creation" do 
		lambda { BlockTrigger.new }.should raise_error( ArgumentError )
	end
	
	it "should match if the block returns true" do 
		@trigger.match?(true).should be_true
	end
	
	it "should not match if the block returns non-boolean" do 
		@trigger.match?(:symbol).should be_false
	end
	
	it "should not match if the block returns false" do 
		@trigger.match?(false).should be_false
	end
	
	it "should not match if the block returns nil" do 
		@trigger.match?(nil).should be_false
	end
	
end



describe InstanceOfTrigger do 
	
	before :each do 
		@trigger = InstanceOfTrigger.new( QuitEvent )
	end
	
	it_should_behave_like "an event trigger"

	it "should match if the event is an instance of the correct class" do 
		@trigger.match?( QuitEvent.new ).should be_true
	end
	
	it "should not match if the event is only kind of the correct class" do 
		@trigger.match?( Event.new ).should be_false
	end

	it "should not match if the event is not an instance of the correct class" do 
		@trigger.match?( :foo ).should be_false
	end

end



describe JoystickAxisMoveTrigger do

	before :each do 
		@event_class   = JoystickAxisMoved
		@trigger_class = JoystickAxisMoveTrigger
		@trigger       = @trigger_class.new
	end

	it_should_behave_like "an event trigger"

	it "should match any JoystickAxisMoved by default" do
		@trigger = @trigger_class.new()
		event = @event_class.new( 0, 0, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should match if trigger joystick and axis are :any" do
		@trigger = @trigger_class.new( :any, :any )
		event = @event_class.new( 0, 0, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should match if joystick matches" do
		@trigger = @trigger_class.new( 1, :any )
		event = @event_class.new( 1, 0, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should not match if joystick does not match" do
		@trigger = @trigger_class.new( 2, :any )
		event = @event_class.new( 1, 0, 0 )
		@trigger.match?( event ).should be_false
	end

	it "should match if axis matches" do
		@trigger = @trigger_class.new( :any, 1 )
		event = @event_class.new( 0, 1, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should not match if axis does not match" do
		@trigger = @trigger_class.new( :any, 2 )
		event = @event_class.new( 0, 1, 0 )
		@trigger.match?( event ).should be_false
	end

	it "should match if both joystick and axis match" do
		@trigger = @trigger_class.new( 1, 2 )
		event = @event_class.new( 1, 2, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should not match if neither joystick and axis matches" do
		@trigger = @trigger_class.new( 3, 4 )
		event = @event_class.new( 1, 2, 0 )
		@trigger.match?( event ).should be_false
	end

end



describe JoystickBallMoveTrigger do

	before :each do 
		@event_class   = JoystickBallMoved
		@trigger_class = JoystickBallMoveTrigger
		@trigger       = @trigger_class.new
	end

	it_should_behave_like "an event trigger"

	it "should match any JoystickBallMoved by default" do
		@trigger = @trigger_class.new()
		event = @event_class.new( 0, 0, [0,0] )
		@trigger.match?( event ).should be_true
	end

	it "should match if trigger joystick and ball are :any" do
		@trigger = @trigger_class.new( :any, :any )
		event = @event_class.new( 0, 0, [0,0] )
		@trigger.match?( event ).should be_true
	end

	it "should match if joystick matches" do
		@trigger = @trigger_class.new( 1, :any )
		event = @event_class.new( 1, 0, [0,0] )
		@trigger.match?( event ).should be_true
	end

	it "should not match if joystick does not match" do
		@trigger = @trigger_class.new( 2, :any )
		event = @event_class.new( 1, 0, [0,0] )
		@trigger.match?( event ).should be_false
	end

	it "should match if ball matches" do
		@trigger = @trigger_class.new( :any, 1 )
		event = @event_class.new( 0, 1, [0,0] )
		@trigger.match?( event ).should be_true
	end

	it "should not match if ball does not match" do
		@trigger = @trigger_class.new( :any, 2 )
		event = @event_class.new( 0, 1, [0,0] )
		@trigger.match?( event ).should be_false
	end

	it "should match if both joystick and ball match" do
		@trigger = @trigger_class.new( 1, 2 )
		event = @event_class.new( 1, 2, [0,0] )
		@trigger.match?( event ).should be_true
	end

	it "should not match if neither joystick and ball matches" do
		@trigger = @trigger_class.new( 3, 4 )
		event = @event_class.new( 1, 2, [0,0] )
		@trigger.match?( event ).should be_false
	end

end



describe JoystickButtonPressTrigger do

	before :each do 
		@event_class   = JoystickButtonPressed
		@trigger_class = JoystickButtonPressTrigger
		@trigger       = @trigger_class.new
	end

	it_should_behave_like "an event trigger"

	it "should match any JoystickButtonPressed by default" do
		@trigger = @trigger_class.new()
		event = @event_class.new( 0, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should match if trigger joystick and button are :any" do
		@trigger = @trigger_class.new( :any, :any )
		event = @event_class.new( 0, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should match if joystick matches" do
		@trigger = @trigger_class.new( 1, :any )
		event = @event_class.new( 1, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should not match if joystick does not match" do
		@trigger = @trigger_class.new( 2, :any )
		event = @event_class.new( 1, 0 )
		@trigger.match?( event ).should be_false
	end

	it "should match if button matches" do
		@trigger = @trigger_class.new( :any, 1 )
		event = @event_class.new( 0, 1 )
		@trigger.match?( event ).should be_true
	end

	it "should not match if button does not match" do
		@trigger = @trigger_class.new( :any, 2 )
		event = @event_class.new( 0, 1 )
		@trigger.match?( event ).should be_false
	end

	it "should match if both joystick and button match" do
		@trigger = @trigger_class.new( 1, 2 )
		event = @event_class.new( 1, 2 )
		@trigger.match?( event ).should be_true
	end

	it "should not match if neither joystick and button matches" do
		@trigger = @trigger_class.new( 3, 4 )
		event = @event_class.new( 1, 2 )
		@trigger.match?( event ).should be_false
	end

end



describe JoystickButtonReleaseTrigger do

	before :each do 
		@event_class   = JoystickButtonReleased
		@trigger_class = JoystickButtonReleaseTrigger
		@trigger       = @trigger_class.new
	end

	it_should_behave_like "an event trigger"

	it "should match any JoystickButtonReleased by default" do
		@trigger = @trigger_class.new()
		event = @event_class.new( 0, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should match if trigger joystick and button are :any" do
		@trigger = @trigger_class.new( :any, :any )
		event = @event_class.new( 0, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should match if joystick matches" do
		@trigger = @trigger_class.new( 1, :any )
		event = @event_class.new( 1, 0 )
		@trigger.match?( event ).should be_true
	end

	it "should not match if joystick does not match" do
		@trigger = @trigger_class.new( 2, :any )
		event = @event_class.new( 1, 0 )
		@trigger.match?( event ).should be_false
	end

	it "should match if button matches" do
		@trigger = @trigger_class.new( :any, 1 )
		event = @event_class.new( 0, 1 )
		@trigger.match?( event ).should be_true
	end

	it "should not match if button does not match" do
		@trigger = @trigger_class.new( :any, 2 )
		event = @event_class.new( 0, 1 )
		@trigger.match?( event ).should be_false
	end

	it "should match if both joystick and button match" do
		@trigger = @trigger_class.new( 1, 2 )
		event = @event_class.new( 1, 2 )
		@trigger.match?( event ).should be_true
	end

	it "should not match if neither joystick and button matches" do
		@trigger = @trigger_class.new( 3, 4 )
		event = @event_class.new( 1, 2 )
		@trigger.match?( event ).should be_false
	end

end



describe JoystickHatMoveTrigger do

	before :each do 
		@event_class   = JoystickHatMoved
		@trigger_class = JoystickHatMoveTrigger
		@trigger       = @trigger_class.new
	end

	it_should_behave_like "an event trigger"

	it "should match any JoystickHatMoved by default" do
		@trigger = @trigger_class.new()
		event = @event_class.new( 0, 0, :up )
		@trigger.match?( event ).should be_true
	end

	it "should match if trigger joystick, hat, and dir are :any" do
		@trigger = @trigger_class.new( :any, :any, :any )
		event = @event_class.new( 0, 0, :up )
		@trigger.match?( event ).should be_true
	end

	it "should match if joystick matches" do
		@trigger = @trigger_class.new( 1, :any, :any )
		event = @event_class.new( 1, 0, :up )
		@trigger.match?( event ).should be_true
	end

	it "should not match if joystick does not match" do
		@trigger = @trigger_class.new( 2, :any, :any )
		event = @event_class.new( 1, 0, :up )
		@trigger.match?( event ).should be_false
	end

	it "should match if hat matches" do
		@trigger = @trigger_class.new( :any, 1, :any )
		event = @event_class.new( 0, 1, :up )
		@trigger.match?( event ).should be_true
	end

	it "should not match if hat does not match" do
		@trigger = @trigger_class.new( :any, 2, :any )
		event = @event_class.new( 0, 1, :up )
		@trigger.match?( event ).should be_false
	end

	it "should match if dir matches" do
		@trigger = @trigger_class.new( :any, :any, :up )
		event = @event_class.new( 0, 0, :up )
		@trigger.match?( event ).should be_true
	end

	it "should not match if dir does not match" do
		@trigger = @trigger_class.new( :any, :any, :down )
		event = @event_class.new( 0, 0, :up )
		@trigger.match?( event ).should be_false
	end

	it "should match if both joystick and hat match" do
		@trigger = @trigger_class.new( 1, 2, :any )
		event = @event_class.new( 1, 2, :up )
		@trigger.match?( event ).should be_true
	end

	it "should match if both joystick and dir match" do
		@trigger = @trigger_class.new( 1, :any, :up )
		event = @event_class.new( 1, 0, :up )
		@trigger.match?( event ).should be_true
	end

	it "should not match if neither joystick and hat matches" do
		@trigger = @trigger_class.new( 3, :any, :down )
		event = @event_class.new( 1, 0, :up )
		@trigger.match?( event ).should be_false
	end

	it "should match if joystick, hat, and dir all match" do
		@trigger = @trigger_class.new( 1, 2, :up )
		event = @event_class.new( 1, 2, :up )
		@trigger.match?( event ).should be_true
	end

	it "should not match if joystick, hat, and dir don't match" do
		@trigger = @trigger_class.new( 3, 4, :down )
		event = @event_class.new( 1, 2, :up )
		@trigger.match?( event ).should be_false
	end

end



shared_examples_for "a keyboard event trigger" do

	it_should_behave_like "an event trigger"

  it "should match if the event key is :any and mods is :any" do
		@trigger = @trigger_class.new()
    @trigger.match?( @event_class.new(:z, [:left_shift]) ).should be_true
  end

  it "should match if the event key is the same and mods is :any" do
		@trigger = @trigger_class.new( :a )
    @trigger.match?( @event_class.new(:a, []) ).should be_true
  end
	
  it "should match if the event key is :any and mods are the same" do
		@trigger = @trigger_class.new( :any, [:left_shift] )
    @trigger.match?( @event_class.new(:z, [:left_shift]) ).should be_true
  end

  it "should match if the event key is the same and mods are the same" do
		@trigger = @trigger_class.new( :a, [:left_shift] )
    @trigger.match?( @event_class.new(:a, [:left_shift]) ).should be_true
  end

  it "should match if the event key is :any and mods match :none" do
		@trigger = @trigger_class.new( :any, :none )
    @trigger.match?( @event_class.new(:a, []) ).should be_true
  end
	
  it "should match if the event key is the same and mods match :none" do
		@trigger = @trigger_class.new( :a, :none )
    @trigger.match?( @event_class.new(:a, []) ).should be_true
  end


  ["alt", "ctrl", "meta", "shift"].each do |m|

    it "should match if event mods is [:left_#{m}] and mods is [:#{m}]" do
      @trigger = @trigger_class.new( :a, [m.intern] )
      @trigger.match?( @event_class.new(:a, ["left_#{m}".intern]) ).should be_true
    end
    
    it "should match if event mods is [:right_#{m}] and mods is [:#{m}]" do
      @trigger = @trigger_class.new( :a, [m.intern] )
      @trigger.match?( @event_class.new(:a, ["right_#{m}".intern]) ).should be_true
    end

  end	

	it "should not care about mods order" do
		@trigger = @trigger_class.new( :a, [:left_shift, :left_ctrl] )
		@trigger.match?( @event_class.new(:a, [:left_ctrl, :left_shift]) ).should be_true
	end

end



describe KeyPressTrigger do
  
	before :each do 
    @event_class   = KeyPressed
    @trigger_class = KeyPressTrigger
		@trigger       = @trigger_class.new
	end

  it_should_behave_like "a keyboard event trigger"

end

describe KeyReleaseTrigger do
  
	before :each do 
    @event_class   = KeyReleased
    @trigger_class = KeyReleaseTrigger
		@trigger       = @trigger_class.new
	end

  it_should_behave_like "a keyboard event trigger"

end



describe KindOfTrigger do 
	
	before :each do 
		@trigger = KindOfTrigger.new( Event )
	end
	
	it_should_behave_like "an event trigger"

	it "should match if the event is an instance of the correct class" do 
		@trigger.match?( Event.new ).should be_true
	end
	
	it "should match if the event is kind of the correct class" do 
		@trigger.match?( QuitEvent.new ).should be_true
	end

	it "should not match if the event is not kind of the correct class" do 
		@trigger.match?( :foo ).should be_false
	end

end



shared_examples_for "a mouse button event trigger" do

	it_should_behave_like "an event trigger"

	it "should match if the event button is :any" do
		@trigger = @trigger_class.new()
		@trigger.match?( @event_class.new([0,0], :mouse_left) ).should be_true
	end

	it "should match if the event button is the same" do
		@trigger = @trigger_class.new( :mouse_left )
		@trigger.match?( @event_class.new([0,0], :mouse_left) ).should be_true
	end

	it "should not match if the event button is not the same" do
		@trigger = @trigger_class.new( :mouse_left )
		@trigger.match?( @event_class.new([0,0], :mouse_right) ).should be_false
	end

end


describe MousePressTrigger do

	before :each do 
		@event_class   = MousePressed
		@trigger_class = MousePressTrigger
		@trigger       = @trigger_class.new
	end

	it_should_behave_like "a mouse button event trigger"

end

describe MouseReleaseTrigger do

	before :each do 
		@event_class   = MouseReleased
		@trigger_class = MouseReleaseTrigger
		@trigger       = @trigger_class.new
	end

	it_should_behave_like "a mouse button event trigger"

end



describe MouseMoveTrigger do

	before :each do 
		@event_class   = MouseMoved
		@trigger_class = MouseMoveTrigger
		@trigger       = @trigger_class.new
	end

	it_should_behave_like "an event trigger"

	it "should match if the trigger buttons is :any" do
		@trigger = @trigger_class.new()
		event = @event_class.new([0,0], [0,0], [:mouse_left])
		@trigger.match?( event ).should be_true
	end

	it "should match if t. buttons is :none and e. buttons is []" do
		@trigger = @trigger_class.new( :none )
		event = @event_class.new([0,0], [0,0], [])
		@trigger.match?( event ).should be_true
	end

	it "should not match if t. buttons is :none and e. buttons is not []" do
		@trigger = @trigger_class.new( :none )
		event = @event_class.new([0,0], [0,0], [:mouse_left])
		@trigger.match?( event ).should be_false
	end

	it "should match if e. buttons includes t. button" do
		@trigger = @trigger_class.new( :mouse_left )
		event = @event_class.new([0,0], [0,0], [:mouse_left, :mouse_right])
		@trigger.match?( event ).should be_true
	end

	it "should not match if e. buttons does not include t. button" do
		@trigger = @trigger_class.new( :mouse_wheel_up )
		event = @event_class.new([0,0], [0,0], [:mouse_left, :mouse_right])
		@trigger.match?( event ).should be_false
	end

	it "should match if t. buttons is same as e. buttons" do
		@trigger = @trigger_class.new( [:mouse_left, :mouse_right] )
		event = @event_class.new([0,0], [0,0], [:mouse_left, :mouse_right])
		@trigger.match?( event ).should be_true
	end

	it "should not match if t. buttons is not same as e. buttons" do
		@trigger = @trigger_class.new( [:mouse_wheel_up, :mouse_right] )
		event = @event_class.new([0,0], [0,0], [:mouse_left, :mouse_right])
		@trigger.match?( event ).should be_false
	end

	it "should not care about buttons order" do
		@trigger = @trigger_class.new( [:mouse_right, :mouse_left] )
		event = @event_class.new([0,0], [0,0], [:mouse_left, :mouse_right])
		@trigger.match?( event ).should be_true
	end

end



describe TickTrigger do 

	before :each do 
		@trigger = TickTrigger.new
	end

	it_should_behave_like "an event trigger"

	it "should match if the event is an instance of ClockTicked" do 
		@trigger.match?( ClockTicked.new(0.1) ).should be_true
	end

	it "should not match if the event is not an instance of TickEvent" do 
		@trigger.match?( :foo ).should be_false
	end
	
end



describe YesTrigger do 
	
	before :each do 
		@trigger = YesTrigger.new
	end
	
	it_should_behave_like "an event trigger"

	it "should match no matter what it is given" do 
		@trigger.match?( true ).should be_true
		@trigger.match?( false ).should be_true
		@trigger.match?( nil ).should be_true
		@trigger.match?( FakeEvent.new(0.1) ).should be_true
		@trigger.match?( :foo ).should be_true
		@trigger.match?( -4 ).should be_true
	end

end
