#include <math.h>
#include <ruby.h>
#include "rubygame_cFtor.h"
#include "defines.h"

static VALUE mRubygame;
static VALUE mBody;

static VALUE rg_cFtor;
static VALUE rg_cSegment;
static VALUE rg_cRect;
static VALUE rg_cCircle;

void rg_ftor_add(rg_ftor *result, rg_ftor *a, rg_ftor *b)
{
	result->x = a->x + b->x;
	result->y = a->y + b->y;
}

void rg_ftor_subtract(rg_ftor *result, rg_ftor *a, rg_ftor *b)
{
	result->x = a->x - b->x;
	result->y = a->y - b->y;
}

void rg_ftor_negate(rg_ftor *result, rg_ftor *a)
{
	result->x = -a->x;
	result->y = -a->y;
}

void rg_ftor_magnitude_and_rotation(rg_ftor *result, double magnitude, double rad)
{
	result->x = cos(rad)*magnitude;
	result->y = sin(rad)*magnitude;
}

void rg_ftor_rotated_to(rg_ftor *result, rg_ftor *a, double rad)
{
	rg_ftor_magnitude_and_rotation(result, rg_ftor_magnitude(a), rad);
}

void rg_ftor_rotated_by(rg_ftor *result, rg_ftor *a, double rad)
{
	rg_ftor_magnitude_and_rotation(result, rg_ftor_magnitude(a), rg_ftor_angle(a)+rad);
}

void rg_ftor_rotated_around(rg_ftor *result, rg_ftor *original, rg_ftor *center, double rad)
{
	rg_ftor_subtract(result, original, center);
	rg_ftor_rotated_by(result, result, rad);
	rg_ftor_add(result, center, result);
}


void rg_ftor_resized_to(rg_ftor *result, rg_ftor *a, double magnitude)
{
	rg_ftor_magnitude_and_rotation(result, magnitude, rg_ftor_angle(a));
}

void rg_ftor_resized_by(rg_ftor *result, rg_ftor *a, double factor)
{
	rg_ftor_magnitude_and_rotation(result, rg_ftor_magnitude(a)*factor, rg_ftor_angle(a));
}

void rg_ftor_normalized(rg_ftor *result, rg_ftor *a)
{
	rg_ftor_resized_to(result, a, 1.0);
}

void rg_ftor_projected(rg_ftor *result, rg_ftor *project, rg_ftor *on)
{
	double fac = rg_ftor_dotproduct(project, on)/rg_ftor_magnitude2(on);
	result->x = on->x*fac;
	result->y = on->y*fac;
}

double rg_ftor_magnitude(rg_ftor *a)
{
	return sqrt(rg_ftor_magnitude2(a));
}

double rg_ftor_magnitude2(rg_ftor *a)
{
	return (a->x * a->x) + (a->y * a->y);
}

double rg_ftor_dotproduct(rg_ftor *a, rg_ftor *b)
{
	return ((a->x * b->x) + (a->y * b->y));
}

double rg_ftor_angle(rg_ftor *a)
{
	return atan2(a->y, a->x);
}

double rg_ftor_angle_deg(rg_ftor *a)
{
	return RAD2DEG(atan2(a->y, a->x));
}

double rg_ftor_angle_between(rg_ftor *a, rg_ftor *b)
{
	return acos(rg_ftor_dotproduct(a,b)/(rg_ftor_magnitude(a)*rg_ftor_magnitude(b)));
}



/***  RUBY method wrappers  ***************************************************/
static VALUE rg_ftor_rb_singleton_new(int argc, VALUE *argv, VALUE class)
{
	rg_ftor *ftor;
	VALUE   rb_ftor;
	rb_ftor = Data_Make_Struct(class, rg_ftor, NULL, free, ftor);
	rb_obj_call_init(rb_ftor, argc, argv);
	return rb_ftor;
}

static VALUE rg_ftor_rb_singleton_bracket(VALUE class, VALUE x, VALUE y)
{
	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(class, rg_ftor, NULL, free, ftor);
	ftor->x = NUM2DBL(x);
	ftor->y = NUM2DBL(y);
	return rb_ftor;	
}

static VALUE rg_ftor_rb_singleton_polar(VALUE class, VALUE mag, VALUE rad)
{
	rg_ftor *ftor;
	VALUE rb_ftor = Data_Make_Struct(class, rg_ftor, NULL, free, ftor);
	rg_ftor_magnitude_and_rotation(ftor, NUM2DBL(mag), NUM2DBL(rad));
	return rb_ftor;	
}

static VALUE rg_ftor_rb_initialize(VALUE self, VALUE x, VALUE y)
{
	rg_ftor *ftor;
	Data_Get_Struct(self, rg_ftor, ftor);
	ftor->x = NUM2DBL(x);
	ftor->y = NUM2DBL(y);
	return self;
}

