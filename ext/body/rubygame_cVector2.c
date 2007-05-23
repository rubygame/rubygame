#include <math.h>
#include <ruby.h>
#include "rubygame_defines.h"
#include "rubygame_cVector2.h"
#include "collision_math.h"

VALUE cVector2;

void rg_vector2_add(rg_vector2 *result, rg_vector2 *a, rg_vector2 *b)
{
	result->x = a->x + b->x;
	result->y = a->y + b->y;
}

void rg_vector2_subtract(rg_vector2 *result, rg_vector2 *a, rg_vector2 *b)
{
	result->x = a->x - b->x;
	result->y = a->y - b->y;
}

void rg_vector2_negate(rg_vector2 *result, rg_vector2 *a)
{
	result->x = -a->x;
	result->y = -a->y;
}

void rg_vector2_magnitude_and_rotation(rg_vector2 *result, double magnitude, double rad)
{
	result->x = cos(rad)*magnitude;
	result->y = sin(rad)*magnitude;
}

void rg_vector2_rotated_to(rg_vector2 *result, rg_vector2 *a, double rad)
{
	rg_vector2_magnitude_and_rotation(result, rg_vector2_magnitude(a), rad);
}

void rg_vector2_rotated_by(rg_vector2 *result, rg_vector2 *a, double rad)
{
	rg_vector2_magnitude_and_rotation(result, rg_vector2_magnitude(a), rg_vector2_angle(a)+rad);
}

void rg_vector2_rotated_around(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double rad)
{
	rg_vector2_subtract(result, original, center);
	rg_vector2_rotated_by(result, result, rad);
	rg_vector2_add(result, center, result);
}


void rg_vector2_resized_to(rg_vector2 *result, rg_vector2 *a, double magnitude)
{
	rg_vector2_magnitude_and_rotation(result, magnitude, rg_vector2_angle(a));
}

void rg_vector2_resized_by(rg_vector2 *result, rg_vector2 *a, double factor)
{
	rg_vector2_magnitude_and_rotation(result, rg_vector2_magnitude(a)*factor, rg_vector2_angle(a));
}

void rg_vector2_normalized(rg_vector2 *result, rg_vector2 *a)
{
	rg_vector2_resized_to(result, a, 1.0);
}

void rg_vector2_projected(rg_vector2 *result, rg_vector2 *project, rg_vector2 *on)
{
	double fac = rg_vector2_dotproduct(project, on)/rg_vector2_magnitude2(on);
	result->x = on->x*fac;
	result->y = on->y*fac;
}

double rg_vector2_magnitude(rg_vector2 *a)
{
	return sqrt(rg_vector2_magnitude2(a));
}

double rg_vector2_magnitude2(rg_vector2 *a)
{
	return (a->x * a->x) + (a->y * a->y);
}

double rg_vector2_dotproduct(rg_vector2 *a, rg_vector2 *b)
{
	return ((a->x * b->x) + (a->y * b->y));
}

double rg_vector2_angle(rg_vector2 *a)
{
	return atan2(a->y, a->x);
}

double rg_vector2_angle_deg(rg_vector2 *a)
{
	return RAD2DEG(atan2(a->y, a->x));
}

double rg_vector2_angle_between(rg_vector2 *a, rg_vector2 *b)
{
	return acos(rg_vector2_dotproduct(a,b)/(rg_vector2_magnitude(a)*rg_vector2_magnitude(b)));
}



/***  RUBY method wrappers  ***************************************************/

/* 
 *  :nodoc:
 */
static VALUE rg_vector2_rb_singleton_alloc(VALUE class)
{
	rg_vector2 *vector2;
	VALUE    rb_vector2;
	rb_vector2 = Data_Make_Struct(class, rg_vector2, NULL, free, vector2);
	vector2->x = 0;
	vector2->y = 0;
	return rb_vector2;
}

/* 
 *  call-seq:
 *    Vector2[x,y] -> Vector2
 *
 *  Create a Vector2 from components. This method is both, less to type and
 *  faster than Vector2.new.
 */
