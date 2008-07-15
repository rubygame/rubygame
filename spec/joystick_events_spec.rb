
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame::Events



describe JoystickAxisMoved do

  def make_jam( mods = {} )
    args = {
      :joystick_id => 1, :axis => 2, :value => 0.5
    }.update(mods)

    JoystickAxisMoved.new( args[:joystick_id],
                           args[:axis],
                           args[:value] )
  end

  before :each do
    @event = make_jam
  end
  

  it "should have a joystick id" do
    @event.should respond_to(:joystick_id)
  end

  it "should set joystick id from initialize arg" do
    @event.joystick_id.should == 1
  end

  it "should reject all except positive integers for joystick id" do
    [0, -1, 1.2, :foo, "red", [], {}].each do |thing|
      lambda { make_jam(:joystick_id => thing) }.should raise_error
    end
  end

  it "joystick id should be read-only" do
    @event.should_not respond_to(:joystick_id=)
  end



  it "should have an axis number" do
    @event.should respond_to(:axis)
  end

  it "should set axis from initialize arg" do
    @event.axis.should == 2
  end

  it "should reject all except positive integers for axis number" do
    [0, -1, 1.2, :foo, "red", [], {}].each do |thing|
      lambda { make_jam(:axis => thing) }.should raise_error
    end
  end

  it "axis number should be read-only" do
    @event.should_not respond_to(:axis=)
  end



  it "should have a value" do
    @event.should respond_to(:value)
  end

  it "should set value from initialize arg" do
    @event.value.should == 0.5
  end

  it "should reject non-numeric values" do
    [:foo, "red", [], {}].each do |thing|
      lambda { make_jam(:value => thing) }.should raise_error
    end
  end

  it "should convert values to float"
  it "should only accept values from -1.0 to 1.0"
  it "should reject values outside of range"

  it "value should be read-only" do
    @event.should_not respond_to(:value=)
  end

end
