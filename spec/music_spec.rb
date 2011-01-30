

require 'rubygame'
include Rubygame


samples_dir = File.join( File.dirname(__FILE__), "..", "samples", "")
test_dir = File.dirname(__FILE__)

song = samples_dir + "song.ogg"
whiff = samples_dir + "whiff.wav"
short = File.join( File.dirname(__FILE__), "short.ogg")
dne = samples_dir + "does_not_exist.ogg"
panda = samples_dir + "panda.png"

# value for testing nearness of volume
small = 0.00001



#########################
##                     ##
##    INITIALIAZING    ##
##                     ##
#########################


describe Music, "(new)" do
	it "should raise NotImplementedError" do
		lambda{ Sound.new }.should raise_error(NotImplementedError)
	end
end

describe Music, "(load)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
  end

  after :each do
    Rubygame.close_audio
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
    Rubygame.open_audio
  end

  after :each do
    Rubygame.close_audio
  end

  it "should raise SDLError" do
    lambda { @music = Music.load(dne) }.should raise_error(SDLError)
  end

end



describe Music, "(non-music file)" do

  before :each do
    Rubygame.open_audio
  end

  after :each do
    Rubygame.close_audio
  end

  it "should raise SDLError" do
    lambda { @music = Music.load(panda) }.should raise_error(SDLError)
  end

end

describe Music, "(named resource)" do
  before :each do
    Music.autoload_dirs = [samples_dir]
  end

  after :each do
    Music.autoload_dirs = []
    Music.instance_eval { @resources = {} }
  end

  it "should include NamedResource" do
    Music.included_modules.should include(NamedResource)
  end

  it "should respond to :[]" do
    Music.should respond_to(:[])
  end

  it "should respond to :[]=" do
    Music.should respond_to(:[]=)
  end

  it "should allow setting resources" do
    s = Music.load(short)
    Music["short"] = s
    Music["short"].should == s
  end

  it "should reject non-Music resources" do
    lambda { Music["foo"] = "bar" }.should raise_error(TypeError)
  end

  it "should autoload images as Music instances" do
    unless( Rubygame::VERSIONS[:sdl_mixer] )
      raise "Can't test sound loading, no SDL_mixer installed."
    end

    Music["song.ogg"].should be_instance_of(Music)
  end

  it "should return nil for nonexisting files" do
    unless( Rubygame::VERSIONS[:sdl_mixer] )
      raise "Can't test sound loading, no SDL_mixer installed."
    end

    Music["foobar.ogg"].should be_nil
  end

  it "should set names of autoload Musics" do
    unless( Rubygame::VERSIONS[:sdl_mixer] )
      raise "Can't test sound loading, no SDL_mixer installed."
    end

    Music["song.ogg"].name.should == "song.ogg"
  end
end


#########################
##                     ##
##        BASIC        ##
##                     ##
#########################


describe Music, "(playing)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1
    @music.play
  end

  after :each do
    Rubygame.close_audio
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
    @music.volume = 0.2
    @music.volume.should be_within(small).of(0.2)
  end

end


describe Music, "(playing without open audio)" do

  before :each do
    @music = Music.load(song)
    @music.volume = 0.1
    @music.play
  end

  after :each do
    Rubygame.close_audio
  end

  it { @music.should be_playing }
  it { @music.should_not be_paused }
  it { @music.should_not be_stopped }

  it "should be the current music" do
    Music.current_music.should == @music
  end

end



describe Music, "(paused)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1
    @music.play
    @music.pause
  end

  after :each do
    Rubygame.close_audio
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
    @music.volume = 0.2
    @music.volume.should be_within(small).of(0.2)
  end

end



describe Music, "(stopped)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1
    @music.play
    @music.stop
  end

  after :each do
    Rubygame.close_audio
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
    @music.volume = 0.2
    @music.volume.should be_within(small).of(0.2)
  end

end



#########################
##                     ##
##      START AT       ##
##                     ##
#########################


describe Music, "(negative start at)" do
  before :each do
    Rubygame.open_audio
    @music = Music.load(short)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda { @music.play(:start_at => -1) }.should raise_error(ArgumentError)
  end
end

describe Music, "(start at)" do
  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should be playing right away" do
    @music.play( :start_at => 7 )
    @music.should be_playing
  end

  it "should end sooner" do
    @music.play( :start_at => 7.4 )
    sleep 0.2
    @music.should be_stopped
  end
end


#########################
##                     ##
##      REPEATING      ##
##                     ##
#########################


describe Music, "(negative repeats, except -1)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda { @music.play(:repeats => -2) }.should raise_error(ArgumentError)
  end
end


describe Music, "(repeats forever)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(short)
    @music.volume = 0.1 # for programmer sanity
    @music.play( :repeats => -1 )
  end

  after :each do
    Rubygame.close_audio
  end

  it "should still be playing after a while" do
    sleep 0.3
    @music.should be_playing
  end

end


