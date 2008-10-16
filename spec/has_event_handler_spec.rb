
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame

HasEventHandler = Rubygame::EventHandler::HasEventHandler


class HandledObject
  include HasEventHandler
  def initialize
    super
  end
end


describe HasEventHandler do

  before :each do
    @object = HandledObject.new
    @results = []
  end
  
  ###############
  # MAGIC HOOKS #
  ###############

  it "should have a #magic_hooks method" do
    @object.should respond_to(:magic_hooks)
  end

  describe "#magic_hooks" do

    it "should accept a hash" do
      lambda { @object.magic_hooks({}) }.should_not raise_error
    end

    it "should reject non-hashes" do
      lambda { @object.magic_hooks([])            }.should raise_error
      lambda { @object.magic_hooks(EventHook.new) }.should raise_error
      lambda { @object.magic_hooks("string")      }.should raise_error
    end

    it "should accept a valid hook hash" do
      lambda {
        @object.magic_hooks( { :up => :foo } )
      }.should_not raise_error
    end

    ############
    # TRIGGERS #
    ############

    it "should accept :mouse_* symbol triggers" do
      lambda {
        @object.magic_hooks( { :mouse_left       => :foo } )
        @object.magic_hooks( { :mouse_right      => :foo } )
        @object.magic_hooks( { :mouse_middle     => :foo } )
        @object.magic_hooks( { :mouse_wheel_up   => :foo } )
        @object.magic_hooks( { :mouse_wheel_down => :foo } )
      }.should_not raise_error
    end

    it "should accept keyboard symbol triggers" do
      lambda {
        @object.magic_hooks( { :a       => :foo } )
        @object.magic_hooks( { :up      => :foo } )
        @object.magic_hooks( { :space   => :foo } )
        @object.magic_hooks( { :number1 => :foo } )
      }.should_not raise_error
    end

  end



end
