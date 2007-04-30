// require 'ruby/numeric'; circle = Segment.new(Ftor[1,1], Ftor[2,2]); circle.rotate(90.to_radian, Ftor[2,2])
#include <ruby.h>
#include <math.h>
#include "rubygame_cFtor.h"
#include "rubygame_cCircle.h"

static VALUE mRubygame;
static VALUE mBody;

static VALUE rg_cFtor;
static VALUE rg_cSegment;
static VALUE rg_cRect;
static VALUE rg_cCircle;

void rg_circle_move(rg_circle *circle, rg_ftor *ftor)
{
	rg_ftor_add(&circle->center, &circle->center, ftor);
}

void rg_circle_rotate_around(rg_circle *circle, rg_ftor *center, double rad)
{
	rg_ftor_rotated_around(&circle->center, &circle->center, center, rad);
}


/***  RUBY method wrappers  ***************************************************/
static VALUE rg_circle_rb_singleton_new(int argc, VALUE *argv, VALUE class)
{
	rg_circle *circle;
	VALUE rb_circle = Data_Make_Struct(class, rg_circle, NULL, free, circle);
	rb_obj_call_init(rb_circle, argc, argv);
	return rb_circle;
}

static VALUE rg_circle_rb_initialize(VALUE self, VALUE center, VALUE radius)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	rg_ftor    *c_center;
	Data_Get_Struct(center, rg_ftor, c_center);

	circle->center  = *c_center;
	circle->radius  = NUM2DBL(radius);
	
	return self;
}

static VALUE rg_circle_rb_center(VALUE self)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	rg_ftor    *ftor;
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, ftor);

	*ftor = circle->center;

	return rb_ftor;
}

static VALUE rg_circle_rb_radius(VALUE self)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	return rb_float_new(circle->radius);
}

static VALUE rg_circle_rb_move(VALUE self, VALUE by)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	rg_ftor    *vec;
	Data_Get_Struct(by, rg_ftor, vec);

	rg_circle_move(circle, vec);

	return self;
}

static VALUE rg_circle_rb_rotate(VALUE self, VALUE rad, VALUE center)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);

	rg_ftor    *c_center;
	Data_Get_Struct(center, rg_ftor, c_center);

	rg_circle_rotate_around(circle, c_center, NUM2DBL(rad));

	return self;
}

static VALUE rg_circle_rb_inspect(VALUE self)
{
	rg_circle *circle;
	Data_Get_Struct(self, rg_circle, circle);
	VALUE str;
	char buf[255];
	
	sprintf(buf, "#<%s:0x%lx center: %.2f, %.2f radius: %.1f>",
		rb_obj_classname(self),
		self,
		circle->center.x,
		circle->center.y,
		circle->radius
	);
	str  = rb_str_new2(buf);
	return str;
}

void Init_rg_cCircle()
{
	mRubygame   = rb_define_module("Rubygame");
	mBody       = rb_define_module_under(mRubygame, "Body");

	rg_cCircle  = rb_define_class_under(mBody, "Circle", rb_cObject);
	rg_cRect    = rb_define_class_under(mBody, "Rect", rb_cObject);
	rg_cSegment = rb_define_class_under(mBody, "Segment", rb_cObject);
	rg_cFtor    = rb_define_class_under(mBody, "Ftor", rb_cObject);

	rb_define_singleton_method(rg_cCircle, "new",    rg_circle_rb_singleton_new, -1);

	rb_define_method(rg_cCircle, "initialize",    rg_circle_rb_initialize, 2);
	rb_define_method(rg_cCircle, "center",        rg_circle_rb_center, 0);
	rb_define_method(rg_cCircle, "radius",        rg_circle_rb_radius, 0);
	rb_define_method(rg_cCircle, "move",          rg_circle_rb_move, 1);
	rb_define_method(rg_cCircle, "rotate",        rg_circle_rb_rotate, 2);
	rb_define_method(rg_cCircle, "inspect",       rg_circle_rb_inspect, 0);
}
