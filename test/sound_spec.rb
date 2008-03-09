require 'rubygame'
include Rubygame

samples_dir = File.join( File.dirname(__FILE__), "..", "samples", "")
sound = samples_dir + "song.ogg"
not_sound = samples_dir + "does_not_exist.ogg"




describe "new loaded Sound" do 
	
	before :each do
		Mixer.open_audio
		@sound = Sound.new(sound)
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
		@sound = Sound.new(sound)
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
		@sound = Sound.new(sound)
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
		@sound = Sound.new(sound)
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
