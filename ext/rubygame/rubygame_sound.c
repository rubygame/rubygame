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

static void _rg_wrapchunk_deepcopy( RG_WrapChunk *wrap, RG_WrapChunk *other )
{
	*(wrap->chunk) = *(other->chunk);
}


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

static int _rg_sound_play( RG_Sound *sound, 
                            int fade_in, int repeats, int stop_after )
{
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
		return Mix_PlayChannelTimed(sound->channel, sound->wrap->chunk,
		                            repeats, stop_after);
	}
	else
	{
		/* Play sound with fading in */
		return Mix_FadeInChannelTimed(sound->channel, sound->wrap->chunk,
		                              repeats, fade_in, stop_after);
	}
}

static VALUE rg_sound_alloc( VALUE klass )
{
	RG_Sound *sound = _rg_sound_alloc();
	return Data_Wrap_Struct(klass, 0, _rg_sound_free, sound);
}

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

static VALUE rg_sound_initialize_copy( VALUE self, VALUE other )
{
	RG_Sound *soundA, *soundB;
	Data_Get_Struct(self,  RG_Sound, soundA);
	Data_Get_Struct(other, RG_Sound, soundB);

	_rg_sound_copy( soundA, soundB );

	return self;
}

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
			fade_in = (int)(1000 * NUM2LONG( temp ));
		}

		temp = rb_hash_aref(options, make_symbol("repeats"));
		if( RTEST(temp) )
		{
			repeats = NUM2INT(temp);
		}

		temp = rb_hash_aref(options, make_symbol("stop_after"));
		if( RTEST(temp) )
		{
			stop_after = (int)(1000 * NUM2LONG( temp ));
		}

	}

	int result = _rg_sound_play( sound, fade_in, repeats, stop_after );

	if( result == -1 )
	{
		rb_raise(eSDLError, "Could not play Sound: %s", Mix_GetError());
	}

	return self;
}

void Rubygame_Init_Sound()
{
#if 0
  mRubygame = rb_define_module("Rubygame");
#endif

  /* Sound class */
  cSound = rb_define_class_under(mRubygame,"Sound",rb_cObject);
	rb_define_alloc_func( cSound, rg_sound_alloc );

	rb_define_method( cSound, "initialize",      rg_sound_initialize,       1 );
	rb_define_method( cSound, "initialize_copy", rg_sound_initialize_copy,  1 );

	rb_define_method( cSound, "play",            rg_sound_play,            -1 );
}
