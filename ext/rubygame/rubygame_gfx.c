/*
 *--
 * Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 * Copyright (C) 2004-2007  John Croisant
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *++
 */

#include "rubygame_shared.h"
#include "rubygame_gfx.h"

void Init_rubygame_gfx();
void extract_color(VALUE, Uint8*, Uint8*, Uint8*, Uint8*);
void extract_xy(VALUE, Sint16*, Sint16*);

void draw_line(VALUE, VALUE, VALUE, VALUE, int);
VALUE rbgm_draw_line(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aaline(VALUE, VALUE, VALUE, VALUE);

void draw_rect(VALUE, VALUE, VALUE, VALUE, int);
VALUE rbgm_draw_rect(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillrect(VALUE, VALUE, VALUE, VALUE);

void draw_circle(VALUE, VALUE, VALUE, VALUE, int, int);
VALUE rbgm_draw_circle(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aacircle(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillcircle(VALUE, VALUE, VALUE, VALUE);

void draw_ellipse(VALUE, VALUE, VALUE, VALUE, int, int);
VALUE rbgm_draw_ellipse(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aaellipse(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillellipse(VALUE, VALUE, VALUE, VALUE);

void draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE, int);
VALUE rbgm_draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillpie(VALUE, VALUE, VALUE, VALUE, VALUE);

void draw_polygon(VALUE, VALUE, VALUE, int, int);
VALUE rbgm_draw_polygon(VALUE, VALUE, VALUE);
VALUE rbgm_draw_aapolygon(VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillpolygon(VALUE, VALUE, VALUE);

/*
 * TODO: 
 *  Minimize redundancy (e.g. point and color checks). DRY.
 *  Clean up this ugly mess of code!
 */

void extract_color(VALUE rgba, Uint8* r, Uint8* g, Uint8* b, Uint8* a)
{
  rgba = convert_to_array(rgba);
  if(RARRAY(rgba)->len < 3)
    rb_raise(rb_eArgError,"color must be [r,g,b] or [r,g,b,a] form");
  *r = NUM2UINT(rb_ary_entry(rgba,0));
  *g = NUM2UINT(rb_ary_entry(rgba,1));
  *b = NUM2UINT(rb_ary_entry(rgba,2));
  
  if(RARRAY(rgba)->len > 3)
    *a = NUM2UINT(rb_ary_entry(rgba,3));
  else
    *a = 255;
}

void extract_xy(VALUE point, Sint16* x, Sint16* y)
{
	point = convert_to_array(point);
  if(RARRAY(point)->len < 2)
    rb_raise(rb_eArgError,"expected argument as [x,y] form");
  *x = NUM2INT(rb_ary_entry(point,0));
  *y = NUM2INT(rb_ary_entry(point,1));
}

/*********
 * LINES *
 *********/

/* This is wrapped by rbgm_draw_line and rbgm_draw_aaline */
void draw_line(VALUE target, VALUE pt1, VALUE pt2, VALUE rgba, int aa)
{
  SDL_Surface *dest;
  Uint8 r,g,b,a;
  Sint16 x1, y1, x2, y2;

  extract_xy(pt1, &x1, &y1);
  extract_xy(pt2, &x2, &y2);
  
  extract_color(rgba, &r, &g, &b, &a);

  Data_Get_Struct(target,SDL_Surface,dest);
  //printf("dest: %dx%d\n",dest->w,dest->h);

  /* call the appropriate function for the circumstances */
  if(y1 == y2) /* horizontal line */
  {
    //printf("horizontal line.\n");
    hlineRGBA(dest, x1, x2, y1, r,g,b,a);
  }
  else if(x1 == x2) /* vertical line */
  {
    //printf("vertical line.\n");
    vlineRGBA(dest, x1, y1, y2, r,g,b,a);
  }
  else
  {
    if(aa)
    {
      //printf("aa line.\n");
      aalineRGBA(dest, x1, y1, x2, y2, r,g,b,a);
    }
    else
    {
      //printf("no-aa line.\n");
      lineRGBA(dest, x1, y1, x2, y2, r,g,b,a);
    }
  }
  return;
}

/*  call-seq:
 *    draw_line(point1, point2, color)
 *
 *  Draw a line segment between two points on the Surface.
 *  See also #draw_line_a
 *
 *  This method takes these arguments:
 *  point1::  the coordinates of one end of the line, [x1,y1].
 *  point2::  the coordinates of the other end of the line, [x2,y2].
 *  color::   the color of the shape, [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_line(VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
  draw_line(target,pt1,pt2,rgba,0); /* no anti-aliasing */
  return target;
}
/*  call-seq:
 *    draw_line_a(point1, point2, color)
 *
 *  Like #draw_line, but the line will be anti-aliased.
 */
VALUE rbgm_draw_aaline(VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
  draw_line(target,pt1,pt2,rgba,1); /* anti-aliasing */
  return target;
}

/**********************
 * RECTANGLES (BOXES) *
 **********************/

/* This is wrapped by rbgm_draw_rect and rbgm_draw_fillrect */
void draw_rect(VALUE target, VALUE pt1, VALUE pt2, VALUE rgba, int fill)
{
  SDL_Surface *dest;
  Uint8 r,g,b,a;
  Sint16 x1, y1, x2, y2;

  extract_xy(pt1, &x1, &y1);
  extract_xy(pt2, &x2, &y2);
  
  extract_color(rgba, &r, &g, &b, &a);

  Data_Get_Struct(target,SDL_Surface,dest);
  //printf("dest: %dx%d\n",dest->w,dest->h);

  /* call the appropriate function for the circumstances */
  
  if(fill)
  {
    //printf("filled rect\n");
    boxRGBA(dest,x1,y1,x2,y2,r,g,b,a);
  }
  else
  {
    //printf("unfilled rect\n");
    rectangleRGBA(dest,x1,y1,x2,y2,r,g,b,a);
  }
  return;
}
/*  call-seq:
 *    draw_box(point1, point2, color)
 *
 *  Draw a non-solid box (rectangle) on the Surface, given the coordinates of
 *  its top-left corner and bottom-right corner. See also #draw_box_s
 *
 *  This method takes these arguments:
 *  point1::  the coordinates of top-left corner, [x1,y1].
 *  point2::  the coordinates of bottom-right corner, [x2,y2].
 *  color::   the color of the shape, [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_rect(VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
  draw_rect(target,pt1,pt2,rgba,0); /* no fill */
  return target;
}

/*  call-seq:
 *    draw_box_s(point1, point2, color)
 *
 *  Like #draw_box, but the shape is solid, instead of an outline.
 *  (You may find using #fill to be more convenient and perhaps faster than
 *  this method.)
 */
VALUE rbgm_draw_fillrect(VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
  draw_rect(target,pt1,pt2,rgba,1); /* fill */
  return target;
}

/***********
 * CIRCLES *
 ***********/

/* This is wrapped by rbgm_draw_(|aa|fill)circle */
void draw_circle(VALUE target, VALUE center, VALUE radius, VALUE rgba, int aa, int fill)
{
  SDL_Surface *dest;
  Uint8 r,g,b,a;
  Sint16 x, y, rad;

  extract_xy(center, &x, &y);
  rad = NUM2INT(radius);
  
  extract_color(rgba, &r, &g, &b, &a);

  Data_Get_Struct(target,SDL_Surface,dest);
  //printf("dest: %dx%d\n",dest->w,dest->h);

  /* call the appropriate function for the circumstances */
  
  if(fill)
  {
    //printf("filled circle\n");
    filledCircleRGBA(dest,x,y,rad,r,g,b,a);
  }
  else
  {
    if(aa)
    {
      //printf("aa circle\n");
      aacircleRGBA(dest,x,y,rad,r,g,b,a);
    }
    else
    {
      //printf("circle\n");
      circleRGBA(dest,x,y,rad,r,g,b,a);
    }
  }
  return;
}

/* 
 *  call-seq:
 *    draw_circle(center, radius, color)
 *
 *  Draw a non-solid circle on the Surface, given the coordinates of its
 *  center and its radius. See also #draw_circle_a and #draw_circle_s
 *
 *  This method takes these arguments:
 *  center::  the coordinates of circle's center, [x,y].
 *  radius::  the radius (pixels) of the circle.
 *  color::   the color of the shape, [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_circle(VALUE target, VALUE center, VALUE radius, VALUE rgba)
{
  draw_circle(target,center,radius,rgba,0,0); /* no aa, no fill */
  return target;
}
/* 
 *  call-seq:
 *    draw_circle_a(center, radius, color)
 *
 *  Like #draw_circle, but the outline is anti-aliased.
 */
VALUE rbgm_draw_aacircle(VALUE target, VALUE center, VALUE radius, VALUE rgba)
{
  draw_circle(target,center,radius,rgba,1,0); /* aa, no fill */
  return target;
}
/* 
 *  call-seq:
 *    draw_circle_s(center, radius, color)
 *
 *  Like #draw_circle, but the shape is solid, instead of an outline.
 */
VALUE rbgm_draw_fillcircle(VALUE target, VALUE center, VALUE radius, VALUE rgba)
{
  draw_circle(target,center,radius,rgba,0,1); /* no aa, fill */
  return target;
}

/************
 * ELLIPSES *
 ************/

/* This is wrapped by rbgm_draw_(|aa|fill)ellipse */
void draw_ellipse(VALUE target, VALUE center, VALUE radii, VALUE rgba, int aa, int fill)
{
  SDL_Surface *dest;
  Uint8 r,g,b,a;
  Sint16 x, y, radx,rady;

  extract_xy(center, &x, &y);
  extract_xy(radii, &radx, &rady);
  
  extract_color(rgba, &r, &g, &b, &a);

  Data_Get_Struct(target,SDL_Surface,dest);

  /* call the appropriate function for the circumstances */
  
  if(fill)
  {
    //printf("filled ellipse\n");
    filledEllipseRGBA(dest,x,y,radx,rady,r,g,b,a);
  }
  else
  {
    if(aa)
    {
      //printf("aa ellipse\n");
      aaellipseRGBA(dest,x,y,radx,rady,r,g,b,a);
    }
    else
    {
      //printf("ellipse\n");
      ellipseRGBA(dest,x,y,radx,rady,r,g,b,a);
    }
  }
  return;
}

/* 
 *  call-seq:
 *    draw_ellipse(center, radius, color)
 *
 *  Draw a non-solid ellipse (oval) on the Surface, given the 
 *  coordinates of its center and its horizontal and vertical radii.
 *  See also #draw_ellipse_a and #draw_ellipse_s
 *
 *  This method takes these arguments:
 *  center::  the coordinates of ellipse's center, [x,y].
 *  radii::   the x and y radii (pixels), [rx,ry].
 *  color::   the color of the shape, [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_ellipse(VALUE target, VALUE center, VALUE radii, VALUE rgba)
{
  draw_ellipse(target,center,radii,rgba,0,0); /* no aa, no fill */
  return target;
}
/* 
 *  call-seq:
 *    draw_ellipse_a(center, radius, color)
 *
 *  Like #draw_ellipse, but the ellipse border is anti-aliased.
 */
VALUE rbgm_draw_aaellipse(VALUE target, VALUE center, VALUE radii, VALUE rgba)
{
  draw_ellipse(target,center,radii,rgba,1,0); /* aa, no fill */
  return target;
}

/* 
 *  call-seq:
 *    draw_ellipse_s(center, radius, color)
 *
 *  Like #draw_ellipse, but the shape is solid, instead of an outline.
 */
VALUE rbgm_draw_fillellipse(VALUE target, VALUE center, VALUE radii, VALUE rgba)
{
  draw_ellipse(target,center,radii,rgba,0,1); /* no aa, fill */
  return target;
}

/********
 * PIES *
 ********/

/* This is wrapped by rbgm_draw_(|aa|fill)pie */
void draw_pie(VALUE target, VALUE center, VALUE radius, VALUE angles, VALUE rgba, int fill)
{
  SDL_Surface *dest;
  Uint8 r,g,b,a;
  Sint16 x, y, rad, start, end;

  extract_xy(center, &x, &y);
  extract_xy(angles, &start, &end);
  rad = NUM2INT(radius);
  
  extract_color(rgba, &r, &g, &b, &a);

  Data_Get_Struct(target,SDL_Surface,dest);

  /* call the appropriate function for the circumstances */
  
  if(fill)
  {
    //printf("filled pie\n");
#ifdef HAVE_UPPERCASEPIE
    filledPieRGBA(dest,x,y,rad,start,end,r,g,b,a);
#else
    /* before sdl-gfx 2.0.12, it used to be a lowercase pie: */
    filledpieRGBA(dest,x,y,rad,start,end,r,g,b,a);
#endif
  }
  else
  {
    /* this function did not exist until sdl-gfx 2.0.11, but
       rbgm_draw_fillpie checks the version. You should too if you
       directly call this function with fill==1. */
    pieRGBA(dest,x,y,rad,start,end,r,g,b,a);
  }
  return;
}

/* 
 *  call-seq:
 *    draw_pie(center, radius, angles, color)
 *
 *  Draw a non-solid arc (part of a circle), given the coordinates of
 *  its center, radius, and starting/ending angles.
 *  See also #draw_arc_s
 *
 *  *IMPORTANT:* This method will only be defined if Rubygame was compiled
 *  with SDL_gfx-2.0.11 or greater. (Note: #draw_arc_s does not have
 *  this requirement.)
 *
 *  This method takes these arguments:
 *  center::  the coordinates of circle's center, [x,y].
 *  radius::  the radius (pixels) of the circle.
 *  angles::  the start and end angles (in degrees) of the arc, [start,end].
 *            Angles are given *CLOCKWISE* from the positive x
 *            (remember that the positive Y direction is down, rather than up).
 *  color::   the color of the shape, [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_pie(VALUE target, VALUE center, VALUE radius, VALUE angles, VALUE rgba)
{
#ifdef HAVE_NONFILLEDPIE
  draw_pie(target,center,radius,angles,rgba,0); /* no fill */
  return target;
#else
  return Qnil;
#endif
}

/* 
 *  call-seq:
 *    draw_arc_s(center, radius, angles, color)
 *
 * Like #draw_arc, but the shape is solid, instead an outline.
 * (This method does not require SDL_gfx 2.0.11 or greater, 
 * but #draw_arc does.)
 */
VALUE rbgm_draw_fillpie(VALUE target, VALUE center, VALUE radius, VALUE angles, VALUE rgba)
{
  draw_pie(target,center,radius,angles,rgba,1); /* fill */
  return target;
}

/************
 * POLYGONS *
 ************/

/* This is wrapped by rbgm_draw_(|aa|fill)polygon */
void draw_polygon(VALUE target, VALUE points, VALUE rgba, int aa, int fill)
{
  SDL_Surface *dest;
  VALUE each_point;
  int length,loop;
  Uint8 r,g,b,a;
  Sint16 *x, *y;

  /* separate points into arrays of x and y values */
  points = convert_to_array(points);
  length = RARRAY(points)->len;
  x = alloca(sizeof (Sint16) * length);
  y = alloca(sizeof (Sint16) * length);

  for(loop=0;loop<length;loop++)
  {
    each_point = rb_ary_entry(points,loop);
    extract_xy(each_point, &(x[loop]), &(y[loop]));
  }

  extract_color(rgba, &r, &g, &b, &a);

  Data_Get_Struct(target,SDL_Surface,dest);

  /* call the appropriate function for the circumstances */
  
  if(fill)
  {
    //printf("filled polygon\n");
    filledPolygonRGBA(dest,x,y,length,r,g,b,a);
  }
  else
  {
    if(aa)
    {
      //printf("aa polygon\n");
      aapolygonRGBA(dest,x,y,length,r,g,b,a);
    }
    else
    {
      //printf("polygon\n");
      polygonRGBA(dest,x,y,length,r,g,b,a);
    }
  }
  return;
}
/* 
 *  call-seq:
 *    draw_polygon(points, color)
 *
 *  Draw a non-solid polygon, given the coordinates of its vertices, in the
 *  order that they are connected. This is essentially a series of connected
 *  dots. See also #draw_polygon_a and #draw_polygon_s.
 *
 *  This method takes these arguments:
 *  points::  an Array containing the coordinate pairs for each vertex of the
 *            polygon, in the order that they are connected, e.g.
 *            <tt>[ [x1,y1], [x2,y2], ..., [xn,yn] ]</tt>. To draw a closed 
 *            shape, the final coordinate pair should match the first.
 *  color::   the color of the shape, [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_polygon(VALUE target, VALUE points, VALUE rgba)
{
  draw_polygon(target,points,rgba,0,0); /* no aa, no fill */
  return target;
}
/* 
 *  call-seq:
 *    draw_polygon_a(points, color)
 *
 *  Like #draw_polygon, but the lines are anti-aliased.
 */
