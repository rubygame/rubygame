/*
	Rubygame -- Ruby code and bindings to SDL/OpenAL to facilitate game creation
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
#ifdef HAVE_SDL_GFX
#include <SDL_gfxPrimitives.h>

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

VALUE rbgm_draw_line(VALUE module, VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
	draw_line(target,pt1,pt2,rgba,0); /* no anti-aliasing */
	return target;
}

VALUE rbgm_draw_aaline(VALUE module, VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
	draw_line(target,pt1,pt2,rgba,1); /* anti-aliasing */
	return target;
}

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

VALUE rbgm_draw_rect(VALUE module, VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
	draw_rect(target,pt1,pt2,rgba,0); /* no fill */
	return target;
}

VALUE rbgm_draw_fillrect(VALUE module, VALUE target, VALUE pt1, VALUE pt2, VALUE rgba)
{
	draw_rect(target,pt1,pt2,rgba,1); /* fill */
	return target;
}

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

VALUE rbgm_draw_circle(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE rgba)
{
	draw_circle(target,center,radius,rgba,0,0); /* no aa, no fill */
	return target;
}

VALUE rbgm_draw_aacircle(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE rgba)
{
	draw_circle(target,center,radius,rgba,1,0); /* aa, no fill */
	return target;
}

VALUE rbgm_draw_fillcircle(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE rgba)
{
	draw_circle(target,center,radius,rgba,0,1); /* no aa, fill */
	return target;
}

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

VALUE rbgm_draw_ellipse(VALUE module, VALUE target, VALUE center, VALUE radii, VALUE rgba)
{
	draw_ellipse(target,center,radii,rgba,0,0); /* no aa, no fill */
	return target;
}

VALUE rbgm_draw_aaellipse(VALUE module, VALUE target, VALUE center, VALUE radii, VALUE rgba)
{
	draw_ellipse(target,center,radii,rgba,1,0); /* aa, no fill */
	return target;
}

VALUE rbgm_draw_fillellipse(VALUE module, VALUE target, VALUE center, VALUE radii, VALUE rgba)
{
	draw_ellipse(target,center,radii,rgba,0,1); /* no aa, fill */
	return target;
}

/* This is wrapped by rbgm_draw_(|aa|fill)ellipse */
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
#if (SDL_GFXPRIMITIVES_MAJOR >= 2 && SDL_GFXPRIMITIVES_MINOR >= 0 && SDL_GFXPRIMITIVES_MICRO >= 12)
		filledPieRGBA(dest,x,y,rad,start,end,r,g,b,a);
#else
		/* until sdl-gfx 2.0.12, it used to be: */
		filledpieRGBA(dest,x,y,rad,start,end,r,g,b,a);
#endif
	}
	else
	{
		//printf("pie\n");
#if (SDL_GFXPRIMITIVES_MAJOR >= 2 && SDL_GFXPRIMITIVES_MINOR >= 0 && SDL_GFXPRIMITIVES_MICRO >= 11)
		/* this function did not exist until sdl-gfx 2.0.11 */
		pieRGBA(dest,x,y,rad,start,end,r,g,b,a);
#else
		rb_warn("Drawing non-filled pies is not supported by your version of SDL_gfx (%d,%d,%d). Please upgrade to 2.0.11 or later.", SDL_GFXPRIMITIVES_MAJOR, SDL_GFXPRIMITIVES_MINOR, SDL_GFXPRIMITIVES_MICRO);
#endif
	}
	return;
}

#if 0
VALUE rbgm_draw_pie(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE angles, VALUE rgba)
{
	draw_pie(target,center,radius,angles,rgba,0); /* no fill */
	return target;
}
#endif

VALUE rbgm_draw_fillpie(VALUE module, VALUE target, VALUE center, VALUE radius, VALUE angles, VALUE rgba)
{
	draw_pie(target,center,radius,angles,rgba,1); /* fill */
	return target;
}

/* This is wrapped by rbgm_draw_(|aa|fill)polygon */
void draw_polygon(VALUE target, VALUE points, VALUE rgba, int aa, int fill)
{
	SDL_Surface *dest;
	VALUE each_point;
	int length,loop;
	Uint8 r,g,b,a;

	/* separate points into arrays of x and y values */
	length = RARRAY(points)->len;
	Sint16 x[ length ], y[ length ];

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

VALUE rbgm_draw_polygon(VALUE module, VALUE target, VALUE points, VALUE rgba)
{
	draw_polygon(target,points,rgba,0,0); /* no aa, no fill */
	return target;
}

VALUE rbgm_draw_aapolygon(VALUE module, VALUE target, VALUE points, VALUE rgba)
{
	draw_polygon(target,points,rgba,1,0); /* aa, no fill */
	return target;
}

VALUE rbgm_draw_fillpolygon(VALUE module, VALUE target, VALUE points, VALUE rgba)
{
	draw_polygon(target,points,rgba,0,1); /* no aa, fill */
	return target;
}


void Rubygame_Init_Draw()
{
	/* Draw module */
	mDraw = rb_define_module_under(mRubygame,"Draw");
	/* Draw functions */
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

	rb_define_module_function(mDraw,"polygon",rbgm_draw_polygon,3);
	rb_define_module_function(mDraw,"aapolygon",rbgm_draw_aapolygon,3);
	rb_define_module_function(mDraw,"filled_polygon",rbgm_draw_fillpolygon,3);
	//rb_define_module_function(mDraw,"pie",rbgm_draw_pie,5);
	rb_define_module_function(mDraw,"filled_pie",rbgm_draw_fillpie,5);

}
#else /* ndef HAVE_SDL_GFX */
/*
If SDL_gfx is not installed, module still exists, but
all functions are dummy functions which raise StandardError
*/

VALUE rbgm_draw_notloaded(int argc, VALUE *argv, VALUE classmod)
{
	rb_raise(rb_eStandardError,"Transform module could not be loaded: SDL_gfx is missing. Install SDL_gfx and recompile Rubygame.");
	return Qnil;
}

void Rubygame_Init_Draw()
{
	/* Draw module */
	mDraw = rb_define_module_under(mRubygame,"Draw");
	/* Draw functions */
	rb_define_module_function(mDraw,"line",rbgm_draw_notloaded,4);
	rb_define_module_function(mDraw,"aaline",rbgm_draw_notloaded,4);
	rb_define_module_function(mDraw,"box",rbgm_draw_notloaded,4);
	rb_define_module_function(mDraw,"filled_box",rbgm_draw_notloaded,4);
	rb_define_module_function(mDraw,"circle",rbgm_draw_notloaded,4);
	rb_define_module_function(mDraw,"aacircle",rbgm_draw_notloaded,4);
	rb_define_module_function(mDraw,"filled_circle",rbgm_draw_notloaded,4);
	rb_define_module_function(mDraw,"ellipse",rbgm_draw_notloaded,4);
	rb_define_module_function(mDraw,"aaellipse",rbgm_draw_notloaded,4);
	rb_define_module_function(mDraw,"filled_ellipse",rbgm_draw_notloaded,4);

	rb_define_module_function(mDraw,"polygon",rbgm_draw_notloaded,3);
	rb_define_module_function(mDraw,"aapolygon",rbgm_draw_notloaded,3);
	rb_define_module_function(mDraw,"filled_polygon",rbgm_draw_notloaded,3);
	//rb_define_module_function(mDraw,"pie",rbgm_draw_notloaded,5);
	rb_define_module_function(mDraw,"filled_pie",rbgm_draw_notloaded,5);

}
#endif /* HAVE_SDL_GFX */
