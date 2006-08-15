/*
 *  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
 *  Copyright (C) 2004-2006  John 'jacius' Croisant
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

#include "rubygame.h"
#include "rubygame_draw.h"

void Rubygame_Init_Draw();
VALUE mDraw;

#ifdef HAVE_SDL_GFXPRIMITIVES_H

void draw_line(VALUE, VALUE, VALUE, VALUE, int);
VALUE rbgm_draw_line(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aaline(VALUE, VALUE, VALUE, VALUE, VALUE);

void draw_rect(VALUE, VALUE, VALUE, VALUE, int);
VALUE rbgm_draw_rect(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillrect(VALUE, VALUE, VALUE, VALUE, VALUE);

void draw_circle(VALUE, VALUE, VALUE, VALUE, int, int);
VALUE rbgm_draw_circle(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aacircle(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillcircle(VALUE, VALUE, VALUE, VALUE, VALUE);

void draw_ellipse(VALUE, VALUE, VALUE, VALUE, int, int);
VALUE rbgm_draw_ellipse(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aaellipse(VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillellipse(VALUE, VALUE, VALUE, VALUE, VALUE);

void draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE, int);
VALUE rbgm_draw_pie(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillpie(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE);

void draw_polygon(VALUE, VALUE, VALUE, int, int);
VALUE rbgm_draw_polygon(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_aapolygon(VALUE, VALUE, VALUE, VALUE);
VALUE rbgm_draw_fillpolygon(VALUE, VALUE, VALUE, VALUE);


/*********
 * LINES *
 *********/