VALUE rbgm_draw_aapolygon(VALUE target, VALUE points, VALUE rgba)
{
  draw_polygon(target,points,rgba,1,0); /* aa, no fill */
  return target;
}

/* 
 *  call-seq:
 *    draw_polygon_s(points, color)
 *
 *  Like #draw_polygon, but the shape is solid, not an outline.
 */
VALUE rbgm_draw_fillpolygon(VALUE target, VALUE points, VALUE rgba)
{
  draw_polygon(target,points,rgba,0,1); /* no aa, fill */
  return target;
}


VALUE rbgm_transform_rotozoom(int, VALUE*, VALUE);
VALUE rbgm_transform_rotozoomsize(int, VALUE*, VALUE);

VALUE rbgm_transform_zoom(int, VALUE*, VALUE);
VALUE rbgm_transform_zoomsize(int, VALUE*, VALUE);

/*
 *  call-seq:
 *    rotozoom( angle, zoom, smooth=false )  ->  Surface
 *
 *  Return a rotated and/or zoomed version of the given surface. Note that
 *  rotating a Surface anything other than a multiple of 90 degrees will 
 *  cause the new surface to be larger than the original to accomodate the
 *  corners (which would otherwise extend beyond the surface).
 *
 *  If Rubygame was compiled with SDL_gfx-2.0.13 or greater, +zoom+ can be
 *  an Array of 2 Numerics for separate X and Y scaling. Also, it can be
 *  negative to indicate flipping horizontally or vertically.
 *
 *  Will raise SDLError if you attempt to use separate X and Y zoom factors
 *  or negative zoom factors with an unsupported version of SDL_gfx.
 *
 *  This method takes these arguments:
 *  angle::   degrees to rotate counter-clockwise (negative for clockwise).
 *  zoom::    scaling factor(s). A single positive Numeric, unless you have
 *            SDL_gfx-2.0.13 or greater (see above).
 *  smooth::  whether to anti-alias the new surface.
 *            By the way, if true, the new surface will be 32bit RGBA.
 */
