=begin
== Rubygame::Draw
--- Draw.line( dest, start, end, color )
    Draw a non-antialiased line on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|start|)): the start point, in the form (({[x,y]})).
        * ((|end|)): the end point, in the form (({[x,y]})).
        * ((|color|)): the color of the line, in the form (({[R,G,B,A]})).

--- Draw.aaline( dest, start, end, color )
    Draw an antialiased line on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|start|)): the start point, in the form (({[x,y]})).
        * ((|end|)): the end point, in the form (({[x,y]})).
        * ((|color|)): the color of the line, in the form (({[R,G,B,A]})).

--- Draw.box( dest, topleft, bottomright, color )
    Draw an outlined box (rectangle) on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|topleft|)): the location of the top-left corner of the box, in the
          form (({[x,y]})).
        * ((|topleft|)): the location of the bottom-right corner of the box, 
          in the form (({[x,y]})).
        * ((|color|)): the color of the box, in the form (({[R,G,B,A]})).

--- Draw.filled_box( dest, topleft, bottomright, color )
    Draw a filled box (rectangle) on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|topleft|)): the location of the top-left corner of the box, in the
          form (({[x,y]})).
        * ((|topleft|)): the location of the bottom-right corner of the box, 
          in the form (({[x,y]})).
        * ((|color|)): the color of the box, in the form (({[R,G,B,A]})).

--- Draw.circle( dest, center, radius, color )
    Draw an outlined circle  on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|center|)): the location of the center of the circle, in the
          form (({[x,y]})).
        * ((|radius|)): the radius of the circle.
        * ((|color|)): the color of the circle, in the form (({[R,G,B,A]})).

--- Draw.aacircle( dest, center, radius, color )
    Draw an antialiased, outlined circle  on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|center|)): the location of the center of the circle, in the
          form (({[x,y]})).
        * ((|radius|)): the radius of the circle.
        * ((|color|)): the color of the circle, in the form (({[R,G,B,A]})).

--- Draw.filled_circle( dest, center, radius, color )
    Draw a filled circle on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|center|)): the location of the center of the circle, in the
          form (({[x,y]})).
        * ((|radius|)): the radius of the circle.
        * ((|color|)): the color of the circle, in the form (({[R,G,B,A]})).

--- Draw.ellipse( dest, center, radii, color )
    Draw an outlined ellipse (oval) on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|center|)): the location of the center of the ellipse, in the
          form (({[x,y]})).
        * ((|radii|)): the radii of the ellipse, in the form (({[x,y]})).
        * ((|color|)): the color of the ellipse, in the form (({[R,G,B,A]})).

--- Draw.aaellipse( dest, center, radii, color )
    Draw an antialiased, outlined ellipse (oval) on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|center|)): the location of the center of the ellipse, in the
          form (({[x,y]})).
        * ((|radii|)): the radii of the ellipse, in the form (({[x,y]})).
        * ((|color|)): the color of the ellipse, in the form (({[R,G,B,A]})).

--- Draw.filled_ellipse( dest, center, radii, color )
    Draw a filled ellipse (oval) on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|center|)): the location of the center of the ellipse, in the
          form (({[x,y]})).
        * ((|radii|)): the radii of the ellipse, in the form (({[x,y]})).
        * ((|color|)): the color of the ellipse, in the form (({[R,G,B,A]})).

--- Draw.filled_pie( dest, center, radius, angles, color )
    Draw a filled pie (arc) on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|center|)): the location of the center of the pie, in the
          form (({[x,y]})).
        * ((|radius|)): the radius of the pie.
        * ((|angles|)): the start and end angles of the pie, in degrees, in
          the form (({[start,end]})). Zero degrees is the right side.
        * ((|color|)): the color of the pie, in the form (({[R,G,B,A]})).

--- Draw.polygon( dest, points, color )
    Draw an outlined polygon on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|points|)): a list of all the points in the polygon, in the order
          they should be connected, in the form (({[[x1,y1], [x2,y2], ...]})).
        * ((|color|)): the color of the polygon, in the form (({[R,G,B,A]})).

--- Draw.aapolygon( dest, points, color )
    Draw an antialiased, outlined polygon on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|points|)): a list of all the points in the polygon, in the order
          they should be connected, in the form (({[[x1,y1], [x2,y2], ...]})).
        * ((|color|)): the color of the polygon, in the form (({[R,G,B,A]})).

--- Draw.polygon( dest, points, color )
    Draw a filled polygon on a surface.
        * ((|dest|)): the destination surface to draw onto.
        * ((|points|)): a list of all the points in the polygon, in the order
          they should be connected, in the form (({[[x1,y1], [x2,y2], ...]})).
        * ((|color|)): the color of the polygon, in the form (({[R,G,B,A]})).

