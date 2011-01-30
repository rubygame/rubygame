# This is mostly for regression testing and bugfix confirmation at the moment.


require 'rubygame'
include Rubygame
include Rubygame::Events



describe Clock do

  before :each do
    @clock = Clock.new
  end

  after :each do
    Rubygame.quit
  end


  it "should have a granularity accessor" do
    lambda{@clock.granularity = 5}.should_not raise_error
  end

  it "should have a nice accessor" do
    lambda{@clock.nice = true}.should_not raise_error
  end


  describe "with target" do

    it "should pass frametime, granularity, and nice to Clock.delay" do
      @clock.target_frametime = 1
      @clock.granularity = 2
      @clock.nice = true

      Clock.should_receive(:delay).with(1,2,true).and_return(1)
      @clock.tick
    end

  end


  describe "with tick events" do

    before :each do
      @clock.enable_tick_events
    end
    

    it "should return ClockTicked events" do
      @clock.tick.should be_instance_of(ClockTicked)
    end


    it "should cache ClockTicked events" do
      Clock.stub!(:delay).and_return(10)
      # Make sure they are the same exact object
      @clock.tick.should equal(@clock.tick)
    end

  end


  describe "without tick events" do
    
    it "should return integer ticks" do
      @clock.tick.should be_instance_of(Fixnum)
    end

  end

end
