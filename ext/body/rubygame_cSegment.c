// require 'ruby/numeric'; seg = Segment.new(Vector2[1,1], Vector2[2,2]); seg.rotate_around(90.to_radian, Vector2[2,2])
#include <ruby.h>
#include <math.h>
#include "rubygame_defines.h"
#include "rubygame_cVector2.h"
#include "rubygame_cSegment.h"
#include "collision_math.h"

VALUE cSegment;

void rg_segment_move(rg_segment *result, rg_segment *seg, rg_vector2 *vector2)
{
	rg_vector2_add(&result->start, &seg->start, vector2);
}

void rg_segment_rotate_around(rg_segment *result, rg_segment *seg, rg_vector2 *center, double rad)
{
	rg_vector2_rotate_around(&result->start, &seg->start, center, rad);
	rg_vector2_rotate(&result->vec, &seg->vec, rad);
}


/***  RUBY method wrappers  ***************************************************/


/* 
 *  :nodoc:
 */
static VALUE rg_segment_rb_singleton_alloc(VALUE class)
{
	rg_segment *seg;
	VALUE      rb_seg;
	rb_seg = Data_Make_Struct(class, rg_segment, NULL, free, seg);
	seg->start.x = 0;
	seg->start.y = 0;
	seg->vec.x   = 0;
	seg->vec.y   = 0;
	return rb_seg;
}

/* 
 *  call-seq:
 *    Segment.new(Vector2 begin, Vector2 vector) -> Segment
 *
 *  Create a Segment from it's begin and the vector needed to add to get to the end.
 */
static VALUE rg_segment_rb_singleton_new(int argc, VALUE *argv, VALUE class)
{
	rg_segment *seg;
	VALUE      rb_seg;
	rb_seg = Data_Make_Struct(class, rg_segment, NULL, free, seg);
	rb_obj_call_init(rb_seg, argc, argv);
	return rb_seg;
}

/* 
 *  call-seq:
 *    Segment.points(x1,y1, x2,y2) -> Segment
 *
 *  Create a Segment from it's begins and ends components.
 */
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

/* 
 *  :nodoc:
 */
static VALUE rg_segment_rb_initialize(VALUE self, VALUE start, VALUE vec)
{
	rg_segment *seg;
	rg_vector2    *c_start, *c_vec;
	Data_Get_Struct(self, rg_segment, seg);
	Data_Get_Struct(start, rg_vector2, c_start);
	Data_Get_Struct(vec, rg_vector2, c_vec);
	seg->start = *c_start;
	seg->vec   = *c_vec;
	return self;
}

/* 
 *  :nodoc:
 */
static VALUE rg_segment_rb_initialize_copy(VALUE self, VALUE old)
{
	rg_segment *seg1, *seg2;
	Data_Get_Struct(self, rg_segment, seg1);
	Data_Get_Struct(old, rg_segment, seg2);
	*seg1 = *seg2;
	return self;
}

/* 
 *  call-seq:
 *    begin -> Vector2
 *
 *  Returns the Vector2 pointing to the begin of the Segment.
 */
static VALUE rg_segment_rb_begin(VALUE self)
{
	rg_segment *seg;
	rg_vector2    *vector2;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, vector2);
	vector2->x = seg->start.x;
	vector2->y = seg->start.y;
	return rb_vector2;
}

/* 
 *  call-seq:
 *    center -> Vector2
 *
 *  Returns the Vector2 pointing to the center of the Segment.
 */
static VALUE rg_segment_rb_center(VALUE self)
{
	rg_segment *seg;
	rg_vector2    *vector2;
	rg_vector2    half;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, vector2);
	rg_vector2_resized_by(&half, &seg->vec, 0.5);
	rg_vector2_add(vector2, &seg->start, &half);
	return rb_vector2;
}

/* 
 *  call-seq:
 *    end -> Vector2
 *
 *  Returns the Vector2 pointing to the end of the Segment.
 */
static VALUE rg_segment_rb_end(VALUE self)
{
	rg_segment *seg;
	rg_vector2    *vector2;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, vector2);
	rg_vector2_add(vector2, &seg->start, &seg->vec);
	return rb_vector2;
}

/* 
 *  call-seq:
 *    vec -> Vector2
 *
 *  Returns the Vector2 from begin to end of the Segment.
 */
static VALUE rg_segment_rb_vec(VALUE self)
{
	rg_segment *seg;
	rg_vector2    *vector2;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, vector2);
	vector2->x = seg->vec.x;
	vector2->y = seg->vec.y;
	return rb_vector2;
}