static VALUE rg_vector2_rb_singleton_bracket(VALUE class, VALUE x, VALUE y)
{
	rg_vector2 *vector2;
	VALUE rb_vector2 = Data_Make_Struct(class, rg_vector2, NULL, free, vector2);
	vector2->x = NUM2DBL(x);
	vector2->y = NUM2DBL(y);
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    Vector2.new(angle, magnitude) -> Vector2
 *
 *  Create a Vector2 from angle (in radians) and magnitude.
 */
static VALUE rg_vector2_rb_singleton_polar(VALUE class, VALUE rad, VALUE mag)
{
	rg_vector2 *vector2;
	VALUE rb_vector2 = Data_Make_Struct(class, rg_vector2, NULL, free, vector2);
	rg_vector2_magnitude_and_rotation(vector2, NUM2DBL(mag), NUM2DBL(rad));
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    Vector2.new(x,y) -> Vector2
 *
 *  Create a Vector2 from components. See also Vector2::[] (it's faster).
 */
static VALUE rg_vector2_rb_initialize(VALUE self, VALUE x, VALUE y)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	vector2->x = NUM2DBL(x);
	vector2->y = NUM2DBL(y);
	return self;
}

/* 
 *  :nodoc:
 */
static VALUE rg_vector2_rb_initialize_copy(VALUE self, VALUE old)
{
	rg_vector2 *vector21, *vector22;
	Data_Get_Struct(self, rg_vector2, vector21);
	Data_Get_Struct(old, rg_vector2, vector22);

	*vector21 = *vector22;
	
	return self;
}

/* 
 *  call-seq:
 *    x -> Float
 *
 *  The x component of the receiver.
 */
static VALUE rg_vector2_rb_x(VALUE self)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	return rb_float_new(vector2->x);
}

/* 
 *  call-seq:
 *    x = a_float
 *
 *  Set the x component of the receiver to a_float.
 */
static VALUE rg_vector2_rb_xset(VALUE self, VALUE vx)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	vector2->x = NUM2DBL(vx);
	return vx;
}

/* 
 *  call-seq:
 *    y -> Float
 *
 *  The y component of the receiver.
 */
static VALUE rg_vector2_rb_y(VALUE self)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	return rb_float_new(vector2->y);
}

/* 
 *  call-seq:
 *    y = a_float
 *
 *  Set the y component of the receiver to a_float.
 */
static VALUE rg_vector2_rb_yset(VALUE self, VALUE vy)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	vector2->y = NUM2DBL(vy);
	return vy;
}

/* 
 *  call-seq:
 *    magnitude -> Float
 *
 *  The magnitude of the receiver. Can be used to calculate distances.
 *  I.e. the distance between 5,5 and 10,8 is (Vector2[5,5]-Vector2[10,8]).magnitude.
 */
static VALUE rg_vector2_rb_magnitude(VALUE self)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	return rb_float_new(rg_vector2_magnitude(vector2));
}

/* 
 *  call-seq:
 *    angle -> Float
 *
 *  The angle of the receiver in radians.
 */
static VALUE rg_vector2_rb_angle(VALUE self)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	return rb_float_new(rg_vector2_angle(vector2));
}

/* 
 *  call-seq:
 *    angle_deg -> Float
 *
 *  The angle of a the receiver in degrees.
 */
static VALUE rg_vector2_rb_angle_deg(VALUE self)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	return rb_float_new(rg_vector2_angle_deg(vector2));
}

/* 
 *  call-seq:
 *    self + other -> Vector2
 *
 *  Sum of two Vector2s (component wise addition).
 */
static VALUE rg_vector2_rb_binary_plus(VALUE self, VALUE other)
{
	rg_vector2 *a, *b, *c;

	Data_Get_Struct(self, rg_vector2, a);
	Data_Get_Struct(other, rg_vector2, b);

	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, c);
	rg_vector2_add(c, a, b);

	return rb_vector2;
}

/* 
 *  call-seq:
 *    self - other -> Vector2
 *
 *  Difference of two Vector2s (component wise subtraction).
 */
static VALUE rg_vector2_rb_binary_minus(VALUE self, VALUE other)
{
	rg_vector2 *a, *b, *c;

	Data_Get_Struct(self, rg_vector2, a);
	Data_Get_Struct(other, rg_vector2, b);

	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, c);
	rg_vector2_subtract(c, a, b);

	return rb_vector2;
}

/* 
 *  call-seq:
 *    +vector2 -> Vector2
 *
 *  Returns a duplicate of self.
 */
