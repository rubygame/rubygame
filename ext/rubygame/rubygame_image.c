/*
 *  Interface to SDL_image library, for loading image files to Surfaces.
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
#include "rubygame_surface.h"
#include "rubygame_image.h"

void Rubygame_Init_Image();
VALUE rbgm_image_load(VALUE, VALUE);
VALUE rbgm_from_string(int, VALUE*, VALUE);

/*
 *  call-seq:
 *    Surface.load_image( filename )  ->  Surface
 *
 *  **NOTE:** This method name is DEPRECATED and will be removed in
 *  Rubygame 3.0. Please use the Surface.load instead.
 *
 *  Load an image file from the disk to a Surface. If the image has an alpha
 *  channel (e.g. PNG with transparency), the Surface will as well. If the
 *  image cannot be loaded (for example if the image format is unsupported),
 *  will raise SDLError.
 *
 *  This method is only usable if Rubygame was compiled with the SDL_image
 *  library; you can check Rubygame::VERSIONS[:sdl_image] to see if it was.
 *
 *  This method takes this argument:
 *  filename:: a string containing the relative or absolute path to the
 *             image file. The file must have the proper file extension,
 *             as it is used to determine image format.
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
VALUE rbgm_image_load_image( VALUE class, VALUE filename )
{

  /* This feature will be removed in Rubygame 3.0. */
  rg_deprecated("Rubygame::Surface.load_image", "3.0");

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

/*
 *  call-seq:
 *    Surface.load( filename )  ->  Surface
 *
 *  Load an image file from the disk to a Surface. If the image has an alpha
 *  channel (e.g. PNG with transparency), the Surface will as well. If the
 *  image cannot be loaded (for example if the image format is unsupported),
 *  will raise SDLError.
 *
 *  This method is only usable if Rubygame was compiled with the SDL_image
 *  library; you can check Rubygame::VERSIONS[:sdl_image] to see if it was.
 *
 *  This method takes this argument:
 *  filename:: a string containing the relative or absolute path to the
 *             image file. The file must have the proper file extension,
 *             as it is used to determine image format.
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
VALUE rbgm_image_load( VALUE class, VALUE filename )
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

/*
 *  call-seq:
 *    Surface.from_string( data [,type] )  ->  Surface
 *
 *  Load an image file from memory (in the form of the given data to a Surface.
 *  If the image has an alpha channel (e.g. PNG with transparency), the Surface
 *  will as well. If the image cannot be loaded (for example if the image
 *  format is unsupported), will raise SDLError.
 *
 *  This method is only usable if Rubygame was compiled with the SDL_image
 *  library; you can check Rubygame::VERSIONS[:sdl_image] to see if it was.
 *
 *  This method takes these arguments:
 *  data:: a string containing the data for the image, such as IO::read would
 *         return.
 *  type:: The type of file that the image is (i.e. 'TGA').  Case is not 
 *         important.  If absent, the library will try to automatically
 *         detect the type.
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
VALUE rbgm_from_string( int argc, VALUE *argv, VALUE obj)
{
	Check_Type(argv[0], T_STRING);
	/* There's probably a better way of using a string as raw data than this,
	 * but I don't know it. */
	void *raw = (void *)RSTRING_PTR(argv[0]);
	int len = RSTRING_LEN(argv[0]);
	
	SDL_RWops *rw = SDL_RWFromMem(raw,len);
	
	SDL_Surface *surf;
	if(argc > 1) {
		Check_Type(argv[1], T_STRING);
		surf = IMG_LoadTyped_RW(rw, 1,StringValuePtr(argv[1]));
	} else {
		surf = IMG_Load_RW(rw,1);
	}
	
	if(surf == NULL)
	{
		rb_raise(eSDLError,"Couldn't load image from string: %s", IMG_GetError());
	}
	return Data_Wrap_Struct( cSurface, 0, SDL_FreeSurface, surf);	
}

/* 
 *  Document-class: Rubygame::Surface
 *
 *  Surface represents an image, a block of colored pixels arranged in a 2D grid.
 *  You can load image files to a new Surface with #load_image, or create
 *  an empty one with Surface.new and draw shapes on it with #draw_line,
 *  #draw_circle, and all the rest.
 *
 *  One of the most important Surface concepts is #blit, copying image
 *  data from one Surface onto another. By blitting Surfaces onto the
 *  Screen (which is a special type of Surface) and then using Screen#update,
 *  you can make images appear for the player to see.
 *
 */
void Init_rubygame_image()
{

#if 0
	mRubygame = rb_define_module("Rubygame");
	cSurface = rb_define_class_under(mRubygame,"Surface",rb_cObject);
#endif

	Init_rubygame_shared();

  rb_hash_aset(rb_ivar_get(mRubygame,rb_intern("VERSIONS")),
               ID2SYM(rb_intern("sdl_image")),
               rb_ary_new3(3,
                           INT2NUM(SDL_IMAGE_MAJOR_VERSION),
                           INT2NUM(SDL_IMAGE_MINOR_VERSION),
                           INT2NUM(SDL_IMAGE_PATCHLEVEL)));

	/* Image methods */
	rb_define_singleton_method(cSurface,"load_image", rbgm_image_load_image, 1);
	rb_define_singleton_method(cSurface,"load",       rbgm_image_load,       1);
	rb_define_singleton_method(cSurface,"from_string",rbgm_from_string,     -1);
}
