/*
 *  Interface to SDL_mixer music playback and mixing.
 *--
 *  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004-2008  John Croisant
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

#include "SDL_mixer.h"
#include "rubygame_shared.h"
#include "rubygame_mixer.h"

VALUE cMusic;


/*
 * A pointer to a Mix_Music, with a reference count.
 * Allows re-use of music data, then freeing memory when
 * there are no references to it.
 */
typedef struct RG_WrapMusic {
  /* 'private' */
  Mix_Music *music;
  int ref_count;
} RG_WrapMusic;


/*
 * The struct that the Music class wraps. Stores a 
 * pointer to a RG_WrapMusic and important attributes
 * of the Music like its volume.
 */
typedef struct RG_Music {
  /* 'public' */
  float volume;

  /* 'private' */
  RG_WrapMusic *wrap;
  int repeats;
} RG_Music;




/* Allocate/initialize the memory for a RG_WrapMusic and return a pointer. */
static RG_WrapMusic* _rg_wrapmusic_alloc()
{
  RG_WrapMusic *wrap;
  wrap = ALLOC(RG_WrapMusic);

  wrap->music = NULL;
  wrap->ref_count = 0;

  return wrap;
}

/* Load a Mix_Music from a file and assign it to the RG_WrapMusic. */
static int _rg_wrapmusic_load( RG_WrapMusic *wrap, char *file )
{
  wrap->music = Mix_LoadMUS( file );

  if( !(wrap->music) )
    return -1;
  else
    return 0;
}

/* Make a copy of the other's Mix_Music data, and assign
 * it to the RG_WrapMusic.
 */
static void _rg_wrapmusic_deepcopy( RG_WrapMusic *wrap, RG_WrapMusic *other )
{
  wrap->music = other->music;
}


/* Free the memory used by the RG_WrapMusic */
static void _rg_wrapmusic_free( RG_WrapMusic *wrap )
{
  Mix_FreeMusic( wrap->music );
  wrap->music = NULL;
  free(wrap);
}




/* Associate a RG_WrapMusic with a RG_Music. Handles reference counts. */
static inline void _rg_music_associate( RG_Music *music, RG_WrapMusic *wrap )
{
  music->wrap = wrap;
  music->wrap->ref_count += 1;
}

/* Deassociate the RG_Music's WrapMusic. Handles reference counts. */
static inline void _rg_music_deassociate( RG_Music *music )
{
  music->wrap->ref_count -= 1;
  music->wrap = NULL;
}

/* Allocate/initialize the memory for a RG_Music and return a pointer. */
static RG_Music* _rg_music_alloc()
{
  RG_Music *music;
  music = ALLOC(RG_Music);

  music->wrap = NULL;
  music->volume = 1.f;
  music->repeats = 0;

  return music;
}


/*
 * Free the memory used by the RG_Music, and possibly the memory
 * used by the WrapMusic it refers to.
 */
static void _rg_music_free( RG_Music *music )
{
  RG_WrapMusic *wrap = music->wrap;

  _rg_music_deassociate( music );

  free(music);

  /* If the WrapMusic has no more referrers, free it too. */
  if( wrap->ref_count <= 0 )
  {
    _rg_wrapmusic_free( wrap );
  }
}


/* Load a new Music from a file. */
static int _rg_music_load( RG_Music *music, char *file )
{
  RG_WrapMusic *wrap = _rg_wrapmusic_alloc();

  int result = _rg_wrapmusic_load( wrap, file );

  _rg_music_associate( music, wrap );

  return result;
}


/*
 * Make a shallow copy of the given Music; the new Music points to
 * the same audio data in memory as the old one. Also copies
 * user-visible attributes (e.g. volume).
 */
static void _rg_music_copy( RG_Music *music, RG_Music *other )
{
  _rg_music_associate( music, other->wrap );

  music->volume = other->volume;
}


