

require 'rubygame'
include Rubygame
include Rubygame::EventTriggers
include Rubygame::EventActions



HasEventHandler = Rubygame::EventHandler::HasEventHandler

class HandledObject
  include HasEventHandler
end


describe HasEventHandler do

  before :each do
    @object = HandledObject.new
    @results = []
  end
  
  ###############
  # MAGIC HOOKS #
  ###############

  it "should have a #make_magic_hooks method" do
    @object.should respond_to(:make_magic_hooks)
  end

  describe "#make_magic_hooks" do

    it "should accept a hash" do
      lambda { @object.make_magic_hooks({}) }.should_not raise_error
    end

    it "should reject non-hashes" do
      lambda { @object.make_magic_hooks(EventHook.new) }.should raise_error
      lambda { @object.make_magic_hooks("string")      }.should raise_error
    end

    it "should accept a valid hook hash" do
      lambda {
        @object.make_magic_hooks( { :up => :foo } )
      }.should_not raise_error
    end

    it "should accept a hook hash with multiple pairs" do
      lambda {
        @object.make_magic_hooks( { :up => :foo,
                               :down => :bar,
                               :mouse_left => :shoot } )
      }.should_not raise_error
    end

    it "should return an Array of EventHook instances" do
      hooks = @object.make_magic_hooks( { :up => :foo,
                             :down => :bar,
                             :mouse_left => :shoot } )

      hooks.should be_instance_of(Array)
      hooks.each { |hook| hook.should be_instance_of(EventHook) }
    end

    ############
    # TRIGGERS #
    ############

    it "should accept :mouse_* symbol triggers" do
      lambda {
        @object.make_magic_hooks( { :mouse_left       => :foo } )
        @object.make_magic_hooks( { :mouse_right      => :foo } )
        @object.make_magic_hooks( { :mouse_middle     => :foo } )
        @object.make_magic_hooks( { :mouse_wheel_up   => :foo } )
        @object.make_magic_hooks( { :mouse_wheel_down => :foo } )
      }.should_not raise_error
    end

    it "should turn :mouse_* symbols into MousePressTriggers" do
      hooks = @object.make_magic_hooks( {:mouse_left => :foo })
      hooks[0].trigger.should be_instance_of(MousePressTrigger)
    end

    it "should accept keyboard symbol triggers" do
      lambda {
        @object.make_magic_hooks( { :a       => :foo } )
        @object.make_magic_hooks( { :up      => :foo } )
        @object.make_magic_hooks( { :space   => :foo } )
        @object.make_magic_hooks( { :number1 => :foo } )
      }.should_not raise_error
    end

    it "should turn keyboard symbols into KeyPressTriggers" do
      hooks = @object.make_magic_hooks( {:a => :foo })
      hooks[0].trigger.should be_instance_of(KeyPressTrigger)
    end

    it "should accept classes as triggers" do
      lambda {
        @object.make_magic_hooks( { Object => :foo } )
        @object.make_magic_hooks( { Events::MousePressed => :foo } )
        @object.make_magic_hooks( { Events::WindowResized => :foo } )
      }.should_not raise_error
    end

    it "should turn classes into InstanceOfTriggers" do
      hooks = @object.make_magic_hooks( {Object => :foo })
      hooks[0].trigger.should be_instance_of(InstanceOfTrigger)
    end

    it "should turn :tick into TickTrigger" do
      hooks = @object.make_magic_hooks( {:tick => :foo })
      hooks[0].trigger.should be_instance_of(TickTrigger)
    end

    it "should accept objects with #match? as triggers" do
      fake_trigger = Object.new
      class << fake_trigger; def match?; end; end

      lambda {
        @object.make_magic_hooks( { fake_trigger => :foo } )
      }.should_not raise_error
    end

    it "should use a dup of #match? triggers" do
      class FakeTrigger; def match?; end; end
      fake_trigger = FakeTrigger.new

      hooks = @object.make_magic_hooks( { fake_trigger => :foo } )

      hooks[0].trigger.should be_instance_of(FakeTrigger)
      hooks[0].trigger.should_not eql(fake_trigger)
    end

    it "should not accept invalid triggers" do
      lambda {
        @object.make_magic_hooks( { Object.new => :foo } )
      }.should raise_error(ArgumentError)

      lambda {
        @object.make_magic_hooks( { "string" => :foo } )
      }.should raise_error(ArgumentError)

      lambda {
        @object.make_magic_hooks( { 1 => :foo } )
      }.should raise_error(ArgumentError)
    end


    ###########
    # ACTIONS #
    ###########

    it "should accept method name symbol actions" do
      lambda {
        @object.make_magic_hooks( { :up => :foo } )
      }.should_not raise_error
    end

    it "should turn method names into MethodActions" do
      hooks = @object.make_magic_hooks( { :up => :foo } )
      hooks[0].action.should be_instance_of(MethodAction)
    end

    it "should accept Proc actions" do
      lambda {
        @object.make_magic_hooks( { :up => Proc.new { |o,e| :foo } } )
      }.should_not raise_error
    end

    it "should turn Procs into BlockActions" do
      hooks = @object.make_magic_hooks( { :up => Proc.new { |o,e| :foo } } )
      hooks[0].action.should be_instance_of(BlockAction)
    end

    it "should accept detached method actions" do
      lambda {
        @object.make_magic_hooks( { :up => Object.new.method(:to_s) } )
      }.should_not raise_error
    end

    it "should turn detached ethods into BlockActions" do
      hooks = @object.make_magic_hooks( { :up => Object.new.method(:to_s) } )
      hooks[0].action.should be_instance_of(BlockAction)
    end

    it "should accept objects with #perform as actions" do
      fake_action = Object.new
      class << fake_action; def perform; end; end

      lambda {
        @object.make_magic_hooks( { :up => fake_action } )
      }.should_not raise_error
    end

    it "should use a dup of #perform actions" do
      class FakeAction; def perform; end; end
      fake_action = FakeAction.new

      hooks = @object.make_magic_hooks( { :up => fake_action } )

      hooks[0].action.should be_instance_of(FakeAction)
      hooks[0].action.should_not eql(fake_action)
    end

    it "should not accept invalid actions" do
      lambda {
        @object.make_magic_hooks( { :up => Object.new } )
      }.should raise_error(ArgumentError)

      lambda {
        @object.make_magic_hooks( { :up => "string" } )
      }.should raise_error(ArgumentError)

      lambda {
        @object.make_magic_hooks( { :up => 1 } )
      }.should raise_error(ArgumentError)
    end

  end


  describe "#make_magic_hooks_for" do
    
    it "should use the given owner" do
      hooks = @object.make_magic_hooks_for( :owner, {:a => :foo } )
      hooks[0].owner.should == :owner
    end

  end


  # Regression test
  it "#handle should not eat NoMethodErrors" do
    @object.make_magic_hooks( :a => proc{ bad_method_call() } )
    lambda {
      @object.handle( Events::KeyPressed.new(:a) )
    }.should raise_error(NoMethodError)
  end

end