VALUE rbgm_transform_rotozoom(int argc, VALUE *argv, VALUE self)
{
  SDL_Surface *src, *dst;
  double angle, zoomx, zoomy;
  int smooth = 0;

  VALUE vangle, vzoom, vsmooth;

  rb_scan_args(argc, argv, "21", &vangle, &vzoom, &vsmooth);

  Data_Get_Struct(self,SDL_Surface,src);

  angle = NUM2DBL(vangle);
  smooth = RTEST(vsmooth) ? 1 : 0;

  switch( TYPE(vzoom) )
  {
   case T_ARRAY: {
     /* separate X and Y factors */
#ifdef HAVE_ROTOZOOMXY
     /* Do the real function. */
     zoomx = NUM2DBL(rb_ary_entry(vzoom,0));
     zoomy = NUM2DBL(rb_ary_entry(vzoom,1));
     dst = rotozoomSurfaceXY(src, angle, zoomx, zoomy, smooth);
     if(dst == NULL)
       rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());
#else
     /* Raise SDLError. You should have checked first! */
     rb_raise(eSDLError,"Separate X/Y rotozoom scale factors is not supported by your version of SDL_gfx (%d,%d,%d). Please upgrade to 2.0.13 or later.", SDL_GFXPRIMITIVES_MAJOR, SDL_GFXPRIMITIVES_MINOR, SDL_GFXPRIMITIVES_MICRO);
     return Qnil;
#endif
     break;
   }

    case T_FLOAT:
    case T_FIXNUM: {
      /* uniform factor for both X and Y */
      zoomx = NUM2DBL(vzoom);
#ifndef HAVE_ROTOZOOMXY
      if(zoomx < 0)                /* negative zoom (for flipping) */
      {
      	/* Raise SDLError. You should have checked first! */
      	rb_raise(eSDLError,"Negative rotozoom scale factor is not supported by your version of SDL_gfx (%d,%d,%d). Please upgrade to 2.0.13 or later.", SDL_GFXPRIMITIVES_MAJOR, SDL_GFXPRIMITIVES_MINOR, SDL_GFXPRIMITIVES_MICRO);
      }
#endif
      dst = rotozoomSurface(src, angle, zoomx, smooth);
      if(dst == NULL)
      	rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());
      break;
    }

    default: {
      rb_raise(rb_eArgError,
               "wrong zoom factor type (expected Array or Numeric)");
      break;
    }

  }

  return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,dst);
}