static VALUE rg_vector2_rb_unary_plus(VALUE self)
{
	rg_vector2 *a, *b;
	Data_Get_Struct(self, rg_vector2, a);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, b);
	b->x = a->x;
	b->y = a->y;
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    -vector2 -> Vector2
 *
 *  Returns a Vector2 with all components negated.
 */
static VALUE rg_vector2_rb_unary_minus(VALUE self)
{
	rg_vector2 *a, *b;
	Data_Get_Struct(self, rg_vector2, a);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, b);
	b->x = -a->x;
	b->y = -a->y;
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    dot(other_vector2) -> Float
 *
 *  Returns the dot product between receiver and other_vector2 (sum of products of components,
 *  i.e. a.x*b.x + a.y*b.y).
 */
static VALUE rg_vector2_rb_dotproduct(VALUE self, VALUE other)
{
	rg_vector2 *a, *b;

	Data_Get_Struct(self, rg_vector2, a);
	Data_Get_Struct(other, rg_vector2, b);

	return rb_float_new(rg_vector2_dotproduct(a, b));
}

/* 
 *  call-seq:
 *    normalized -> Vector2
 *
 *  Returns a Vector2 with the same angle but normalized magnitude ( == 1).
 */
static VALUE rg_vector2_rb_normalized(VALUE self)
{
	rg_vector2 *a, *b;
	Data_Get_Struct(self, rg_vector2, a);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, b);
	
	rg_vector2_normalized(b, a);
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    resized_to(new_magnitude) -> Vector2
 *
 *  Returns a Vector2 with the same angle but magnitude scaled by factor 'new_magnitude'.
 */
static VALUE rg_vector2_rb_resized_to(VALUE self, VALUE size)
{
	rg_vector2 *a, *b;
	Data_Get_Struct(self, rg_vector2, a);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, b);
	
	rg_vector2_resized_to(b, a, NUM2DBL(size));
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    resized_by(factor) -> Vector2
 *
 *  Returns a Vector2 with the same angle but magnitude scaled by factor 'factor'.
 */
static VALUE rg_vector2_rb_resized_by(VALUE self, VALUE factor)
{
	rg_vector2 *a, *b;
	Data_Get_Struct(self, rg_vector2, a);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, b);
	
	rg_vector2_resized_by(b, a, NUM2DBL(factor));
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    rotated_to(radians) -> Vector2
 *
 *  Returns a Vector2 with the same magnitude but the angle rotated to the angle
 *  'radians' given in radians.
 */
static VALUE rg_vector2_rb_rotated_to(VALUE self, VALUE rad)
{
	rg_vector2 *a, *b;
	Data_Get_Struct(self, rg_vector2, a);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, b);
	
	rg_vector2_rotated_to(b, a, NUM2DBL(rad));
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    rotated_by(radians) -> Vector2
 *
 *  Returns a Vector2 with the same magnitude but the angle rotated by the angle
 *  'radians' given in radians.
 */
static VALUE rg_vector2_rb_rotated_by(VALUE self, VALUE rad)
{
	rg_vector2 *a, *b;
	Data_Get_Struct(self, rg_vector2, a);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, b);
	
	rg_vector2_rotated_by(b, a, NUM2DBL(rad));
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    rotated_around(Vector2 center, radians) -> Vector2
 *
 *  A new Vector2 created by rotating the point in the coordinate system the Vector2
 *  as position vector determines rotated around point 'center' given as Vector2
 *  by an angle 'radians' in radians.
 */
static VALUE rg_vector2_rb_rotated_around(VALUE self, VALUE center, VALUE rad)
{
	rg_vector2 *a, *b, *c;
	Data_Get_Struct(self, rg_vector2, a);
	Data_Get_Struct(center, rg_vector2, b);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, c);
	
	rg_vector2_rotated_around(c, a, b, NUM2DBL(rad));
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    projected(Vector2 on) -> Vector2
 *
 *  Projects the Vector2 on another Vector2.
 */
static VALUE rg_vector2_rb_projected(VALUE self, VALUE project_on)
{
	rg_vector2 *a, *b, *c;

	Data_Get_Struct(self, rg_vector2, a);
	Data_Get_Struct(project_on, rg_vector2, b);

	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, c);
	
	rg_vector2_projected(c, a, b);
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    to_a -> [x, y]
 *
 *  Returns an array with the components.
 */
