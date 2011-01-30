

require 'rubygame'
include Rubygame::Events



shared_examples_for "a mouse button event" do
  
  it "should have a button symbol" do
    @event.button.should == :mouse_left
  end

  it "should complain if button symbol is not a symbol" do
    lambda { @event.class.new(4) }.should raise_error(ArgumentError)
  end

  it "should complain if button symbol is omitted" do
    lambda { @event.class.new }.should raise_error(ArgumentError)
  end

  it "button symbol should be read-only" do
    @event.should_not respond_to(:button=)
  end



  it "should have a position" do
    @event.pos.should == [1,2]
  end

  it "should complain if position isn't Array-like" do
    lambda { @event.class.new(4,:mouse_left) }.should raise_error
  end

  it "should complain if position is omitted" do
    lambda { @event.class.new(:mouse_left) }.should raise_error(ArgumentError)
  end

  it "position should be read-only" do
    @event.should_not respond_to(:pos=)
  end

  it "position should be frozen" do
    @event.pos.should be_frozen
  end

  it "should not freeze the original position Array" do
    a = [0,0]
    @event.class.new(a, :mouse_left)
    a.should_not be_frozen
  end
 
end



describe MousePressed do

  before :each do
    @event = MousePressed.new( [1,2], :mouse_left )
  end

  it_should_behave_like "a mouse button event"

end



describe MouseReleased do
  
  before :each do
    @event = MouseReleased.new( [1,2], :mouse_left )
  end

  it_should_behave_like "a mouse button event"

end



describe MouseMoved do
  
  before :each do
    @event = MouseMoved.new( [1,2], [3,4], [:mouse_left] )
  end

  it "should have a position" do
    @event.pos.should == [1,2]
  end

  it "should complain if position is not Array-like" do
    lambda { @event.class.new( 4, [3,4] ) }.should raise_error
  end

  it "should complain if position is omitted" do
    lambda { @event.class.new() }.should raise_error(ArgumentError)
  end

  it "position should be frozen" do
    @event.pos.should be_frozen
  end

  it "should not freeze the original position Array" do
    a = [0,0]
    @event.class.new(a, [3,4])
    a.should_not be_frozen
  end
 


  it "should have a relative movement" do
    @event.rel.should == [3,4]
  end

  it "should complain if relative movement is not Array-like" do
    lambda { @event.class.new( [1,2], 4 ) }.should raise_error
  end

  it "should complain if relative movement is omitted" do
    lambda { @event.class.new( [1,2] ) }.should raise_error(ArgumentError)
  end

  it "relative movement should be frozen" do
    @event.rel.should be_frozen
  end

  it "should not freeze the original relative movement Array" do
    a = [0,0]
    @event.class.new([1,2], a)
    a.should_not be_frozen
  end



  it "should have an array of held buttons" do
    @event.buttons.should == [:mouse_left]
  end

  it "should complain if held buttons is not Array-like" do
    lambda { @event.class.new( [1,2], [3,4], 4 ) }.should raise_error
  end

  it "should have no held buttons if omitted" do
    @event = MouseMoved.new( [1,2], [3,4] )
    @event.buttons.should == []
  end

  it "buttons should be frozen" do
    @event.buttons.should be_frozen
  end

  it "should not freeze the original buttons Array" do
    a = [:mouse_left]
    @event.class.new([1,2], [3,4], a)
    a.should_not be_frozen
  end

end
