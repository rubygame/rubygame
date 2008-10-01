
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

  end


end
