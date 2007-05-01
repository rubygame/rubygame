// require 'ruby/numeric'; seg = Segment.new(Ftor[1,1], Ftor[2,2]); seg.rotate(90.to_radian, Ftor[2,2])
#include <ruby.h>
#include <math.h>
#include "rubygame_defines.h"
#include "rubygame_cFtor.h"
#include "rubygame_cSegment.h"
#include "rubygame_cRect.h"

static VALUE mRubygame;
static VALUE mBody;

static VALUE rg_cFtor;
static VALUE rg_cSegment;
static VALUE rg_cRect;
static VALUE rg_cCircle;

void rg_rect_top(rg_segment *seg, rg_rect *rect)
{
	seg->start = rect->topleft;
	seg->vec   = rect->horizontal;
}
void rg_rect_right(rg_segment *seg, rg_rect *rect)
{
	rg_ftor_add(&seg->start, &rect->topleft, &rect->horizontal);
	seg->vec = rect->vertical;
}
void rg_rect_bottom(rg_segment *seg, rg_rect *rect)
{
	rg_ftor_add(&seg->start, &rect->topleft, &rect->vertical);
	seg->vec   = rect->horizontal;
}
void rg_rect_left(rg_segment *seg, rg_rect *rect)
{
	seg->start = rect->topleft;
	seg->vec   = rect->vertical;
}

void rg_rect_top_mid(rg_ftor *ftor, rg_rect *rect)
{
	rg_ftor_resized_by(ftor, &rect->horizontal, 0.5);
	rg_ftor_add(ftor, &rect->topleft, ftor);
}

void rg_rect_top_right(rg_ftor *ftor, rg_rect *rect)
{
	rg_ftor_add(ftor, &rect->topleft, &rect->horizontal);
}

void rg_rect_mid_right(rg_ftor *ftor, rg_rect *rect)
{
	rg_ftor_resized_by(ftor, &rect->vertical, 0.5);
	rg_ftor_add(ftor, &rect->topleft, ftor);
	rg_ftor_add(ftor, &rect->horizontal, ftor);
}

void rg_rect_bottom_right(rg_ftor *ftor, rg_rect *rect)
{
	rg_ftor_add(ftor, &rect->topleft, &rect->horizontal);
	rg_ftor_add(ftor, ftor, &rect->vertical);
}

void rg_rect_bottom_mid(rg_ftor *ftor, rg_rect *rect)
{
	rg_ftor_resized_by(ftor, &rect->horizontal, 0.5);
	rg_ftor_add(ftor, &rect->topleft, ftor);
	rg_ftor_add(ftor, &rect->vertical, ftor);
}

void rg_rect_bottom_left(rg_ftor *ftor, rg_rect *rect)
{
	rg_ftor_add(ftor, &rect->topleft, &rect->vertical);
}

void rg_rect_mid_left(rg_ftor *ftor, rg_rect *rect)
{
	rg_ftor_resized_by(ftor, &rect->vertical, 0.5);
	rg_ftor_add(ftor, &rect->topleft, ftor);
}

void rg_rect_center(rg_ftor *ftor, rg_rect *rect)
{
	rg_ftor_add(ftor, &rect->horizontal, &rect->vertical);
	rg_ftor_resized_by(ftor, ftor, 0.5);
	rg_ftor_add(ftor, &rect->topleft, ftor);
}

void rg_rect_move(rg_rect *rect, rg_ftor *ftor)
{
	rg_ftor_add(&rect->topleft, &rect->topleft, ftor);
}

void rg_rect_rotate_around(rg_rect *rect, rg_ftor *center, double rad)
{
	rg_ftor_rotated_around(&rect->topleft, &rect->topleft, center, rad);
	rg_ftor_rotated_by(&rect->horizontal, &rect->horizontal, rad);
	rg_ftor_rotated_by(&rect->vertical, &rect->vertical, rad);
}



/***  RUBY method wrappers  ***************************************************/

/*
 * :nodoc:
 */
static VALUE rg_rect_rb_singleton_alloc(VALUE class)
{
	rg_rect *rect;
	VALUE rb_rect = Data_Make_Struct(class, rg_rect, NULL, free, rect);
	rect->topleft.x    = 0;
	rect->topleft.y    = 0;
	rect->horizontal.x = 0;
	rect->horizontal.y = 0;
	rect->vertical.x   = 0;
	rect->vertical.y   = 0;
	return rb_rect;
}

/* 
 *  call-seq:
 *    Rect.rect(x,y,width,height)
 *
 *  Creates a rect with top left of 'x' and 'y' with width and height 'width' and 'height'.
 *  Also see Rect.new.
 */
static VALUE rg_rect_rb_singleton_rect(VALUE class, VALUE x, VALUE y, VALUE w, VALUE h)
{
	rg_rect *rect;
	VALUE rb_rect = Data_Make_Struct(class, rg_rect, NULL, free, rect);

	double c_x = NUM2DBL(x);
	double c_y = NUM2DBL(y);
	double c_w = NUM2DBL(w);
	double c_h = NUM2DBL(h);

	rg_ftor topleft    = { c_x, c_y };
	rg_ftor horizontal = { c_w, 0 };
	rg_ftor vertical   = { 0, c_h };
	
	rect->topleft    = topleft;
	rect->horizontal = horizontal;
	rect->vertical   = vertical;

	return rb_rect;
}

