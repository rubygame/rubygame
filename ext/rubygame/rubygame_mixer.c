/*
 *  Interface to SDL_mixer, for audio playback and mixing.
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

VALUE rbgm_mixer_openaudio(int, VALUE*, VALUE);
VALUE rbgm_mixer_closeaudio(VALUE);
VALUE rbgm_mixer_getmixchans();
VALUE rbgm_mixer_setmixchans(VALUE, VALUE);
VALUE rbgm_mixer_getdrivername(VALUE);

VALUE cSample;
VALUE rbgm_sample_new(VALUE, VALUE);
VALUE rbgm_mixchan_play( VALUE, VALUE, VALUE, VALUE );
VALUE rbgm_mixchan_stop( VALUE, VALUE );
VALUE rbgm_mixchan_pause( VALUE, VALUE );
VALUE rbgm_mixchan_resume( VALUE, VALUE );

VALUE cMusic;
VALUE rbgm_mixmusic_setcommand(VALUE, VALUE); 
VALUE rbgm_mixmusic_new(VALUE, VALUE);

VALUE rbgm_mixmusic_play(int, VALUE*, VALUE);
VALUE rbgm_mixmusic_stop(VALUE);
VALUE rbgm_mixmusic_resume(VALUE);
VALUE rbgm_mixmusic_pause(VALUE);
VALUE rbgm_mixmusic_rewind(VALUE);
VALUE rbgm_mixmusic_setposition(VALUE, VALUE);
VALUE rbgm_mixmusic_paused(VALUE);
VALUE rbgm_mixmusic_playing(VALUE);

VALUE rbgm_mixmusic_getvolume(VALUE);
VALUE rbgm_mixmusic_setvolume(VALUE, VALUE);
VALUE rbgm_mixmusic_fadein(int, VALUE*, VALUE);
VALUE rbgm_mixmusic_fadeout(VALUE, VALUE);
VALUE rbgm_mixmusic_fading(int, VALUE*, VALUE);


/* --
 * SETUP AND INITIALIZATION
 * ++
 */

/* call-seq:
 *  open_audio( frequency=22050, format=AUDIO_U16SYS, channels=2, buffer=4096)
 *  
 *  Initializes the audio device. You must call this before using the other
 *  mixer functions. See also #close_audio().
 *
 *  Returns nil. May raise an SDLError if initialization fails.
 *  
 *  This method takes these arguments:
 *
 *  frequency::  output sampling frequency in samples per second (Hz).
 *               22050 (default) is recommended for most games; 44100 is CD
 *               rate. The larger the value, the more processing required.
 *
 *  format::     output sample format. One of these integer constants,
 *               located in the Rubygame::Mixer module.
 *
 *               AUDIO_U16SYS:: unsigned 16-bit samples (default)
 *               AUDIO_S16SYS:: signed 16-bit samples
 *               AUDIO_U8::     unsigned 8-bit samples.
 *               AUDIO_S8::     signed 8-bit samples.
 *
 *  channels::   output sound channels. Use 2 (default) for stereo, 1 for mono.
 *               (this option does not affect number of mixing channels)
 *
 *  buffer::     size of the sound buffer, in bytes. 4096 (default) is good for
 *               most games. Smaller values have less delay before playing a
 *               sound, but require more CPU usage (and might have skipping
 *               on slow systems). Larger values are the opposite way.
 *
 */
