#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2009  John Croisant
#
#	This library is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++



# *IMPORTANT*: this class only exists if SDL_mixer is available!
# Your code should check "defined?(Rubygame::Sound) != nil" to see if
# you can use this class, or be prepared to rescue from NameError.
#
# Sound holds a sound effect, loaded from an audio file (see #load for
# supported formats).
#
# Sound can #play, #pause/#unpause, #stop, adjust #volume,
# and #fade_out (you can fade in by passing an option to #play).
#
# Sound can create duplicates (with #dup or #clone) in a memory-efficient
# way -- the new Sound instance refers back to the same audio data,
# so having 100 duplicates of a sound uses only slightly more memory
# than having the first sound. Duplicates can different volume levels,
# too!
#
# Sound includes the Rubygame::NamedResource mixin module, which
# can perform autoloading of sounds on demand, among other things.
#
class Rubygame::Sound

  include Rubygame::NamedResource

  class << self

    # Searches each directory in Sound.autoload_dirs for a file with
    # the given filename. If it finds that file, loads it and returns
    # a Sound instance. If it doesn't find the file, returns nil.
    #
    # See Rubygame::NamedResource for more information about this
    # functionality.
    #
    def autoload( filename )
      path = find_file( filename )

      if( path )
        return load( path )
      else
        return nil
      end
    end


    # Load the given audio file.
    # Supported file formats are WAVE, MOD, MIDI, OGG, and MP3.
    #
    # filename::   Full or relative path to the file. (String, required)
    #
    # Returns::    The new Sound instance. (Sound)
    # May raise::  SDLError, if the sound file could not be loaded.
    #
    def load( filename )
      Rubygame.open_audio

      sound = SDL::Mixer.LoadWAV( filename.to_s )

      if( sound.pointer.null? )
        raise( Rubygame::SDLError, "Could not load Sound file '%s': %s"%
               [filename, SDL.GetError()] )
      end

      return new( sound )
    end

  end


  # call-seq:
  #   new
  #
  # **NOTE**: Don't use this method. Use Sound.load.
  #
  # Raises NotImplementedError.
  #
  def initialize( sound=nil )
    if( sound.instance_of? SDL::Mixer::Chunk )
      @struct  = sound
      @volume  = 1
      @channel = -1
    else
      raise( NotImplementedError, "Sound.new is not implemented. "+
             "Use Sound.load to load a sound file." )
    end
  end


  attr_reader :struct # :nodoc:
  protected :struct


  # call-seq:
  #   clone( other )  ->  sound
  #   dup( other )  ->  sound
  #
  # Create a copy of the given Sound instance. More efficient than
  # using #load to load the sound file again.
  #
  # other::       An existing Sound instance. (Sound, required)
  #
  # Returns::     The new Sound instance. (Sound)
  #
  # **NOTE**: #clone and #dup do slightly different things; #clone
  # will copy the 'frozen' state of the object, while #dup will create
  # a fresh, un-frozen object.
  #
  def initialize_copy( other )
    @struct  = other.struct
    @volume  = other.volume
    @channel = -1
  end



  # call-seq:
  #   play( options={:fade_in => 0, :repeats => 0, :stop_after => nil} )
  #
  # Play the Sound, optionally fading in, repeating a certain number
  # of times (or forever), and/or stopping automatically after a certain time.
  #
  # See also #pause and #stop.
  #
  # options::     Hash of options, listed below. (Hash, required)
  #
  #   :fade_in::     Fade in from silence over the given number of
  #                  seconds. Default: 0. (Numeric, optional)
  #   :repeats::     Repeat the sound the given number of times, or
  #                  forever (or until stopped) if -1. Default: 0.
  #                  (Integer, optional)
  #   :stop_after::  Automatically stop playing after playing for the given
  #                  number of seconds. Use nil to disable this behavior.
  #                  (Numeric or nil, optional)
  #
  #
  # Returns::     The receiver (self).
  # May raise::   SDLError, if the audio device could not be opened, or
  #               if the sound file could not be played.
  #
  #
  # **NOTE**: If the sound is already playing (or paused), it will be stopped
  # and played again from the beginning.
  #
  # Example:
  #   # Fade in over 2 seconds, play 4 times (1 + 3 repeats),
  #   # but stop playing after 5 seconds.
  #   sound.play( :fade_in => 2, :repeats => 3, :stop_after => 5 );
  #
  def play( options={} )

    fade_in    = (options[:fade_in]  or 0)
    repeats    = (options[:repeats]  or 0)
    stop_after = (options[:stop_after] or nil)


    fade_in =
      if( fade_in < 0 )
        raise ArgumentError, ":fade_in cannot be negative (got %.2f)"%fade_in
      elsif( fade_in < 0.05 )
        # Work-around for a bug with SDL_mixer not working with small
        # non-zero fade-ins
        0
      else
        (fade_in * 1000).to_i
      end


    repeats =
      if( repeats < -1 )
        raise( ArgumentError,
               ":repeats cannot be negative, except -1 (got #{repeats})" )
      else
        repeats
      end


    stop_after =
      if( stop_after.nil? )
        -1
      elsif( stop_after < 0 )
        raise( ArgumentError,
               ":stop_after cannot be negative, (got %.2f)"%stop_after )
      else
        (stop_after * 1000).to_i
      end



    Rubygame.open_audio


    # If it's already playing on a channel, stop it first.
    if channel_active?
      SDL::Mixer.HaltChannel( @channel )
    end


    # Find first available channel
    @channel = SDL::Mixer.GroupAvailable(-1)


    if @channel == -1
      # No channels were available, so make one more than there are now.
      # (Mix_AllocateChannels(-1) returns the current number of channels)
      SDL::Mixer.AllocateChannels( SDL::Mixer.AllocateChannels(-1) + 1 )

      # Try again
      @channel = SDL::Mixer.GroupAvailable(-1)
    end


    # Set sound channel volume before we play
    SDL::Mixer.Volume( @channel, (SDL::Mixer::MAX_VOLUME * @volume).to_i )


    result =
      if( fade_in <= 0 )
        # Play sound without fading in
        SDL::Mixer.PlayChannelTimed( @channel, @struct, repeats, stop_after )
      else
        # Play sound with fading in
        SDL::Mixer.FadeInChannelTimed( @channel, @struct,
                                       repeats, fade_in, stop_after )
      end


    if( result == -1 )
      raise Rubygame::SDLError, "Could not play Sound: #{SDL.GetError()}"
    end


    return self

  end


  # True if the Sound is currently playing (not paused and not stopped).
  # See also #paused? and #stopped?.
  #
  def playing?
    channel_active? and
      SDL::Mixer.Playing(@channel) == 1 and
      SDL::Mixer.Paused(@channel) == 0
  end



  # Pause the Sound. Unlike #stop, it can be unpaused later to resume
  # from where it was paused. See also #unpause and #paused?.
  #
  # Returns::     The receiver (self).
  #
  # **NOTE**: Does nothing if the sound is not currently playing.
  #
  def pause
    if channel_active?
      SDL::Mixer.Pause( @channel )
    end

    return self
  end


  # Unpause the Sound, if it is currently paused. Resumes from
  # where it was paused. See also #pause and #paused?.
  #
  # Returns::     The receiver (self).
  #
  # **NOTE**: Does nothing if the sound is not currently paused.
  #
  def unpause
    if channel_active?
      SDL::Mixer.Resume( @channel )
    end

    return self
  end


  # True if the Sound is currently paused (not playing and not stopped).
  # See also #playing? and #stopped?.
  #
  def paused?
    channel_active? and
      SDL::Mixer.Playing( @channel ) == 1 and
      SDL::Mixer.Paused( @channel ) == 1
  end



  # Stop the Sound. Unlike #pause, the sound must be played again from
  # the beginning, it cannot be resumed from it was stopped.
  #
  # Returns::     The receiver (self).
  #
  # **NOTE**: Does nothing if the sound is not currently playing or paused.
  #
  def stop
    if channel_active?
      SDL::Mixer.HaltChannel( @channel )
    end

    return self
  end


  # True if the Sound is currently stopped (not playing and not paused).
  # See also #playing? and #paused?.
  #
  def stopped?
    (not channel_active?) or (SDL::Mixer.Playing(@channel) == 0)
  end



  # Fade out to silence over the given number of seconds. Once the sound
  # is silent, it is automatically stopped.
  #
  # Returns::     The receiver (self).
  #
  # **NOTE**: If the sound is currently paused, the fade will start,
  # but you won't be able to hear it happening unless you #unpause during
  # the fade.
  #
  # Does nothing if the sound is currently stopped.
  #
  def fade_out( fade_time )
    if( fade_time < 0 )
      raise ArgumentError, "fade time cannot be negative (got %.2f)"%fade_time
    end

    if channel_active?
      SDL::Mixer.FadeOutChannel( @channel, (fade_time * 1000).to_i )
    end

    return self
  end


  # True if the Sound is currently fading in or out.
  # See also #play and #fade_out.
  #
  # direction::  Check if it is fading :in, :out, or :either.
  #              (Symbol, required)
  #
  def fading?( direction=:either )
    return false unless channel_active?

    case direction
    when :in
      SDL::Mixer.FadingChannel( @channel ) == SDL::Mixer::FADING_IN
    when :out
      SDL::Mixer.FadingChannel( @channel ) == SDL::Mixer::FADING_OUT
    else
      SDL::Mixer.FadingChannel( @channel ) != SDL::Mixer::NO_FADING
    end
  end



  # Return the volume level of the sound.
  # 0.0 is totally silent, 1.0 is full volume.
  #
  # **NOTE**: Ignores fading in or out.
  #
  def volume
    @volume
  end


  # Set the new #volume level of the sound.
  # 0.0 is totally silent, 1.0 is full volume.
  # The new volume will be clamped to this range if it is too small or
  # too large.
  #
  # Volume cannot be set while the sound is fading in or out.
  # Be sure to check #fading? or rescue from SDLError when
  # using this method.
  #
  # May raise::  SDLError if the sound is fading in or out.
  #
  def volume=( new_vol )
    # Clamp it to valid range
    new_vol = if new_vol < 0.0;      0.0
              elsif new_vol > 1.0;   1.0
              else;                  new_vol
              end

    if channel_active?
      if fading?
        raise Rubygame::SDLError, "cannot set Sound volume while fading"
      else
        SDL::Mixer.Volume( @channel, (SDL::Mixer::MAX_VOLUME * new_vol).to_i )
      end
    end

    @volume = new_vol
  end


  # call-seq:
  #   fire( options={:volume => nil, :fade_in => 0, :repeats => 0, :stop_after => nil} )
  # 
  # Plays the sound on a new mixer channel that is detached from the
  # sound instance. This method is convenient when you simply want to
  # play a sound effect, and don't care about controlling it later.
  # 
  # You can use this method to play the same sound effect more than
  # once simultaneously, but you cannot control it once it starts
  # playing (you can't stop or pause it, etc.).
  # 
  # This method takes all the same options as #play, as well as the
  # following:
  # 
  # :volume::  The volume to play the clone at. If omitted or nil,
  #            uses the current volume of this instance.
  # 
  # Unlike #play, the :repeats option must be 0 or greater (it cannot
  # repeat forever).
  # 
  # May raise::
  #   ArgumentError if any options are invalid, or SDLError if the
  #   sound could not be played.
  # 
  def fire( options={} )
    if options[:repeats] and options[:repeats] < 0
      raise ArgumentError, ":repeats must be >= 0 (got #{repeats})"
    end
    sound = self.dup
    sound.volume = options[:volume] if options[:volume]
    sound.play(options)
    nil
  end


  private


  def channel_active?
    (@channel != -1) and
      (SDL::Mixer.GetChunk(@channel).pointer == @struct.pointer)
  end

end