/* 
 *  call-seq:
 *    length -> Float
 *
 *  Returns the length of the Segment (same as vec.magnitude).
 */
static VALUE rg_segment_rb_length(VALUE self)
{
	rg_segment *seg;
	Data_Get_Struct(self, rg_segment, seg);
	return rb_float_new(rg_vector2_magnitude(&seg->vec));
}

/* 
 *  call-seq:
 *    angle -> Float
 *
 *  Returns the angle of the Segment (in radians).
 */
static VALUE rg_segment_rb_angle(VALUE self)
{
	rg_segment *seg;
	Data_Get_Struct(self, rg_segment, seg);
	return rb_float_new(rg_vector2_angle(&seg->vec));
}

/* 
 *  call-seq:
 *    moved(by)  ->  Vector2
 *
 *  Move Segment by Vector2 'by'.
 */
static VALUE rg_segment_rb_move(VALUE self, VALUE by)
{
	rg_segment *seg, *result;
	rg_vector2    *vec;
	Data_Get_Struct(self, rg_segment, seg);
	Data_Get_Struct(by, rg_vector2, vec);

	VALUE rb_result = Data_Make_Struct(cSegment, rg_segment, NULL, free, result);
	rg_segment_move(result, seg, vec);
	return rb_result;
}

/* 
 *  call-seq:
 *    rotated_around(pivot, angle)  ->  Vector2
 *
 *  Rotates the Segment by angle (radians) around the pivot point (Vector2).
 */
static VALUE rg_segment_rb_rotated_around(VALUE self, VALUE center, VALUE rad)
{
	rg_segment *seg, *result;
	rg_vector2    *c_center;
	Data_Get_Struct(self, rg_segment, seg);
	Data_Get_Struct(center, rg_vector2, c_center);

	VALUE rb_result = Data_Make_Struct(cSegment, rg_segment, NULL, free, result);
	rg_segment_rotate_around(result, seg, c_center, NUM2DBL(rad));
	return rb_result;
}

/* 
 *  call-seq:
 *    inspect -> String
 *
 *  Begin and end, magnitude and angle of the Segment as String.
 */
static VALUE rg_segment_rb_inspect(VALUE self)
{
	rg_segment *seg;
	rg_vector2    end, vec;
	Data_Get_Struct(self, rg_segment, seg);
	VALUE str;
	char buf[255];
	rg_vector2_add(&end, &seg->start, &seg->vec);
	vec = seg->vec;
	
	snprintf(buf, 255, "#<%s:0x%lx %.2f, %.2f - %.2f, %.2f (|%.2f| %.1f°)>",
		rb_obj_classname(self),
		self,
		seg->start.x,
		seg->start.y,
		end.x,
		end.y,
		rg_vector2_magnitude(&vec),
		rg_vector2_angle_deg(&vec)
	);
	str  = rb_str_new2(buf);
	return str;
}

/*
 * Document-class: Rubygame::Body::Segment
 *
 *  Segment represents a line segment, determined by a begin and an end.
 */
void Init_Segment()
{
	mRubygame = rb_define_module("Rubygame");
	mBody     = rb_define_module_under(mRubygame, "Body");

	cSegment = rb_define_class_under(mBody, "Segment", rb_cObject);

	rb_define_alloc_func(cSegment, rg_segment_rb_singleton_alloc);

	rb_define_singleton_method(cSegment, "new",    rg_segment_rb_singleton_new, -1);
	rb_define_singleton_method(cSegment, "points", rg_segment_rb_singleton_points, 4);

	rb_define_method(cSegment, "initialize",      rg_segment_rb_initialize, 2);
	rb_define_method(cSegment, "initialize_copy", rg_segment_rb_initialize_copy, 1);
	rb_define_method(cSegment, "begin",           rg_segment_rb_begin, 0);
	rb_define_method(cSegment, "center",          rg_segment_rb_center, 0);
	rb_define_method(cSegment, "end",             rg_segment_rb_end, 0);
	rb_define_method(cSegment, "vector",          rg_segment_rb_vec, 0);
	rb_define_method(cSegment, "length",          rg_segment_rb_length, 0);
	rb_define_method(cSegment, "angle",           rg_segment_rb_angle, 0);
	rb_define_method(cSegment, "move",            rg_segment_rb_move, 1);
	rb_define_method(cSegment, "rotated_around",  rg_segment_rb_rotated_around, 2);
	rb_define_method(cSegment, "inspect",         rg_segment_rb_inspect, 0);
}
