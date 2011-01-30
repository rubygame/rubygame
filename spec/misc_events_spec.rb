

require 'rubygame'
include Rubygame::Events



shared_examples_for "a simple event" do
  
  it "should take zero arguments at creation" do
    lambda { @class.new }.should_not raise_error
    lambda { @class.new(:foo) }.should raise_error
  end

end



describe InputFocusGained do
  before :each do
    @class = InputFocusGained
  end

  it_should_behave_like "a simple event"
end

describe InputFocusLost do
  before :each do
    @class = InputFocusLost
  end

  it_should_behave_like "a simple event"
end



describe MouseFocusGained do
  before :each do
    @class = MouseFocusGained
  end

  it_should_behave_like "a simple event"
end

describe MouseFocusLost do
  before :each do
    @class = MouseFocusLost
  end

  it_should_behave_like "a simple event"
end



describe WindowMinimized do
  before :each do
    @class = WindowMinimized
  end

  it_should_behave_like "a simple event"
end

describe WindowUnminimized do
  before :each do
    @class = WindowUnminimized
  end

  it_should_behave_like "a simple event"
end



describe WindowExposed do
  before :each do
    @class = WindowExposed
  end

  it_should_behave_like "a simple event"
end



describe QuitRequested do
  before :each do
    @class = QuitRequested
  end

  it_should_behave_like "a simple event"
end




describe WindowResized do
  
  it "should have a size" do
    WindowResized.new([20,20]).should respond_to(:size)
  end

  it "should accept an [x,y] Array as size" do
    lambda { WindowResized.new([20,20]) }.should_not raise_error(ArgumentError)
  end

  it "should reject negative sizes" do
    lambda { WindowResized.new([-20, 20]) }.should raise_error(ArgumentError)
    lambda { WindowResized.new([ 20,-20]) }.should raise_error(ArgumentError)
    lambda { WindowResized.new([-20,-20]) }.should raise_error(ArgumentError)
  end

  it "should reject size zero" do
    lambda { WindowResized.new([  0, 20]) }.should raise_error(ArgumentError)
    lambda { WindowResized.new([ 20,  0]) }.should raise_error(ArgumentError)
    lambda { WindowResized.new([  0,  0]) }.should raise_error(ArgumentError)
  end

  it "should reject non-Array-like objects as size" do
    lambda { WindowResized.new( 20     ) }.should raise_error(NoMethodError)
    lambda { WindowResized.new( :foo   ) }.should raise_error(NoMethodError)
    lambda { WindowResized.new( "blue" ) }.should raise_error(NoMethodError)
  end

  it "should reject sizes with wrong number of elements" do
    lambda { WindowResized.new([          ]) }.should raise_error(ArgumentError)
    lambda { WindowResized.new([ 20       ]) }.should raise_error(ArgumentError)
    lambda { WindowResized.new([ 20,20,20 ]) }.should raise_error(ArgumentError)
  end

  it "size should be read-only" do
    WindowResized.new([20,20]).should_not respond_to(:size=)
  end

  it "size should be frozen" do
    WindowResized.new([20,20]).size.should be_frozen
  end

  it "should not freeze the original Array passed as size" do
    a = [20,20]
    WindowResized.new(a)
    a.should_not be_frozen
  end

end
