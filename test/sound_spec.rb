require 'rubygame'
include Rubygame

samples_dir = File.join( File.dirname(__FILE__), "..", "samples", "")
test_dir = File.dirname(__FILE__)

song = samples_dir + "song.ogg"
short = File.join( File.dirname(__FILE__), "short.ogg")
dne = samples_dir + "does_not_exist.ogg"
panda = samples_dir + "panda.png"



######################### 
##                     ##
##    INITIALIAZING    ##
##                     ##
#########################


describe "new loaded Sound" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(song)
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should have a volume of 1.0" do 
		@sound.volume.should == 1.0
	end
	
	it { @sound.should_not be_playing }
	it { @sound.should_not be_paused }
	it { @sound.should be_stopped }	
	
end



describe Sound, "loaded without open audio" do 

	before :each do
		@sound = Sound.new(song)
	end

	after :each do 
		Rubygame.close_audio
	end

	it "should open audio" do
		Rubygame.open_audio.should be_false
	end

	it "should have a volume of 1.0" do 
		@sound.volume.should == 1.0
	end

	it { @sound.should_not be_playing }
	it { @sound.should_not be_paused }
	it { @sound.should be_stopped }	

end



describe "loading Sound from nonexistent file" do 
	
	before :each do
		Mixer.open_audio
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should raise SDLError" do 
		lambda { @sound = Sound.new(dne) }.should raise_error(SDLError)
	end
	
end



describe "loading Sound from non-sound file" do 
	
	before :each do
		Mixer.open_audio
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should raise SDLError" do 
		lambda { @sound = Sound.new(panda) }.should raise_error(SDLError)
	end
	
end



######################### 
##                     ##
##        BASIC        ##
##                     ##
#########################


describe "Sound that is playing" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(song)
		@sound.play
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it { @sound.should be_playing }
	it { @sound.should_not be_paused }
	it { @sound.should_not be_stopped }	
	
	it "should be playing after being played again" do 
		@sound.play
		@sound.should be_playing
	end

	it "should be paused after being paused" do 
		@sound.pause
		@sound.should be_paused
	end
	
	it "should be stopped after being stopped" do 
		@sound.stop
		@sound.should be_stopped
	end
	
	it "should be able to change volume" do
		@sound.volume = 0.5
		@sound.volume.should == 0.5
	end
	
end


describe Sound, "played without open audio" do 

	before :each do
		@sound = Sound.new(song)
		Rubygame.close_audio
		@sound.play
	end

	after :each do 
		Rubygame.close_audio
	end

	it "should open audio" do
		Rubygame.open_audio.should be_false
	end

	it "should be playing" do
		@sound.should be_playing
	end

end


describe "Sound that is paused" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(song)
		@sound.play
		@sound.pause
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it { @sound.should_not be_playing }
	it { @sound.should be_paused }
	it { @sound.should_not be_stopped }	

	it "should be playing after being played" do 
		@sound.play
		@sound.should be_playing
	end
	
	it "should be playing after being unpaused" do 
		@sound.unpause
		@sound.should be_playing
	end
	
	it "should still be paused after being paused again" do 
		@sound.pause
		@sound.should be_paused
	end
	
	it "should be stopped after being stopped" do 
		@sound.stop
		@sound.should be_stopped
	end
	
	it "should be able to change volume" do
		@sound.volume = 0.5
		@sound.volume.should == 0.5
	end
	
end



describe "Sound that is stopped" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(song)
		@sound.play
		@sound.stop
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it { @sound.should_not be_playing }
	it { @sound.should_not be_paused }
	it { @sound.should be_stopped }	
	
	it "should not be paused after being paused" do 
		@sound.pause
		@sound.should_not be_paused
	end
	
	it "should be stopped after being stopped" do 
		@sound.stop
		@sound.should be_stopped
	end
	
	it "should be playing after being played" do 
		@sound.play
		@sound.should be_playing
	end
	
	it "should be able to change volume" do
		@sound.volume = 0.5
		@sound.volume.should == 0.5
	end
	
end



######################### 
##                     ##
##    AUTO-STOPPING    ##
##                     ##
#########################


describe "Sound set to stop after 0.2 seconds" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(song)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play( :stop_after => 0.2 )
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should still be playing at 0.15 seconds" do 
		sleep 0.15
		@sound.should be_playing
	end
	
	it "should be stopped at 0.25 seconds" do 
		sleep 0.25
		@sound.should be_stopped
	end
	
end



describe "Sound that is short" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(short)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should be stopped after it has expired" do 
		sleep 0.15
		@sound.should be_stopped
	end
	
end



describe "Sound that repeats forever but stops after 0.3 seconds" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(short)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play( :repeats => -1, :stop_after => 0.3 )
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should still be playing at 0.25 second" do 
		sleep 0.25
		@sound.should be_playing
	end
	
	it "should be stopped at 0.35 second" do 
		sleep 0.35
		@sound.should be_stopped
	end
	
end



######################### 
##                     ##
##      REPEATING      ##
##                     ##
#########################


describe "Sound that repeats forever" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(short)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play( :repeats => -1 )
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should still be playing at 0.3 seconds" do 
		sleep 0.3
		@sound.should be_playing
	end
	
end



describe "Sound that repeats 3 times" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(short)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play( :repeats => 3 )
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should still be playing after 3 plays" do 
		sleep 0.1*3
		@sound.should be_playing
	end
	
	it "should be stopped after 4 plays" do 
		sleep 0.1*4 + 0.05
		@sound.should be_stopped
	end
	
end



######################### 
##                     ##
##       FADING        ##
##                     ##
#########################


describe "Sound that fades in for 0.2 seconds" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(short)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play( :repeats => -1, :fade_in => 0.2 )
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should be playing right away" do 
		@sound.should be_playing
	end
	
	it "should be fading in right away" do 
		@sound.should be_fading
		@sound.fading?(:in).should be_true
	end
	
	it "should still be fading in after 0.15 seconds" do 
		sleep 0.15
		@sound.should be_fading
		@sound.fading?(:in).should be_true
	end
	
	it "should not be fading in after 0.25 seconds" do 
		sleep 0.25
		@sound.should_not be_fading
		@sound.fading?(:in).should be_false
	end
	
	it "should still be playing after it has faded in" do 
		sleep 0.25
		@sound.should be_playing
	end
	
	it "should not allow changing volume" do 
		lambda { @sound.volume = 0.5 }.should raise_error(SDLError)
		@sound.volume.should_not == 0.5
	end
	
end


describe "Sound that fades out for 0.2 seconds" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(short)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play( :repeats => -1 )
		@sound.fade_out( 0.2 )
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should be playing right away" do 
		@sound.should be_playing
	end
	
	it "should be fading out right away" do 
		@sound.should be_fading
		@sound.fading?(:out).should be_true
	end
	
	it "should still be fading out after 0.25 seconds" do 
		sleep 0.15
		@sound.should be_fading
		@sound.fading?(:out).should be_true
	end
	
	it "should not be fading out after 0.35 seconds" do 
		sleep 0.25
		@sound.should_not be_fading
		@sound.fading?(:out).should be_false
	end
	
	it "should be stopped after it has faded out" do 
		sleep 0.25
		@sound.should be_stopped
	end
	
	it "should not allow changing volume" do 
		lambda { @sound.volume = 0.5 }.should raise_error(SDLError)
		@sound.volume.should_not == 0.5
	end

end
