
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame::Events



describe JoystickAxisMoved do

  def make_jam( mods = {} )
    args = {
      :joystick_id => 1, :axis => 2
    }.update(mods)

    JoystickAxisMoved.new( args[:joystick_id],
                           args[:axis] )
  end

  before :each do
    @event = make_jam
  end
  

  it "should have a joystick id" do
    @event.should respond_to(:joystick_id)
  end

  it "should accept positive integers for joystick id" do
    lambda { make_jam }.should_not raise_error
  end

  it "should set joystick id from initialize arg" do
    make_jam.joystick_id.should == 1
  end

  it "should reject all except positive integers for joystick id" do
    lambda { make_jam( :joystick_id => 0     ) }.should raise_error(ArgumentError)
    lambda { make_jam( :joystick_id => -1    ) }.should raise_error(ArgumentError)
    lambda { make_jam( :joystick_id => :foo  ) }.should raise_error(ArgumentError)
    lambda { make_jam( :joystick_id => "red" ) }.should raise_error(ArgumentError)
  end

  it "joystick id should be read-only" do
    @event.should_not respond_to(:joystick_id=)
  end



  it "should have an axis number" do
    @event.should respond_to(:axis)
  end

  it "should accept positive integers for axis number" do
    lambda { make_jam }.should_not raise_error
  end

  it "should set axis from initialize arg" do
    make_jam.axis.should == 2
  end

  it "should reject all except positive integers for axis number" do
    lambda { make_jam( :axis => 0     ) }.should raise_error(ArgumentError)
    lambda { make_jam( :axis => -1    ) }.should raise_error(ArgumentError)
    lambda { make_jam( :axis => 1.2   ) }.should raise_error(ArgumentError)
    lambda { make_jam( :axis => :foo  ) }.should raise_error(ArgumentError)
    lambda { make_jam( :axis => "red" ) }.should raise_error(ArgumentError)
  end

  it "axis number should be read-only" do
    @event.should_not respond_to(:axis=)
  end


  it "should have a value" do
    @event.should respond_to(:value)
  end

  it "should only accept numbers for value"
  it "should reject non-numeric values"
  it "should convert values to float"
  it "should only accept values from -1.0 to 1.0"
  it "should reject values outside of range"

  it "value should be read-only" do
    @event.should_not respond_to(:value=)
  end

end