/* 
 *  call-seq:
 *    initialize(Ftor topleft, Ftor horizontal, Ftor vertical)
 *
 *  FIXME
 *  Also see Rect.rect.
 */
static VALUE rg_rect_rb_initialize(VALUE self, VALUE topleft, VALUE horizontal, VALUE vertical)
{
	rg_rect *rect;
	rg_ftor *c_topleft, *c_horizontal, *c_vertical;
	Data_Get_Struct(self, rg_rect, rect);
	Data_Get_Struct(topleft,    rg_ftor, c_topleft);
	Data_Get_Struct(horizontal, rg_ftor, c_horizontal);
	Data_Get_Struct(vertical,   rg_ftor, c_vertical);
	rect->topleft    = *c_topleft;
	rect->horizontal = *c_horizontal;
	rect->vertical   = *c_vertical;
	return self;
}

/* 
 *  :nodoc:
 */
static VALUE rg_rect_rb_initialize_copy(VALUE self, VALUE old)
{
	rg_rect *rect1, *rect2;
	Data_Get_Struct(self, rg_rect, rect1);
	Data_Get_Struct(old, rg_rect, rect2);

	*rect1 = *rect2;
	
	return self;
}

/* 
 *  call-seq:
 *    left -> Segment
 *
 *  Returns a Segment from top left to top right of the Rect.
 */
static VALUE rg_rect_rb_top(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_segment *seg;
	VALUE rb_seg = Data_Make_Struct(rg_cSegment, rg_segment, NULL, free, seg);
	
	rg_rect_top(seg, rect);

	return rb_seg;
}

/* 
 *  call-seq:
 *    left -> Segment
 *
 *  Returns a Segment from top right to bottom right of the Rect.
 */
static VALUE rg_rect_rb_right(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_segment *seg;
	VALUE rb_seg = Data_Make_Struct(rg_cSegment, rg_segment, NULL, free, seg);
	
	rg_rect_right(seg, rect);

	return rb_seg;
}

/* 
 *  call-seq:
 *    left -> Segment
 *
 *  Returns a Segment from bottom left to bottom right of the Rect.
 */
static VALUE rg_rect_rb_bottom(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_segment *seg;
	VALUE rb_seg = Data_Make_Struct(rg_cSegment, rg_segment, NULL, free, seg);
	
	rg_rect_bottom(seg, rect);

	return rb_seg;
}

/* 
 *  call-seq:
 *    left -> Segment
 *
 *  Returns a Segment from top left to bottom left of the Rect.
 */
static VALUE rg_rect_rb_left(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_segment *seg;
	VALUE rb_seg = Data_Make_Struct(rg_cSegment, rg_segment, NULL, free, seg);
	
	rg_rect_left(seg, rect);

	return rb_seg;
}

/* 
 *  call-seq:
 *    top_left -> Ftor
 *
 *  Returns an Ftor pointing to the top left corner of the Rect.
 */
static VALUE rg_rect_rb_top_left(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	*ftor = rect->topleft;

	return rb_ftor;
}

/* 
 *  call-seq:
 *    top_mid -> Ftor
 *
 *  Returns an Ftor pointing to the middle of the top Segment.
 */
static VALUE rg_rect_rb_top_mid(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_top_mid(ftor, rect);

	return rb_ftor;
}

/* 
 *  call-seq:
 *    top_right -> Ftor
 *
 *  Returns an Ftor pointing to the top right corner of the Rect.
 */
static VALUE rg_rect_rb_top_right(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_top_right(ftor, rect);

	return rb_ftor;
}

/* 
 *  call-seq:
 *    mid_right -> Ftor
 *
 *  Returns an Ftor pointing to the middle of the right Segment.
 */
static VALUE rg_rect_rb_mid_right(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_mid_right(ftor, rect);

	return rb_ftor;
}

/* 
 *  call-seq:
 *    bottom_right -> Ftor
 *
 *  Returns an Ftor pointing to the bottom right corner of the Rect.
 */
static VALUE rg_rect_rb_bottom_right(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_bottom_right(ftor, rect);

	return rb_ftor;
}

/* 
 *  call-seq:
 *    bottom_mid -> Ftor
 *
 *  Returns an Ftor pointing to the middle of the bottom Segment.
 */
static VALUE rg_rect_rb_bottom_mid(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_bottom_mid(ftor, rect);

	return rb_ftor;
}

/* 
 *  call-seq:
 *    bottom_left -> Ftor
 *
 *  Returns an Ftor pointing to the bottom left corner of the Rect.
 */
static VALUE rg_rect_rb_bottom_left(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_bottom_left(ftor, rect);

	return rb_ftor;
}

/* 
 *  call-seq:
 *    mid_left -> Ftor
 *
 *  Returns an Ftor pointing to the middle of the left Segment.
 */
static VALUE rg_rect_rb_mid_left(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_mid_left(ftor, rect);

	return rb_ftor;
}

