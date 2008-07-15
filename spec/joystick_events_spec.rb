
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame::Events



describe "a joystick event", :shared => true do

  it "should have a joystick id" do
    make_event.should respond_to(:joystick_id)
  end

  it "should set joystick id from initialize arg" do
    make_event(:joystick_id => 1).joystick_id.should == 1
  end

  it "should accept only non-negative integers for joystick id" do
    [-1, 1.2, :foo, "red", [], {}].each do |thing|
      lambda { make_event(:joystick_id => thing) }.should raise_error
    end
  end

  it "joystick id should be read-only" do
    make_event.should_not respond_to(:joystick_id=)
  end

end



describe JoystickAxisMoved do

  def make_event( mods = {} )
    args = {
      :joystick_id => 0, :axis => 0, :value => 0.0
    }.update(mods)

    JoystickAxisMoved.new( args[:joystick_id],
                           args[:axis],
                           args[:value] )
  end

  before :each do
    @event = make_event
  end
  


  it_should_behave_like "a joystick event"



  it "should have an axis number" do
    @event.should respond_to(:axis)
  end

  it "should set axis from initialize arg" do
    make_event(:axis => 1).axis.should == 1
  end

  it "should accept only non-negative integers for axis" do
    [-1, 1.2, :foo, "red", [], {}].each do |thing|
      lambda { make_event(:axis => thing) }.should raise_error
    end
  end

  it "axis number should be read-only" do
    @event.should_not respond_to(:axis=)
  end



  it "should have a value" do
    @event.should respond_to(:value)
  end

  it "should set value from initialize arg" do
    make_event(:value => 0.5).value.should == 0.5
  end

  it "should reject non-numeric values" do
    [:foo, "red", [], {}].each do |thing|
      lambda { make_event(:value => thing) }.should raise_error
    end
  end

  it "should convert values to float" do
    make_event(:value => 1).value.should eql(1.0)
  end

  it "should reject values not in -1.0 to 1.0" do
    [-10, -1.01, 1.01, 10].each do |thing|
      lambda { make_event(:value => thing) }.should raise_error
    end
  end

  it "value should be read-only" do
    @event.should_not respond_to(:value=)
  end

end





describe JoystickBallMoved do

  def make_event( mods = {} )
    args = {
      :joystick_id => 0, :ball => 0, :rel => [0,0]
    }.update(mods)

    JoystickBallMoved.new( args[:joystick_id],
                           args[:ball],
                           args[:rel] )
  end

  before :each do
    @event = make_event
  end
  


  it_should_behave_like "a joystick event"



  it "should have an ball number" do
    @event.should respond_to(:ball)
  end

  it "should set ball from initialize arg" do
    make_event(:ball => 1).ball.should == 1
  end

  it "should accept only non-negative integers for ball" do
    [-1, 1.2, :foo, "red", [], {}].each do |thing|
      lambda { make_event(:ball => thing) }.should raise_error
    end
  end

  it "ball number should be read-only" do
    @event.should_not respond_to(:ball=)
  end



  it "should have a relative position" do
    @event.should respond_to(:rel)
  end

  it "should set relative position from initialize arg" do
    make_event(:rel => [1,2]).rel.should == [1,2]
  end

end
