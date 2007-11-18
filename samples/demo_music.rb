#!/usr/bin/env ruby

require 'rubygame'

Rubygame.init()

def test_music() 
	mix = Rubygame::Mixer

	# Use the lines below to get rid of artsd and contact ALSA directly on Linux.
	# ARTSD happens to be buggy on my old, old linux distro. 
	if false
		if RUBY_PLATFORM =~ /linux/
			`killall artsd`
			ENV['SDL_AUDIODRIVER'] = "alsa"
		end
	end

	mix.open_audio
	puts "Using audio driver:" + mix.driver_name
	music = mix::Music

	if ARGV[0]
		file = ARGV[0]
	else
		file = "song.ogg"
		puts "If you want, you could give a filename as an argument to this script."
	end

	mus = music.load_audio(file);

	puts "Testing fading in over 3 seconds, repeating forever."
	mus.fade_in(3, -1);
	puts('ERROR: Music not fading in') unless mus.fading?(:in)
	sleep 3

	puts "Playing for 2 seconds."
	sleep 2

	puts "Lowering volume to half for 3 seconds."
	mus.volume = 0.5;
	puts "ERROR: Volume wasn't adjusted" unless mus.volume == 0.5
	sleep 3

	puts "Restoring volume to full."
	mus.volume = 1.0;
	sleep 2

	puts "Pausing for 1 seconds."
	mus.pause
	puts "ERROR: Music not paused." unless mus.paused?
	sleep 1

	puts "Resuming."
	mus.resume
	puts "ERROR: Music not resumed" unless mus.playing?

	puts "Playing for 2 seconds."
	sleep 2

	puts "Fading out over 2 seconds."
	mus.fade_out(2);
	puts "ERROR: Music not fading out " unless mus.fading?(:out)

	while mus.playing? or mus.fading? == :out do Thread.pass end
	# Test playing of music to the end

	puts "ERROR: Music not ended" if mus.playing?
	mix.close_audio
end

music_thread = Thread.new do test_music() end
music_thread.join
Rubygame.quit()