/*
 *  call-seq:
 *    rotozoom_size( size, angle, zoom )  ->  [width, height] or nil
 *
 *  Return the dimensions of the surface that would be returned if
 *  #rotozoom() were called on a Surface of the given size, with
 *  the same angle and zoom factors.
 *
 *  If Rubygame was compiled with SDL_gfx-2.0.13 or greater, +zoom+ can be
 *  an Array of 2 Numerics for separate X and Y scaling. Also, it can be
 *  negative to indicate flipping horizontally or vertically.
 *
 *  Will return +nil+ if you attempt to use separate X and Y zoom factors
 *  or negative zoom factors with an unsupported version of SDL_gfx.
 *
 *  This method takes these arguments:
 *  size::  an Array with the hypothetical Surface width and height (pixels)
 *  angle:: degrees to rotate counter-clockwise (negative for clockwise).
 *  zoom::  scaling factor(s). A single positive Numeric, unless you have
 *          SDL_gfx-2.0.13 or greater (see above).
 */
VALUE rbgm_transform_rzsize(int argc, VALUE *argv, VALUE module)
{
  int w,h, dstw,dsth;
  double angle, zoomx, zoomy;

  VALUE vsize, vangle, vzoom;

  rb_scan_args(argc,argv,"3", &vsize, &vangle, &vzoom);

  vsize = convert_to_array(vsize);
  w = NUM2INT(rb_ary_entry(argv[0],0));
  h = NUM2INT(rb_ary_entry(argv[0],0));
  angle = NUM2DBL(vangle);

  switch( TYPE(vzoom) )
  {
    case T_ARRAY: {
      /* Separate X/Y rotozoom scaling was not supported prior to 2.0.13. */
      /* Check if we have at least version 2.0.13 of SDL_gfxPrimitives */
#ifdef HAVE_ROTOZOOMXY
      /* Do the real function. */
      zoomx = NUM2DBL(rb_ary_entry(vzoom,0));
      zoomy = NUM2DBL(rb_ary_entry(vzoom,1));
      rotozoomSurfaceSizeXY(w, h, angle, zoomx, zoomy, &dstw, &dsth);
#else 
      /* Return nil, because it's not supported. */
      return Qnil;
#endif
      break;
    }

    case T_FLOAT:
    case T_FIXNUM: {
      zoomx = NUM2DBL(argv[1]);
#ifndef HAVE_ROTOZOOMXY
      if(zoomx < 0)                /* negative zoom (for flipping) */
      {
      	/* Return nil, because it's not supported. */
      	return Qnil;
      }
#endif
      rotozoomSurfaceSize(w, h, angle, zoomx, &dstw, &dsth);
      break;
    }

    default: {
      rb_raise(rb_eArgError,
               "wrong zoom factor type (expected Array or Numeric)");
      break;
    }

  }

  /*   if(dstw == NULL || dsth == NULL)
       rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());*/
  return rb_ary_new3(2,INT2NUM(dstw),INT2NUM(dsth));

}