/* Make a new Music with a copy of the audio from an existing Music */
static void _rg_music_deepcopy( RG_Music *music, RG_Music *other )
{
  RG_WrapMusic *wrap = _rg_wrapmusic_alloc();
  _rg_wrapmusic_deepcopy( wrap, other->wrap );

  _rg_music_associate( music, wrap );

  music->volume = other->volume;
}


/*
 * Play the music, fading in, repeating, and starting at a time as specified.
 * fade_in and start_at are in milliseconds here!
 */
static int _rg_music_play( RG_Music *music, 
                           int fade_in, int repeats, double start_at )
{

  /* Open audio if it's not already. Return -1 if it failed. */
  if( ensure_open_audio() != 0 )
  {
    return -1;
  }

  /* Doing a little restart dance to please the SDL_mixer gods. */
  Mix_PlayMusic( music->wrap->music, 0 );
  Mix_HaltMusic();

  /* Set music channel volume before we play */
  Mix_VolumeMusic( (int)(MIX_MAX_VOLUME * music->volume) );


  if( fade_in <= 0 )
  {
    fade_in = 0;
  }

  if( start_at < 0 )
  {
    start_at = 0;
  }

  /* Remember repeats, for when we rewind or jump. */
  music->repeats = repeats;

  /* Play music as specified, and return whether it worked. */
  return Mix_FadeInMusicPos( music->wrap->music,
                             repeats, fade_in, start_at );

}




/*
 * Return the Music which is currently set on the music channel (i.e.
 * was played most recently) or nil if no Music has ever been played.
 *
 * NOTE: The current Music could be playing, paused, or stopped. Use
 * #playing? or #stopped? if you want to know whether the current
 * music is still playing.
 */
static VALUE rg_music_current( VALUE klass )
{
  return rb_iv_get( cMusic, "@current_music" );
}


/* Set the currently-active Music to the given Music or nil.
 */
static VALUE _rg_music_set_current( VALUE music )
{
  return rb_iv_set( cMusic, "@current_music", music );
}


/* Check that the music is currently active on the music channel. */
static int _rg_music_current_check( VALUE music )
{
  return ( rg_music_current( cMusic ) == music );
}


/* Ruby allocation function. */
static VALUE rg_music_alloc( VALUE klass )
{
  RG_Music *music = _rg_music_alloc();
  return Data_Wrap_Struct(klass, 0, _rg_music_free, music);
}



/*
 *  call-seq:
 *    new( filename )  ->  music
 *
 *  Load the given audio file.
 *  Supported file formats are WAVE, MOD, MIDI, OGG, and MP3.
 *
 *  filename::    Full or relative path to the file. (String, required)
 *
 *  Returns::     The new Music instance. (Music)
 *  May raise::   SDLError, if the music file could not be loaded.
 *
 */
static VALUE rg_music_initialize( VALUE self, VALUE filename )
{
  RG_Music *music;
  Data_Get_Struct(self, RG_Music, music);

  char *file = StringValuePtr(filename);

  int result = _rg_music_load( music, file );

  if( result == -1 )
  {
    rb_raise(eSDLError, "Could not load Music file '%s': %s",
             file, Mix_GetError());
  }

  return self;
}


/*
 *  call-seq:
 *    clone( other )  ->  music
 *    dup( other )  ->  music
 *
 *  Create a copy of the given Music instance. More efficient
 *  than using #new to load the music file again.
 *
 *  other::       An existing Music instance. (Music, required)
 *
 *  Returns::     The new Music instance. (Music)
 *
 *  **NOTE**: #clone and #dup do slightly different things; #clone will copy
 *  the 'frozen' state of the object, while #dup will create a fresh, un-frozen
 *  object.
 *
 */
static VALUE rg_music_initialize_copy( VALUE self, VALUE other )
{
  RG_Music *musicA, *musicB;
  Data_Get_Struct(self,  RG_Music, musicA);
  Data_Get_Struct(other, RG_Music, musicB);

  _rg_music_copy( musicA, musicB );

  return self;
}




