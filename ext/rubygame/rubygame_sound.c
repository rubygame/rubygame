/*
 *  Interface to SDL_mixer sound playback and mixing.
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

VALUE cSound;

/* A pointer to a Mix_Chunk, with a reference count.
 * Allows re-use of sound data, then freeing memory when
 * there are no references to it.
 */
typedef struct RG_WrapChunk {
	/* 'private' */
	Mix_Chunk *chunk;
	int ref_count;
} RG_WrapChunk;


/* The struct that the Sound class wraps. Stores a 
 * pointer to a RG_WrapChunk and important attributes
 * of the Sound like its volume and channel it's
 * playing on.
 */
typedef struct RG_Sound {
	/* 'public' */
	float volume;

	/* 'private' */
	RG_WrapChunk *wrap;
	int channel;
} RG_Sound;




/* Allocate/initialize the memory for a RG_WrapChunk and return a pointer. */
static RG_WrapChunk* _rg_wrapchunk_alloc()
{
	RG_WrapChunk *wrap;
	wrap = ALLOC(RG_WrapChunk);

	wrap->chunk = NULL;
	wrap->ref_count = 0;

	return wrap;
}

/* Load a Mix_Chunk from a file and assign it to the RG_WrapChunk. */
static int _rg_wrapchunk_load( RG_WrapChunk *wrap, char *file )
{
	wrap->chunk = Mix_LoadWAV( file );
	
	if( !(wrap->chunk) )
		return -1;
	else
		return 0;
}

/* Make a copy of the other's Mix_Chunk audio data, and assign
 * it to the RG_WrapChunk.
 */
static void _rg_wrapchunk_deepcopy( RG_WrapChunk *wrap, RG_WrapChunk *other )
{
	*(wrap->chunk) = *(other->chunk);
}


/* Free the memory used by the RG_WrapChunk */
static void _rg_wrapchunk_free( RG_WrapChunk *wrap )
{
	Mix_FreeChunk( wrap->chunk );
	wrap->chunk = NULL;
	free(wrap);
}




/* Associate a RG_WrapChunk with a RG_Sound. Handles reference counts. */
static inline void _rg_sound_associate( RG_Sound *sound, RG_WrapChunk *wrap )
{
	sound->wrap = wrap;
	sound->wrap->ref_count += 1;
}

/* Deassociate the RG_Sound's WrapChunk. Handles reference counts. */
static inline void _rg_sound_deassociate( RG_Sound *sound )
{
	sound->wrap->ref_count -= 1;
	sound->wrap = NULL;
}

/* Allocate/initialize the memory for a RG_Sound return a pointer. */
static RG_Sound* _rg_sound_alloc()
{
	RG_Sound *sound;
	sound = ALLOC(RG_Sound);

	sound->wrap = NULL;
	sound->volume = 1.f;
	sound->channel = -1;

	return sound;
}


/* Free the memory used by the Sound, and possibly the memory
 * used by the WrapChunk it refers to.
 */
static void _rg_sound_free( RG_Sound *sound )
{
	RG_WrapChunk *wrap = sound->wrap;

	_rg_sound_deassociate( sound );

	free(sound);

	/* If the WrapChunk has no more referrers, free it too. */
	if( wrap->ref_count <= 0 )
	{
		_rg_wrapchunk_free( wrap );
	}
}


/* Load a new Sound from a file. */
static int _rg_sound_load( RG_Sound *sound, char *file )
{
	RG_WrapChunk *wrap = _rg_wrapchunk_alloc();

	int result = _rg_wrapchunk_load( wrap, file );

	_rg_sound_associate( sound, wrap );

	return result;
}


/* Make a shallow copy of the given Sound; the new Sound points to
 * the same audio data in memory as the old one. Also copies
 * user-visible attributes (e.g. volume).
 */
static void _rg_sound_copy( RG_Sound *sound, RG_Sound *other )
{
	_rg_sound_associate( sound, other->wrap );

	sound->volume = other->volume;
	sound->channel = -1;
}


/* Make a new Sound with a copy of the audio from an existing Sound */
static void _rg_sound_deepcopy( RG_Sound *sound, RG_Sound *other )
{
	RG_WrapChunk *wrap = _rg_wrapchunk_alloc();
	_rg_wrapchunk_deepcopy( wrap, other->wrap );

	_rg_sound_associate( sound, wrap );

	sound->volume = other->volume;
	sound->channel = -1;
}


/* Check that the given channel is (still) loaded with the given chunk. */
static int _rg_sound_channel_check( RG_Sound *sound )
{
	/* channel is unset, so it doesn't belong. */
	if( sound->channel == -1 )
	{
		return 0;
	}

	Mix_Chunk *chan_chunk = Mix_GetChunk(sound->channel);	

	/* Check that the channel chunk is the same as the given one */
	return ( sound->wrap->chunk == chan_chunk );
}


