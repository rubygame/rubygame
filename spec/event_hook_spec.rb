

require 'rubygame'
include Rubygame



describe "EventHook" do

  ##############
  # ATTRIBUTES #
  ##############

  [:owner, :trigger, :action, :consumes, :active].each do |a|

    it "should have an accessor for @#{a}" do
      EventHook.new.should respond_to(a)
      EventHook.new.should respond_to("#{a}=".intern)
    end

    it "should accept :#{a} at creation" do
      e = EventHook.new(a => :value)
      e.send(a).should == :value
    end

    # Default values for attributes.
    # owner, trigger, and action default to nil.
    defaults = {:consumes => false, :active => true}

    it "@#{a} should be #{defaults[a].inspect} by default" do
      EventHook.new.send(a).should == defaults[a]
    end

    it "should allow setting @#{a} post-creation" do
      e = EventHook.new
      e.send("#{a}=".intern, :value)
      e.send(a).should == :value
    end

  end


  ############
  # MATCHING #
  ############

  it "should have a #match? method" do
    EventHook.new.should respond_to(:match?)
  end

  it "#match? should take one event" do
    lambda { EventHook.new.match?(      ) }.should raise_error
    lambda { EventHook.new.match?( 1    ) }.should_not raise_error
    lambda { EventHook.new.match?( 1, 2 ) }.should raise_error
  end

  it "should ask the trigger to see if an event matches" do
    trigger = mock("trigger")
    trigger.should_receive(:match?).with(:event)
    EventHook.new(:trigger => trigger).match?(:event)
  end

  it "should match if the event matches the trigger" do
    trigger = mock("trigger", :match? => true)
    EventHook.new(:trigger => trigger).match?(:event).should be_true
  end

  it "should not match if the event does not match the trigger" do
    trigger = mock("trigger", :match? => false)
    EventHook.new(:trigger => trigger).match?(:event).should be_false
  end

  it "should not match if there is no trigger" do
    EventHook.new.match?(:event).should be_false
  end

  it "should not match if the hook is not active" do
    trigger = mock("trigger", :match? => true)
    e = EventHook.new(:trigger => trigger, :active => false)
    e.match?(:event).should be_false
  end


  ##############
  # PERFORMING #
  ##############

  it "should have a #perform method" do
    EventHook.new.should respond_to(:perform)
  end

  it "#perform should take one event" do
    lambda { EventHook.new.perform(      ) }.should raise_error
    lambda { EventHook.new.perform( 1    ) }.should_not raise_error
    lambda { EventHook.new.perform( 1, 2 ) }.should raise_error
  end

  it "should call the action's #perform with the owner and event" do
    action = mock("action")
    action.should_receive(:perform).with(:owner, :event)
    EventHook.new(:action => action, :owner => :owner).perform(:event)
  end

end
