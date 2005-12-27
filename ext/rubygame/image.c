/*
 *  Image module -- loading and saving image files to/from Surfaces.
 * --
 *  Rubygame -- Ruby classes and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004  John 'jacius' Croisant
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
 * ++
 */

#include "rubygame.h"

#ifdef HAVE_SDL_IMAGE_H
#include "SDL_image.h"
#endif

/*--
 * Always try to define these if they aren't already.
 * Image.version() will return [0,0,0] if SDL_image is not present.
 *++
 */
#ifndef SDL_IMAGE_MAJOR_VERSION
#define SDL_IMAGE_MAJOR_VERSION 0
#endif

#ifndef SDL_IMAGE_MINOR_VERSION
#define SDL_IMAGE_MINOR_VERSION 0
#endif

#ifndef SDL_IMAGE_PATCHLEVEL
#define SDL_IMAGE_PATCHLEVEL 0
#endif

/*
 *  call-seq:
 *     version  =>  [major, minor, patch]
 *
 *  Return the major, minor, and patch numbers for the version of 
 *  SDL_image that Rubygame was compiled with. This is intended to
 *  allow games to detect which drawing operations are permitted and decide
 *  whether the SDL_image version is Good Enough to play the game
 *  (perhaps without certain "optional" features).
 *
 *  More sophisticated methods of detecting which operations are permitted are
 *  planned for future versions.
 */
VALUE rbgm_image_version(VALUE module)
{ 
  return rb_ary_new3(3,
					 INT2NUM(SDL_IMAGE_MAJOR_VERSION),
					 INT2NUM(SDL_IMAGE_MINOR_VERSION),
					 INT2NUM(SDL_IMAGE_PATCHLEVEL));
}

/* Vanilla SDL function, doesn't need SDL_image. */

/* 
 *  call-seq:
 *     savebmp( surface, filename )  =>  nil
 *
 *  Save the Surface as a Windows Bitmap (BMP) file with the given filename.
 */
VALUE rbgm_image_savebmp( VALUE module, VALUE surface, VALUE filename )
{
	char *name;
	SDL_Surface *surf;

	name = StringValuePtr(filename);
	Data_Get_Struct(surface,SDL_Surface,surf);
	if(SDL_SaveBMP(surf,name)!=0)
	{
		rb_raise(eSDLError,\
			"Couldn't save surface to file %s: %s",name,SDL_GetError());
	}
	return Qnil;
}

/* Now for the stuff that really needs SDL_image. */
#ifdef HAVE_SDL_IMAGE_H

/* Image module functions: */

/*
 *  call-seq:
 *     load( filename )  =>  Surface
 *
 *  Load an image file from the disk to a Surface. If the image has an alpha
 *  channel (e.g. PNG with transparency), the Surface will as well. If the
 *  image cannot be loaded (for example if the image format is unsupported),
 *  will raise SDLError.
 *
 *  This method takes this argument:
 *  filename:: a string containing the relative or absolute path to the
 *             image file. You should use construct the path with 
 *             File.join("path","to","file") to be sure it will work properly
 *             on all operating systems. The file must have a proper extension,
 *             as the file extension is used to determine image format.
 *
 *  These formats may be supported, but some may not be available on a
 *  particular system.
 *  BMP:: "Windows Bitmap" format.
 *  GIF:: "Graphics Interchange Format."
 *  JPG:: "Independent JPEG Group" format.
 *  LBM:: "Linear Bitmap" format (?)
 *  PCX:: "PC Paintbrush" format
 *  PNG:: "Portable Network Graphics" format.
 *  PNM:: "Portable Any Map" format. (i.e., PPM, PGM, or PBM)
 *  TGA:: "Truevision TARGA" format.
 *  TIF:: "Tagged Image File Format"
 *  XCF:: "eXperimental Computing Facility" (GIMP native format).
 *  XPM:: "XPixMap" format.
 */
VALUE rbgm_image_load( VALUE module, VALUE filename )
{
	char *name;
	SDL_Surface *surf;

	name = StringValuePtr(filename);
	surf = IMG_Load( name );
	if(surf == NULL)
	{
		rb_raise(eSDLError,"Couldn't load image `%s': %s", name, IMG_GetError());
	}
	return Data_Wrap_Struct( cSurface,0,SDL_FreeSurface,surf );
}

#endif /* HAVE_SDL_IMAGE_H */

void Rubygame_Init_Image()
{
#if 0
	/* Pretend to define Rubygame module, so RDoc knows about it: */
	mRubygame = rb_define_module("Rubygame");
#endif

	/* Image module -- exists regardless of SDL_image presence*/
	mImage = rb_define_module_under(mRubygame,"Image");

	/* This one doesn't actually need SDL_image, only vanilla SDL */
	rb_define_module_function(mImage,"savebmp",rbgm_image_savebmp,2);

#ifdef HAVE_SDL_IMAGE_H
	/* Image methods */
	rb_define_module_function(mImage,"usable?",rbgm_usable,0);
	rb_define_module_function(mImage,"load",rbgm_image_load,1);

#else /* HAVE_SDL_IMAGE_H */

	/* Dummy methods */
	rb_define_module_function(mImage,"usable?",rbgm_unusable,0);
	rb_define_module_function(mImage,"load",rbgm_dummy,-1);

#endif /* HAVE_SDL_IMAGE_H */
}
