=begin
== Rubygame::Image
--- Image.load( filename )
    Load an image file to a Surface. If the image has an alpha channel, it will
    be used. The supported image file types are: 
    BMP, GIF, JPG, LBM, PCX, PNG, PNM, TGA, TIF, XPM, XCF.
        * ((|filename|)): path to the image to load.

--- Image.savebmp( surface, filename )
    Save surface as a Bitmap (bmp) image file, filename. Raises SDLError if 
    the operation fails.
=end