VALUE rbgm_mixer_openaudio(int argc, VALUE *argv, VALUE module)
{
  VALUE vfreq, vformat, vchannels, vbuffer;
  int freq = 22050;
  Uint16 format = AUDIO_S16SYS;
  int channels = 2;
  int buffer = 4096;

  rb_scan_args(argc, argv, "04", &vfreq, &vformat, &vchannels, &vbuffer);

  if( RTEST(vfreq) )
  {
    freq = NUM2INT(vfreq);
  }

  if( RTEST(vformat) )
  {
    format = NUM2UINT(vformat);
  }

  if( RTEST(vchannels) )
  {
    channels = NUM2INT(vchannels);
  }

  if( RTEST(vbuffer) )
  {
    buffer = NUM2INT(vbuffer);
  }

  if ( Mix_OpenAudio(freq, format, channels, buffer) < 0 )
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
 *  driver_name -> string 
 *
 *  Returns the name of the audio driver that SDL is using.
 *
 *  May raise an SDLError if initialization fails.
 */

VALUE rbgm_mixer_getdrivername(VALUE module)
{
  char driver_name[1024];
  if(SDL_AudioDriverName(driver_name, sizeof(driver_name)) == NULL)
  {	
    rb_raise(eSDLError, "Error fetrching audio driver name: %s", SDL_GetError());
  }
  return rb_str_new2(driver_name);
}



/* --
 * SAMPLES
 * ++
 */

/* call-seq:
 *  load_audio( filename )  ->  Sample
 *
 *  Load an audio sample (a "chunk", to use SDL_mixer's term) from a file.
 *  Only WAV files are supported at this time.
 *
 *  Raises SDLError if the sample could not be loaded.
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
 *  play(sample, channel_num, repeats )  ->  integer
 *
 *  Play an audio Sample on a mixing channel, repeating a certain number
 *  of extra times. Returns the number of the channel that the sample
 *  is being played on.
 *
 *  Raises SDLError if something goes wrong.
 *  
 *  This method takes these arguments:
 *  sample::      what Sample to play
 *  channel_num:: which mixing channel to play the sample on.
 *                Use -1 to play on the first unreserved channel.
 *  repeats::     how many extra times to repeat the sample.
 *                Can be -1 to repeat forever until it is stopped.
 */
VALUE rbgm_mixchan_play( VALUE self, VALUE samplev, VALUE chanv, VALUE loopsv )
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


/* --
 * MUSIC
 * ++
 */

/* call-seq:
 *  set_music_command(command)  ->  integer
 *
 *  Sets the external command used to play music. 
 *
 *  Raises SDLError if something goes wrong.
 *
 *  This method takes these arguments:
 *  command::     what command to use to play the music. 
 *
 */
VALUE rbgm_mixmusic_setcommand(VALUE class, VALUE commandv) 
{
  int result;	
  result = Mix_SetMusicCMD(StringValuePtr(commandv));
  if( result < 0 )
  {
    rb_raise(eSDLError, "Error setting music player commando to `%s': %s",
             StringValuePtr(commandv), Mix_GetError());
  }
  return INT2NUM( result );
}

/* call-seq:
 *  load_audio( filename )  ->  Music
 *
 *  Load music from a file. Supports WAVE, MOD, MIDI, OGG, and MP3 formats.
 *
 *  Raises SDLError if the music could not be loaded.
 */
VALUE rbgm_mixmusic_new(VALUE class, VALUE filev)
{
  VALUE self;
  Mix_Music* music;

  music = Mix_LoadMUS( StringValuePtr(filev) );

  if( music == NULL )
  { 
    rb_raise(eSDLError, "Error loading audio music from file `%s': %s",
             StringValuePtr(filev), Mix_GetError());
  }
	self = Data_Wrap_Struct( cMusic, 0, Mix_FreeMusic, music );

	//rb_obj_call_init(self,argc,argv);

  return self;
}

/*  call-seq:
 *     play( repeats = 0 )
 *
 *  Play music, repeating a certain number of extra times. If
 *  any music was already playing, that music will be stopped
 *  first, and this music will start.
 *
 *  Raises SDLError if something goes wrong.
 *  
 *  This method takes these arguments:
 *  repeats::     how many extra times to play the music.
 *                Can be -1 to repeat forever until it is stopped.
 */
VALUE rbgm_mixmusic_play(int argc, VALUE *argv, VALUE self)
{
  Mix_Music* music;
  int reps, result;
  VALUE repsv;

  Data_Get_Struct( self, Mix_Music, music );

  rb_scan_args(argc, argv, "01", &repsv);

  if( RTEST(repsv) )
  {
    reps = NUM2INT(repsv);
  }
  else
  {
    reps = 0;
  }
  
  if( reps > -1 )
  {
    /* Adjust so repeats means the same as it does for Samples */
    reps += 1;
  }
  
  result = Mix_PlayMusic(music, reps);

  if ( result < 0 )
  {
    rb_raise(eSDLError, "Error playing music: %s", 
             Mix_GetError());
  }

  return Qnil;
}

/*  call-seq:
 *     stop
 *
 *  Stop playback of music. 
 *  See also #play
 */
VALUE rbgm_mixmusic_stop(VALUE self)
{
  Mix_HaltMusic();
  return Qnil;
}

/*  call-seq:
 *     pause
 *
 *  Pause playback of the playing music. You can later #resume
 *  playback from the point where you paused.
 *  Safe to use on already-paused music.
 *  See also #play_music.
 */
VALUE rbgm_mixmusic_pause(VALUE self)
{
  Mix_PauseMusic();
  return Qnil;
}

/*  call-seq:
 *     resume
 *
 *  Resume playback of paused music from the point it was paused.
 *  Safe to use on already-playing music.
 *  See also #play.
 */
VALUE rbgm_mixmusic_resume(VALUE self)
{
  Mix_ResumeMusic();
  return Qnil;
}

/*  call-seq:
 *     rewind
 *
 *  Rewind the music to the start. This is safe to use on stopped, paused, and playing music. 
 *  Only works for MOD, OGG, MP3, and MIDI (but not WAV).
 * 
 */
VALUE rbgm_mixmusic_rewind(VALUE self)
{
  Mix_RewindMusic();
  return Qnil;
}

/*  call-seq:
 *     position = new_position
 *
 *  Set the current position of the music to the new position.
 *  Only works when music is playing or paused (but not stopped).
 *  Only works for OGG and MP3 files.
 *
 *  Raises SDLError if something goes wrong, or if the music type does not
 *  support setting the position.
 *
 *  new_position::  Position in music, in seconds from the beginning.
 *
 */
VALUE rbgm_mixmusic_setposition(VALUE self, VALUE positionv)
{
  double position = NUM2DBL(positionv);

  switch( Mix_GetMusicType(NULL) )
	{
    case MUS_OGG:
    case MUS_MP3:
      Mix_RewindMusic(); // Needed for MP3, and OK with OGG

      int result = Mix_SetMusicPosition(position);  
      if( result < 0 )
      {
        rb_raise(eSDLError, "Error setting music position: %s", Mix_GetError());
      }

      return positionv;

    case MUS_NONE:
      rb_raise(eSDLError, "Cannot set position when no music is playing.");

    default:
      rb_raise(eSDLError, "Music type does not support setting position.");
  }
} 	

/*  call-seq:
 *     playing?  ->  true or false
 *
 *  Returns true if the music is currently playing.
 *
 */
VALUE rbgm_mixmusic_playing(VALUE self)
{
  return Mix_PlayingMusic() ? Qtrue : Qfalse;
}

/*  call-seq:
 *     paused?  ->  true or false
 *
 *  Returns true if the music is currently paused.
 *
 */
VALUE rbgm_mixmusic_paused(VALUE self)
{
  return Mix_PausedMusic() ? Qtrue : Qfalse;
}

/*  call-seq:
 *     volume
 *
 *  Returns the current volume level of the music.
 *  0.0 is total silence, 1.0 is maximum volume.
 */
VALUE rbgm_mixmusic_getvolume(VALUE self)
{
  return rb_float_new( (double)(Mix_VolumeMusic(-1)) / MIX_MAX_VOLUME );
}

/*  call-seq:
 *     volume = new_volume
 *
 *  Sets the volume level of the music.
 *  0.0 is total silence, 1.0 is maximum volume.
 */
VALUE rbgm_mixmusic_setvolume(VALUE self, VALUE volumev)
{
  double volume = NUM2DBL(volumev);
  Mix_VolumeMusic( (int)(volume * MIX_MAX_VOLUME) );
  return volumev;
}

/*  call-seq:
 *     fade_in( fade_time, repeats=0, start=0 )
 *
 *  Play the music, fading in and repeating a certain number of times.
 *  See also #play.
 *
 *  Raises SDLError if something goes wrong.
 *  
 *  fade_time::  Time in seconds for the fade-in effect to complete.
 *  repeats::    Number of extra times to play through the music.
 *               -1 plays the music forever until it is stopped.
 *               Defaults to 0, play only once (no repeats).
 *  start::      Time to start from, in seconds since the beginning.
 *               Defaults to 0, the beginning of the song.
 *               Non-zero values only work for OGG and MP3; other
 *               music types will raise SDLError.
 */
VALUE rbgm_mixmusic_fadein(int argc, VALUE *argv, VALUE self)
{
  VALUE fadev, repsv, startv;
  rb_scan_args(argc, argv, "12", &fadev, &repsv, &startv);

  Mix_Music* music;
  Data_Get_Struct( self, Mix_Music, music );

  int fade, reps, result;
  fade = (int)(NUM2DBL(fadev) * 1000); /* convert to milliseconds */

  if( RTEST(repsv) )
  {
    reps = NUM2INT(repsv);
  }
  else
  {
    reps = 0;
  }

  if( reps > -1 )
  {
    /* Adjust so repeats means the same as it does for Samples */
    reps += 1;
  }
  
  if( !RTEST(startv) || NUM2DBL(startv) == 0.0 )
  {
		result = Mix_FadeInMusic(music, reps, fade);
  }
  else
	{
    result = Mix_FadeInMusicPos(music, reps, fade, NUM2DBL(startv));
  }

  if( result < 0 )
  {
    rb_raise(eSDLError, "Error fading in music: %s", Mix_GetError());
  }

  return Qnil;
}

/*  call-seq:
 *     fade_out( fade_time )
 *
 *  Gradually fade the music to silence over +fade_length+ seconds.
 *  After the fade is complete, the music will be automatically stopped.
 *
 *  Raises SDLError if something goes wrong.
 *
 *  fade_time::    Time until the music is totally silent, in seconds.
 */
VALUE rbgm_mixmusic_fadeout(VALUE self, VALUE fadev)
{
  int fade = (int)(NUM2DBL(fadev) * 1000);
  int result = Mix_FadeOutMusic(fade);

  if ( result < 0 )
  {
    rb_raise(eSDLError, "Error fading out music: %s", Mix_GetError());
  }
  return Qnil;
}

/*  call-seq:
 *     fading?( direction = nil )  ->  true or false
 *
 *  True if the music is fading in or out (or either). You can
 *  specify +direction+ as :in/:out to check only fading in/out;
 *  otherwise, it will return true if it's fading either way.
 *
 *  direction::  :in, :out, or nil if you don't care which.
 *  Returns::    true if the music is fading in the given direction.
 */
VALUE rbgm_mixmusic_fading(int argc, VALUE *argv, VALUE self)
{
  VALUE dirv;
  rb_scan_args(argc, argv, "01", &dirv);

  if( dirv == make_symbol("in") )
  {
    return ( (Mix_FadingMusic() == MIX_FADING_IN)  ? Qtrue : Qfalse );
  }
  else if( dirv == make_symbol("out") )
  {
    return ( (Mix_FadingMusic() == MIX_FADING_OUT) ? Qtrue : Qfalse );
  }
  else
  {
    return ( (Mix_FadingMusic() != MIX_NO_FADING)  ? Qtrue : Qfalse );
  }
}


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

	/*
	 *  The Mixer module provides access to the SDL_mixer library for audio
	 *  playback and mixing. This module is still very basic, but it is
	 *  good enough to load and play WAV files on multiple mix channels.
	 *
	 *  See the Sample class for loading audio files.
	 *  See the Music class for streaming music from a file.
	 */
  mMixer = rb_define_module_under(mRubygame, "Mixer");

  rb_define_const(mMixer,"AUDIO_U8", INT2NUM(AUDIO_U8));
  rb_define_const(mMixer,"AUDIO_S8", INT2NUM(AUDIO_S8));
  rb_define_const(mMixer,"AUDIO_U16",UINT2NUM(AUDIO_U16));
  rb_define_const(mMixer,"AUDIO_S16",UINT2NUM(AUDIO_S16));
  rb_define_const(mMixer,"AUDIO_U16SYS", INT2NUM(AUDIO_U16SYS));
  rb_define_const(mMixer,"AUDIO_S16SYS", INT2NUM(AUDIO_S16SYS));
  rb_define_const(mMixer,"AUDIO_U16LSB",UINT2NUM(AUDIO_U16LSB));
  rb_define_const(mMixer,"AUDIO_S16LSB",UINT2NUM(AUDIO_S16LSB));
  rb_define_const(mMixer,"AUDIO_U16MSB",UINT2NUM(AUDIO_U16MSB));
  rb_define_const(mMixer,"AUDIO_S16MSB",UINT2NUM(AUDIO_S16MSB));

  rb_define_const(mMixer,"CHANNELS",INT2NUM(MIX_CHANNELS));
  rb_define_const(mMixer,"DEFAULT_FREQUENCY",INT2NUM(MIX_DEFAULT_FREQUENCY));
  rb_define_const(mMixer,"DEFAULT_FORMAT",UINT2NUM(MIX_DEFAULT_FORMAT));
  rb_define_const(mMixer,"DEFAULT_CHANNELS",UINT2NUM(MIX_DEFAULT_CHANNELS));
  rb_define_const(mMixer,"MAX_VOLUME",INT2NUM(MIX_MAX_VOLUME));

  rb_define_const(mMixer,"NO_FADING", INT2NUM(MIX_NO_FADING));
  rb_define_const(mMixer,"FADING_OUT", INT2NUM(MIX_FADING_OUT));
  rb_define_const(mMixer,"FADING_IN", INT2NUM(MIX_FADING_IN));



  rb_define_module_function(mMixer,"open_audio",rbgm_mixer_openaudio, -1);
  rb_define_module_function(mMixer,"close_audio",rbgm_mixer_closeaudio, 0);
  rb_define_module_function(mMixer,"mix_channels",rbgm_mixer_getmixchans, 0);
  rb_define_module_function(mMixer,"mix_channels=",rbgm_mixer_setmixchans, 1);
  rb_define_module_function(mMixer,"driver_name", rbgm_mixer_getdrivername, 0);



  /* Stores audio data to play with Mixer.play() */
  cSample = rb_define_class_under(mMixer, "Sample", rb_cObject);
  rb_define_singleton_method(cSample, "load_audio", rbgm_sample_new, 1);
  rb_define_module_function(mMixer,"play", rbgm_mixchan_play, 3);
  rb_define_module_function(mMixer,"stop", rbgm_mixchan_stop, 1);
  rb_define_module_function(mMixer,"pause", rbgm_mixchan_pause, 1);
  rb_define_module_function(mMixer,"resume", rbgm_mixchan_resume, 1);


/*  The Music class is used for playing music from a file. It supports
 *  WAVE, MOD, MIDI, OGG, and MP3 files. There are two important differences
 *  between Music and Sample:
 *
 *  1. Music streams the music from disk, which means it can start faster and
 *     uses less memory than Sample, which loads the entire file into memory.
 *     This is especially important for music files, which are often several
 *     minutes long.
 *  2. There can only be one Music instance playing at once, while there can
 *     be many Samples playing at once. If you play a second Music while one
 *     is already playing, the first one will be stopped. See #play.
 */
  cMusic = rb_define_class_under(mMixer, "Music", rb_cObject);
  rb_define_singleton_method(cMusic, "load_audio", rbgm_mixmusic_new, 1);

  //rb_define_singleton_method(cMusic, "set_command", rbgm_mixmusic_setcommand, 1);
	
  rb_define_method(cMusic, "play",      rbgm_mixmusic_play,       -1);
  rb_define_method(cMusic, "stop",      rbgm_mixmusic_stop,        0);
  rb_define_method(cMusic, "pause",     rbgm_mixmusic_pause,       0);
  rb_define_method(cMusic, "resume",    rbgm_mixmusic_resume,      0);
  rb_define_method(cMusic, "rewind",    rbgm_mixmusic_rewind,      0);
  rb_define_method(cMusic, "position=", rbgm_mixmusic_setposition, 1);
  rb_define_method(cMusic, "paused?",   rbgm_mixmusic_paused,      0);
  rb_define_method(cMusic, "playing?",  rbgm_mixmusic_playing,     0);

  rb_define_method(cMusic, "volume",    rbgm_mixmusic_getvolume,   0);
  rb_define_method(cMusic, "volume=",   rbgm_mixmusic_setvolume,   1);
  rb_define_method(cMusic, "fade_in",   rbgm_mixmusic_fadein,     -1);
  rb_define_method(cMusic, "fade_out",  rbgm_mixmusic_fadeout,     1);
  rb_define_method(cMusic, "fading?",   rbgm_mixmusic_fading,     -1);
}


