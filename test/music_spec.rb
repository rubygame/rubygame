require 'rubygame'
include Rubygame

samples_dir = File.join( File.dirname(__FILE__), "..", "samples", "")

song = samples_dir + "song.ogg"
short = "short.ogg"
dne = samples_dir + "does_not_exist.ogg"
panda = samples_dir + "panda.png"



#########################
##                     ##
##    INITIALIAZING    ##
##                     ##
#########################


describe Music, "(new)" do

  before :each do
    Mixer.open_audio
    @music = Music.new(song)
  end

  after :each do
    Mixer.close_audio
  end

  it "should have a volume of 1.0" do
    @music.volume.should == 1.0
  end

  it { @music.should_not be_playing }
  it { @music.should_not be_paused }
  it { @music.should be_stopped }

end



describe Music, "(nonexistent file)" do

  before :each do
    Mixer.open_audio
  end

  after :each do
    Mixer.close_audio
  end

  it "should raise SDLError" do
    lambda { @music = Music.new(dne) }.should raise_error(SDLError)
  end

end



describe Music, "(non-music file)" do

  before :each do
    Mixer.open_audio
  end

  after :each do
    Mixer.close_audio
  end

  it "should raise SDLError" do
    lambda { @music = Music.new(panda) }.should raise_error(SDLError)
  end

end



#########################
##                     ##
##        BASIC        ##
##                     ##
#########################


describe Music, "(playing)" do

  before :each do
    Mixer.open_audio
    @music = Music.new(song)
    @music.volume = 0.1
    @music.play
  end

  after :each do
    Mixer.close_audio
  end

  it { @music.should be_playing }
  it { @music.should_not be_paused }
  it { @music.should_not be_stopped }

  it "should be the current music" do
    Music.current_music.should == @music
  end

  it "should be playing after being played again" do
    @music.play
    @music.should be_playing
  end

  it "should be paused after being paused" do
    @music.pause
    @music.should be_paused
  end

  it "should be stopped after being stopped" do
    @music.stop
    @music.should be_stopped
  end

  it "should be able to change volume" do
    @music.volume = 0.5
    @music.volume.should == 0.5
  end

end



describe Music, "(paused)" do

  before :each do
    Mixer.open_audio
    @music = Music.new(song)
    @music.volume = 0.1
    @music.play
    @music.pause
  end

  after :each do
    Mixer.close_audio
  end

  it { @music.should_not be_playing }
  it { @music.should be_paused }
  it { @music.should_not be_stopped }

  it "should be the current music" do
    Music.current_music.should == @music
  end

  it "should be playing after being played" do
    @music.play
    @music.should be_playing
  end

  it "should be playing after being unpaused" do
    @music.unpause
    @music.should be_playing
  end

  it "should still be paused after being paused again" do
    @music.pause
    @music.should be_paused
  end

  it "should be stopped after being stopped" do
    @music.stop
    @music.should be_stopped
  end

  it "should be able to change volume" do
    @music.volume = 0.5
    @music.volume.should == 0.5
  end

end



describe Music, "(stopped)" do

  before :each do
    Mixer.open_audio
    @music = Music.new(song)
    @music.volume = 0.1
    @music.play
    @music.stop
  end

  after :each do
    Mixer.close_audio
  end

  it { @music.should_not be_playing }
  it { @music.should_not be_paused }
  it { @music.should be_stopped }

  it "it should still be the current music" do 
    Music.current_music.should == @music
  end
  
  it "should not be paused after being paused" do
    @music.pause
    @music.should_not be_paused
  end

  it "should be stopped after being stopped" do
    @music.stop
    @music.should be_stopped
  end

  it "should be playing after being played" do
    @music.play
    @music.should be_playing
  end

  it "should be able to change volume" do
    @music.volume = 0.5
    @music.volume.should == 0.5
  end

end



#########################
##                     ##
##      REPEATING      ##
##                     ##
#########################


describe "Music that repeats forever" do

  before :each do
    Mixer.open_audio
    @music = Music.new(short)
    @music.volume = 0.1 # for programmer sanity
    @music.play( :repeats => -1 )
  end

  after :each do
    Mixer.close_audio
  end

  it "should still be playing at 0.3 seconds" do
    sleep 0.3
    @music.should be_playing
  end

end



describe "Music that repeats 3 times" do

  before :each do
    Mixer.open_audio
    @music = Music.new(short)
    @music.volume = 0.1 # for programmer sanity
    @music.play( :repeats => 3 )
  end

  after :each do
    Mixer.close_audio
  end

  it "should still be playing after 3 plays" do
    sleep 0.1*3
    @music.should be_playing
  end

  it "should be stopped after 4 plays" do
    sleep 0.1*4 + 0.05
    @music.should be_stopped
  end

end



#########################
##                     ##
##       FADING        ##
##                     ##
#########################


describe "Music that fades in for 0.3 seconds" do

  before :each do
    Mixer.open_audio
    @music = Music.new(song)
    @music.volume = 0.1 # for programmer sanity
    @music.play( :fade_in => 0.2 )
  end

  after :each do
    Mixer.close_audio
  end

  it "should be playing right away" do
    @music.should be_playing
  end

  it "should be fading in right away" do
    @music.should be_fading
    @music.fading?(:in).should be_true
  end

  it "should still be fading in after 0.1 seconds" do
    sleep 0.1
    @music.should be_fading
    @music.fading?(:in).should be_true
  end

  it "should not be fading in after 0.3 seconds" do
    sleep 0.3
    @music.should_not be_fading
    @music.fading?(:in).should be_false
  end

  it "should still be playing after it has faded in" do
    sleep 0.3
    @music.should be_playing
  end

  it "should not allow changing volume" do
    lambda { @music.volume = 0.5 }.should raise_error(SDLError)
    @music.volume.should_not == 0.5
  end

end


describe "Music that fades out for 0.3 seconds" do

  before :each do
    Mixer.open_audio
    @music = Music.new(song)
    @music.volume = 0.1 # for programmer sanity
    @music.play( :repeats => -1 )
    @music.fade_out( 0.2 )
  end

  after :each do
    Mixer.close_audio
  end

  it "should be playing right away" do
    @music.should be_playing
  end

  it "should be fading out right away" do
    @music.should be_fading
    @music.fading?(:out).should be_true
  end

  it "should still be fading out after 0.1 seconds" do
    sleep 0.1
    @music.should be_fading
    @music.fading?(:out).should be_true
  end

  it "should not be fading out after 0.3 seconds" do
    sleep 0.3
    @music.should_not be_fading
    @music.fading?(:out).should be_false
  end

  it "should be stopped after it has faded out" do
    sleep 0.3
    @music.should be_stopped
  end

  it "should not allow changing volume" do
    lambda { @music.volume = 0.5 }.should raise_error(SDLError)
    @music.volume.should_not == 0.5
  end

end