/*
 *  call-seq:
 *    play( options={:fade_in => 0, :repeats => 0, :start_at => 0} )  ->  self
 *
 *  Play the Music, optionally fading in, repeating a certain number
 *  of times (or forever), and/or starting at a certain position in
 *  the song.
 *
 *  See also #pause and #stop.
 *
 *  options::     Hash of options, listed below. (Hash, required)
 *
 *    :fade_in::     Fade in from silence over the given number of
 *                   seconds. Default: 0. (Numeric, optional)
 *    :repeats::     Repeat the music the given number of times, or
 *                   forever (or until stopped) if -1. Default: 0.
 *                   (Integer, optional)
 *    :start_at::    Start playing the music at the given time in the
 *                   song, in seconds. Default: 0. (Numeric, optional)
 *                   **NOTE**: Non-zero start times only work for
 *                   OGG and MP3 formats! Please refer to #jump.
 *
 *
 *  Returns::     The receiver (self).
 *  May raise::   SDLError, if the music file could not be played, or
 *                if you used :start_at with an unsupported format.
 *
 *	**NOTE**: Only one music can be playing at once. If any music is
 *  already playing (or paused), it will be stopped before playing the
 *  new music.
 *
 *  Example:
 *    # Fade in over 2 seconds, play 4 times (1 + 3 repeats),
 *    # starting at 60 seconds since the beginning of the song.
 *    music.play( :fade_in => 2, :repeats => 3, :start_at => 60 );
 *
 */
static VALUE rg_music_play( int argc, VALUE *argv, VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  VALUE options;
  rb_scan_args(argc, argv, "01", &options);

  int fade_in    =  0;
  int repeats    =  1;
  double start_at   =  0;

  /* If we got some options */
  if( RTEST(options) )
  {
    /* Make sure options is a Hash table */
    if( TYPE(options) != T_HASH )
    {
      rb_raise(rb_eTypeError, "wrong argument type %s (expected Hash)",
               rb_obj_classname(options));
    }

    VALUE temp;


    temp = rb_hash_aref(options, make_symbol("fade_in"));
    if( RTEST(temp) )
    {
      fade_in = (int)(1000 * NUM2DBL( temp ));

      if( fade_in < 0 )
      {
        rb_raise(rb_eArgError, ":fade_in cannot be negative (got %.2f)",
                 fade_in / 1000);
      }
      else if( fade_in < 50 )
      {
        /* Work-around for a bug with SDL_mixer not working with small non-zero fade-ins */
        fade_in = 0;
      }
    }


    temp = rb_hash_aref(options, make_symbol("repeats"));
    if( RTEST(temp) )
    {
      repeats = NUM2INT(temp);

      if( repeats > -1 )
      {
        /* Adjust so repeats means the same as it does for Sound */
        repeats += 1;
      }

      if( repeats < -1 )
      {
        rb_raise(rb_eArgError, ":repeats cannot be negative, except -1 (got %d)",
                 repeats);
      }
    }


    temp = rb_hash_aref(options, make_symbol("start_at"));
    if( RTEST(temp) )
    {
      start_at = (double)(NUM2DBL( temp ));

      if( start_at < 0 )
      {
        rb_raise(rb_eArgError, ":start_at cannot be negative (got %.2f)",
                 start_at);
      }
    }

  }

  int result = _rg_music_play( music, fade_in, repeats, start_at );

  if( result == -1 )
  {
    rb_raise(eSDLError, "Could not play Music: %s", Mix_GetError());
  }

  /* This music is now current. */
  _rg_music_set_current( self );

  return self;
}


/*
 *  call-seq:
 *    playing?  ->  true or false
 *
 *  True if the Music is currently playing (not paused or stopped).
 *  See also #paused? and #stopped?.
 *
 */
static VALUE rg_music_playingp( VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  /* Check that the music is current. */
  if( _rg_music_current_check(self) )
  {
    /* Return true if music is playing, but not paused. */
    if( Mix_PlayingMusic() && !Mix_PausedMusic() )
    {
      return Qtrue;
    }
    else
    {
      return Qfalse;
    }
  }
  else
  {
    return Qfalse;
  }
}



