

require 'rubygame'
include Rubygame::Events



shared_examples_for "a keyboard event" do
  
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

  it "should complain if string is not String-like" do
    lambda {@event.class.new( :a, [:shift], 4 )}.should raise_error
  end

  it "string should be frozen" do
    @event.string.should be_frozen
  end

end


describe KeyReleased do
  
  before :each do
    @event = KeyReleased.new( :a, [:shift] )
  end

  it_should_behave_like "a keyboard event"

end



describe "Rubygame.pressed_keys" do

  # Helper method to make an Array like would be returned from
  # SDL.GetKeyState. If you pass SDL::K_* constants to this method,
  # they will be marked as "pressed" in the array.
  # 
  def mock_keys( *pressed )
    keys = Array.new(SDL::K_LAST, 0)
    pressed.each{ |key| keys[key] = 1 }
    keys
  end

  it "should query SDL.GetKeyState" do
    SDL.should_receive(:GetKeyState).and_return( mock_keys() )
    Rubygame.pressed_keys
  end

  it "should return an empty hash when no keys are pressed" do
    SDL.stub(:GetKeyState){ mock_keys() }
    Rubygame.pressed_keys.should == {}
  end

  it "should have a pair for every pressed key" do
    SDL.stub(:GetKeyState){ mock_keys( SDL::K_a, SDL::K_LCTRL ) }
    keys = Rubygame.pressed_keys
    keys.should have_key( :a )
    keys.should have_key( :left_ctrl )
  end

  it "should have a value of true for every pressed key" do
    SDL.stub(:GetKeyState){ mock_keys( SDL::K_a, SDL::K_LCTRL ) }
    keys = Rubygame.pressed_keys
    keys[:a].should be_true
    keys[:left_ctrl].should be_true
  end

  it "should have a falsey value for non-pressed keys" do
    SDL.stub(:GetKeyState){ mock_keys( SDL::K_a, SDL::K_LCTRL ) }
    keys = Rubygame.pressed_keys
    keys[:b].should satisfy{ |v|  not v }
    keys[:left_shift].should satisfy{ |v|  not v }
  end

end
