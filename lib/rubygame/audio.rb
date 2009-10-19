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



module Rubygame

  # call-seq:
  #   open_audio( options={:buffer=>1024, :channels=>2, :frequency=>22050} )
  #
  # Initializes the audio device using the given settings.
  #
  # NOTE: Audio will be automatically opened when Rubygame::Sound or
  # Rubygame::Music are first used. You only need to open audio
  # manually if you want settings different from the default, or if
  # you are using the older, deprecated Music and Sample classes from
  # the Rubygame::Mixer module.
  #
  # If audio is already open, this method has no effect, and returns false.
  # If you want to change audio settings, you must #close_audio() and
  # then open it again.
  #
  # options::    A Hash of any of the following options. (Hash, optional)
  #
  #    :frequency::  output sample rate in audio samples per second
  #                  (Hz). Affects the quality of the sound output, at
  #                  the expense of CPU usage. If omitted, the default
  #                  (22050) is used. The default is recommended for
  #                  most games.
  #
  #    :channels::   output sound channels. Use 2 for stereo, 1 for mono.
  #                  If omitted, the default (2) is used.
  #
  #    :buffer::     size of the sound buffer, in bytes. Must be a
  #                  power of 2 (e.g. 512, 1024, 2048). If omitted,
  #                  the default (1024) is used. If your game is
  #                  fast-paced, you may want to use a smaller value
  #                  to reduce audio delay, the time between when you
  #                  play a sound and when it is heard.
  #
  # Returns::    true if the audio was newly opened by this action, or
  #              false if it was already open before this action.
  #
  # May raise::  SDLError, if initialization fails.
  #              ArgumentError, if an invalid value is given for any option.
  #
  def self.open_audio( options={} )
    return false if audio_open?

    unless options.kind_of? Hash
      raise TypeError, "invalid options Hash: #{options.inspect}"
    end

    buff = (options[:buffer] or 1024)
    chan = (options[:channels] or 2)
    freq = (options[:frequency] or SDL::Mixer::DEFAULT_FREQUENCY)

    # In general, format should always be the default.
    frmt = SDL::Mixer::DEFAULT_FORMAT


    buff = if( buff <= 0 )
             raise ArgumentError, "buffer size must be positive (got #{buff})"
           elsif( buff & (buff - 1) != 0 )
             raise( ArgumentError, "buffer size must be a power of 2 "+
                    "(e.g. 512, 1024) (got #{buff})" )
           else
             buff.to_i
           end


    chan = if( chan != 1 && chan != 2 )
             raise( ArgumentError, 
                    "channels must be 1 (mono) or 2 (stereo) (got #{chan})" )
           else
             chan.to_i
           end


    freq = if( freq <= 0 )
             raise ArgumentError, "frequency must be positive (got #{freq})"
           else
             freq.to_i
           end

    result = SDL::Mixer.OpenAudio(freq, frmt, chan, buff)

    if( result < 0 )
      raise Rubygame::SDLError, "Could not open audio: #{SDL.GetError()}"
    end

    return true
  end



  # Deinitializes and closes the audio device. If audio was not open,
  # this method does nothing, and returns false. See also #open_audio().
  # 
  # NOTE: The audio will be automatically closed when the program
  # exits. You only need to close audio manually if you want to
  # call #open_audio with different settings.
  # 
  # Returns::  true if the audio was open before this action.
  #
  def self.close_audio
    if audio_open?
      SDL::Mixer.CloseAudio()
      return true
    else
      return false
    end
  end


  def self.audio_open?          # :nodoc:
    SDL::Mixer.QuerySpec(nil,nil,nil) > 0
  end


  # Returns the name of the audio driver that SDL is using.
  # This method opens the audio device if it is not open already.
  #
  # May raise an SDLError if the audio device could not be opened.
  #
  def self.audio_driver
    open_audio
    return SDL.AudioDriverName
  end

end
