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
# Your code should check "defined?(Rubygame::Music) != nil" to see if
# you can use this class, or be prepared to rescue from NameError.
#
# Music holds a song, streamed from an audio file (see #load for
# supported formats). There are two important differences between
# the Music and Sound classes:
#
# 1. Only one Music can be playing. If you try to play
#    a second song, the first one will be stopped.
#
# 2. Music doesn't load the entire audio file, so it can begin
#    quickly and doesn't use much memory. This is good, because
#    music files are usually much longer than sound effects!
#
# Music can #play, #pause/#unpause, #stop, #rewind, #jump_to another
# time, adjust #volume, and #fade_out (fade in by passing an option
# to #play).
#
# Music includes the Rubygame::NamedResource mixin module, which
# can perform autoloading of music on demand, among other things.
#
class Rubygame::Music

  include Rubygame::NamedResource

  class << self

    # Searches each directory in Music.autoload_dirs for a file with
    # the given filename. If it finds that file, loads it and returns
    # a Music instance. If it doesn't find the file, returns nil.
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
    # Returns::    The new Music instance. (Music)
    # May raise::  SDLError, if the music file could not be loaded.
    #
    def load( filename )
      Rubygame.open_audio

      music = SDL::Mixer.LoadMUS( filename.to_s )

      if( music.pointer.null? )
        raise( Rubygame::SDLError, "Could not load Music file '%s': %s"%
               [filename, SDL.GetError()] )
      end

      return new( music )
    end


    def current_music
      @current_music
    end

    def __current_music=( music ) # :nodoc:
      @current_music = music
    end

  end


  # call-seq:
  #   new
  #
  # **NOTE**: Don't use this method. Use Music.load.
  #
  # Raises NotImplementedError.
  #
  def initialize( music=nil )
    if( music.instance_of? SDL::Mixer::Music )
      @struct  = music
      @volume  = 1
      @repeats = 0
    else
      raise( NotImplementedError, "Music.new is not implemented. "+
             "Use Music.load to load a music file." )
    end
  end


  attr_reader :struct # :nodoc:
  protected :struct


  # call-seq:
  #   clone( other )  ->  music
  #   dup( other )  ->  music
  #
  # Create a copy of the given Music instance. More efficient than
  # using #load to load the music file again.
  #
  # other::       An existing Music instance. (Music, required)
  #
  # Returns::     The new Music instance. (Music)
  #
  # **NOTE**: #clone and #dup do slightly different things; #clone
  # will copy the 'frozen' state of the object, while #dup will create
  # a fresh, un-frozen object.
  #
  def initialize_copy( other )
    @struct  = other.struct
    @volume  = other.volume
    @repeats = other.repeats
  end



  # call-seq:
  #   play( options={:fade_in => 0, :repeats => 0, :start_at => 0} )
  #
  # Play the Music, optionally fading in, repeating a certain number
  # of times (or forever), and/or starting at a certain position in
  # the song.
  #
  # See also #pause and #stop.
  #
  # options::     Hash of options, listed below. (Hash, required)
  #
  #   :fade_in::     Fade in from silence over the given number of
  #                  seconds. Default: 0. (Numeric, optional)
  #   :repeats::     Repeat the music the given number of times, or
  #                  forever (or until stopped) if -1. Default: 0.
  #                  (Integer, optional)
  #   :start_at::    Start playing the music at the given time in the
  #                  song, in seconds. Default: 0. (Numeric, optional)
  #                  **NOTE**: Non-zero start times only work for
  #                  OGG and MP3 formats! Please refer to #jump.
  #
  #
  # Returns::     The receiver (self).
  # May raise::   SDLError, if the audio device could not be opened, or
  #               if the music file could not be played, or if you used
  #               :start_at with an unsupported format.
  #
  #
  # **NOTE**: Only one music can be playing at once. If any music is
  # already playing (or paused), it will be stopped before playing the
  # new music.
  #
  # Example:
  #   # Fade in over 2 seconds, play 4 times (1 + 3 repeats),
  #   # starting at 60 seconds since the beginning of the song.
  #   music.play( :fade_in => 2, :repeats => 3, :start_at => 60 );
  #
  def play( options={} )

    fade_in  = (options[:fade_in]  or 0)
    repeats  = (options[:repeats]  or 0)
    start_at = (options[:start_at] or 0)


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
      elsif( repeats > -1 )
        # Adjust so repeats means the same as it does for Sound
        (repeats + 1).to_i
      else
        -1
      end


    start_at =
      if( start_at < 0 )
        raise( ArgumentError,
               ":start_at cannot be negative, (got %.2f)"%start_at )
      else
        start_at.to_f
      end


    Rubygame.open_audio


    # Doing a little restart dance to please the SDL_mixer gods.
    SDL::Mixer.PlayMusic( @struct, 0 )
    SDL::Mixer.HaltMusic()

    # Set music channel volume before we play
    SDL::Mixer.VolumeMusic( (SDL::Mixer::MAX_VOLUME * @volume).to_i )


    @repeats = repeats

    result = SDL::Mixer.FadeInMusicPos( @struct, repeats, fade_in, start_at )

    if( result == -1 )
      raise Rubygame::SDLError, "Could not play Music: #{SDL.GetError()}"
    end

    self.class.__current_music = self

    return self

  end


  # True if the Music is currently playing (not paused and not stopped).
  # See also #paused? and #stopped?.
  #
  def playing?
    current? and
      SDL::Mixer.PlayingMusic() == 1 and
      SDL::Mixer.PausedMusic() == 0
  end



  # Pause the Music. Unlike #stop, it can be unpaused later to resume
  # from where it was paused. See also #unpause and #paused?.
  #
  # Returns::     The receiver (self).
  #
  # **NOTE**: Does nothing if the music is not currently playing.
  #
  def pause
    if current?
      SDL::Mixer.PauseMusic()
    end

    return self
  end


  # Unpause the Music, if it is currently paused. Resumes from
  # where it was paused. See also #pause and #paused?.
  #
  # Returns::     The receiver (self).
  #
  # **NOTE**: Does nothing if the music is not currently paused.
  #
  def unpause
    if current?
      SDL::Mixer.ResumeMusic()
    end

    return self
  end


  # True if the Music is currently paused (not playing and not stopped).
  # See also #playing? and #stopped?.
  #
  def paused?
    current? and
      SDL::Mixer.PlayingMusic() == 1 and
      SDL::Mixer.PausedMusic() == 1
  end



  # Stop the Music. Unlike #pause, the music must be played again from
  # the beginning, it cannot be resumed from it was stopped.
  #
  # Returns::     The receiver (self).
  #
  # **NOTE**: Does nothing if the music is not currently playing or paused.
  #
  def stop
    if current?
      SDL::Mixer.HaltMusic()
    end

    return self
  end


  # True if the Music is currently stopped (not playing and not paused).
  # See also #playing? and #paused?.
  #
  def stopped?
    (not current?) or (SDL::Mixer.PlayingMusic() == 0)
  end



  # Fade out to silence over the given number of seconds. Once the music
  # is silent, it is automatically stopped.
  #
  # Returns::     The receiver (self).
  #
  # **NOTE**: If the music is currently paused, the fade will start,
  # but you won't be able to hear it happening unless you #unpause during
  # the fade.
  #
  # Does nothing if the music is currently stopped.
  #
  def fade_out( fade_time )
    if( fade_time < 0 )
      raise ArgumentError, "fade time cannot be negative (got %.2f)"%fade_time
    end

    if current?
      result = SDL::Mixer.FadeOutMusic( (fade_time * 1000).to_i )
      if( result < 0 )
        raise Rubygame::SDLError, "Error fading out music: #{SDL.GetError()}"
      end
    end

    return self
  end


  # True if the Music is currently fading in or out.
  # See also #play and #fade_out.
  #
  # direction::  Check if it is fading :in, :out, or :either.
  #              (Symbol, required)
  #
  def fading?( direction=:either )
    return false unless current?

    case direction
    when :in
      SDL::Mixer.FadingMusic() == SDL::Mixer::FADING_IN
    when :out
      SDL::Mixer.FadingMusic() == SDL::Mixer::FADING_OUT
    else
      SDL::Mixer.FadingMusic() != SDL::Mixer::NO_FADING
    end
  end



  # Return the volume level of the music.
  # 0.0 is totally silent, 1.0 is full volume.
  #
  # **NOTE**: Ignores fading in or out.
  #
  def volume
    @volume
  end


  # Set the new #volume level of the music.
  # 0.0 is totally silent, 1.0 is full volume.
  # The new volume will be clamped to this range if it is too small or
  # too large.
  #
  # Volume cannot be set while the music is fading in or out.
  # Be sure to check #fading? or rescue from SDLError when
  # using this method.
  #
  # May raise::  SDLError if the music is fading in or out.
  #
  def volume=( new_vol )
    # Clamp it to valid range
    new_vol = if new_vol < 0.0;      0.0
              elsif new_vol > 1.0;   1.0
              else;                  new_vol
              end

    if current?
      if fading?
        raise Rubygame::SDLError, "cannot set Music volume while fading"
      else
        SDL::Mixer.VolumeMusic( (SDL::Mixer::MAX_VOLUME * new_vol).to_i )
      end
    end

    @volume = new_vol
  end



  def repeats                   # :nodoc:
    @repeats
  end



  # Rewind the Music to the beginning. If the Music was paused, it
  # will still be paused after the rewind. Does nothing if the Music
  # is stopped.
  #
  def rewind
    if current? and not stopped?
      was_paused = paused?

      SDL::Mixer.HaltMusic()
      result = SDL::Mixer.PlayMusic(@struct, @repeats)

      if( result == -1 )
        raise Rubygame::SDLError, "Could not rewind music: #{SDL.GetError()}"
      end

      SDL::Mixer.PauseMusic() if was_paused
    end

    return self
  end


  # Jump to any time in the Music, in seconds since the beginning.
  # If the Music was paused, it will still be paused again after the
  # jump. Does nothing if the Music was stopped.
  #
  # **NOTE**: Only works for OGG and MP3 formats! Other formats (e.g.
  # WAV) will usually raise SDLError.
  #
  # time::   the time to jump to, in seconds since the beginning
  #          of the song. (Numeric, required)
  #
  # May raise::  SDLError if something goes wrong, or if the music
  #              type does not support jumping.
  #
  # **CAUTION**: This method may be unreliable (and could even crash!)
  # if you jump to a time after the end of the song. Unfortunately,
  # SDL_Mixer does not provide a way to find the song's length, so
  # Rubygame cannot warn you if you go off the end. Be careful!
  #
  def jump_to( time )
    if current? and not stopped?
      was_paused = paused?

      if( time < 0 )
        raise Rubygame::SDLError, "cannot jump to negative time (got #{time})"
      end

      result = SDL::Mixer.SetMusicPosition( time.to_f )

      if( result == -1)
        raise Rubygame::SDLError, "could not jump music: #{SDL.GetError()}"
      end

      SDL::Mixer.PauseMusic() if was_paused
    end

    return self
  end



  private


  def current?               # :nodoc:
    self.class.current_music == self
  end

end
