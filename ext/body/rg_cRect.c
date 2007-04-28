// require 'ruby/numeric'; seg = Segment.new(Ftor[1,1], Ftor[2,2]); seg.rotate(90.to_radian, Ftor[2,2])
#include <ruby.h>
#include <math.h>
#include "rg_cFtor.h"
#include "rg_cSegment.h"
#include "rg_cRect.h"
#include "defines.h"

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
	rg_ftor_negate(&seg->vec, &rect->vertical);
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
static VALUE rg_rect_rb_singleton_new(int argc, VALUE *argv, VALUE class)
{
	rg_rect *rect;
	VALUE rb_rect = Data_Make_Struct(class, rg_rect, NULL, free, rect);
	rb_obj_call_init(rb_rect, argc, argv);
	return rb_rect;
}

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

static VALUE rg_rect_rb_top_left(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	*ftor = rect->topleft;

	return rb_ftor;
}

static VALUE rg_rect_rb_top_mid(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_top_mid(ftor, rect);

	return rb_ftor;
}

static VALUE rg_rect_rb_top_right(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_top_right(ftor, rect);

	return rb_ftor;
}

static VALUE rg_rect_rb_mid_right(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_mid_right(ftor, rect);

	return rb_ftor;
}

static VALUE rg_rect_rb_bottom_right(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_bottom_right(ftor, rect);

	return rb_ftor;
}

static VALUE rg_rect_rb_bottom_mid(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_bottom_mid(ftor, rect);

	return rb_ftor;
}

static VALUE rg_rect_rb_bottom_left(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_bottom_left(ftor, rect);

	return rb_ftor;
}

static VALUE rg_rect_rb_mid_left(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_mid_left(ftor, rect);

	return rb_ftor;
}

static VALUE rg_rect_rb_center(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	
	rg_rect_center(ftor, rect);

	return rb_ftor;
}

static VALUE rg_rect_rb_angle(VALUE self)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);
	return rb_float_new(rg_ftor_angle(&rect->horizontal));
}

static VALUE rg_rect_rb_move(VALUE self, VALUE by)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor *vec;
	Data_Get_Struct(by, rg_ftor, vec);

	rg_rect_move(rect, vec);

	return self;
}

static VALUE rg_rect_rb_rotate(VALUE self, VALUE rad, VALUE center)
{
	rg_rect *rect;
	Data_Get_Struct(self, rg_rect, rect);

	rg_ftor    *c_center;
	Data_Get_Struct(center, rg_ftor, c_center);

	rg_rect_rotate_around(rect, c_center, NUM2DBL(rad));

	return self;
}

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

void Init_rg_cRect()
{
	mRubygame = rb_define_module("Rubygame");
	mBody     = rb_define_module_under(mRubygame, "Body");

	rg_cCircle  = rb_define_class_under(mBody, "Circle", rb_cObject);
	rg_cRect    = rb_define_class_under(mBody, "Rect", rb_cObject);
	rg_cSegment = rb_define_class_under(mBody, "Segment", rb_cObject);
	rg_cFtor    = rb_define_class_under(mBody, "Ftor", rb_cObject);

	rb_define_singleton_method(rg_cRect, "new",    rg_rect_rb_singleton_new, -1);
	rb_define_singleton_method(rg_cRect, "rect",   rg_rect_rb_singleton_rect, 4);

	rb_define_method(rg_cRect, "initialize",    rg_rect_rb_initialize, 3);
	rb_define_method(rg_cRect, "top_left",      rg_rect_rb_top_left, 0);
	rb_define_method(rg_cRect, "top_mid",       rg_rect_rb_top_mid, 0);
	rb_define_method(rg_cRect, "top_right",     rg_rect_rb_top_right, 0);
	rb_define_method(rg_cRect, "mid_right",     rg_rect_rb_mid_right, 0);
	rb_define_method(rg_cRect, "bottom_right",  rg_rect_rb_bottom_right, 0);
	rb_define_method(rg_cRect, "bottom_mid",    rg_rect_rb_bottom_mid, 0);
	rb_define_method(rg_cRect, "bottom_left",   rg_rect_rb_bottom_left, 0);
	rb_define_method(rg_cRect, "mid_left",      rg_rect_rb_mid_left, 0);
	rb_define_method(rg_cRect, "center",        rg_rect_rb_center, 0);
	rb_define_method(rg_cRect, "angle",         rg_rect_rb_angle, 0);
	rb_define_method(rg_cRect, "move",          rg_rect_rb_move, 1);
	rb_define_method(rg_cRect, "rotate",        rg_rect_rb_rotate, 2);
	rb_define_method(rg_cRect, "inspect",       rg_rect_rb_inspect, 0);
}
