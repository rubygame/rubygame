/*
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
 *
 */

#ifndef _RUBYGAME_MIXER_H
#define _RUBYGAME_MIXER_H

#include "SDL_audio.h"
#include "SDL_mixer.h"

extern void Init_rubygame_mixer();
extern VALUE mMixer;

extern VALUE rbgm_mixer_openaudio(VALUE, VALUE, VALUE, VALUE, VALUE);
extern VALUE rbgm_mixer_closeaudio(VALUE);
extern VALUE rbgm_mixer_getmixchans();
extern VALUE rbgm_mixer_setmixchans(VALUE, VALUE);
extern VALUE rbgm_mixer_getdrivername(VALUE);

extern VALUE cSample;
extern VALUE rbgm_sample_new(VALUE, VALUE);
extern VALUE rbgm_mixchan_play( VALUE, VALUE, VALUE, VALUE );
extern VALUE rbgm_mixchan_stop( VALUE, VALUE );
extern VALUE rbgm_mixchan_pause( VALUE, VALUE );
extern VALUE rbgm_mixchan_resume( VALUE, VALUE );

extern VALUE cMusic;
extern VALUE rbgm_mixmusic_setcommand(VALUE, VALUE); 
extern VALUE rbgm_mixmusic_new(VALUE, VALUE);

extern VALUE rbgm_mixmusic_play(int, VALUE*, VALUE);
extern VALUE rbgm_mixmusic_stop(VALUE);
extern VALUE rbgm_mixmusic_resume(VALUE);
extern VALUE rbgm_mixmusic_pause(VALUE);
extern VALUE rbgm_mixmusic_rewind(VALUE);
extern VALUE rbgm_mixmusic_setposition(VALUE, VALUE);
extern VALUE rbgm_mixmusic_paused(VALUE);
extern VALUE rbgm_mixmusic_playing(VALUE);

extern VALUE rbgm_mixmusic_getvolume(VALUE);
extern VALUE rbgm_mixmusic_setvolume(VALUE, VALUE);
extern VALUE rbgm_mixmusic_fadein(int, VALUE*, VALUE);
extern VALUE rbgm_mixmusic_fadeout(VALUE, VALUE);
extern VALUE rbgm_mixmusic_fading(int, VALUE*, VALUE);

#endif
