#!/usr/bin/env ruby

require 'rubygame'

Rubygame.init()

Rubygame::Mixer.open_audio

sound = Rubygame::Sound.new("song.ogg")

# You can make as many copies of sounds as you want, without
# using up extra memory by loading the sound file again.
sound2 = sound.dup

# Duplicate sounds can have different volumes! Neat, huh?
sound.volume = 1.0 # full volume
sound2.volume  = 0.5 # half volume

puts "sound.volume == #{sound.volume}; sound2.volume == #{sound2.volume}"

# Fade in for 1 sec, keep repeating, but stop playing after 10 secs
sound.play(:fade_in => 1, :repeats => -1, :stop_after => 10)

puts "sound is now fading (in either direction)" if sound.fading?
puts "specifically, it's fading IN" if sound.fading?(:in)

puts "sound is playing at volume #{sound.volume}" if sound.playing?

# Let it play for a while
sleep 5

sound.pause
puts "sound is now paused" if sound.paused?

sleep 2

sound.unpause
puts "sound is now playing again (unpaused)" if sound.playing?

sleep 3

sound.volume = 0.5
puts "sound is now playing at volume #{sound.volume}"

# Let it play itself out
sleep 3

# 11 (= 5 + 3 + 3) second total play time so far
puts "sound has stopped automatically after 10 seconds of playing" if sound.stopped?

# Wait for a while
sleep 5

sound.play
puts "sound is now playing again" if sound.playing?

# Let it play for a while
sleep 2

sound.fade_out(5)

# sound.fading?(:either) is same as sound.fading?()
puts "sound is now fading (in either direction)" if sound.fading?(:either)
puts "specifically, it's fading OUT" if sound.fading?(:out)

# Let it fade out, but not the whole way
sleep 3

sound.stop
puts "sound is now stopped" if sound.stopped?


Rubygame.quit
