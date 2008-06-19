
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame::Events



describe "a keyboard event", :shared => true do
  
  it "should have a key symbol" do
    @event.key.should == :a
  end

  it "should have an array of modifiers" do
    @event.modifiers.should == [:shift]
  end
 
end



describe "KeyPressed Event" do

  before :each do
    @event = KeyPressed.new( :a, [:shift], "A" )
  end

  it_should_behave_like "a keyboard event"

  it "should have a utf8 string"

end


describe "KeyReleased Event" do
  
  before :each do
    @event = KeyReleased.new( :a, [:shift] )
  end

  it_should_behave_like "a keyboard event"

end