describe Music, "(repeats)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(short)
    @music.volume = 0.1 # for programmer sanity
    @music.play( :repeats => 3 )
  end

  after :each do
    Rubygame.close_audio
  end

  it "should be playing before its last repeat" do
    sleep 0.1*3
    @music.should be_playing
  end

  it "should not be stopped after its last repeat" do
    sleep 0.1*4 + 0.05
    @music.should be_stopped
  end

end


#########################
##                     ##
##       FADING        ##
##                     ##
#########################


describe Music, "(negative fade in)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    lambda { @music.play(:fade_in => -1) }.should raise_error(ArgumentError)
  end
end

describe Music, "(fading in)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should be playing right away" do
    @music.play( :fade_in => 0.3 )
    @music.should be_playing
  end

  it "should be fading in right away" do
    @music.play( :fade_in => 0.3 )
    @music.should be_fading
    @music.fading?(:in).should be_true
  end

  it "should be fading in before it has faded in" do
    @music.play( :fade_in => 0.3 )
    sleep 0.2
    @music.should be_fading
    @music.fading?(:in).should be_true
  end

  it "should not be fading in after it has faded in" do
    @music.play( :fade_in => 0.3 )
    sleep 0.4
    @music.should_not be_fading
    @music.fading?(:in).should be_false
  end

  it "should still be playing after it has faded in" do
    @music.play( :fade_in => 0.3 )
    sleep 0.4
    @music.should be_playing
  end

  it "should not allow changing volume" do
    @music.play( :fade_in => 0.3 )
    lambda { @music.volume = 0.2 }.should raise_error(SDLError)
    @music.volume.should be_within(small).of(0.1)
  end

end


describe Music, "(negative fade out)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should be playing right away" do
    @music.play
    lambda { @music.fade_out( -1 ) }.should raise_error(ArgumentError)
  end

end

describe Music, "(fading out)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1 # for programmer sanity
    @music.play
  end

  after :each do
    Rubygame.close_audio
  end

  it "should be playing right away" do
    @music.fade_out( 0.3 )
    @music.should be_playing
  end

  it "should be fading out right away" do
    @music.fade_out( 0.3 )
    @music.should be_fading
    @music.fading?(:out).should be_true
  end

  it "should be fading out before it has faded out" do
    @music.fade_out( 0.3 )
    sleep 0.2
    @music.should be_fading
    @music.fading?(:out).should be_true
  end

  it "should not be fading out after it has faded out" do
    @music.fade_out( 0.3 )
    sleep 0.4
    @music.should_not be_fading
    @music.fading?(:out).should be_false
  end

  it "should be stopped after it has faded out" do
    @music.fade_out( 0.3 )
    sleep 0.4
    @music.should be_stopped
  end

  it "should not allow changing volume" do
    @music.fade_out( 0.3 )
    lambda { @music.volume = 0.2 }.should raise_error(SDLError)
    @music.volume.should be_within(small).of(0.1)
  end

end



#########################
##                     ##
##       REWIND        ##
##                     ##
#########################


describe Music, "(rewinding)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(short)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should be playing if it was playing before" do
    @music.play
    @music.rewind
    @music.should be_playing
  end

  it "should be paused if it was paused before" do
    @music.play
    @music.pause
    @music.rewind
    @music.should be_paused
  end

  it "should be stopped if it was stopped before" do
    @music.play
    @music.stop
    @music.rewind
    @music.should be_stopped
  end

  it "should repeat if it was repeating before" do
    @music.play( :repeats => -1 )
    @music.rewind
    sleep 0.3
    @music.should be_playing
  end

  it "should play again" do
    @music.play
    sleep 0.09
    @music.rewind
    sleep 0.09
    @music.should be_playing
  end
end


#########################
##                     ##
##      JUMP  TO       ##
##                     ##
#########################


describe Music, "(jump to)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(song)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should still be playing if it was playing" do
    @music.play
    @music.jump_to(5)
    @music.should be_playing
  end

  it "should end sooner if playing" do
    @music.play
    @music.jump_to(7.4)
    sleep 0.2
    @music.should be_stopped
  end

  it "should still be paused if it was paused" do
    @music.play
    @music.pause
    @music.jump_to(5)
    @music.should be_paused
  end

  it "should end sooner after being unpaused" do
    @music.play
    @music.pause
    @music.jump_to(7.4)
    @music.unpause
    sleep 0.2
    @music.should be_stopped
  end
end


describe Music, "(jump to, unsupported format)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(whiff)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should raise SDLError" do
    @music.play
    lambda { @music.jump_to(0.1) }.should raise_error(SDLError)
  end

end


describe Music, "(jump to, negative time)" do

  before :each do
    Rubygame.open_audio
    @music = Music.load(whiff)
    @music.volume = 0.1 # for programmer sanity
  end

  after :each do
    Rubygame.close_audio
  end

  it "should raise ArgumentError" do
    @music.play
    lambda { @music.jump_to }.should raise_error(ArgumentError)
  end

end
