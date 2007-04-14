/*
 *  Interface to SDL_mixer library, for audio playback and mixing.
 *--
 *  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004-2007  John Croisant
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *++
 */

#include "rubygame_shared.h"
#include "rubygame_mixer.h"

void Init_rubygame_mixer();
VALUE mMixer;

VALUE rbgm_mixer_openaudio(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_mixer_closeaudio(VALUE);
VALUE rbgm_mixer_getmixchans();
VALUE rbgm_mixer_setmixchans(VALUE, VALUE);

VALUE cSample;
VALUE rbgm_sample_new(VALUE, VALUE);

VALUE rbgm_mixchan_play( VALUE, VALUE, VALUE, VALUE );
VALUE rbgm_mixchan_stop( VALUE, VALUE );
VALUE rbgm_mixchan_pause( VALUE, VALUE );
VALUE rbgm_mixchan_resume( VALUE, VALUE );

/* call-seq:
 *  open_audio( frequency, format, channels, samplesize)
 *  
 *  Initializes the audio device. You must call this before using the other
 *  mixer functions. See also #close_audio().
 *
 *  Returns nil. May raise an SDLError if initialization fails.
 *  
 *  This method takes these arguments:
 *  frequency::  output sampling frequency in samples per second (Hz).
 *               22050 is recommended for most games; 44100 is CD audio
 *               rate. The larger the value, the more processing required.
 *  format::     output sample format.
 *  channels::   output sound channels. Use 2 for stereo, 1 for mono.
 *               (this option does not affect number of mixing channels)
 *  samplesize:: bytes per output sample.
 *
 */
VALUE rbgm_mixer_openaudio(VALUE module, VALUE frequencyv, VALUE formatv, 
                           VALUE channelsv, VALUE samplesizev)
{
  int frequency, channels, samplesize;
  Uint16 format;
  
  frequency = NUM2INT(frequencyv);
  format = NUM2UINT(formatv);
  channels = NUM2INT(channelsv);
  samplesize = NUM2INT(samplesizev);

  if ( Mix_OpenAudio(frequency, format, channels, samplesize) < 0 )
  {
    rb_raise(eSDLError, "Error initializing SDL_mixer: %s", Mix_GetError());
  }

  return Qnil;
}

/* call-seq:
 *  close_audio()
 *  
 *  Close the audio device being used by the mixer. You should not use any
 *  mixer functions after this function, unless you use #open_audio() to
 *  re-open the audio device. See also #open_audio().
 *
 *  Returns nil.
 */
VALUE rbgm_mixer_closeaudio(VALUE module)
{
  Mix_CloseAudio();
  return Qnil;
}

/* call-seq:
 *  #mix_channels()  ->  integer
 *
 *  Returns the number of mixing channels currently allocated.
 *  See also #mix_channels=().
 */
VALUE rbgm_mixer_getmixchans(VALUE module)
{
  int result;
  result = Mix_AllocateChannels(-1);

  return INT2NUM(result);
}

/* call-seq:
 *  #mix_channels = num_channels 
 *
 *  Set the number of mixer channels, allocating or deallocating channels as
 *  needed. This can be called many times, even during audio playback. If this
 *  call reduces the number of channels allocated, the excess channels will
 *  be stopped automatically. See also #mix_channels()
 *
 *  Returns the number of mixing channels allocated.
 *
 *  Note that 8 mixing channels are allocated when #open_audio() is called.
 *  This method only needs to be called if you want a different number (either
 *  greater or fewer) of mixing channels.
 *  
 *  This method takes this argument:
 *  num_channels::  desired number of mixing channels, an integer. 
 *                  Negative values will cause this method to behave as
 *                  #mix_channels(), returning the number of channels currently
 *                  allocated, without changing it.
 */
VALUE rbgm_mixer_setmixchans(VALUE module, VALUE channelsv)
{
  int desired;
  int allocated;

  desired = NUM2INT(channelsv);
  allocated = Mix_AllocateChannels(desired);

  return INT2NUM(allocated);
}

/* call-seq:
 *  new( filename )  ->  Sample
 *
 *  Load an audio sample (aka chunk) from a file.
 *  Only WAV files are supported at this time.
 *
 *  May raise SDLError if the sample could not be loaded.
 */
VALUE rbgm_sample_new(VALUE class, VALUE filev)
{
  VALUE self;
  Mix_Chunk* sample;

  sample = Mix_LoadWAV( StringValuePtr(filev) );

  if( sample == NULL )
  { 
    rb_raise(eSDLError, "Error loading audio Sample from file `%s': %s",
             StringValuePtr(filev), Mix_GetError());
  }
	self = Data_Wrap_Struct( cSample, 0, Mix_FreeChunk, sample );

	//rb_obj_call_init(self,argc,argv);

  return self;
}

/* call-seq:
 *  play(sample, repeats, channel_num )  ->  integer
 *
 *  Play the given audio sample on the given mixing channel, repeating the
 *  given number of times. Returns the number of the channel the sample
 *  will be played on.
 *
 *  May raise SDLError
 *  
 *  This method takes these arguments:
 *  sample::      Sample to play
 *  repeats::     number of times after the first to repeat the sample.
 *                So, the sample will play +repeats+ + 1 times total.
 *                Can be -1 to repeat forever until it is stopped.
 *  channel_num:: number of the mixing channel to play the sample on.
 *                Use -1 to play on the first unreserved channel.
 */
VALUE rbgm_mixchan_play( VALUE self, VALUE samplev, VALUE loopsv, VALUE chanv )
{
  Mix_Chunk* sample;
  int loops, channel, result;

  channel = NUM2INT(chanv);
  Data_Get_Struct( samplev, Mix_Chunk, sample );
  loops = NUM2INT(loopsv);
  
  result = Mix_PlayChannel(channel, sample, loops);

  if ( result < 0 )
  {
    rb_raise(eSDLError, "Error playing sample on channel %d: %s", 
             channel, Mix_GetError());
  }

  return INT2NUM( result );
}


/* call-seq:
 *  stop( channel_num )
 *
 *  Stop playback of a playing or paused mixing channel.
 *  Unlike #pause, playback cannot be resumed from the current point.
 *  See also #play.
 */
VALUE rbgm_mixchan_stop( VALUE self, VALUE chanv )
{
  Mix_HaltChannel(NUM2INT(chanv));
  return Qnil;
}

/* call-seq:
 *  pause( channel_num )
 *
 *  Pause playback of a currently-playing mixing channel.
 *  Playback can be resumed from the current point with #resume.
 *  See also #stop.
 */
VALUE rbgm_mixchan_pause( VALUE self, VALUE chanv )
{
  Mix_Pause(NUM2INT(chanv));
  return Qnil;
}

/* call-seq:
 *  resume( channel_num )
 *
 *  Resume playback of a paused mixing channel. The channel must have been
 *  paused (via the #pause method) for this to have any effect. Playback will
 *  resume from the point where the channel was paused.
 *  
 */
VALUE rbgm_mixchan_resume( VALUE self, VALUE chanv )
{
  Mix_Resume(NUM2INT(chanv));
  return Qnil;
}

/*
 *  Document-module: Rubygame::Mixer
 *
 *  The Mixer module provides access to the SDL_mixer library for audio
 *  playback and mixing. 
 */
void Init_rubygame_mixer()
{

#if 0
  mRubygame = rb_define_module("Rubygame");
#endif

  Init_rubygame_shared();

  rb_hash_aset(rb_ivar_get(mRubygame,rb_intern("VERSIONS")),
               ID2SYM(rb_intern("sdl_mixer")),
               rb_ary_new3(3,
                           INT2NUM(SDL_MIXER_MAJOR_VERSION),
                           INT2NUM(SDL_MIXER_MINOR_VERSION),
                           INT2NUM(SDL_MIXER_PATCHLEVEL)));

  mMixer = rb_define_module_under(mRubygame, "Mixer");

  rb_define_const(mMixer, "AUDIO_U8", INT2NUM(AUDIO_U8));
  rb_define_const(mMixer, "AUDIO_S8", INT2NUM(AUDIO_S8));
  rb_define_const(mMixer, "AUDIO_U16SYS", INT2NUM(AUDIO_U16SYS));
  rb_define_const(mMixer, "AUDIO_S16SYS", INT2NUM(AUDIO_S16SYS));

  rb_define_module_function(mMixer,"open_audio",rbgm_mixer_openaudio, 4);
  rb_define_module_function(mMixer,"close_audio",rbgm_mixer_closeaudio, 0);
  rb_define_module_function(mMixer,"mix_channels",rbgm_mixer_getmixchans, 0);
  rb_define_module_function(mMixer,"mix_channels=",rbgm_mixer_setmixchans, 1);

  cSample = rb_define_class_under(mMixer, "Sample", rb_cObject);
  rb_define_singleton_method(cSample, "new", rbgm_sample_new, 1);

  rb_define_module_function(mMixer,"play", rbgm_mixchan_play, 3);
  rb_define_module_function(mMixer,"stop", rbgm_mixchan_stop, 1);
  rb_define_module_function(mMixer,"pause", rbgm_mixchan_pause, 1);
  rb_define_module_function(mMixer,"resume", rbgm_mixchan_resume, 1);

}