/* Play the sound, fading in, repeating, and stopping as specified.
 * fade_in and stop_after are in milliseconds!
 */
static int _rg_sound_play( RG_Sound *sound, 
                            int fade_in, int repeats, int stop_after )
{
	/* If it's already playing on a channel, stop it first. */
	if( _rg_sound_channel_check(sound) )
	{
		Mix_HaltChannel( sound->channel );
	}

	/* Find first available channel */
	sound->channel = Mix_GroupAvailable(-1);

	if( sound->channel == -1 )
	{
		/* No channels were available, so make one more than there are now.
		 * (Mix_AllocateChannels(-1) returns the current number of channels)
		 */
		Mix_AllocateChannels( Mix_AllocateChannels(-1) + 1 );

		/* Try again. */
		sound->channel = Mix_GroupAvailable(-1);
	}
	
	/* Set its volume before we play */
	Mix_Volume( sound->channel, (int)(MIX_MAX_VOLUME * sound->volume) );


	if( fade_in <= 0 )
	{
		/* Play sound without fading in */
		return Mix_PlayChannelTimed( sound->channel, sound->wrap->chunk,
		                             repeats, stop_after );
	}
	else
	{
		/* Play sound with fading in */
		return Mix_FadeInChannelTimed( sound->channel, sound->wrap->chunk,
		                               repeats, fade_in, stop_after );
	}
}


/* Ruby allocation function. */
static VALUE rg_sound_alloc( VALUE klass )
{
	RG_Sound *sound = _rg_sound_alloc();
	return Data_Wrap_Struct(klass, 0, _rg_sound_free, sound);
}



/*
 *  call-seq:
 *    new( filename )  ->  sound
 *
 *  Load the given audio file.
 *  Supported file formats are WAV, AIFF, RIFF, OGG (Ogg Vorbis), and
 *  VOC (SoundBlaster).
 *
 *  filename::    Full or relative path to the file. (String, required)
 *
 *  Returns::     The new Sound instance. (Sound)
 *  May raise::   SDLError, if the sound file could not be loaded.
 *
 */
static VALUE rg_sound_initialize( VALUE self, VALUE filename )
{
	RG_Sound *sound;
	Data_Get_Struct(self, RG_Sound, sound);

	char *file = StringValuePtr(filename);

	int result = _rg_sound_load( sound, file );

	if( result == -1 )
	{
		rb_raise(eSDLError, "Could not load Sound file '%s': %s",
		                    file, Mix_GetError());
	}

	return self;
}


/*
 *  call-seq:
 *    clone( other )  ->  sound
 *    dup( other )  ->  sound
 *
 *  Create a copy of the given Sound instance. Much more memory-efficient
 *  than using #new to load the sound file again.
 *
 *  other::       An existing Sound instance. (Sound, required)
 *
 *  Returns::     The new Sound instance. (Sound)
 *
 *  **NOTE**: #clone and #dup do slightly different things; #clone will copy
 *  the 'frozen' state of the object, while #dup will create a fresh, un-frozen
 *  object.
 *
 */
static VALUE rg_sound_initialize_copy( VALUE self, VALUE other )
{
	RG_Sound *soundA, *soundB;
	Data_Get_Struct(self,  RG_Sound, soundA);
	Data_Get_Struct(other, RG_Sound, soundB);

	_rg_sound_copy( soundA, soundB );

	return self;
}




/*
 *  call-seq:
 *    play( options={} )  ->  self
 *
 *  Play the Sound, optionally fading in, repeating a certain number of
 *  times (or forever), and/or stopping automatically after a certain time.
 *
 *  See also #pause and #stop.
 *
 *  options::     Hash of options, listed below. (Hash, required)
 *
 *    :fade_in::     Fade in from silence over the given number of seconds.
 *                   (Numeric)
 *    :repeats::     Repeat the sound the given number of times, or forever
 *                   (or until stopped) if -1. (Integer)
 *    :stop_after::  Automatically stop playing after playing for the given
 *                   number of seconds. (Numeric)
 *
 *  Returns::     The receiver (self).
 *  May raise::   SDLError, if the sound file could not be played.
 *
 *	**NOTE**: If the sound is already playing (or paused), it will be stopped
 *  and played again from the beginning.
 *
 *  Example:
 *    # Fade in over 2 seconds, play 4 times (1 + 3 repeats),
 *    # but stop playing after 5 seconds.
 *    sound.play( :fade_in => 2, :repeats => 3, :stop_after => 5 );
 *
 */
