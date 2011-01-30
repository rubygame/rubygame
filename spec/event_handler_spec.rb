

require 'rubygame'
include Rubygame
include Rubygame::EventActions
include Rubygame::EventTriggers



################
# SPEC HELPERS #
################

class TestEvent
  def initialize( foo=true ); @foo = foo; end
  attr_reader :foo
end

class TestTrigger
  def initialize( match=true )
    @match = match
  end

  def match?(e)
    return (@match and e.foo and
            ((@match == true) or
             (e.foo == true) or
             (e.foo == @match)))
  end
end


# Creates the DESCRIPTION HASH for an EventHook which matches
# any event and appends a string to the owner when performed.
def hash_factory( owner, output )
  return {
    :owner    => owner,
    :trigger  => TestTrigger.new(output),
    :action   => BlockAction.new{|o,e| o << output},
    :active   => true,
    :consumes => false
  }
end

# Creates an EventHook which matches any event and appends
# a string to the owner when performed.
def hook_factory( owner, output )
  return EventHook.new( hash_factory(owner, output) ) 
end



#########
# SPECS #
#########

describe EventHandler do

  before :each do
    @handler = EventHandler.new
    @results = []
    @hook1 = hook_factory( @results, "hook1" )
    @hook2 = hook_factory( @results, "hook2" )
    @hash1 = hash_factory( @results, "hash1" )
    @hash2 = hash_factory( @results, "hash2" )
    @event = TestEvent.new(true)
  end


  it "should have no hooks after creation" do
    @handler.handle(@event)
    @results.should == []
  end


  #############
  # APPENDING #
  #############

  describe "(appending)" do

    ###############
    # EVENT HOOK  #
    ###############

    it "should be able to append an EventHook instance" do
      @handler.append_hook( @hook1 )
      @handler.handle(@event)
      @results.should == ["hook1"]
    end

    it "should put appended EventHook instances at the end" do
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )      
      @handler.handle(@event)
      @results.should == ["hook1", "hook2"]
    end

    it "should move hooks to the end when re-appended" do
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )      
      @handler.append_hook( @hook1 )
      @handler.handle(@event)
      @results.should == ["hook2", "hook1"]
    end

    it "should return the appended EventHook instance" do
      @handler.append_hook( @hook1 ).should == @hook1      
    end

    ####################
    # HASH DESCRIPTION #
    ####################

    it "should be able to append a description Hash" do
      @handler.append_hook( @hash1 )
      @handler.handle(@event)
      @results.should == ["hash1"]
    end

    it "should return an EventHook when appending a description Hash" do
      new_hook = @handler.append_hook( @hash1 )
      new_hook.should be_instance_of( EventHook )
    end

    it "the returned EventHook should match the description Hash" do
      new_hook = @handler.append_hook( @hash1 )
      @hash1.each_pair { |k,v| new_hook.send(k).should == v }
    end

  end



  ##############
  # PREPENDING #
  ##############

  describe "(prepending)" do

    ###############
    # EVENT HOOK  #
    ###############

    it "should be able to prepend an EventHook instance" do
      @handler.prepend_hook( @hook1 )
      @handler.handle(@event)
      @results.should == ["hook1"]
    end

    it "should put prepended EventHook instances at the front" do
      @handler.append_hook( @hook1 )
      @handler.prepend_hook( @hook2 )      
      @handler.handle(@event)
      @results.should == ["hook2", "hook1"]
    end

    it "should move hooks to the front when re-prepended" do
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )      
      @handler.prepend_hook( @hook2 )
      @handler.handle(@event)
      @results.should == ["hook2", "hook1"]
    end

    it "should return the prepended EventHook instance" do
      @handler.prepend_hook( @hook1 ).should == @hook1      
    end

    ####################
    # HASH DESCRIPTION #
    ####################

    it "should be able to prepend a description Hash" do
      @handler.prepend_hook( @hash1 )
      @handler.handle(@event)
      @results.should == ["hash1"]
    end

    it "should return an EventHook when prepending a description Hash" do
      new_hook = @handler.prepend_hook( @hash1 )
      new_hook.should be_instance_of( EventHook )
    end

    it "the returned EventHook should match the description Hash" do
      new_hook = @handler.prepend_hook( @hash1 )
      @hash1.each_pair { |k,v| new_hook.send(k).should == v }
    end

  end



  ############
  # HANDLING #
  ############

  describe "(handling)" do

    it "should check all hook triggers to see if the event matches" do
      @hook1.trigger.should_receive(:match?).with(@event)
      @hook2.trigger.should_receive(:match?).with(@event)
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )
      @handler.handle(@event)
    end
    
    it "should perform actions of matching hooks" do
      @hook1.action.should_receive(:perform).with(@results, @event)
      @hook2.action.should_receive(:perform).with(@results, @event)
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )
      @handler.handle(@event)
    end

    it "should not perform actions of non-matching hooks" do
      @event = TestEvent.new("hook1")
      @hook1.action.should_receive(:perform).with(@results, @event)
      @hook2.action.should_not_receive(:perform)
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )
      @handler.handle( @event )
    end

    it "should not perform actions of inactive hooks" do
      @hook2.active = false
      @hook2.action.should_not_receive(:perform)
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )
      @handler.handle( @event )
    end

    it "should not perform later actions after event is consumed" do
      @hook1.consumes = true
      @hook1.action.should_receive(:perform).with(@results, @event)
      @hook2.action.should_not_receive(:perform)
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )
      @handler.handle(@event)
    end

    it "non-matching triggers should not consume events" do
      @hook1.consumes = true
      @hook1.active = false
      @hook1.action.should_not_receive(:perform)
      @hook2.action.should_receive(:perform).with(@results, @event)
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )
      @handler.handle(@event)
    end

  end



  #############
  # HAS_HOOK? #
  #############

  describe "(has_hook?)" do
    
    it "should not have hooks that haven't been added" do
      @handler.has_hook?(@hook1).should be_false
      @handler.has_hook?(@hook2).should be_false
    end

    it "should have hooks that have been added" do
      @handler.append_hook(@hook1)
      @handler.prepend_hook(@hook2)
      @handler.has_hook?(@hook1).should be_true
      @handler.has_hook?(@hook2).should be_true
    end

  end



  ############
  # REMOVING #
  ############

  describe "(removing)" do
    
    it "should remove the hook if it is on the stack" do
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )
      @handler.remove_hook( @hook2 )
      @handler.should_not have_hook(@hook2)
    end

    it "should not remove any hooks except the given one" do
      @handler.append_hook( @hook1 )
      @handler.append_hook( @hook2 )
      @handler.remove_hook( @hook2 )
      @handler.should have_hook(@hook1)
    end

    it "should have no effect if the hook is not on the stack" do
      @handler.append_hook( @hook1 )
      @handler.remove_hook( @hook2 )
      @handler.should_not have_hook(@hook2)
    end

  end

end