/* 
 *  call-seq:
 *     zoom(zoom, smooth=false)  ->  Surface
 *
 *  Return a zoomed version of the Surface.
 *
 *  This method takes these arguments:
 *  zoom::    a Numeric factor to scale by in both x and y directions,
 *            or an Array with separate x and y scale factors.
 *  smooth::  whether to anti-alias the new surface.
 *            By the way, if true, the new surface will be 32bit RGBA.
 */
VALUE rbgm_transform_zoom(int argc, VALUE *argv, VALUE self)
{
  SDL_Surface *src, *dst;
  double zoomx, zoomy;
  int smooth = 0;

  VALUE vzoom, vsmooth;

  rb_scan_args(argc, argv, "11", &vzoom, &vsmooth);

  Data_Get_Struct(self,SDL_Surface,src);

  smooth = RTEST(vsmooth) ? 1 : 0;

  switch( TYPE(vzoom) )
  {
    case T_ARRAY:{
      zoomx = NUM2DBL(rb_ary_entry(vzoom,0));
      zoomy = NUM2DBL(rb_ary_entry(vzoom,1));
      break;
    }
    case T_FLOAT:
    case T_FIXNUM: {
      zoomx = NUM2DBL(argv[0]);
      zoomy = zoomx;
      break;
    }
    default: {
      rb_raise(rb_eArgError,
               "wrong zoom factor type (expected Array or Numeric)");
      break;
    }

  }
  dst = zoomSurface(src,zoomx,zoomy,smooth);
  if(dst == NULL)
    rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());
  return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,dst);
}

