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


#  **NOTE:** This module is DEPRECATED and will be removed in Rubygame 3.0.
#  Please use Rubygame.open_audio, Rubygame.close_audio, Rubygame::Sound,
#  and Rubygame::Music instead.
#
#  The Mixer module provides access to the SDL_mixer library for audio
#  playback and mixing. This module is still very basic, but it is
#  good enough to load and play WAV files on multiple mix channels.
#
#  See the Sample class for loading audio files.
#  See the Music class for streaming music from a file.
#
module Rubygame::Mixer

  AUDIO_U8     = SDL::AUDIO_U8
  AUDIO_S8     = SDL::AUDIO_S8
  AUDIO_U16SYS = SDL::AUDIO_U16SYS
  AUDIO_S16SYS = SDL::AUDIO_S16SYS


  #  **NOTE:** This method is DEPRECATED and will be removed in
  #  Rubygame 3.0. Please use the Rubygame.open_audio instead.
  #
  #  Initializes the audio device. You must call this before using the other
  #  mixer functions. See also #close_audio().
  #
  #  Returns nil. May raise an SDLError if initialization fails.
  #  
  #  This method takes these arguments:
  #
  #  frequency::  output sample rate in audio samples per second (Hz).
  #               Affects the quality of the sound output, at the
  #               expense of CPU usage. If nil, the default (22050) is
  #               used. 22050 is recommended for most games. For
  #               reference, 44100 is CD quality.
  #               
  #               The larger the value, the more processing required.
  #
  #  format::     output sample format. If nil, the default recommended
  #               system format is used. It's _highly_ recommended you
  #               leave this nil!
  #
  #               But if you're feeling reckless, you can use one of these
  #               constants located in the Rubygame::Mixer module:
  #
  #               AUDIO_U16SYS:: unsigned 16-bit samples.
  #               AUDIO_S16SYS:: signed 16-bit samples.
  #               AUDIO_U8::     unsigned 8-bit samples.
  #               AUDIO_S8::     signed 8-bit samples.
  #
  #  channels::   output sound channels. Use 2 for stereo, 1 for mono.
  #               If nil, the default (2) is used.
  #               This option is not related to mixing channels.
  #
  #  buffer::     size of the sound buffer, in bytes. If nil, the default
  #               (1024) is used. Larger values have more delay before
  #               playing a sound, but require less CPU usage (and
  #               have less skipping on slow systems).
  #
  #
  def self.open_audio( frequency=nil, format=nil, channels=nil, buffer=nil )

    Rubygame.deprecated( "Rubygame::Mixer", "3.0" )

    frequency ||= 22050
    format    ||= SDL::Mixer::DEFAULT_FORMAT
    channels  ||= 2
    buffer    ||= 1024

    result = SDL::Mixer.OpenAudio(frequency, format, channels, buffer)

    if( result < 0 )
      raise( Rubygame::SDLError,
             "Error initializing SDL_mixer: #{SDL.GetError()}" )
    end

    return nil
  end


  #  **NOTE:** This method is DEPRECATED and will be removed in
  #  Rubygame 3.0. Please use the Rubygame.close_audio instead.
  #
  #  Close the audio device being used by the mixer. You should not use any
  #  mixer functions after this function, unless you use #open_audio() to
  #  re-open the audio device. See also #open_audio().
  #
  #  Returns nil.
  #
  def self.close_audio()
    Rubygame.deprecated( "Rubygame::Mixer", "3.0" )
    SDL::Mixer.CloseAudio()
    return nil
  end


  #  **NOTE:** This method is DEPRECATED and will be removed in
  #  Rubygame 3.0. Please use the Rubygame::Sound class instead.
  #
  #  Returns the number of mixing channels currently allocated.
  #  See also #mix_channels=
  #
  def self.mix_channels
    Rubygame.deprecated( "Rubygame::Mixer", "3.0" )
    return SDL::Mixer.AllocateChannels(-1)
  end


  #  **NOTE:** This method is DEPRECATED and will be removed in
  #  Rubygame 3.0. Please use the Rubygame::Sound class instead.
  #
  #  Set the number of mixer channels, allocating or deallocating channels as
  #  needed. This can be called many times, even during audio playback. If this
  #  call reduces the number of channels allocated, the excess channels will
  #  be stopped automatically. See also #mix_channels
  #
  #  Returns the number of mixing channels allocated.
  #
  #  Note that 8 mixing channels are allocated when #open_audio is called.
  #  This method only needs to be called if you want a different number (either
  #  greater or fewer) of mixing channels.
  #  
  #  This method takes this argument:
  #  num_channels::  desired number of mixing channels, an integer. 
  #                  Negative values will cause this method to behave as
  #                  #mix_channels, returning the number of channels
  #                  currently allocated, without changing it.
  #
  def self.mix_channels=( num_channels )
    Rubygame.deprecated( "Rubygame::Mixer", "3.0" )
    return SDL::Mixer.AllocateChannels( num_channels )
  end


  #  **NOTE:** This method is DEPRECATED and will be removed in
  #  Rubygame 3.0. Please use the Rubygame.audio_driver instead.
  #
  #  Returns the name of the audio driver that SDL is using.
  #
  #  May raise SDLError if initialization fails.
  #
  def self.driver_name
    Rubygame.deprecated( "Rubygame::Mixer", "3.0" )

    driver = SDL.AudioDriverName()

    if driver.nil?
      raise( Rubygame::SDLError,
             "Error fetching audio driver name: #{SDL.GetError()}" )
    end

    return driver
  end


  #  **NOTE:** This method is DEPRECATED and will be removed in
  #  Rubygame 3.0. Please use the Rubygame::Sound class instead.
  #
  #  Play an audio Sample on a mixing channel, repeating a certain number
  #  of extra times. Returns the number of the channel that the sample
  #  is being played on.
  #
  #  Raises SDLError if something goes wrong.
  #  
  #  This method takes these arguments:
  #  sample::      what Sample to play
  #  channel_num:: which mixing channel to play the sample on.
  #                Use -1 to play on the first unreserved channel.
  #  repeats::     how many extra times to repeat the sample.
  #                Can be -1 to repeat forever until it is stopped.
  #
  def self.play( sample, channel_num, repeats )
    Rubygame.deprecated( "Rubygame::Mixer", "3.0" )
    
    result = SDL::Mixer.PlayChannel( channel_num, sample.struct, repeats )

    if( result < 0 )
      raise( Rubygame::SDLError,
             "Error playing sample on channel %d: %s"%
             [channel, SDL.GetError()] )
    end

    return result
  end


  #  Stop playback of a playing or paused mixing channel.
  #  Unlike #pause, playback cannot be resumed from the current point.
  #  See also #play.
  # 
  def self.stop( channel_num )
    Rubygame.deprecated( "Rubygame::Mixer", "3.0" )
    SDL::Mixer.HaltChannel( channel_num )
    return nil
  end


  #  Pause playback of a currently-playing mixing channel.
  #  Playback can be resumed from the current point with #resume.
  #  See also #stop.
  #
  def self.pause( channel_num )
    Rubygame.deprecated( "Rubygame::Mixer", "3.0" )
    SDL::Mixer.Pause( channel_num )
    return nil
  end


  #  Resume playback of a paused mixing channel. The channel must have
  #  been paused (via the #pause method) for this to have any effect.
  #  Playback will resume from the point where the channel was paused.
  #
  def self.resume( channel_num )
    Rubygame.deprecated( "Rubygame::Mixer", "3.0" )
    SDL::Mixer.Resume( channel_num )
    return nil
  end