/* This is wrapped by rbgm_draw_line and rbgm_draw_aaline */
void draw_line(VALUE target, VALUE pt1, VALUE pt2, VALUE rgba, int aa)
{
  SDL_Surface *dest;
  Uint8 r,g,b,a;
  Sint16 x1, y1, x2, y2;

  /* get the starting and ending points of the line */
  if(RARRAY(pt1)->len < 2)
    rb_raise(rb_eArgError,"point 1 must be [x,y] form");
  if(RARRAY(pt2)->len < 2)
    rb_raise(rb_eArgError,"point 2 must be [x,y] form");
  x1 = NUM2INT(rb_ary_entry(pt1,0));
  y1 = NUM2INT(rb_ary_entry(pt1,1));
  x2 = NUM2INT(rb_ary_entry(pt2,0));
  y2 = NUM2INT(rb_ary_entry(pt2,1));
  //printf("pts: [%d,%d], [%d,%d]\n",x1,y1,x2,y2);
  
  /* get the color of the line */
  if(RARRAY(rgba)->len < 3)
    rb_raise(rb_eArgError,"color must be [r,g,b] or [r,g,b,a] form");
  r = NUM2UINT(rb_ary_entry(rgba,0));
  g = NUM2UINT(rb_ary_entry(rgba,1));
  b = NUM2UINT(rb_ary_entry(rgba,2));
  //printf("color: [%d,%d,%d]\n",r,g,b);
  
  /* did we get alpha, or not? */
  if(RARRAY(rgba)->len > 3)
    a = NUM2UINT(rb_ary_entry(rgba,3));
  else
    a = 255;
  //printf("alpha: %d\n",a);

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
 *    line(surface, point1, point2, color)
 *
 *  Draw a line segment between two points on a surface. See also #aaline.
 *
 *  This method takes these arguments:
 *  surface:: the target surface to draw on.
 *  point1::  the coordinates of one end of the line, in the form [x,y].
 *  point2::  the coordinates of the other end of the line, as above.
 *  color::   the color of the shape, in the form [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_line(VALUE module, VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
  draw_line(target,pt1,pt2,rgba,0); /* no anti-aliasing */
  return target;
}
/*  call-seq:
 *    aaline(surface, point1, point2, color)
 *
 *  As #line, but the line will be anti-aliased.
 */
VALUE rbgm_draw_aaline(VALUE module, VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
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

  /* get the starting and ending points of the line */
  if(RARRAY(pt1)->len < 2)
    rb_raise(rb_eArgError,"point 1 must be [x,y] form");
  if(RARRAY(pt2)->len < 2)
    rb_raise(rb_eArgError,"point 2 must be [x,y] form");
  x1 = NUM2INT(rb_ary_entry(pt1,0));
  y1 = NUM2INT(rb_ary_entry(pt1,1));
  x2 = NUM2INT(rb_ary_entry(pt2,0));
  y2 = NUM2INT(rb_ary_entry(pt2,1));
  //printf("pts: [%d,%d], [%d,%d]\n",x1,y1,x2,y2);
  
  /* get the color of the line */
  if(RARRAY(rgba)->len < 3)
    rb_raise(rb_eArgError,"color must be [r,g,b] or [r,g,b,a] form");
  r = NUM2UINT(rb_ary_entry(rgba,0));
  g = NUM2UINT(rb_ary_entry(rgba,1));
  b = NUM2UINT(rb_ary_entry(rgba,2));
  //printf("color: [%d,%d,%d]\n",r,g,b);
  
  /* did we get alpha, or not? */
  if(RARRAY(rgba)->len > 3)
    a = NUM2UINT(rb_ary_entry(rgba,3));
  else
    a = 255;
  //printf("alpha: %d\n",a);

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
 *    box(surface, point1, point2, color)
 *
 *  Draw a non-filled box (rectangle) on a surface, given the coordinates of
 *  its top-left corner and bottom-right corner. See also #filled_box.
 *
 *  This method takes these arguments:
 *  surface:: the target surface to draw on.
 *  point1::  the coordinates of top-left corner, in the form [x,y].
 *  point2::  the coordinates of bottom-right corner, in the form [x,y].
 *  color::   the color of the shape, in the form [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_rect(VALUE module, VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
  draw_rect(target,pt1,pt2,rgba,0); /* no fill */
  return target;
}

/*  call-seq:
 *    filled_box(surface, point1, point2, color)
 *
 *  As #box, but the shape is solid, not an outline. (You may
 *  find using Surface#fill to be more convenient, and perhaps faster than
 *  this method.)
 */
VALUE rbgm_draw_fillrect(VALUE module, VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
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

  /* get the starting and ending points of the line */
  if(RARRAY(center)->len < 2)
    rb_raise(rb_eArgError,"center point must be [x,y] form");
  x = NUM2INT(rb_ary_entry(center,0));
  y = NUM2INT(rb_ary_entry(center,1));
  rad = NUM2INT(radius);
  //printf("pts: [%d,%d], [%d,%d]\n",x1,y1,x2,y2);
  
  /* get the color of the line */
  if(RARRAY(rgba)->len < 3)
    rb_raise(rb_eArgError,"color must be [r,g,b] or [r,g,b,a] form");
  r = NUM2UINT(rb_ary_entry(rgba,0));
  g = NUM2UINT(rb_ary_entry(rgba,1));
  b = NUM2UINT(rb_ary_entry(rgba,2));
  //printf("color: [%d,%d,%d]\n",r,g,b);
  
  /* did we get alpha, or not? */
  if(RARRAY(rgba)->len > 3)
    a = NUM2UINT(rb_ary_entry(rgba,3));
  else
    a = 255;
  //printf("alpha: %d\n",a);

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
 *    circle(surface, center, radius, color)
 *
 *  Draw an empty circle on a surface, given the coordinates of its center
 *  and its radius. See also #aacircle and #filled_circle.
 *
 *  This method takes these arguments:
 *  surface:: the target surface to draw on.
 *  center::  the coordinates of circle's center, in the form [x,y].
 *  radius::  the radius (pixels) of the circle.
 *  color::   the color of the shape, in the form [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_circle(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE rgba)
{
  draw_circle(target,center,radius,rgba,0,0); /* no aa, no fill */
  return target;
}
/* 
 *  call-seq:
 *    aacircle(surface, center, radius, color)
 *
 *  As #circle, but the outline is anti-aliased.
 */
VALUE rbgm_draw_aacircle(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE rgba)
{
  draw_circle(target,center,radius,rgba,1,0); /* aa, no fill */
  return target;
}
/* 
 *  call-seq:
 *    filled_circle(surface, center, radius, color)
 *
 *  As #circle, but the shape is solid, not an outline.
 */
VALUE rbgm_draw_fillcircle(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE rgba)
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

  /* get the starting and ending points of the line */
  if(RARRAY(center)->len < 2)
    rb_raise(rb_eArgError,"center point must be [x,y] form");
  if(RARRAY(radii)->len < 2)
    rb_raise(rb_eArgError,"radii must be [rad_x,rad_y] form");
  x = NUM2INT(rb_ary_entry(center,0));
  y = NUM2INT(rb_ary_entry(center,1));
  radx = NUM2INT(rb_ary_entry(radii,0));
  rady = NUM2INT(rb_ary_entry(radii,1));
  //printf("pts: [%d,%d], [%d,%d]\n",x1,y1,x2,y2);
  
  /* get the color of the line */
  if(RARRAY(rgba)->len < 3)
    rb_raise(rb_eArgError,"color must be [r,g,b] or [r,g,b,a] form");
  r = NUM2UINT(rb_ary_entry(rgba,0));
  g = NUM2UINT(rb_ary_entry(rgba,1));
  b = NUM2UINT(rb_ary_entry(rgba,2));
  //printf("color: [%d,%d,%d]\n",r,g,b);
  
  /* did we get alpha, or not? */
  if(RARRAY(rgba)->len > 3)
    a = NUM2UINT(rb_ary_entry(rgba,3));
  else
    a = 255;
  //printf("alpha: %d\n",a);

  Data_Get_Struct(target,SDL_Surface,dest);
  //printf("dest: %dx%d\n",dest->w,dest->h);

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
 *    ellipse(surface, center, radius, color)
 *
 *  Draw an empty ellipse (i.e. an oval) on a surface, given the 
 *  coordinates of its center and its horizontal and vertical radii.
 *  See also #aaellipse and #filled_ellipse.
 *
 *  This method takes these arguments:
 *  surface:: the target surface to draw on.
 *  center::  the coordinates of ellipse's center, in the form [x,y].
 *  radii::   the x and y radii (pixels), in the form [xr,yr].
 *  color::   the color of the shape, in the form [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_ellipse(VALUE module, VALUE target, VALUE center, VALUE radii, VALUE rgba)
{
  draw_ellipse(target,center,radii,rgba,0,0); /* no aa, no fill */
  return target;
}
/* 
 *  call-seq:
 *    aaellipse(surface, center, radius, color)
 *
 *  As #ellipse, but the ellipse border is anti-aliased.
 */
VALUE rbgm_draw_aaellipse(VALUE module, VALUE target, VALUE center, VALUE radii, VALUE rgba)
{
  draw_ellipse(target,center,radii,rgba,1,0); /* aa, no fill */
  return target;
}

/* 
 *  call-seq:
 *    filled_ellipse(surface, center, radius, color)
 *
 *  As #ellipse, but the shape is solid, not an outline.
 */
VALUE rbgm_draw_fillellipse(VALUE module, VALUE target, VALUE center, VALUE radii, VALUE rgba)
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

  /* get the starting and ending points of the line */
  if(RARRAY(center)->len < 2)
    rb_raise(rb_eArgError,"center point must be [x,y] form");
  if(RARRAY(angles)->len < 2)
    rb_raise(rb_eArgError,"angles must be [start,end] form");
  x = NUM2INT(rb_ary_entry(center,0));
  y = NUM2INT(rb_ary_entry(center,1));
  rad = NUM2INT(radius);
  start = NUM2INT(rb_ary_entry(angles,0));
  end = NUM2INT(rb_ary_entry(angles,1));
  //printf("pt: [%d,%d], %d, %d, %d\n",x,y,rad,start,end);
  
  /* get the color of the line */
  if(RARRAY(rgba)->len < 3)
    rb_raise(rb_eArgError,"color must be [r,g,b] or [r,g,b,a] form");
  r = NUM2UINT(rb_ary_entry(rgba,0));
  g = NUM2UINT(rb_ary_entry(rgba,1));
  b = NUM2UINT(rb_ary_entry(rgba,2));
  //printf("color: [%d,%d,%d]\n",r,g,b);
  
  /* did we get alpha, or not? */
  if(RARRAY(rgba)->len > 3)
    a = NUM2UINT(rb_ary_entry(rgba,3));
  else
    a = 255;
  //printf("alpha: %d\n",a);

  Data_Get_Struct(target,SDL_Surface,dest);
  //printf("dest: %dx%d\n",dest->w,dest->h);

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
 *    pie(surface, center, radius, angles, color)
 *
 *  Draw a non-filled pie shape (i.e. an arc), given the coordinates of its
 *  center and its radius, and its starting and ending angles. The shape is
 *  that of a circle with a "slice" removed, as if it were a pie. (Think
 *  P*cm*n.) See also #filled_pie.
 *
 *  This function can only be used if Rubygame was compiled with at least 
 *  version 2.0.11 of SDL_gfx. Otherwise, it will issue a warning and
 *  return nil. (#filled_pie does not require version 2.0.11).
 *
 *  This method takes these arguments:
 *  surface:: the target surface to draw on.
 *  center::  the coordinates of circle's center, in the form [x,y].
 *  radius::  the radius (pixels) of the circle.
 *  angles::  the start and end angles (in degrees) of the arc, in the form
 *            [start,end]. Angles are given *CLOCKWISE* from the positive x
 *            (remember that the positive Y direction is down, rather than up).
 *  color::   the color of the shape, in the form [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_pie(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE angles, VALUE rgba)
{
#ifdef HAVE_NONFILLEDPIE
  draw_pie(target,center,radius,angles,rgba,0); /* no fill */
  return target;
#else
  rb_warn("Drawing non-filled pies is not supported by your version of SDL_gfx (%d,%d,%d). Please upgrade to 2.0.11 or later.", SDL_GFXPRIMITIVES_MAJOR, SDL_GFXPRIMITIVES_MINOR, SDL_GFXPRIMITIVES_MICRO);  
  return Qnil;
#endif
}

/* 
 *  call-seq:
 *    filled_pie(surface, center, radius, angles, color)
 *
 *  As #pie, but the shape is solid, not an outline. (This method does not
 *  require SDL_gfx 2.0.11 as #pie does.)
 */
VALUE rbgm_draw_fillpie(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE angles, VALUE rgba)
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
  length = RARRAY(points)->len;
  x = alloca(sizeof (Sint16) * length);
  y = alloca(sizeof (Sint16) * length);

  for(loop=0;loop<length;loop++)
  {
    each_point = rb_ary_entry(points,loop);
    x[loop] = NUM2INT(rb_ary_entry(each_point,0));
    y[loop] = NUM2INT(rb_ary_entry(each_point,1));
  }
  //printf("pts: [%d,%d], [%d,%d]\n",x1,y1,x2,y2);
  
  /* get the color of the line */
  if(RARRAY(rgba)->len < 3)
    rb_raise(rb_eArgError,"color must be [r,g,b] or [r,g,b,a] form");
  r = NUM2UINT(rb_ary_entry(rgba,0));
  g = NUM2UINT(rb_ary_entry(rgba,1));
  b = NUM2UINT(rb_ary_entry(rgba,2));
  //printf("color: [%d,%d,%d]\n",r,g,b);
  
  /* did we get alpha, or not? */
  if(RARRAY(rgba)->len > 3)
    a = NUM2UINT(rb_ary_entry(rgba,3));
  else
    a = 255;
  //printf("alpha: %d\n",a);

  Data_Get_Struct(target,SDL_Surface,dest);
  //printf("dest: %dx%d\n",dest->w,dest->h);

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
 *    polygon(surface, points, color)
 *
 *  Draw an empty polygon, given the coordinates of its vertices, in the
 *  order that they are connected. This is essentially a series of connected
 *  dots.
 *
 *  This method takes these arguments:
 *  surface:: the target surface to draw on.
 *  points::  an Array containing the coordinate pairs for each vertex of the
 *            polygon, in the order that they are connected, e.g.
 *            <tt>[ [x1,y1], [x2,y2], ..., [xn,yn] ]</tt>. To draw a closed 
 *            shape, the final coordinate pair should match the first.
 *  color::   the color of the shape, in the form [r,g,b,a]. If alpha
 *            is omitted, it is drawn at full opacity.
 */
VALUE rbgm_draw_polygon(VALUE module, VALUE target, VALUE points, VALUE rgba)
{
  draw_polygon(target,points,rgba,0,0); /* no aa, no fill */
  return target;
}
/* 
 *  call-seq:
 *    aapolygon(surface, points, color)
 *
 *  As #polygon, but the lines are anti-aliased.
 */
VALUE rbgm_draw_aapolygon(VALUE module, VALUE target, VALUE points, VALUE rgba)
{
  draw_polygon(target,points,rgba,1,0); /* aa, no fill */
  return target;
}

/* 
 *  call-seq:
 *    filled_polygon(surface, points, color)
 *
 *  As #polygon, but the shape is solid, not an outline.
 */
VALUE rbgm_draw_fillpolygon(VALUE module, VALUE target, VALUE points, VALUE rgba)
{
  draw_polygon(target,points,rgba,0,1); /* no aa, fill */
  return target;
}

#endif /* HAVE_SDL_GFXPRIMITIVES_H */



/* 
 *  Document-module: Rubygame::Draw
 *
 *  The Draw module provides an interface to SDL_gfx's methods for drawing
 *  geometric primitives and other colored shapes onto Surfaces. Some methods
 *  require a specific version of SDL_gfx, most notably #filled_pie
 *
 *  The base methods (e.g. #circle), draw the outline of the shape, without
 *  any color inside of it.
 *
 *  Most shapes also have an anti-aliased version (e.g. #aacircle), which draws
 *  smooth outlines with no "jaggies" or "stairsteps". Please note that
 *  anti-aliased shapes take considerably longer to draw than aliased shapes.
 *
 *  Most shapes also have a filled version (e.g. #filled_circle), which draws
 *  a solid shape filled with color.
 *
 *  At this time, there are no methods to draw shapes which are both filled
 *  and anti-aliased. For some shapes, it may be possible to approximate this
 *  effect by drawing a filled shape, then an anti-aliased outline in the same
 *  position.
 */
void Rubygame_Init_Draw()
{
#if 0
	/* Pretend to define Rubygame module, so RDoc knows about it: */
	mRubygame = rb_define_module("Rubygame");
#endif

#ifdef HAVE_SDL_GFXPRIMITIVES_H

  rb_hash_aset(rb_ivar_get(mRubygame,rb_intern("VERSIONS")),
               ID2SYM(rb_intern("sdl_gfx")),
               rb_ary_new3(3,
                           INT2NUM(SDL_GFXPRIMITIVES_MAJOR),
                           INT2NUM(SDL_GFXPRIMITIVES_MINOR),
                           INT2NUM(SDL_GFXPRIMITIVES_MICRO)));

  /* Draw module */
  mDraw = rb_define_module_under(mRubygame,"Draw");

  rb_define_module_function(mDraw,"line",rbgm_draw_line,4);
  rb_define_module_function(mDraw,"aaline",rbgm_draw_aaline,4);
  rb_define_module_function(mDraw,"box",rbgm_draw_rect,4);
  rb_define_module_function(mDraw,"filled_box",rbgm_draw_fillrect,4);
  rb_define_module_function(mDraw,"circle",rbgm_draw_circle,4);
  rb_define_module_function(mDraw,"aacircle",rbgm_draw_aacircle,4);
  rb_define_module_function(mDraw,"filled_circle",rbgm_draw_fillcircle,4);
  rb_define_module_function(mDraw,"ellipse",rbgm_draw_ellipse,4);
  rb_define_module_function(mDraw,"aaellipse",rbgm_draw_aaellipse,4);
  rb_define_module_function(mDraw,"filled_ellipse",rbgm_draw_fillellipse,4);
  rb_define_module_function(mDraw,"pie",rbgm_draw_pie,5);
  rb_define_module_function(mDraw,"filled_pie",rbgm_draw_fillpie,5);
  rb_define_module_function(mDraw,"polygon",rbgm_draw_polygon,3);
  rb_define_module_function(mDraw,"aapolygon",rbgm_draw_aapolygon,3);
  rb_define_module_function(mDraw,"filled_polygon",rbgm_draw_fillpolygon,3);

#endif

}