/*
 *  call-seq:
 *    pause  ->  self
 *
 *  Pause the Music. Unlike #stop, it can be unpaused later to resume
 *  from where it was paused. See also #unpause and #paused?.
 *
 *  Returns::     The receiver (self).
 *
 *  **NOTE**: Does nothing if the music is not currently playing.
 *
 */
static VALUE rg_music_pause( VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  /* Check that the music is current. */
  if( _rg_music_current_check(self) )
  {
    Mix_PauseMusic();
  }

  return self;
}


/*
 *  call-seq:
 *    unpause  ->  self
 *
 *  Unpause the Music, if it is currently paused. Resumes from
 *  where it was paused. See also #pause and #paused?.
 *
 *  Returns::     The receiver (self).
 *
 *  **NOTE**: Does nothing if the music is not currently paused.
 *
 */
static VALUE rg_music_unpause( VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  /* Check that the music is current. */
  if( _rg_music_current_check(self) )
  {
    Mix_ResumeMusic();
  }

  return self;
}


/*
 *  call-seq:
 *    paused?  ->  true or false
 *
 *  True if the Music is currently paused (not playing or stopped).
 *  See also #playing? and #stopped?.
 *
 */
static VALUE rg_music_pausedp( VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  /* Check that the music is current. */
  if( _rg_music_current_check(self) )
  {
    /* Return true if it's "playing" (not stopped), as well as paused. */
    if( Mix_PlayingMusic() && Mix_PausedMusic() )
    {
      return Qtrue;
    }
    else
    {
      return Qfalse;
    }
  }
  else
  {
    return Qfalse;
  }
}



/*
 *  call-seq:
 *    stop  ->  self
 *
 *  Stop the Music. Unlike #pause, the music must be played again from
 *  the beginning, it cannot be resumed from it was stopped.
 *
 *  Returns::     The receiver (self).
 *
 *  **NOTE**: Does nothing if the music is not currently playing or paused.
 *
 */
static VALUE rg_music_stop( VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  /* Check that the music is current. */
  if( _rg_music_current_check(self) )
  {
    Mix_HaltMusic();
  }

  return self;
}


/*
 *  call-seq:
 *    stopped?  ->  true or false
 *
 *  True if the Music is currently stopped (not playing or paused).
 *  See also #playing? and #paused?.
 *
 */
static VALUE rg_music_stoppedp( VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  /* Check that the music is current. */
  if( _rg_music_current_check(self) )
  {
    /* Return true if it's not playing. */
    if( !Mix_PlayingMusic() )
    {
      return Qtrue;
    }
    else
    {
      return Qfalse;
    }
  }
  else
  {
    return Qtrue;
  }
}


/*
 *  call-seq:
 *    fade_out( fade_time )  ->  self
 *
 *  Fade out to silence over the given number of seconds. Once the music
 *  is silent, it is automatically stopped.
 *
 *  Returns::     The receiver (self).
 *
 *  **NOTE**: If the music is currently paused, the fade will start,
 *  but you won't be able to hear it happening unless you #unpause during
 *  the fade. 
 *
 *  Does nothing if the music is currently stopped.
 *
 */
static VALUE rg_music_fadeout( VALUE self, VALUE fade_time )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  int fade_ms = (int)(1000 * NUM2DBL(fade_time));

  if( fade_ms < 0 )
  {
    rb_raise(rb_eArgError, "fade_time cannot be negative (got %.2f)",
             fade_ms / 1000);
  }

  /* Check that the music is current */
  if( _rg_music_current_check(self) )
  {
    int result = Mix_FadeOutMusic( fade_ms );

    if ( result < 0 )
    {
      rb_raise(eSDLError, "Error fading out music: %s", Mix_GetError());
    }

  }

  return self;
}


/*
 *  call-seq:
 *    fading?( direction=:either )  ->  true or false
 *
 *  True if the Music is currently fading in or out.
 *  See also #play and #fade_out.
 *
 *  direction::  Check if it is fading :in, :out, or :either.
 *               (Symbol, required)
 *
 */
