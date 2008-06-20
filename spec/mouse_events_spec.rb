
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame::Events



describe "a mouse button event", :shared => true do
  
  it "should have a button symbol"

  it "should complain if button symbol is not a symbol"

  it "should have a position"

  it "should complain if position is not an array"
 
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