end



#  **NOTE:** This class is DEPRECATED and will be removed in Rubygame 3.0.
#  Please use the Rubygame::Sound class instead.
#
#  Stores audio data to play with Rubygame::Mixer.play
#
class Rubygame::Mixer::Sample

  #  **NOTE:** Rubygame::Mixer::Sample is DEPRECATED and will be removed in
  #  Rubygame 3.0. Please use the Rubygame::Sound class instead.
  #
  #  Load an audio sample (a "chunk", to use SDL_mixer's term) from a file.
  #  Only WAV files are supported at this time.
  #
  #  Raises SDLError if the sample could not be loaded.
  #
  def self.load_audio( filename )
    Rubygame.deprecated( "Rubygame::Mixer::Sample", "3.0" )

    chunk = SDL::Mixer.LoadWAV( filename.to_s )

    if( chunk.pointer.null? )
      raise( Rubygame::SDLError,
             "Error loading audio Sample from file `%s': %s"%
             [filename, SDL.GetError()] )
    end

    return new( chunk )
  end


  attr_reader :struct # :nodoc:
  protected :struct


  # call-seq: new
  def initialize( struct=nil )
    @struct = struct
  end

end



#  **NOTE:** This class is DEPRECATED and will be removed in Rubygame 3.0.
#  Please use the Rubygame::Music class instead.
#
#  The Music class is used for playing music from a file. It supports
#  WAVE, MOD, MIDI, OGG, and MP3 files. There are two important differences
#  between Music and Sample:
#
#  1. Music streams the music from disk, which means it can start faster and
#     uses less memory than Sample, which loads the entire file into memory.
#     This is especially important for music files, which are often several
#     minutes long.
#  2. There can only be one Music instance playing at once, while there can
#     be many Samples playing at once. If you play a second Music while one
#     is already playing, the first one will be stopped. See #play.
#
class Rubygame::Mixer::Music

  # #  Sets the external command used to play music. 
  # #
  # #  Raises SDLError if something goes wrong.
  # #
  # #  This method takes these arguments:
  # #  command::     what command to use to play the music. 
  # #
  # def set_command( command )
  #   Rubygame.deprecated( "Rubygame::Mixer::Music", "3.0" )
  # 
  #   result = SDL::Mixer.SetMusicCMD( command )
  # 
  #   if( result < 0 )
  #     raise( Rubygame::SDLError,
  #            "Error setting music player command to `%s': %s"%
  #            [command, SDL.GetError()] )
  #   end
  #
  #   return result
  # end


  #  **NOTE:** Rubygame::Mixer::Music is DEPRECATED and will be removed
  #  in Rubygame 3.0. Please use the Rubygame::Music class instead.
  #
  #  Load music from a file. Supports WAV, MOD, MIDI, OGG, and MP3 formats.
  #
  #  Raises SDLError if the music could not be loaded.
  #
  def self.load_audio
    Rubygame.deprecated( "Rubygame::Mixer::Music", "3.0" )

    music = SDL::Mixer.LoadMUS( filename.to_s )

    if( music.pointer.null? )
      raise( Rubygame::SDLError,
             "Error loading audio music from file `%s': %s"%
             [filename, SDL.GetError()] )
    end

    return new( music )
  end


  attr_reader :struct # :nodoc:
  protected :struct


  # call-seq: new
  def initialize( struct=nil )
    @struct = struct
  end


  #  Play music, repeating a certain number of extra times. If
  #  any music was already playing, that music will be stopped
  #  first, and this music will start.
  #
  #  Raises SDLError if something goes wrong.
  #  
  #  This method takes these arguments:
  #  repeats::     how many extra times to play the music.
  #                Can be -1 to repeat forever until it is stopped.
  #
  def play( repeats=0 )
    # Adjust so repeats means the same as it does for Samples
    repeats += 1 if repeats > -1

    result = SDL::Mixer.PlayMusic( @struct, repeats )

    if( result < 0 )
      raise Rubygame::SDLError, "Error playing music: #{SDL.GetError()}"
    end

    return self
  end


  #  Stop playback of music. 
  #  See also #play
  #
  def stop
    SDL::Mixer::HaltMusic()
    return self
  end


  #  Pause playback of the playing music. You can later #resume
  #  playback from the point where you paused.
  #  Safe to use on already-paused music.
  #  See also #play_music.
  #
  def pause
    SDL::Mixer::PauseMusic()
    return self
  end


  #  Resume playback of paused music from the point it was paused.
  #  Safe to use on already-playing music.
  #  See also #play.
  #
  def resume
    SDL::Mixer::ResumeMusic()
    return self
  end


  #  Rewind the music to the start. This is safe to use on stopped,
  #  paused, and playing music. Only works for MOD, OGG, MP3, and
  #  MIDI (but not WAV).
  # 
  def rewind
    SDL::Mixer::RewindMusic()
    return self
  end


  #  Jump to a certain time in the music.
  #  Only works when music is playing or paused (but not stopped).
  #  Only works for OGG and MP3 files.
  #
  #  Raises SDLError if something goes wrong, or if the music type does not
  #  support setting the position.
  #
  #  time::  Time to jump to, in seconds from the beginning.
  #
  def jump( time )
    case SDL::Mixer.GetMusicType(nil)
    when SDL::Mixer::MUS_OGG, SDL::Mixer::MUS_MP3

      SDL::Mixer::RewindMusic() # Needed for MP3, and OK with OGG

      result = SDL::Mixer.SetmusicPosition( time )
      
      if( result < 0 )
        raise( Rubygame::SDLError,
               "Error jumping to time in music: #{SDL.GetError()}" )
      end

    when SDL::Mixer::MUS_NONE
      raise Rubygame::SDLError, "Cannot jump when no music is playing."
    else
      raise Rubygame::SDLError, "Music type does not support jumping."
    end
  end


  #  Returns true if the music is currently playing.
  #
  def playing?
    return SDL::Mixer::PlayingMusic()
  end


  #  Returns true if the music is currently paused.
  #
  def paused?
    return SDL::Mixer::PausedMusic()
  end


  #  Returns the current volume level of the music.
  #  0.0 is total silence, 1.0 is maximum volume.
  #
  def volume
    return (SDL::Mixer::VolumeMusic(-1).to_f / SDL::Mixer::MAX_VOLUME)
  end


  #  Sets the volume level of the music.
  #  0.0 is total silence, 1.0 is maximum volume.
  #
  def volume=( new_volume )
    SDL::Mixer.VolumeMusic( (volume * SDL::Mixer::MAX_VOLUME).to_i )
    return new_volume
  end


  #  Play the music, fading in and repeating a certain number of times.
  #  See also #play.
  #
  #  Raises SDLError if something goes wrong.
  #  
  #  fade_time::  Time in seconds for the fade-in effect to complete.
  #  repeats::    Number of extra times to play through the music.
  #               -1 plays the music forever until it is stopped.
  #               Defaults to 0, play only once (no repeats).
  #  start::      Time to start from, in seconds since the beginning.
  #               Defaults to 0, the beginning of the song.
  #               Non-zero values only work for OGG and MP3; other
  #               music types will raise SDLError.
  #
  def fade_in( fade_time, repeats=0, start=0 )
    fade_time *= 1000 # convert to milliseconds
    repeats = (repeats or 0)
    start   = (start   or 0)

    # Adjust so repeats means the same as it does for Samples
    repeats += 1 if repeats > -1

    result =
      if( start == 0 )
        SDL::Mixer.FadeInMusic( @struct, repeats, fade_time )
      else
        SDL::Mixer.FadeInMusicPos( @struct, repeats, fade_time, start )
      end

    if( result < 0 )
      raise Rubygame::SDLError, "Error fading in music: #{SDL.GetError()}"
    end

    return self
  end


  #  Gradually fade the music to silence over +fade_length+ seconds.
  #  After the fade is complete, the music will be automatically stopped.
  #
  #  Raises SDLError if something goes wrong.
  #
  #  fade_time::    Time until the music is totally silent, in seconds.
  #
  def fade_out( fade_time )
    fade_time *= 1000 # convert to milliseconds

    result = SDL::Mixer.FadeOutMusic( fade_time )

    if( result < 0 )
      raise Rubygame::SDLError, "Error fading out music: #{SDL.GetError()}"
    end
  end


  #  True if the music is fading in or out (or either). You can
  #  specify +direction+ as :in/:out to check only fading in/out;
  #  otherwise, it will return true if it's fading either way.
  #
  #  direction::  :in, :out, or nil if you don't care which.
  #  Returns::    true if the music is fading in the given direction.
  #
  def fading?( direction=nil )
    case direction
    when :in
      return (SDL::Mixer.FadingMusic() == SDL::Mixer::FADING_IN)
    when :out
      return (SDL::Mixer.FadingMusic() == SDL::Mixer::FADING_OUT)
    else
      return (SDL::Mixer.FadingMusic() != SDL::Mixer::NO_FADING)
    end
  end
end


