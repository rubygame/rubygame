
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

  it "should complain if position is not an array"

  it "should complain if position is omitted" do
    lambda { @event.class.new(:mouse_left) }.should raise_error(ArgumentError)
  end
 
end



describe "MousePressed" do

  before :each do
    @event = MousePressed.new( :mouse_left, [1,2] )
  end

  it_should_behave_like "a mouse button event"

end


describe "MouseReleased" do
  
  before :each do
    @event = MouseReleased.new( :mouse_left, [1,2] )
  end

  it_should_behave_like "a mouse button event"

end