/* 
 *  call-seq:
 *     zoom_to(width, height, smooth=false)  ->  Surface
 *
 *  Return a zoomed version of the Surface.
 *
 *  This method takes these arguments:
 *  width::   the width to scale to. If nil is given, will keep x axis unscaled.
 *  height::  the height to scale to. If nil is given, will keep x axis
 *            unscaled.
 *  smooth::  whether to anti-alias the new surface. This option can be
 *            omitted, in which case the surface will not be anti-aliased.
 *            If true, the new surface will be 32bit RGBA.
 */
VALUE rbgm_transform_zoom_to(int argc, VALUE *argv, VALUE self)
{
  SDL_Surface *src, *dst;
  VALUE v_width, v_height, v_smooth;
  double zoomx, zoomy;
  int smooth;

  rb_scan_args(argc, argv, "21", &v_width, &v_height, &v_smooth);

  Data_Get_Struct(self,SDL_Surface,src);
  smooth = RTEST(v_smooth) ? 1 : 0;
  zoomx  = NIL_P(v_width) ? 1.0 : NUM2DBL(v_width)/src->w;
  zoomy  = NIL_P(v_height) ? 1.0 : NUM2DBL(v_height)/src->h;
  dst    = zoomSurface(src,zoomx,zoomy,smooth);

  if(dst == NULL)
    rb_raise(eSDLError,"Could not rotozoom surface: %s",SDL_GetError());

  return Data_Wrap_Struct(cSurface,0,SDL_FreeSurface,dst);
}

