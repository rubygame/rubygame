// require 'ruby/numeric'; seg = Segment.new(Ftor[1,1], Ftor[2,2]); seg.rotate(90.to_radian, Ftor[2,2])
#include <ruby.h>
#include <math.h>
#include "rubygame_defines.h"
#include "rubygame_cFtor.h"
#include "rubygame_cSegment.h"

static VALUE mRubygame;
static VALUE mBody;

static VALUE rg_cFtor;
static VALUE rg_cSegment;
static VALUE rg_cRect;
static VALUE rg_cCircle;

void rg_segment_move(rg_segment *seg, rg_ftor *ftor)
{
	rg_ftor_add(&seg->start, &seg->start, ftor);
}

void rg_segment_rotate_around(rg_segment *seg, rg_ftor *center, double rad)
{
	rg_ftor_rotated_around(&seg->start, &seg->start, center, rad);
	rg_ftor_rotated_by(&seg->vec, &seg->vec, rad);
}


/***  RUBY method wrappers  ***************************************************/
static VALUE rg_segment_rb_singleton_new(int argc, VALUE *argv, VALUE class)
{
	rg_segment *seg;
	VALUE      rb_seg;
	rb_seg = Data_Make_Struct(class, rg_segment, NULL, free, seg);
	rb_obj_call_init(rb_seg, argc, argv);
	return rb_seg;
}

static VALUE rg_segment_rb_singleton_points(VALUE class, VALUE bx, VALUE by, VALUE ex, VALUE ey)
{
	rg_segment *seg;
	VALUE      rb_seg;
	rb_seg = Data_Make_Struct(class, rg_segment, NULL, free, seg);
	seg->start.x = NUM2DBL(bx);
	seg->start.y = NUM2DBL(by);
	seg->vec.x   = NUM2DBL(ex)-seg->start.x;
	seg->vec.y   = NUM2DBL(ey)-seg->start.y;

	return rb_seg;
}

static VALUE rg_segment_rb_initialize(VALUE self, VALUE start, VALUE vec)
{
	rg_segment *seg;
	rg_ftor    *c_start, *c_vec;
	Data_Get_Struct(self, rg_segment, seg);
	Data_Get_Struct(start, rg_ftor, c_start);
	Data_Get_Struct(vec, rg_ftor, c_vec);
	seg->start = *c_start;
	seg->vec   = *c_vec;
	return self;
}

static VALUE rg_segment_rb_begin(VALUE self)
{
	rg_segment *seg;
	rg_ftor    *ftor;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	ftor->x = seg->start.x;
	ftor->y = seg->start.y;
	return rb_ftor;
}

static VALUE rg_segment_rb_center(VALUE self)
{
	rg_segment *seg;
	rg_ftor    *ftor;
	rg_ftor    half;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	rg_ftor_resized_by(&half, &seg->vec, 0.5);
	rg_ftor_add(ftor, &seg->start, &half);
	return rb_ftor;
}

static VALUE rg_segment_rb_end(VALUE self)
{
	rg_segment *seg;
	rg_ftor    *ftor;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	rg_ftor_add(ftor, &seg->start, &seg->vec);
	return rb_ftor;
}

static VALUE rg_segment_rb_vec(VALUE self)
{
	rg_segment *seg;
	rg_ftor    *ftor;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);
	ftor->x = seg->vec.x;
	ftor->y = seg->vec.y;
	return rb_ftor;
}

static VALUE rg_segment_rb_length(VALUE self)
{
	rg_segment *seg;
	Data_Get_Struct(self, rg_segment, seg);
	return rb_float_new(rg_ftor_magnitude(&seg->vec));
}

static VALUE rg_segment_rb_angle(VALUE self)
{
	rg_segment *seg;
	Data_Get_Struct(self, rg_segment, seg);
	return rb_float_new(rg_ftor_angle(&seg->vec));
}

static VALUE rg_segment_rb_move(VALUE self, VALUE by)
{
	rg_segment *seg;
	rg_ftor    *vec;
	Data_Get_Struct(self, rg_segment, seg);
	Data_Get_Struct(by, rg_ftor, vec);
	rg_segment_move(seg, vec);
	return self;
}

static VALUE rg_segment_rb_rotate(VALUE self, VALUE rad, VALUE center)
{
	rg_segment *seg;
	rg_ftor    *c_center;
	Data_Get_Struct(self, rg_segment, seg);
	Data_Get_Struct(center, rg_ftor, c_center);
	rg_segment_rotate_around(seg, c_center, NUM2DBL(rad));
	return self;
}

static VALUE rg_segment_rb_inspect(VALUE self)
{
	rg_segment *seg;
	rg_ftor    end, vec;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE str;
	char buf[255];
	rg_ftor_add(&end, &seg->start, &seg->vec);
	vec = seg->vec;
	
	sprintf(buf, "#<%s:0x%lx %.2f, %.2f - %.2f, %.2f (|%.2f| %.1f°)>",
		rb_obj_classname(self),
		self,
		seg->start.x,
		seg->start.y,
		end.x,
		end.y,
		rg_ftor_magnitude(&vec),
		rg_ftor_angle_deg(&vec)
	);
	str  = rb_str_new2(buf);
	return str;
}

void Init_rg_cSegment()
{
	mRubygame = rb_define_module("Rubygame");
	mBody     = rb_define_module_under(mRubygame, "Body");

	rg_cCircle  = rb_define_class_under(mBody, "Circle", rb_cObject);
	rg_cRect    = rb_define_class_under(mBody, "Rect", rb_cObject);
	rg_cSegment = rb_define_class_under(mBody, "Segment", rb_cObject);
	rg_cFtor    = rb_define_class_under(mBody, "Ftor", rb_cObject);

	rb_define_singleton_method(rg_cSegment, "new",    rg_segment_rb_singleton_new, -1);
	rb_define_singleton_method(rg_cSegment, "points", rg_segment_rb_singleton_points, 4);

	rb_define_method(rg_cSegment, "initialize",    rg_segment_rb_initialize, 2);
	rb_define_method(rg_cSegment, "begin",         rg_segment_rb_begin, 0);
	rb_define_method(rg_cSegment, "center",        rg_segment_rb_center, 0);
	rb_define_method(rg_cSegment, "end",           rg_segment_rb_end, 0);
	rb_define_method(rg_cSegment, "vector",        rg_segment_rb_vec, 0);
	rb_define_method(rg_cSegment, "length",        rg_segment_rb_length, 0);
	rb_define_method(rg_cSegment, "angle",         rg_segment_rb_angle, 0);
	rb_define_method(rg_cSegment, "move",          rg_segment_rb_move, 1);
	rb_define_method(rg_cSegment, "rotate",        rg_segment_rb_rotate, 2);
	rb_define_method(rg_cSegment, "inspect",       rg_segment_rb_inspect, 0);
}
