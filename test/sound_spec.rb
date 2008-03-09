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
	
	it "should not be playing" do 
		@sound.should_not be_playing
	end
	
	it "should not be paused" do 
		@sound.should_not be_paused
	end
	
	it "should be stopped" do 
		@sound.should be_stopped
	end
		
end
	
