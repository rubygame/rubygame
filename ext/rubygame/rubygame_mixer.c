/*
 *  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004-2006  John 'jacius' Croisant
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
 *
 */

#include "rubygame.h"
#include "rubygame_mixer.h"

void Rubygame_Init_Mixer();
VALUE mMixer;


/* call-seq:
 *  open_audio( frequency, format, channels, chunksize)
 *  
 *  Initializes the audio device. You must call this before using the other
 *  mixer functions.
 *  
 *  This method takes these arguments:
 *  frequency::  output sampling frequency in samples per second (Hz).
 *               22050 is recommended for most games; 44100 is CD audio
 *               rate. The larger the value, the more processing required.
 *  format::     output sample format.
 *  channels::   output sound channels. Use 2 for stereo, 1 for mono.
 *               (this option does not affect number of mixing channels)
 *  chunksize::  bytes per output sample.
 */
VALUE rbgm_mixer_openaudio(VALUE module, VALUE freq, VALUE form, 
                           VALUE chans, VALUE chunk)
{
  int frequency, channels, chunksize;
  Uint16 format;
  
  frequency = NUM2INT(freq);
  format = NUM2UINT(freq);
  channels = NUM2INT(chans);
  chunksize = NUM2INT(chunk);

  if ( Mix_OpenAudio(frequency, format, channels, chunksize) < 0 )
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
 *  re-open the audio device. Returns nil.
 */
VALUE rbgm_mixer_closeaudio(VALUE module)
{
  MixCloseAudio();
  return Qnil;
}


/*
 *  Document-module: Rubygame::Mixer
 *
 *  The Mixer module provides access to the SDL_mixer library for audio
 *  playback and mixing. 
 */
Rubygame_Init_Mixer()
{

#if 0
  /* Pretend to define Rubygame module, so RDoc knows about it: */
  mRubygame = rb_define_module("Rubygame");
#endif

  mMixer = rb_define_module_under(mRubygame, "Mixer");

  rb_define_const(mMixer, "AUDIO_U8", INT2NUM(AUDIO_U8));
  rb_define_const(mMixer, "AUDIO_S8", INT2NUM(AUDIO_S8));
  rb_define_const(mMixer, "AUDIO_U16SYS", INT2NUM(AUDIO_U16SYS));
  rb_define_const(mMixer, "AUDIO_S16SYS", INT2NUM(AUDIO_S16SYS));

  rb_define_module_function(mMixer,"open_audio",rbgm_mixer_openaudio, 4);
  rb_define_module_function(mMixer,"close_audio",rbgm_mixer_closeaudio, 0);

}