/* 
 *  call-seq:
 *    zoom_size(size, zoom)  ->  [width, height]
 *
 *  Return the dimensions of the surface that would be returned if
 *  #zoom were called with a surface of the given size and zoom factors.
 *
 *  This method takes these arguments:
 *  size:: an Array with the hypothetical surface width and height (pixels)
 *  zoom:: the factor to scale by in both x and y directions, or an Array
 *         with separate x and y scale factors.
 */
VALUE rbgm_transform_zoomsize(int argc, VALUE *argv, VALUE module)
{
  int w,h, dstw,dsth;
  double zoomx, zoomy;

  VALUE vsize, vzoom;

  rb_scan_args(argc,argv,"2", &vsize, &vzoom);

  vsize = convert_to_array(vsize);
  w = NUM2INT(rb_ary_entry(vsize,0));
  h = NUM2INT(rb_ary_entry(vsize,1));

  switch( TYPE(vzoom) )
  {
    case T_ARRAY: {
      zoomx = NUM2DBL(rb_ary_entry(vzoom,0));
      zoomy = NUM2DBL(rb_ary_entry(vzoom,1));
      break;
    }

    case T_FLOAT:
    case T_FIXNUM: {
      zoomx = NUM2DBL(vzoom);
      zoomy = zoomx;
      break;
    }
    default: {
      rb_raise(rb_eArgError,
               "wrong zoom factor type (expected Array or Numeric)");
      break;
    }
  }

  zoomSurfaceSize(w, h,  zoomx, zoomy, &dstw, &dsth);
  return rb_ary_new3(2,INT2NUM(dstw),INT2NUM(dsth));
}