/* 
 *  call-seq:
 *    center -> Ftor
 *
 *  Returns an Ftor pointing to the center of the Rect.
 */
static VALUE rg_rect_rb_center(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_center(ftor, rect);

	return rb_ftor;
}

/* 
 *  call-seq:
 *    angle -> Float
 *
 *  Returns the angle (measured at the top Segment) in radians.
 */
static VALUE rg_rect_rb_angle(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);
	return rb_float_new(rg_ftor_angle(&rect->horizontal));
}

/* 
 *  call-seq:
 *    move(by) -> self
 *
 *  Moves the Rect by an Ftor 'by'.
 */
static VALUE rg_rect_rb_move(VALUE self, VALUE by)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *vec;
	Data_Get_Struct(by, rg_ftor, vec);

	rg_rect_move(rect, vec);

	return self;
}

/* 
 *  call-seq:
 *    rotate(radians, around) -> self
 *
 *  Rotates the rect around the position 'around' which must be given as an
 *  Ftor, by an angle of 'radians' which must be given in radians.
 */
static VALUE rg_rect_rb_rotate(VALUE self, VALUE rad, VALUE center)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor    *c_center;
	Data_Get_Struct(center, rg_ftor, c_center);

	rg_rect_rotate_around(rect, c_center, NUM2DBL(rad));

	return self;
}

/* 
 *  call-seq:
 *    inspect -> String
 *
 *  Displays the four corners of the rect and in parens the width and height.
 */
static VALUE rg_rect_rb_inspect(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);
	VALUE str;
	char buf[255];

	rg_ftor  topright, bottomright, bottomleft;
	rg_rect_top_right(&topright, rect);
	rg_rect_bottom_right(&bottomright, rect);
	rg_rect_bottom_left(&bottomleft, rect);
	
	sprintf(buf, "#<%s:0x%lx %.2f, %.2f / %.2f, %.2f / %.2f, %.2f / %.2f, %.2f (%.2fx%.2f)>",
		rb_obj_classname(self),
		self,
		rect->topleft.x,
		rect->topleft.y,
		topright.x,
		topright.y,
		bottomright.x,
		bottomright.y,
		bottomleft.x,
		bottomleft.y,
		rg_ftor_magnitude(&rect->horizontal),
		rg_ftor_magnitude(&rect->vertical)
	);
	str  = rb_str_new2(buf);
	return str;
}

/*
 * Document-class: Rubygame::Body::Rect
 *
 *  Rect is a class to represent bodies of rectangular shape.
 *  Bodies are only used for collision and positioning.
 */
void Init_rg_cRect()
{
	mRubygame = rb_define_module("Rubygame");
	mBody     = rb_define_module_under(mRubygame, "Body");

	rg_cCircle  = rb_define_class_under(mBody, "Circle", rb_cObject);
	rg_cRect    = rb_define_class_under(mBody, "Rect", rb_cObject);
	rg_cSegment = rb_define_class_under(mBody, "Segment", rb_cObject);
	rg_cFtor    = rb_define_class_under(mBody, "Ftor", rb_cObject);

	rb_define_alloc_func(rg_cRect, rg_rect_rb_singleton_alloc);

	rb_define_singleton_method(rg_cRect, "rect",   rg_rect_rb_singleton_rect, 4);

	rb_define_method(rg_cRect, "initialize",      rg_rect_rb_initialize, 3);
	rb_define_method(rg_cRect, "initialize_copy", rg_rect_rb_initialize_copy, 1);
	rb_define_method(rg_cRect, "top",             rg_rect_rb_top, 0);
	rb_define_method(rg_cRect, "right",           rg_rect_rb_right, 0);
	rb_define_method(rg_cRect, "bottom",          rg_rect_rb_bottom, 0);
	rb_define_method(rg_cRect, "left",            rg_rect_rb_left, 0);
	rb_define_method(rg_cRect, "top_left",        rg_rect_rb_top_left, 0);
	rb_define_method(rg_cRect, "top_mid",         rg_rect_rb_top_mid, 0);
	rb_define_method(rg_cRect, "top_right",       rg_rect_rb_top_right, 0);
	rb_define_method(rg_cRect, "mid_right",       rg_rect_rb_mid_right, 0);
	rb_define_method(rg_cRect, "bottom_right",    rg_rect_rb_bottom_right, 0);
	rb_define_method(rg_cRect, "bottom_mid",      rg_rect_rb_bottom_mid, 0);
	rb_define_method(rg_cRect, "bottom_left",     rg_rect_rb_bottom_left, 0);
	rb_define_method(rg_cRect, "mid_left",        rg_rect_rb_mid_left, 0);
	rb_define_method(rg_cRect, "center",          rg_rect_rb_center, 0);
	rb_define_method(rg_cRect, "angle",           rg_rect_rb_angle, 0);
	rb_define_method(rg_cRect, "move",            rg_rect_rb_move, 1);
	rb_define_method(rg_cRect, "rotate",          rg_rect_rb_rotate, 2);
	rb_define_method(rg_cRect, "inspect",         rg_rect_rb_inspect, 0);
}
