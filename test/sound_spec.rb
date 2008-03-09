require 'rubygame'
include Rubygame

samples_dir = File.join( File.dirname(__FILE__), "..", "samples", "")

song = samples_dir + "song.ogg"
whiff = samples_dir + "whiff.wav"
dne = samples_dir + "does_not_exist.ogg"




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



describe "Sound set to stop after 0.5 seconds" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(song)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play( :stop_after => 0.5 )
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should still be playing at 0.45 seconds" do 
		sleep 0.45
		@sound.should be_playing
	end
	
	it "should be stopped at 0.55 seconds" do 
		sleep 0.55
		@sound.should be_stopped
	end
	
end



describe "Sound that is short" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(whiff)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should be stopped after it has expired" do 
		sleep 0.6
		@sound.should be_stopped
	end
	
end


describe "Sound that is short but repeats forever" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(whiff)
		@sound.volume = 0.01 # for programmer sanity
		@sound.play( :repeats => -1 )
	end
	
	after :each do 
		Mixer.close_audio
	end
	
	it "should still be playing at 1 second" do 
		sleep 1.0
		@sound.should be_playing
	end
	
end