static VALUE rg_ftor_rb_x(VALUE self)
{
	rg_ftor *ftor;
	Data_Get_Struct(self, rg_ftor, ftor);
	return rb_float_new(ftor->x);
}

static VALUE rg_ftor_rb_y(VALUE self)
{
	rg_ftor *ftor;
	Data_Get_Struct(self, rg_ftor, ftor);
	return rb_float_new(ftor->y);
}

static VALUE rg_ftor_rb_magnitude(VALUE self)
{
	rg_ftor *ftor;
	Data_Get_Struct(self, rg_ftor, ftor);
	return rb_float_new(rg_ftor_magnitude(ftor));
}

static VALUE rg_ftor_rb_angle(VALUE self)
{
	rg_ftor *ftor;
	Data_Get_Struct(self, rg_ftor, ftor);
	return rb_float_new(rg_ftor_angle(ftor));
}

static VALUE rg_ftor_rb_angle_deg(VALUE self)
{
	rg_ftor *ftor;
	Data_Get_Struct(self, rg_ftor, ftor);
	return rb_float_new(rg_ftor_angle_deg(ftor));
}

static VALUE rg_ftor_rb_binary_plus(VALUE self, VALUE other)
{
	rg_ftor *a, *b, *c;

	Data_Get_Struct(self, rg_ftor, a);
	Data_Get_Struct(other, rg_ftor, b);

	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, c);
	rg_ftor_add(c, a, b);

	return rb_ftor;
}

static VALUE rg_ftor_rb_binary_minus(VALUE self, VALUE other)
{
	rg_ftor *a, *b, *c;

	Data_Get_Struct(self, rg_ftor, a);
	Data_Get_Struct(other, rg_ftor, b);

	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, c);
	rg_ftor_subtract(c, a, b);

	return rb_ftor;
}

static VALUE rg_ftor_rb_unary_plus(VALUE self)
{
	rg_ftor *a, *b;
	Data_Get_Struct(self, rg_ftor, a);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, b);
	b->x = a->x;
	b->y = a->y;
	return rb_ftor;	
}

static VALUE rg_ftor_rb_unary_minus(VALUE self)
{
	rg_ftor *a, *b;
	Data_Get_Struct(self, rg_ftor, a);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, b);
	b->x = -a->x;
	b->y = -a->y;
	return rb_ftor;	
}

static VALUE rg_ftor_rb_dotproduct(VALUE self, VALUE other)
{
	rg_ftor *a, *b;

	Data_Get_Struct(self, rg_ftor, a);
	Data_Get_Struct(other, rg_ftor, b);

	return rb_float_new(rg_ftor_dotproduct(a, b));
}

static VALUE rg_ftor_rb_normalized(VALUE self)
{
	rg_ftor *a, *b;
	Data_Get_Struct(self, rg_ftor, a);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, b);
	
	rg_ftor_normalized(b, a);
	return rb_ftor;	
}

static VALUE rg_ftor_rb_resized_to(VALUE self, VALUE size)
{
	rg_ftor *a, *b;
	Data_Get_Struct(self, rg_ftor, a);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, b);
	
	rg_ftor_resized_to(b, a, NUM2DBL(size));
	return rb_ftor;	
}

static VALUE rg_ftor_rb_resized_by(VALUE self, VALUE factor)
{
	rg_ftor *a, *b;
	Data_Get_Struct(self, rg_ftor, a);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, b);
	
	rg_ftor_resized_by(b, a, NUM2DBL(factor));
	return rb_ftor;	
}

static VALUE rg_ftor_rb_rotated_to(VALUE self, VALUE rad)
{
	rg_ftor *a, *b;
	Data_Get_Struct(self, rg_ftor, a);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, b);
	
	rg_ftor_rotated_to(b, a, NUM2DBL(rad));
	return rb_ftor;	
}

static VALUE rg_ftor_rb_rotated_by(VALUE self, VALUE rad)
{
	rg_ftor *a, *b;
	Data_Get_Struct(self, rg_ftor, a);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, b);
	
	rg_ftor_rotated_by(b, a, NUM2DBL(rad));
	return rb_ftor;	
}

static VALUE rg_ftor_rb_rotated_around(VALUE self, VALUE center, VALUE rad)
{
	rg_ftor *a, *b, *c;
	Data_Get_Struct(self, rg_ftor, a);
	Data_Get_Struct(center, rg_ftor, b);
	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, c);
	
	rg_ftor_rotated_around(c, a, b, NUM2DBL(rad));
	return rb_ftor;	
}

