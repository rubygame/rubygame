# TODO: More specs!

# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )

require 'rubygame'
include Rubygame


describe Screen do

  before :each do
    Rubygame.init
  end

  after :each do
    Rubygame.quit
  end

  it "should not be open by default" do
    Screen.open?.should be_false
  end

  it ".new should open the display window" do
    Screen.new( [10,10] )
    Screen.open?.should be_true
  end

  it ".open should open the display window" do
    Screen.open( [10,10] )
    Screen.open?.should be_true
  end

  it ".set_mode should open the display window" do
    Screen.set_mode( [10,10] )
    Screen.open?.should be_true
  end

  it ".instance should open the display window" do
    Screen.instance( [10,10] )
    Screen.open?.should be_true
  end

  it ".close should close the display window if open" do
    Screen.open( [10,10] )
    Screen.close
    Screen.open?.should be_false
  end

  it ".close should do nothing if the display window is not open" do
    Screen.close
    Screen.open?.should be_false
  end

  it "should not be open after Rubygame.quit" do
    Screen.new( [10,10] )
    Rubygame.quit
    Screen.open?.should be_false
  end


  describe "instance" do

    it "should be open after opening it" do
      screen = Screen.open( [10,10] )
      screen.should be_open
    end

    it "should have a close method" do
      screen = Screen.open( [10,10] )
      lambda{ screen.close }.should_not raise_error
    end

    it "should not be open after #close" do
      screen = Screen.open( [10,10] )
      screen.close
      screen.should_not be_open
    end

    it "should not be open after Screen.close" do
      screen = Screen.open( [10,10] )
      Screen.close
      screen.should_not be_open
    end

    it "should not be open after #close and re-open" do
      screen = Screen.open( [10,10] )
      screen.close
      Screen.open( [10,10] )
      screen.should_not be_open
    end

    it "should not be open after Rubygame.quit" do
      screen = Screen.open( [10,10] )
      Rubygame.quit
      screen.should_not be_open
    end

    it "#close should not raise error when already closed" do
      screen = Screen.open( [10,10] )
      screen.close
      lambda{ screen.close }.should_not raise_error
    end

    it "#close should not affect other instances" do
      screen1 = Screen.open( [10,10] )
      screen1.close
      screen2 = Screen.open( [10,10] )
      screen1.close
      screen2.should be_open
    end

  end


end
