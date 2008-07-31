
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame


describe EventQueue do
  
  before :each do
    @queue = EventQueue.new
  end

  it "#each should yield each event in the queue in order" do 
    collect = []
    @queue.push( [1,2,3] )
    @queue.each { |e| collect << e}
    collect.should == [1,2,3]
  end

  it "#each should flush the buffer afterwards" do
    @queue.push( [1,2,3] )
    @queue.each { |e| "do nothing" }
    @queue.should be_empty
  end

  it "#each should fetch SDL events if autofetch is on" do
    @queue.autofetch = true
    @queue.stub!(:fetch_sdl_events).and_return([:foo])
    @queue.each { |e| e.should == :foo }
  end


  it "#peek_each should yield each event in the queue in order" do 
    collect = []
    @queue.push( [1,2,3] )
    @queue.peek_each { |e| collect << e}
    collect.should == [1,2,3]
  end

  it "#peek_each should not flush the buffer afterwards" do
    @queue.push( [1,2,3] )
    @queue.peek_each { |e| "do nothing" }
    @queue.should_not be_empty
  end

end
