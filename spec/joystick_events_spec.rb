

require 'rubygame'
include Rubygame::Events



shared_examples_for "a joystick event" do

  ###############
  # JOYSTICK ID #
  ###############

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


##############################
#                            #
#           AXIS             #
#                            #
##############################


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



  ########
  # AXIS #
  ########

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



  #########
  # VALUE #
  #########

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





##############################
#                            #
#           BALL             #
#                            #
##############################


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


  ########
  # BALL #
  ########

  it "should have a ball number" do
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


  #######
  # REL #
  #######

  it "should have a relative position" do
    @event.should respond_to(:rel)
  end

  it "should set relative position from initialize arg" do
    make_event(:rel => [1,2]).rel.should == [1,2]
  end

  it "should reject non-Array relative positions" do
    [1, 1.2, :foo, "red", {}].each do |thing|
      lambda { make_event(:rel => thing) }.should raise_error
    end
  end

  it "should reject relative positions with wrong number of elements" do
    [ [], [0], [0,0,0] ].each do |thing|
      lambda { make_event(:rel => thing) }.should raise_error
    end
  end

  it "rel should be read-only" do
    @event.should_not respond_to(:rel=)
  end

  it "rel should be frozen" do
    @event.rel.should be_frozen
  end

  it "should not freeze the original Array passed as relative position" do
    a = [20,20]
    make_event(:rel => a)
    a.should_not be_frozen
  end


end





##############################
#                            #
#          BUTTONS           #
#                            #
##############################


shared_examples_for "a joystick button event" do

  def make_event( mods = {} )
    args = {
      :joystick_id => 0, :button => 0
    }.update(mods)

    @class.new( args[:joystick_id], args[:button] )
  end


  it_should_behave_like "a joystick event"


  ##########
  # BUTTON #
  ##########

  it "should have a button number" do
    @event.should respond_to(:button)
  end

  it "should set button from initialize arg" do
    make_event(:button => 1).button.should == 1
  end

  it "should accept only non-negative integers for button" do
    [-1, 1.2, :foo, "red", [], {}].each do |thing|
      lambda { make_event(:button => thing) }.should raise_error
    end
  end

  it "button should be read-only" do
    @event.should_not respond_to(:button=)
  end
  
end



describe JoystickButtonPressed do

  before :each do
    @class = JoystickButtonPressed
    @event = make_event
  end

  it_should_behave_like "a joystick button event"

end



describe JoystickButtonReleased do

  before :each do
    @class = JoystickButtonReleased
    @event = make_event
  end

  it_should_behave_like "a joystick button event"

end





##############################
#                            #
#            HAT             #
#                            #
##############################


describe JoystickHatMoved do

  def make_event( mods = {} )
    args = {
      :joystick_id => 0, :hat => 0, :direction => nil
    }.update(mods)

    JoystickHatMoved.new( args[:joystick_id], args[:hat], args[:direction] )
  end

  before :each do
    @event = make_event

    @dir_map = {
      :up         => [ 0, -1],
      :up_right   => [ 1, -1],
      :right      => [ 1,  0],
      :down_right => [ 1,  1],
      :down       => [ 0,  1],
      :down_left  => [-1,  1],
      :left       => [-1,  0],
      :up_left    => [-1, -1],
      nil         => [ 0,  0]
    }
  end
  


  it_should_behave_like "a joystick event"


  #######
  # HAT #
  #######

  it "should have a hat number" do
    @event.should respond_to(:hat)
  end

  it "should set hat from initialize arg" do
    make_event(:hat => 1).hat.should == 1
  end

  it "should accept only non-negative integers for hat" do
    [-1, 1.2, :foo, "red", [], {}].each do |thing|
      lambda { make_event(:hat => thing) }.should raise_error
    end
  end

  it "hat number should be read-only" do
    @event.should_not respond_to(:hat=)
  end


  #############
  # DIRECTION #
  #############

  it "should have a direction" do
    @event.should respond_to(:direction)
  end

  it "should set direction from initialize arg" do
    make_event(:direction => :up).direction.should == :up
  end

  it "should accept valid directions" do
    @dir_map.keys.each do |thing|
      lambda { make_event(:direction => thing) }.should_not raise_error
    end
  end

  it "should not accept invalid directions" do
    [-1, 1.2, "red", :foo, [], {}].each do |thing|
      lambda { make_event(:direction => thing) }.should raise_error
    end
  end

  it "direction should be read-only" do
    @event.should_not respond_to(:direction=)
  end


  ##############
  # HORIZONTAL #
  ##############

  it "should have a horizontal direction" do
    @event.should respond_to(:horizontal)
  end

  it "horizontal direction should be derived from direction" do
    @dir_map.each_pair do |dir, hv|
      make_event(:direction => dir).horizontal.should == hv[0]
    end
  end

  it "horizontal direction should be read-only" do
    @event.should_not respond_to(:horizontal=)
  end


  ############
  # VERTICAL #
  ############

  it "should have a vertical direction" do
    @event.should respond_to(:vertical)
  end

  it "vertical direction should be derived from direction" do
    @dir_map.each_pair do |dir, hv|
      make_event(:direction => dir).vertical.should == hv[1]
    end
  end

  it "vertical direction should be read-only" do
    @event.should_not respond_to(:vertical=)
  end


  #########
  # LEFT? #
  #########

  it "should have #left?" do
    @event.should respond_to(:left?)
  end

  it "#left? should be true when leftish" do
    [:left, :up_left, :down_left].each do |thing|
      make_event(:direction => thing).left?.should be_true
    end
  end

  it "#left? should be false when not leftish" do
    [:up, :up_right, :right, :down_right, :down, nil].each do |thing|
      make_event(:direction => thing).left?.should be_false
    end
  end


  ##########
  # RIGHT? #
  ##########

  it "should have #right?" do
    @event.should respond_to(:right?)
  end

  it "#right? should be true when rightish" do
    [:right, :up_right, :down_right].each do |thing|
      make_event(:direction => thing).right?.should be_true
    end
  end

  it "#right? should be false when not rightish" do
    [:up, :down, :down_left, :left, :up_left, nil].each do |thing|
      make_event(:direction => thing).right?.should be_false
    end
  end


  #######
  # UP? #
  #######

  it "should have #up?" do
    @event.should respond_to(:up?)
  end

  it "#up? should be true when uppish" do
    [:up, :up_right, :up_left].each do |thing|
      make_event(:direction => thing).up?.should be_true
    end
  end

  it "#up? should be false when not uppish" do
    [:right, :down_right, :down, :down_left, :left, nil].each do |thing|
      make_event(:direction => thing).up?.should be_false
    end
  end


  #########
  # DOWN? #
  #########

  it "should have #down?" do
    @event.should respond_to(:down?)
  end

  it "#down? should be true when downish" do
    [:down_right, :down, :down_left].each do |thing|
      make_event(:direction => thing).down?.should be_true
    end
  end

  it "#down? should be false when not downish" do
    [:up, :up_right, :right, :left, :up_left, nil].each do |thing|
      make_event(:direction => thing).down?.should be_false
    end
  end


  ###########
  # CENTER? #
  ###########

  it "should have #center?" do
    @event.should respond_to(:center?)
  end

  it "#center should be true when direction is nil" do
    make_event(:direction => nil).center?.should be_true
  end

  it "#center should be false when direction is not nil" do
    dirs = @dir_map.keys - [nil]

    dirs.each do |dir|
      make_event(:direction => dir).center?.should be_false
    end
  end


end
