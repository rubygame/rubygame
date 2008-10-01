
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame


class EventHandler
  # Peeking inside. Cheating!
  attr_reader :hooks
end


describe EventHandler do

  it "should have no hooks after creation" do
    EventHandler.new.hooks.should be_empty
  end


  #############
  # APPENDING #
  #############

  describe "(appending)" do

    before :each do
      @hook1 = EventHook.new(:trigger => :foo)
      @hook2 = EventHook.new(:trigger => :bar)
      @hash = {
        :owner => "owner", :trigger => "trigger",
        :action => "action", :active => "active",
        :consumes => "consumes" 
      }
    end

    it "should be able to append an EventHook instance" do
      handler = EventHandler.new
      handler.append_hook( @hook1 )
      handler.hooks.should == [@hook1]
    end

    it "should put appended EventHook instances at the end" do
      handler = EventHandler.new
      handler.append_hook( @hook1 )
      handler.append_hook( @hook2 )      
      handler.hooks.should == [@hook1, @hook2]
    end

    it "should move hooks to the end when re-appended" do
      handler = EventHandler.new
      handler.append_hook( @hook1 )
      handler.append_hook( @hook2 )      
      handler.append_hook( @hook1 )
      handler.hooks.should == [@hook2, @hook1]
    end


    it "should be able to append a description Hash" do
      handler = EventHandler.new
      handler.append_hook( @hash )
      handler.should have(1).hooks
    end

    it "should convert a description Hash to an EventHook" do
      handler = EventHandler.new
      handler.append_hook( @hash )
      new_hook = handler.hooks[0]

      new_hook.should be_instance_of( EventHook )
    end

    it "the converted hook should match the description" do
      handler = EventHandler.new
      handler.append_hook( @hash )
      new_hook = handler.hooks[0]

      @hash.each_pair { |k,v| new_hook.send(k).should == v }
    end

  end


end
