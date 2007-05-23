// require 'ruby/numeric'; circle = Segment.new(Vector2[1,1], Vector2[2,2]); circle.rotate(90.to_radian, Vector2[2,2])
#include <ruby.h>
#include <math.h>
#include "rubygame_defines.h"
#include "rubygame_cVector2.h"
#include "rubygame_cCircle.h"
#include "collision_math.h"

VALUE cCircle;

void rg_circle_move(rg_circle *circle, rg_vector2 *vector2)
{
	rg_vector2_add(&circle->center, &circle->center, vector2);
}

void rg_circle_rotate_around(rg_circle *circle, rg_vector2 *center, double rad)
{
	rg_vector2_rotated_around(&circle->center, &circle->center, center, rad);
}


/***  RUBY method wrappers  ***************************************************/

/* 
 *  :nodoc:
 */
static VALUE rg_circle_rb_singleton_alloc(VALUE class)
{
	rg_circle *circle;
	VALUE rb_circle = Data_Make_Struct(class, rg_circle, NULL, free, circle);
	circle->center.x = 0;
	circle->center.y = 0;
	circle->radius   = 0;
	return rb_circle;
}

/* 
 *  call-seq:
 *    Circle.new(Vector2 center, radius)
 *
 *  Creates a Circle with center given by a Vector2 'center' and radius 'radius'.
 */
static VALUE rg_circle_rb_initialize(VALUE self, VALUE center, VALUE radius)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	rg_vector2    *c_center;
	Data_Get_Struct(center, rg_vector2, c_center);

	circle->center  = *c_center;
	circle->radius  = NUM2DBL(radius);
	
	return self;
}

/* 
 *  :nodoc:
 */
static VALUE rg_circle_rb_initialize_copy(VALUE self, VALUE old)
{
	rg_circle *circle1, *circle2;
	Data_Get_Struct(self, rg_circle, circle1);
	Data_Get_Struct(old, rg_circle, circle2);

	*circle1 = *circle2;
	
	return self;
}

/* 
 *  call-seq:
 *    center -> Vector2
 *
 *  Returns a Vector2 representing the center of the Circle.
 */
static VALUE rg_circle_rb_center(VALUE self)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	rg_vector2    *vector2;
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, vector2);

	*vector2 = circle->center;

	return rb_vector2;
}

/* 
 *  call-seq:
 *    radius -> Float
 *
 *  Returns the radius of the Circle.
 */
static VALUE rg_circle_rb_radius(VALUE self)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	return rb_float_new(circle->radius);
}

/* 
 *  call-seq:
 *    move(by) -> self
 *
 *  Moves the Circle by a Vector2 'by'.
 */
static VALUE rg_circle_rb_move(VALUE self, VALUE by)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	rg_vector2    *vec;
	Data_Get_Struct(by, rg_vector2, vec);

	rg_circle_move(circle, vec);

	return self;
}

/* 
 *  call-seq:
 *    rotate(radians, around) -> self
 *
 *  Rotates the circle by an angle 'radians' in radians around a Vector2 'around'.
 */
static VALUE rg_circle_rb_rotate(VALUE self, VALUE rad, VALUE center)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	rg_vector2    *c_center;
	Data_Get_Struct(center, rg_vector2, c_center);

	rg_circle_rotate_around(circle, c_center, NUM2DBL(rad));

	return self;
}

/* 
 *  call-seq:
 *    inspect -> String
 *
 *  The Circles center and radius.
 */
static VALUE rg_circle_rb_inspect(VALUE self)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);
	VALUE str;
	char buf[255];
	
	snprintf(buf, 255, "#<%s:0x%lx center: %.2f, %.2f radius: %.1f>",
		rb_obj_classname(self),
		self,
		circle->center.x,
		circle->center.y,
		circle->radius
	);
	str  = rb_str_new2(buf);
	return str;
}

void Init_Circle()
{
	mRubygame   = rb_define_module("Rubygame");
	mBody       = rb_define_module_under(mRubygame, "Body");

	cCircle  = rb_define_class_under(mBody, "Circle", rb_cObject);

	rb_define_alloc_func(cCircle, rg_circle_rb_singleton_alloc);

	rb_define_method(cCircle, "initialize",      rg_circle_rb_initialize, 2);
	rb_define_method(cCircle, "initialize_copy", rg_circle_rb_initialize_copy, 1);
	rb_define_method(cCircle, "center",          rg_circle_rb_center, 0);
	rb_define_method(cCircle, "radius",          rg_circle_rb_radius, 0);
	rb_define_method(cCircle, "move",            rg_circle_rb_move, 1);
	rb_define_method(cCircle, "rotate",          rg_circle_rb_rotate, 2);
	rb_define_method(cCircle, "inspect",         rg_circle_rb_inspect, 0);
}