static VALUE rg_music_fadingp( int argc, VALUE *argv, VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  VALUE vdirection;
  rb_scan_args(argc, argv, "01", &vdirection);

  /* If the music is not current, return false right away. */
  if( !(_rg_music_current_check(self)) )
  {
    return Qfalse;
  }

  if( RTEST(vdirection) )
  {
    if( make_symbol("in") == vdirection )
    {
      return ( (Mix_FadingMusic() == MIX_FADING_IN)  ? Qtrue : Qfalse );
    }

    else if( make_symbol("out") == vdirection )
    {
      return ( (Mix_FadingMusic() == MIX_FADING_OUT) ? Qtrue : Qfalse );
    }

    else if( make_symbol("either") == vdirection )
    {
      return ( (Mix_FadingMusic() != MIX_NO_FADING)  ? Qtrue : Qfalse );
    }
  }

  /* default */
  return ( (Mix_FadingMusic() != MIX_NO_FADING)  ? Qtrue : Qfalse );
}



/*
 *  call-seq:
 *    volume  -> vol
 *
 *  Return the volume level of the music.
 *  0.0 is totally silent, 1.0 is full volume.
 *
 *  **NOTE**: Ignores fading in or out.
 *	
 */
static VALUE rg_music_getvolume( VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  return rb_float_new(music->volume);
}


/*
 *  call-seq:
 *    volume = new_vol
 *
 *  Set the new #volume level of the music.
 *  0.0 is totally silent, 1.0 is full volume.
 * 
 *  Volume cannot be set while the music is fading in or out.
 *  Be sure to check #fading? or rescue from SDLError when
 *  using this method.
 *
 *  May raise::  SDLError if the music is fading in or out.
 *	
 */
static VALUE rg_music_setvolume( VALUE self, VALUE volume )
{
  RG_Music *music;
  Data_Get_Struct(self,  RG_Music, music);

  /* If the music is current, we'll change the current volume. */
  if( _rg_music_current_check(self) )
  {
    /* But only if it's not fading right now. */
    if( Mix_FadingMusic() == MIX_NO_FADING )
    {
      music->volume = NUM2DBL(volume);
      Mix_VolumeMusic( (int)(MIX_MAX_VOLUME * music->volume) );
    }
    else
    {
      rb_raise(eSDLError, "cannot set Music volume while fading");
    }
  }
  else
  {
    /* Save it for later. */
    music->volume = NUM2DBL(volume);
  }

  return volume;
}


/*
 *  call-seq:
 *    rewind  ->  self
 *
 *  Rewind the Music to the beginning. If the Music was paused, it
 *  will still be paused after the rewind. Does nothing if the Music
 *  is stopped.
 */
static VALUE rg_music_rewind( VALUE self )
{
  RG_Music *music;
  Data_Get_Struct(self, RG_Music, music);

  /* Check that the music is current. */
  if( _rg_music_current_check(self) )
  {
    /* Only do anything if it's not stopped */
    if( !rg_music_stoppedp(self) )
    {
      /* Remember whether it was paused. */
      int was_paused = Mix_PausedMusic();

      /*
       * Rather than using SDL_mixer's crippled Mix_RewindMusic,
       * which only works for a few file types, we'll just stop and
       * start the music again from the beginning.
       */
      Mix_HaltMusic();
      int result = Mix_PlayMusic(music->wrap->music, music->repeats);

      if( result == -1 )
      {
        rb_raise(eSDLError, "Could not rewind Music: %s", Mix_GetError());
      }

      /* Pause it again if it was paused before. */
      if( was_paused )
      {
        Mix_PauseMusic();
      }
    }
  }

  return self;
}