static VALUE rg_ftor_rb_projected(VALUE self, VALUE project_on)
{
	rg_ftor *a, *b, *c;

	Data_Get_Struct(self, rg_ftor, a);
	Data_Get_Struct(project_on, rg_ftor, b);

	VALUE rb_ftor = Data_Make_Struct(rg_cFtor, rg_ftor, NULL, free, c);
	
	rg_ftor_projected(c, a, b);
	return rb_ftor;	
}

static VALUE rg_ftor_rb_to_a(VALUE self)
{
	rg_ftor *ftor;
	Data_Get_Struct(self, rg_ftor, ftor);
	return rb_ary_new3(2, rb_float_new(ftor->x), rb_float_new(ftor->y));
}

static VALUE rg_ftor_rb_to_s(VALUE self)
{
	rg_ftor *ftor;
	Data_Get_Struct(self, rg_ftor, ftor);
	VALUE str;
	char buf[255];
	
	sprintf(buf, "<%s %.0f, %.0f>",
		"Ftor",
		ftor->x,
		ftor->y
	);
	str  = rb_str_new2(buf);
	return str;
}

static VALUE rg_ftor_rb_inspect(VALUE self)
{
	rg_ftor *ftor;
	Data_Get_Struct(self, rg_ftor, ftor);
	VALUE str;
	char buf[255];
	
	sprintf(buf, "#<%s:0x%lx %.2f, %.2f (|%.2f|, %.1f°)>",
		rb_obj_classname(self),
		self,
		ftor->x,
		ftor->y,
		rg_ftor_magnitude(ftor),
		rg_ftor_angle_deg(ftor)
	);
	str  = rb_str_new2(buf);
	return str;
}

void Init_rg_cFtor()
{
	mRubygame = rb_define_module("Rubygame");
	mBody     = rb_define_module_under(mRubygame, "Body");

	rg_cCircle  = rb_define_class_under(mBody, "Circle", rb_cObject);
	rg_cRect    = rb_define_class_under(mBody, "Rect", rb_cObject);
	rg_cSegment = rb_define_class_under(mBody, "Segment", rb_cObject);
	rg_cFtor    = rb_define_class_under(mBody, "Ftor", rb_cObject);

	rb_define_singleton_method(rg_cFtor, "polar", rg_ftor_rb_singleton_polar, 2);
	rb_define_singleton_method(rg_cFtor, "new",   rg_ftor_rb_singleton_new, -1);
	rb_define_singleton_method(rg_cFtor, "[]",    rg_ftor_rb_singleton_bracket, 2);

	rb_define_method(rg_cFtor, "initialize",      rg_ftor_rb_initialize, 2);
	rb_define_method(rg_cFtor, "x",               rg_ftor_rb_x, 0);
	rb_define_method(rg_cFtor, "y",               rg_ftor_rb_y, 0);
	rb_define_method(rg_cFtor, "magnitude",       rg_ftor_rb_magnitude, 0);
	rb_define_method(rg_cFtor, "angle",           rg_ftor_rb_angle, 0);
	rb_define_method(rg_cFtor, "angle_deg",       rg_ftor_rb_angle_deg, 0);
	rb_define_method(rg_cFtor, "+",               rg_ftor_rb_binary_plus, 1);
	rb_define_method(rg_cFtor, "-",               rg_ftor_rb_binary_minus, 1);
	rb_define_method(rg_cFtor, "+@",              rg_ftor_rb_unary_plus, 0);
	rb_define_method(rg_cFtor, "-@",              rg_ftor_rb_unary_minus, 0);
	rb_define_method(rg_cFtor, "dot",             rg_ftor_rb_dotproduct, 1);
	rb_define_method(rg_cFtor, "normalized",      rg_ftor_rb_normalized, 0);
	rb_define_method(rg_cFtor, "resized_to",      rg_ftor_rb_resized_to, 1);
	rb_define_method(rg_cFtor, "resized_by",      rg_ftor_rb_resized_by, 1);
	rb_define_method(rg_cFtor, "rotated_to",      rg_ftor_rb_rotated_to, 1);
	rb_define_method(rg_cFtor, "rotated_by",      rg_ftor_rb_rotated_by, 1);
	rb_define_method(rg_cFtor, "rotated_around",  rg_ftor_rb_rotated_around, 2);
	rb_define_method(rg_cFtor, "projected",       rg_ftor_rb_projected, 1);
	rb_define_method(rg_cFtor, "to_a",            rg_ftor_rb_to_a, 0);
	rb_define_method(rg_cFtor, "to_s",            rg_ftor_rb_to_s, 0);
	rb_define_method(rg_cFtor, "inspect",         rg_ftor_rb_inspect, 0);
}