static VALUE rg_vector2_rb_to_a(VALUE self)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	return rb_ary_new3(2, rb_float_new(vector2->x), rb_float_new(vector2->y));
}

/* 
 *  call-seq:
 *    to_s -> String
 *
 *  The components as String.
 */
static VALUE rg_vector2_rb_to_s(VALUE self)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	VALUE str;
	char buf[255];
	
	snprintf(buf, 255, "%.0f, %.0f",
		vector2->x,
		vector2->y
	);
	str  = rb_str_new2(buf);
	return str;
}

/* 
 *  call-seq:
 *    inspect -> String
 *
 *  The components, magnitude and angle.
 */
static VALUE rg_vector2_rb_inspect(VALUE self)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	VALUE str;
	char buf[255];
	
	snprintf(buf, 255, "#<%s:0x%lx %.2f, %.2f (|%.2f|, %.1f°)>",
		rb_obj_classname(self),
		self,
		vector2->x,
		vector2->y,
		rg_vector2_magnitude(vector2),
		rg_vector2_angle_deg(vector2)
	);
	str  = rb_str_new2(buf);
	return str;
}

/*
 * Document-class: Rubygame::Body::Vector2
 *
 *  Vector2 (from Fake vecTOR, as it is similar to a vector but sports some
 *  methods that don't belong to a vector and also is limited to 2d) is
 *  a Vector like class, used to represent Points, Movements and Distances.
 */
void Init_Vector2()
{
	mRubygame = rb_define_module("Rubygame");
	mBody     = rb_define_module_under(mRubygame, "Body");

	cVector2    = rb_define_class_under(mBody, "Vector2", rb_cObject);

	rb_define_alloc_func(cVector2, rg_vector2_rb_singleton_alloc);

	rb_define_singleton_method(cVector2, "polar", rg_vector2_rb_singleton_polar, 2);
	rb_define_singleton_method(cVector2, "[]",    rg_vector2_rb_singleton_bracket, 2);

	rb_define_method(cVector2, "initialize",      rg_vector2_rb_initialize, 2);
	rb_define_method(cVector2, "initialize_copy", rg_vector2_rb_initialize_copy, 1);
	rb_define_method(cVector2, "x",               rg_vector2_rb_x, 0);
	rb_define_method(cVector2, "x=",              rg_vector2_rb_xset, 1);
	rb_define_method(cVector2, "y",               rg_vector2_rb_y, 0);
	rb_define_method(cVector2, "y=",              rg_vector2_rb_yset, 1);
	rb_define_method(cVector2, "magnitude",       rg_vector2_rb_magnitude, 0);
	rb_define_method(cVector2, "angle",           rg_vector2_rb_angle, 0);
	rb_define_method(cVector2, "angle_deg",       rg_vector2_rb_angle_deg, 0);
	rb_define_method(cVector2, "+",               rg_vector2_rb_binary_plus, 1);
	rb_define_method(cVector2, "-",               rg_vector2_rb_binary_minus, 1);
	rb_define_method(cVector2, "+@",              rg_vector2_rb_unary_plus, 0);
	rb_define_method(cVector2, "-@",              rg_vector2_rb_unary_minus, 0);
	rb_define_method(cVector2, "dot",             rg_vector2_rb_dotproduct, 1);
	rb_define_method(cVector2, "normalized",      rg_vector2_rb_normalized, 0);
	rb_define_method(cVector2, "resized_to",      rg_vector2_rb_resized_to, 1);
	rb_define_method(cVector2, "resized_by",      rg_vector2_rb_resized_by, 1);
	rb_define_method(cVector2, "rotated_to",      rg_vector2_rb_rotated_to, 1);
	rb_define_method(cVector2, "rotated_by",      rg_vector2_rb_rotated_by, 1);
	rb_define_method(cVector2, "rotated_around",  rg_vector2_rb_rotated_around, 2);
	rb_define_method(cVector2, "projected",       rg_vector2_rb_projected, 1);
	rb_define_method(cVector2, "to_a",            rg_vector2_rb_to_a, 0);
	rb_define_method(cVector2, "to_s",            rg_vector2_rb_to_s, 0);
	rb_define_method(cVector2, "inspect",         rg_vector2_rb_inspect, 0);
}