/*
 *  call-seq:
 *    jump_to( time )  ->  self
 *
 *  Jump to any time in the Music, in seconds since the beginning.
 *  If the Music was paused, it will still be paused again after the
 *  jump. Does nothing if the Music was stopped.
 *
 *  **NOTE**: Only works for OGG and MP3 formats! Other formats (e.g.
 *  WAV) will usually raise SDLError.
 *
 *  time::   the time to jump to, in seconds since the beginning
 *           of the song. (Numeric, required)
 *
 *  May raise::  SDLError if something goes wrong, or if the music
 *               type does not support jumping.
 *
 *  **CAUTION**: This method may be unreliable (and could even crash!)
 *  if you jump to a time after the end of the song. Unfortunately,
 *  SDL_Mixer does not provide a way to find the song's length, so
 *  Rubygame cannot warn you if you go off the end. Be careful!
 */
static VALUE rg_music_jumpto( VALUE self, VALUE vtime )
{
  RG_Music *music;
  Data_Get_Struct(self, RG_Music, music);

  /* Check that the music is current. */
  if( _rg_music_current_check(self) )
  {
    /* Only do anything if it's not stopped */
    if( !rg_music_stoppedp(self) )
    {
      /* Remember whether it was paused. */
      int was_paused = Mix_PausedMusic();

      double time = NUM2DBL(vtime); /* in seconds */

      if( time < 0 )
      {
        rb_raise(rb_eArgError, "jump_to time cannot be negative (got %d)", time);
      }

      int result = Mix_SetMusicPosition( time );

      if( result == -1 )
      {
        rb_raise(eSDLError, "Could not jump Music: %s", Mix_GetError());
      }

      /* Pause it again if it was paused before. */
      if( was_paused )
      {
        Mix_PauseMusic();
      }
    }
  }

  return self;
}



void Rubygame_Init_Music()
{
#if 0
  mRubygame = rb_define_module("Rubygame");
#endif

  /*
   *  **IMPORTANT**: Music is only available if Rubygame was compiled
   *  with SDL_mixer support!
   *
   *  Music holds a song, streamed from an audio file (see #new for
   *  supported formats). There are two important differences between
   *  the Music and Sound classes:
   *
   *    1. Only one Music can be playing. If you try to play
   *       a second song, the first one will be stopped.
   *
   *    2. Music doesn't load the entire audio file, so it can begin
   *       quickly and doesn't use much memory. This is good,
   *       because songs are usually much longer than sound effects!
   *
   *  Music can #play, #pause/#unpause, #stop, #rewind, #jump_to another
   *  time, adjust #volume, and #fade_out (fade in by passing an option
   *  to #play).
   *
   */
  cMusic = rb_define_class_under(mRubygame,"Music",rb_cObject);


  rb_define_singleton_method( cMusic, "current_music", rg_music_current, 0 );
  rb_iv_set( cMusic, "@current_music", Qnil );


  rb_define_alloc_func( cMusic, rg_music_alloc );

  rb_define_method( cMusic, "initialize",      rg_music_initialize,       1 );
  rb_define_method( cMusic, "initialize_copy", rg_music_initialize_copy,  1 );

  rb_define_method( cMusic, "play",            rg_music_play,            -1 );
  rb_define_method( cMusic, "playing?",        rg_music_playingp,         0 );

  rb_define_method( cMusic, "pause",           rg_music_pause,            0 );
  rb_define_method( cMusic, "unpause",         rg_music_unpause,          0 );
  rb_define_method( cMusic, "paused?",         rg_music_pausedp,          0 );

  rb_define_method( cMusic, "stop",            rg_music_stop,             0 );
  rb_define_method( cMusic, "stopped?",        rg_music_stoppedp,         0 );

  rb_define_method( cMusic, "fade_out",        rg_music_fadeout,          1 );
  rb_define_method( cMusic, "fading?",         rg_music_fadingp,         -1 );

  rb_define_method( cMusic, "volume",          rg_music_getvolume,        0 );
  rb_define_method( cMusic, "volume=",         rg_music_setvolume,        1 );

  rb_define_method( cMusic, "rewind",          rg_music_rewind,           0 );
  rb_define_method( cMusic, "jump_to",         rg_music_jumpto,           1 );
}