/*
 * Document-class: Rubygame::Surface
 *
 *  Surface's draw_* methods provide an interface to SDL_gfx's functions for
 *  drawing colored shapes onto the Surface. Some methods (#draw_arc_s) 
 *  require a minimum SDL_gfx version (at compile time) to exist.
 *
 *  The base methods (e.g. #draw_circle), draw the outline of the shape,
 *  without any color inside of it.
 *
 *  Most shapes also have an anti-aliased version, denoted by the 'a' in its
 *  name (e.g. #draw_circle_a). These methods draw smooth outlines with no
 *  aliasing (pixelated "jaggies").
 *  Please note that anti-aliased drawing methods take longer than their
 *  aliased counterparts.
 *
 *  Most shapes also have a solid version, denoted by the 's' in its name 
 *  (e.g. #draw_circle_s). These methods draw the shape as solid, rather than
 *  an outline.
 *
 *  At this time, there are no methods to draw shapes which are both filled
 *  and anti-aliased. For some shapes, it may be possible to approximate this
 *  effect by drawing a filled shape, then an anti-aliased outline in the same
 *  position.
 */
void Init_rubygame_gfx()
{
#if 0
  mRubygame = rb_define_module("Rubygame");
  cSurface = rb_define_class_under(mRubygame,"Surface",rb_cObject);
#endif

  Init_rubygame_shared();

  rb_hash_aset(rb_ivar_get(mRubygame,rb_intern("VERSIONS")),
               ID2SYM(rb_intern("sdl_gfx")),
               rb_ary_new3(3,
                           INT2NUM(SDL_GFXPRIMITIVES_MAJOR),
                           INT2NUM(SDL_GFXPRIMITIVES_MINOR),
                           INT2NUM(SDL_GFXPRIMITIVES_MICRO)));

  rb_define_method(cSurface,"draw_line",rbgm_draw_line,3);
  rb_define_method(cSurface,"draw_line_a",rbgm_draw_aaline,3);
  rb_define_method(cSurface,"draw_box",rbgm_draw_rect,3);
  rb_define_method(cSurface,"draw_box_s",rbgm_draw_fillrect,3);
  rb_define_method(cSurface,"draw_circle",rbgm_draw_circle,3);
  rb_define_method(cSurface,"draw_circle_a",rbgm_draw_aacircle,3);
  rb_define_method(cSurface,"draw_circle_s",rbgm_draw_fillcircle,3);
  rb_define_method(cSurface,"draw_ellipse",rbgm_draw_ellipse,3);
  rb_define_method(cSurface,"draw_ellipse_a",rbgm_draw_aaellipse,3);
  rb_define_method(cSurface,"draw_ellipse_s",rbgm_draw_fillellipse,3);
#ifdef HAVE_NONFILLEDPIE
  rb_define_method(cSurface,"draw_arc",rbgm_draw_pie,4);
#endif
  rb_define_method(cSurface,"draw_arc_s",rbgm_draw_fillpie,4);
  rb_define_method(cSurface,"draw_polygon",rbgm_draw_polygon,2);
  rb_define_method(cSurface,"draw_polygon_a",rbgm_draw_aapolygon,2);
  rb_define_method(cSurface,"draw_polygon_s",rbgm_draw_fillpolygon,2);


  rb_define_method(cSurface,"rotozoom",rbgm_transform_rotozoom,-1);
  rb_define_method(cSurface,"zoom",rbgm_transform_zoom,-1);
  rb_define_method(cSurface,"zoom_to",rbgm_transform_zoom_to,-1);

  rb_define_module_function(cSurface,"rotozoom_size",rbgm_transform_rzsize,-1);
  rb_define_module_function(cSurface,"zoom_size",rbgm_transform_zoomsize,-1);


}
