
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

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

end
