

require 'rubygame'
include Rubygame



describe EventQueue do
  
  before :each do
    @queue = EventQueue.new
  end



  #############
  # AUTOFETCH #
  #############

  it "autofetch should be on by default" do
    @queue.autofetch.should be_true
  end

  it "should have autofetch read-write accessors" do
    @queue.should respond_to(:autofetch)
    @queue.should respond_to(:autofetch=)
  end



  ########
  # EACH #
  ########

  it "#each should yield each event in the queue in order" do 
    collect = []
    @queue.push( [1,2,3] )
    @queue.each { |e| collect << e}
    collect.should == [1,2,3]
  end

  it "#each should flush the buffer afterwards" do
    @queue.push( [1,2,3] )
    @queue.each {}
    @queue.should be_empty
  end

  it "#each should fetch SDL events if autofetch is on" do
    @queue.autofetch = true

    @queue.should_receive(:fetch_sdl_events).and_return([:foo])
    @queue.each {}
  end

  it "#each should not fetch SDL events if autofetch is off" do
    @queue.autofetch = false

    @queue.should_not_receive(:fetch_sdl_events)
    @queue.each {}
  end



  #############
  # PEEK EACH #
  #############

  it "#peek_each should yield each event in the queue in order" do 
    collect = []
    @queue.push( [1,2,3] )
    @queue.peek_each { |e| collect << e}
    collect.should == [1,2,3]
  end

  it "#peek_each should not flush the buffer afterwards" do
    @queue.push( [1,2,3] )
    @queue.peek_each {}
    @queue.should_not be_empty
  end

  it "#peek_each should fetch SDL events if autofetch is on" do
    @queue.autofetch = true

    @queue.should_receive(:fetch_sdl_events).and_return([:foo])
    @queue.peek_each {}
  end

  it "#peek_each should not fetch SDL events if autofetch is off" do
    @queue.autofetch = false

    @queue.should_not_receive(:fetch_sdl_events)
    @queue.peek_each {}
  end



  ####################
  # FETCH SDL EVENTS #
  ####################

  it "should fetch SDL events from the old place by default" do
    Rubygame.should_receive(:fetch_sdl_events).and_return([])
    @queue.fetch_sdl_events
  end

  it "should fetch SDL events from the new place if enabled" do
    Rubygame::Events.should_receive(:fetch_sdl_events).and_return([])
    @queue.enable_new_style_events
    @queue.fetch_sdl_events
  end




  ##########
  # IGNORE #
  ##########

  it "should provide @ignore read-write accessors" do
    @queue.should respond_to(:ignore)
    @queue.should respond_to(:ignore=)
  end

  it "should silently reject pushed objects whose class is ignored" do
    @queue.ignore << Fixnum
    @queue.push( :foo, 3, :baz )
    @queue.to_ary.should == [:foo, :baz]
  end


  ###############
  # PUSH / POST #
  ###############

  it "should accept pushes" do
    @queue.push( :foo )
    @queue.to_ary.should == [:foo]
  end

  it "should accept multiple pushes at once" do
    @queue.push( :foo, :bar, :baz )
    @queue.to_ary.should == [:foo, :bar, :baz]
  end

  it "should accept a pushed array" do
    @queue.push( [:foo, :bar] )
    @queue.to_ary.should == [:foo, :bar]
  end

  it "should accept posts" do
    @queue.post( :foo )
    @queue.to_ary.should == [:foo]
  end

  it "should accept multiple posts at once" do
    @queue.post( :foo, :bar, :baz )
    @queue.to_ary.should == [:foo, :bar, :baz]
  end

  it "should accept a posted array" do
    @queue.post( [:foo, :bar] )
    @queue.to_ary.should == [:foo, :bar]
  end

  it "should accept <<" do
    @queue << :foo
    @queue.to_ary.should == [:foo]
  end

end