static VALUE rg_sound_play( int argc, VALUE *argv, VALUE self )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	VALUE options;
	rb_scan_args(argc, argv, "01", &options);

	int fade_in    =  0;
	int repeats    =  0;
	int stop_after = -1;

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
		}

		temp = rb_hash_aref(options, make_symbol("repeats"));
		if( RTEST(temp) )
		{
			repeats = NUM2INT(temp);
		}

		temp = rb_hash_aref(options, make_symbol("stop_after"));
		if( RTEST(temp) )
		{
			stop_after = (int)(1000 * NUM2DBL( temp ));
		}

	}

	int result = _rg_sound_play( sound, fade_in, repeats, stop_after );

	if( result == -1 )
	{
		rb_raise(eSDLError, "Could not play Sound: %s", Mix_GetError());
	}

	return self;
}


/*
 *  call-seq:
 *    playing?  ->  true or false
 *
 *  True if the Sound is currently playing (not paused or stopped).
 *  See also #paused? and #stopped?.
 *
 */
static VALUE rg_sound_playingp( VALUE self )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	int channel = sound->channel;

	/* Make sure the sound actually belongs to the channel */
	if( _rg_sound_channel_check(sound) )
	{
		/* Return true if it's playing, but not paused. */
		if( Mix_Playing(channel) && !Mix_Paused(channel) )
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
 *  Pause the Sound. Unlike #stop, it can be unpaused later to resume
 *  from where it was paused. See also #unpause and #paused?.
 *
 *  Returns::     The receiver (self).
 *
 *  **NOTE**: Does nothing if the sound is not currently playing.
 *
 */
static VALUE rg_sound_pause( VALUE self )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	int channel = sound->channel;

	/* Make sure the sound actually belongs to the channel */
	if( _rg_sound_channel_check(sound) )
	{
		Mix_Pause( channel );
	}

	return self;
}


/*
 *  call-seq:
 *    unpause  ->  self
 *
 *  Unpause the Sound, if it is currently paused. Resumes from
 *  where it was paused. See also #pause and #paused?.
 *
 *  Returns::     The receiver (self).
 *
 *  **NOTE**: Does nothing if the sound is not currently paused.
 *
 */
static VALUE rg_sound_unpause( VALUE self )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	int channel = sound->channel;

	/* Make sure the sound actually belongs to the channel */
	if( _rg_sound_channel_check(sound) )
	{
		Mix_Resume( channel );
	}

	return self;
}


/*
 *  call-seq:
 *    paused?  ->  true or false
 *
 *  True if the Sound is currently paused (not playing or stopped).
 *  See also #playing? and #stopped?.
 *
 */
static VALUE rg_sound_pausedp( VALUE self )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	int channel = sound->channel;

	/* Make sure the sound actually belongs to the channel */
	if( _rg_sound_channel_check(sound) )
	{
		/* Return true if it's "playing" (not stopped), as well as paused. */
		if( Mix_Playing(channel) && Mix_Paused(channel) )
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
 *  Stop the Sound. Unlike #pause, the sound must be played again from
 *  the beginning, it cannot be resumed from it was stopped.
 *
 *  Returns::     The receiver (self).
 *
 *  **NOTE**: Does nothing if the sound is not currently playing or paused.
 *
 */
static VALUE rg_sound_stop( VALUE self )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	int channel = sound->channel;

	/* Make sure the sound actually belongs to the channel */
	if( _rg_sound_channel_check(sound) )
	{
		Mix_HaltChannel( channel );
	}

	return self;
}


/*
 *  call-seq:
 *    stopped?  ->  true or false
 *
 *  True if the Sound is currently stopped (not playing or paused).
 *  See also #playing? and #paused?.
 *
 */
static VALUE rg_sound_stoppedp( VALUE self )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	int channel = sound->channel;

	/* Make sure the sound actually belongs to the channel */
	if( _rg_sound_channel_check(sound) )
	{
		/* Return true if it's not playing. */
		if( !Mix_Playing(channel) )
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
		/* If it's not on a channel... it can't be playing! */
		return Qtrue;
	}
}


/*
 *  call-seq:
 *    fade_out( fade_time )  ->  self
 *
 *  Fade out to silence over the given number of seconds. Once the sound
 *  is silent, it is automatically stopped.
 *
 *  Returns::     The receiver (self).
 *
 *  **NOTE**: If the sound is currently paused, the fade will start,
 *  but you won't be able to hear it happening unless you #unpause during
 *  the fade. Does nothing if the sound is currently stopped.
 *
 */
static VALUE rg_sound_fadeout( VALUE self, VALUE fade_time )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	int channel = sound->channel;
	int fade_ms = (int)(1000 * NUM2DBL(fade_time));

	/* Make sure the sound actually belongs to the channel */
	if( _rg_sound_channel_check(sound) )
	{
		Mix_FadeOutChannel( channel, fade_ms );
	}

	return self;
}


/*
 *  call-seq:
 *    fading?( direction=:either )  ->  true or false
 *
 *  True if the Sound is currently fading in or out.
 *  See also #play and #fade_out.
 *
 *  direction::  Check if it is fading :in, :out, or :either.
 *               (Symbol, required)
 *
 */
