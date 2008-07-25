
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame::Events



describe "a keyboard event", :shared => true do
  
  it "should have a key symbol" do
    @event.key.should == :a
  end

  it "should complain if key symbol is not a symbol" do
    lambda { @event.class.new( 4 ) }.should raise_error(ArgumentError)
  end

  it "should have an array of modifiers" do
    @event.modifiers.should == [:shift]
  end

  it "should complain if modifiers is not Array-like" do
    lambda { @event.class.new( :a, 4 ) }.should raise_error
  end

  it "modifiers should be frozen" do
    @event.modifiers.should be_frozen
  end

  it "should not freeze the original modifiers Array" do
    mods = [:shift]
    @event.class.new( :a, mods )
    mods.should_not be_frozen
  end
 
end



describe KeyPressed do

  before :each do
    @event = KeyPressed.new( :a, [:shift], "A" )
  end

  it_should_behave_like "a keyboard event"

  it "should have a string" do
    @event.string.should == "A"
  end

  it "should complain if string is not a string" do
    lambda {
      @event.class.new( :a, [:shift], 4 ) 
    }.should raise_error(ArgumentError)
  end

end


describe KeyReleased do
  
  before :each do
    @event = KeyReleased.new( :a, [:shift] )
  end

  it_should_behave_like "a keyboard event"

end
