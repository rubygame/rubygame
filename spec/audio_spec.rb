

require 'rubygame'



#########################
##                     ##
##       GENERAL       ##
##                     ##
#########################


describe "Opening audio for the first time" do
  after :each do
    Rubygame.close_audio
  end

  it "should return true" do
    Rubygame.open_audio.should be_true
  end
end


describe "Opening audio when it's already open" do
  before :each do
    Rubygame.open_audio
  end

  after :each do
    Rubygame.close_audio
  end

  it "should return false" do
    Rubygame.open_audio.should be_false
  end
end


describe "Opening audio that was opened then closed again" do
  before :each do
    Rubygame.open_audio
    Rubygame.close_audio
  end

  after :each do
    Rubygame.close_audio
  end

  it "should return true" do
    Rubygame.open_audio.should be_true
  end
end


describe "Opening audio with invalid argument" do
  after :each do
    Rubygame.close_audio
  end

  it "should raise TypeError" do
    lambda{ Rubygame.open_audio(:foo) }.should raise_error(TypeError)
  end
end


describe "Closing audio that was open" do
  before :each do
    Rubygame.open_audio
  end

  after :each do
    Rubygame.close_audio
  end

  it "should return true" do
    Rubygame.close_audio.should be_true
  end
end


describe "Closing audio that was not open" do
  before :each do
  end

  after :each do
    Rubygame.close_audio
  end

  it "should return false" do
    Rubygame.close_audio.should be_false
  end
end



#########################
##                     ##
##      FREQUENCY      ##
##                     ##
#########################


describe "Opening audio with a valid frequency" do
  after :each do
    Rubygame.close_audio
  end

  it "should not raise an error" do
    lambda{ Rubygame.open_audio(:frequency => 44100) }.should_not raise_error
  end
end


describe "Opening audio with a negative frequency" do
  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda{ Rubygame.open_audio(:frequency => -1) }.should raise_error(ArgumentError)
  end
end


describe "Opening audio with a frequency of zero" do
  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda{ Rubygame.open_audio(:frequency => 0) }.should raise_error(ArgumentError)
  end
end



#########################
##                     ##
##      CHANNELS       ##
##                     ##
#########################


describe "Opening audio with 1 channel (mono)" do
  after :each do
    Rubygame.close_audio
  end

  it "should not raise an error" do
    lambda{ Rubygame.open_audio(:channels => 1) }.should_not raise_error
  end
end


describe "Opening audio with 2 channels (stereo)" do
  after :each do
    Rubygame.close_audio
  end

  it "should not raise an error" do
    lambda{ Rubygame.open_audio(:channels => 2) }.should_not raise_error
  end
end


describe "Opening audio with a too-small number of channels" do
  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda{ Rubygame.open_audio(:channels => 0) }.should raise_error(ArgumentError)
  end
end


describe "Opening audio with a too-large number of channels" do
  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda{ Rubygame.open_audio(:channels => 3) }.should raise_error(ArgumentError)
  end
end



#########################
##                     ##
##      FREQUENCY      ##
##                     ##
#########################


describe "Opening audio with a valid buffer size" do
  after :each do
    Rubygame.close_audio
  end

  it "should not raise an error" do
    lambda{ Rubygame.open_audio(:buffer => 512) }.should_not raise_error
  end
end


describe "Opening audio with a non-power-of-two buffer size" do
  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda{ Rubygame.open_audio(:buffer => 511) }.should raise_error(ArgumentError)
  end
end


describe "Opening audio with a negative buffer size" do
  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda{ Rubygame.open_audio(:buffer => -1) }.should raise_error(ArgumentError)
  end
end


describe "Opening audio with a buffer of zero" do
  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda{ Rubygame.open_audio(:buffer => 0) }.should raise_error(ArgumentError)
  end
end
