/*
	Rubygame -- Ruby classes and bindings to SDL to facilitate game creation
	Copyright (C) 2004  John 'jacius' Croisant

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "rubygame.h"
#include "SDL_image.h"

/* Image module functions: */

VALUE rbgm_image_load( VALUE module, VALUE filename )
{
	char *name;
	SDL_Surface *surf;

	name = StringValuePtr(filename);
	surf = IMG_Load( name );
	if(surf == NULL)
	{
		rb_raise(eSDLError,"Couldn't load image: %s",IMG_GetError());
	}
	return Data_Wrap_Struct( cSurface,0,SDL_FreeSurface,surf );
}

VALUE rbgm_image_savebmp( VALUE module, VALUE surface, VALUE filename )
{
	char *name;
	SDL_Surface *surf;

	name = StringValuePtr(filename);
	Data_Get_Struct(surface,SDL_Surface,surf);
	if(SDL_SaveBMP(surf,name)!=0)
	{
		rb_raise(eSDLError,\
			"Couldn't same surface to %s: %s",name,SDL_GetError());
	}
	return Qnil;
}

/* Rubification: */

void Rubygame_Init_Image()
{
	/* Image module */
	mImage = rb_define_module_under(mRubygame,"Image");
	/* Image methods */
	rb_define_module_function(mImage,"load",rbgm_image_load,1);
	rb_define_module_function(mImage,"savebmp",rbgm_image_savebmp,2);
}