static VALUE rg_sound_fadingp( int argc, VALUE *argv, VALUE self )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	VALUE vdirection;
	rb_scan_args(argc, argv, "01", &vdirection);
	
	int direction;
	int channel = sound->channel;

	/* If it's not actually on a channel, return false right away. */
	if( !(_rg_sound_channel_check(sound)) )
	{
		return Qfalse;
	}

	if( RTEST(vdirection) )
	{
		if( make_symbol("in") == vdirection )
		{
			return ( (Mix_FadingChannel(channel) == MIX_FADING_IN)  ? Qtrue : Qfalse );
		}
		
		else if( make_symbol("out") == vdirection )
		{
			return ( (Mix_FadingChannel(channel) == MIX_FADING_OUT) ? Qtrue : Qfalse );
		}
		
		else if( make_symbol("either") == vdirection )
		{
			return ( (Mix_FadingChannel(channel) != MIX_NO_FADING)  ? Qtrue : Qfalse );
		}
	}

	/* default */
	return ( (Mix_FadingChannel(channel) != MIX_NO_FADING)  ? Qtrue : Qfalse );
}



/*
 *  call-seq:
 *    volume  -> vol
 *
 *  Return the volume level of the sound.
 *  0.0 is totally silent, 1.0 is full volume.
 *
 *  **NOTE**: Ignores fading in or out.
 *	
 */
static VALUE rg_sound_getvolume( VALUE self )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	return rb_float_new(sound->volume);
}


/*
 *  call-seq:
 *    volume = new_vol
 *
 *  Set the new #volume level of the sound.
 *  0.0 is totally silent, 1.0 is full volume.
 * 
 *  Volume cannot be set while the sound is fading in or out.
 *  Be sure to check #fading? or rescue from SDLError when
 *  using this method.
 *
 *  May raise::  SDLError if the sound is fading in or out.
 *	
 */
static VALUE rg_sound_setvolume( VALUE self, VALUE volume )
{
	RG_Sound *sound;
	Data_Get_Struct(self,  RG_Sound, sound);

	/* Change channel volume if Sound is currently assigned to a channel */
	if( _rg_sound_channel_check(sound) )
	{
		/* But only if it's not fading right now. */
		if( Mix_FadingChannel(sound->channel) == MIX_NO_FADING )
		{
			sound->volume = NUM2DBL(volume);
			Mix_Volume( sound->channel, (int)(MIX_MAX_VOLUME * sound->volume) );
		}
		else
		{
			rb_raise(eSDLError, "cannot set Sound volume while fading");
		}
	}
	else
	{
		/* Save it for later. */
		sound->volume = NUM2DBL(volume);
	}

	return volume;
}


void Rubygame_Init_Sound()
{
#if 0
  mRubygame = rb_define_module("Rubygame");
#endif

	/*
	 *  **IMPORTANT**: Sound is only available if Rubygame was compiled
	 *  with SDL_mixer support!
	 *
	 *  Sound holds a sound effect, loaded from an audio file (see #new for
	 *  supported formats).
	 *
	 *  Sound can #play, #pause/#unpause, #stop, adjust #volume,
	 *  and #fade_out (you can fade in by passing an option to #play).
	 *
	 *  Sound can create duplicates (with #dup or #clone) in a memory-efficient
	 *  way -- the new Sound instance refers back to the same audio data,
	 *  so having 100 duplicates of a sound uses only slightly more memory
	 *  than having the first sound. Duplicates can different volume levels,
	 *  too!
	 *
	 */
  cSound = rb_define_class_under(mRubygame,"Sound",rb_cObject);

	rb_define_alloc_func( cSound, rg_sound_alloc );

	rb_define_method( cSound, "initialize",      rg_sound_initialize,       1 );
	rb_define_method( cSound, "initialize_copy", rg_sound_initialize_copy,  1 );

	rb_define_method( cSound, "play",            rg_sound_play,            -1 );
	rb_define_method( cSound, "playing?",        rg_sound_playingp,         0 );

	rb_define_method( cSound, "pause",           rg_sound_pause,            0 );
	rb_define_method( cSound, "unpause",         rg_sound_unpause,          0 );
	rb_define_method( cSound, "paused?",         rg_sound_pausedp,          0 );

	rb_define_method( cSound, "stop",            rg_sound_stop,             0 );
	rb_define_method( cSound, "stopped?",        rg_sound_stoppedp,         0 );

	rb_define_method( cSound, "fade_out",        rg_sound_fadeout,          1 );
	rb_define_method( cSound, "fading?",         rg_sound_fadingp,         -1 );

	rb_define_method( cSound, "volume",          rg_sound_getvolume,        0 );
	rb_define_method( cSound, "volume=",         rg_sound_setvolume,        1 );
}
