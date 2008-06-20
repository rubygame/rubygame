
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame::Events



describe "a mouse button event", :shared => true do
  
  it "should have a button symbol" do
    @event.button.should == :mouse_left
  end

  it "should complain if button symbol is not a symbol" do
    lambda { @event.class.new(4) }.should raise_error(ArgumentError)
  end

  it "should complain if button symbol is omitted" do
    lambda { @event.class.new }.should raise_error(ArgumentError)
  end


  it "should have a position" do
    @event.pos.should == [1,2]
  end

  it "should complain if position is not an array" do
    lambda { @event.class.new(:mouse_left,4) }.should raise_error(ArgumentError)
  end

  it "should complain if position is omitted" do
    lambda { @event.class.new(:mouse_left) }.should raise_error(ArgumentError)
  end
 
end



describe "MousePressed" do

  before :each do
    @event = MousePressed.new( [1,2], :mouse_left )
  end

  it_should_behave_like "a mouse button event"

end



describe "MouseReleased" do
  
  before :each do
    @event = MouseReleased.new( [1,2], :mouse_left )
  end

  it_should_behave_like "a mouse button event"

end



describe "MouseMoved" do
  
  before :each do
    @event = MouseMoved.new( [1,2], [3,4], [:mouse_left] )
  end

  it "should have a position" do
    @event.pos.should == [1,2]
  end

  it "should complain if position is not an Array" do
    lambda { @event.class.new( 4, [3,4] ) }.should raise_error(ArgumentError)
  end

  it "should complain if position is omitted" do
    lambda { @event.class.new() }.should raise_error(ArgumentError)
  end

  it "should have a relative movement" do
    @event.rel.should == [3,4]
  end

  it "should complain if relative movement is not an Array" do
    lambda { @event.class.new( [1,2], 4 ) }.should raise_error(ArgumentError)
  end

  it "should complain if relative movement is omitted" do
    lambda { @event.class.new( [1,2] ) }.should raise_error(ArgumentError)
  end

  it "should have an array of held buttons" do
    @event.buttons.should == [:mouse_left]
  end

  it "should complain if held buttons is not an Array"

  it "should have no held buttons if omitted"


end
