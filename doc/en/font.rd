=begin
== Rubygame::Font

=== Rubygame::Font::TTF
--- TTF.init
    Initialize the TTF module. You must do this before creating a new TTF 
    object with ((<TTF.new>)).

--- TTF.quit
    Quit the TTF module, without quitting all of Rubygame.

--- TTF.new( filename, size )
    Load a font file (having the extension .TTF or .FON) into a TTF object.
        * ((|filename|)): the .TTF or .FON file to load.
        * ((|size|)): the (approximate) pixel height of the font.

--- TTF#bold
    True if the font has bolding enabled.
--- TTF#bold=( state )
    Set the state of bolding to the given state (true or false).

--- TTF#italic
    True if the font has italics enabled.
--- TTF#italic=( state )
    Set the state of italics to the given state (true or false).

--- TTF#underline
    True if the font has underlining enabled.
--- TTF#underline=( state )
    Set the state of underlining to the given state (true or false).

--- TTF#height
    The font's maximum height (in pixels), the distance from the bottom of a 
    character to the top of the character.

--- TTF#ascent
    The font's maximum ascent (in pixels), the distance from the baseline to 
    the top of a character.

--- TTF#descent
    The font's maximum descent (in pixels), the distance from the baseline to 
    the bottom of a character.

--- TTF#lineskip
    The recommended distance from the top of one line to the top of the next 
    line. This is usually slightly bigger than the ((<height|TTF#height>)).

--- TTF#render( string, antialias, foreground, background )
    Render the given string using the font.
        * ((|string|)): the string to be rendered.
        * ((|antialias|)): whether the string should be rendered with 
          anti-aliasing. This will make it look nicer, but is slower.
        * ((|foreground|)): the color to render the text as, in (({[R,G,B]})) 
          form.
        * ((|background|)): the color to render the text on top of. If not 
          given or nil, the background will be transparent

=== Rubygame::Font::SFont
SFont is a type of bitmapped font, which is loaded from an image file with 
a meaningful top row of pixels, and the font itself below that. The top row
provides information about what parts of of the lower area contains font 
data, and which parts are empty.

The image file should contain all of the glyphs on one row, with the colorkey
color at the bottom-left pixel and the "skip" color an the top-left pixel.

The colorkey color is applied to the image file when it is loaded, so that 
all pixels of that color appear transparent. Alternatively, if the alpha 
value of pixel [0,0] is 0 (that is, if it is fully transparent), the image 
file is assumed to have a proper alpha channel, and no colorkey is applied.
The skip color is used in the top row of pixels to indicate that all the 
pixels below it contain empty space, and that the next pixel that is not 
the skip color marks the beginning of the next glyph.

The official SFont homepage, with information on SFont and sample font 
files, can be found at ((<URL:http://www.linux-games.com/sfont/>)). More 
information on SFont, and a useful utility for automatically generating 
the top row for a font, can be found at: 
((<URL:http://nostatic.org/sfont/>))

--- SFont.default_glyphs
    Returns an array of strings, each string a single ASCII character from 
    ! (33) to ~ (126). This is the default set of characters in a SFont. 
    The full set is as follows:

        ! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @
        A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ `
        a b c d e f g h i j k l m n o p q r s t u v w x y z { | } ~


--- SFont.new( filename, glyphs, space_width )
    Create a now SFont instance. 
        * ((|filename|)): the name of the image file from which the font should
          be loaded. 
        * ((|glyphs|)): array of strings, one for each glyph, in the order they
          are found in the image file. If glyphs is not provided, or is nil, it
          is assumed to be the normal SFont order; that is, ASCII characters 
          ! (33) to ~ (126). See ((<SFont.default_glyphs>)) for a full list.
        * ((|space_width|)): represents the width of a space character, ( ). 
          You can either specify the width in pixels, or specify a character 
          whose width, as found in the image, should be used. Alternatively,
          you could add a space character to the list of glyphs, and to the 
          image file. If space_width is not given or is nil, and the space 
          character is not in the list of glyphs, it will have the same width 
          as the double-quote character (").

--- SFont#height
    Return the height of the font, in pixels. This is the same as the height 
    of the image file.

--- SFont#string_width( string )
    Pretends to render the given string, and returns the width in pixels of the
    surface that would be created if it were rendered (using 
    ((<SFont#render>)). If you want the height too, you can get it with 
    ((<SFont#height>)).
        * ((|string|)): the string to pretend to render.

--- SFont#render( string )
    Renders the given string to a Surface, and returns that surface.
        * ((|string|)): the string to render.
=end
