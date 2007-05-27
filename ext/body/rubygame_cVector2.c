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

void rg_vector2_multiply_scalar(rg_vector2 *result, rg_vector2 *a, double scalar)
{
	result->x = a->x * scalar;
	result->y = a->y * scalar;
}

void rg_vector2_multiply_nonuniform(rg_vector2 *result, rg_vector2 *a, rg_vector2 *scale)
{
	result->x = a->x * scale->x;
	result->y = a->y * scale->y;
}

void rg_vector2_negate(rg_vector2 *result, rg_vector2 *a)
{
	result->x = -a->x;
	result->y = -a->y;
}

void rg_vector2_move_by(rg_vector2 *result, rg_vector2 *original, rg_vector2 *change)
{
	rg_vector2_add(result, original, change);
}

void rg_vector2_move_to(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, rg_vector2 *newpos)
{
	rg_vector2_add(result, original, newpos);
	rg_vector2_subtract(result, result, center);
}

void rg_vector2_set_polar(rg_vector2 *result, double magnitude, double rad)
{
	result->x = cos(rad)*magnitude;
	result->y = sin(rad)*magnitude;
}

void rg_vector2_set_angle(rg_vector2 *result, rg_vector2 *a, double rad)
{
	rg_vector2_set_polar(result, rg_vector2_magnitude(a), rad);
}

void rg_vector2_rotate_by(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double angle)
{
	rg_vector2_subtract(result, original, center);
	rg_vector2_set_angle(result, result, rg_vector2_angle(original)+angle);
	rg_vector2_add(result, center, result);
}

void rg_vector2_rotate_to(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double angle)
{
	rg_vector2_subtract(result, original, center);
	rg_vector2_set_angle(result, result, angle);
	rg_vector2_add(result, center, result);
}

void rg_vector2_set_magnitude(rg_vector2 *result, rg_vector2 *a, double magnitude)
{
	rg_vector2_set_polar(result, magnitude, rg_vector2_angle(a));
}

void rg_vector2_scale_by(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double factor)
{
	rg_vector2_subtract(result, original, center);
	rg_vector2_set_magnitude(result, result, rg_vector2_magnitude(original)*factor);
	rg_vector2_add(result, center, result);
}

void rg_vector2_scale_to(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double new_scale)
{
	rg_vector2_subtract(result, original, center);
	rg_vector2_set_magnitude(result, result, new_scale);
	rg_vector2_add(result, center, result);
}

void rg_vector2_scale_by_nonuniform(result, original, center, factors)
		 rg_vector2 *result, *original, *center, *factors;
{
	rg_vector2_subtract(result, original, center);
	rg_vector2_multiply_nonuniform( result, result, factors );
	rg_vector2_add(result, center, result);
}

void rg_vector2_scale_to_nonuniform(result, original, center, newscale)
		 rg_vector2 *result, *original, *center, *newscale;
{
	result->x = newscale->x;
	result->y = newscale->y;
	rg_vector2_add(result, center, result);
}

void rg_vector2_normalize(rg_vector2 *result, rg_vector2 *a)
{
	rg_vector2_set_magnitude(result, a, 1.0);
}

void rg_vector2_project(rg_vector2 *result, rg_vector2 *project, rg_vector2 *on)
{
	double fac = rg_vector2_dotproduct(project, on)/rg_vector2_magnitude_squared(on);
	result->x = on->x*fac;
	result->y = on->y*fac;
}

double rg_vector2_magnitude(rg_vector2 *a)
{
	return sqrt(rg_vector2_magnitude_squared(a));
}

double rg_vector2_magnitude_squared(rg_vector2 *a)
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
 *  Create a Vector2 from components.
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
 *    Vector2.polar(angle, magnitude) -> Vector2
 *
 *  Create a Vector2 from angle (in radians) and magnitude.
 */
static VALUE rg_vector2_rb_singleton_polar(VALUE class, VALUE angle, VALUE mag)
{
	rg_vector2 *vector2;
	VALUE rb_vector2 = Data_Make_Struct(class, rg_vector2, NULL, free, vector2);
	rg_vector2_set_polar(vector2, NUM2DBL(mag), NUM2DBL(angle));
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    Vector2.polar_deg(angle, magnitude) -> Vector2
 *
 *  Create a Vector2 from angle (in degrees) and magnitude.
 */
static VALUE rg_vector2_rb_singleton_polar_deg(VALUE class, VALUE angle, VALUE mag)
{
	rg_vector2 *vector2;
	VALUE rb_vector2 = Data_Make_Struct(class, rg_vector2, NULL, free, vector2);
	rg_vector2_set_polar(vector2, NUM2DBL(mag), DEG2RAD(NUM2DBL(angle)));
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    Vector2.new(x,y) -> Vector2
 *
 *  Create a Vector2 from components. See also Vector2::[]
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
	rg_vector2 *a, *b;
	Data_Get_Struct(self, rg_vector2, a);
	Data_Get_Struct(old, rg_vector2, b);

	*a = *b;
	
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
static VALUE rg_vector2_rb_set_x(VALUE self, VALUE vx)
{
	if(OBJ_FROZEN(self))
	{
		rb_raise(rb_eTypeError, "can't modify frozen object");
	}

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
static VALUE rg_vector2_rb_set_y(VALUE self, VALUE vy)
{
	if(OBJ_FROZEN(self))
	{
		rb_raise(rb_eTypeError, "can't modify frozen object");
	}

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
 *  I.e. the distance between 5,5 and 10,8 is:
 *    (Vector2[5,5]-Vector2[10,8]).magnitude.
 */
static VALUE rg_vector2_rb_magnitude(VALUE self)
{
	rg_vector2 *vector2;
	Data_Get_Struct(self, rg_vector2, vector2);
	return rb_float_new(rg_vector2_magnitude(vector2));
}

/*
 *  call-seq:
 *    self.magnitude = new_magnitude
 *
 *  Set the magnitude of the receiver to new_magnitude, preserving angle.
 */
static VALUE rg_vector2_rb_set_magnitude(VALUE self, VALUE size)
{
	if(OBJ_FROZEN(self))
	{
		rb_raise(rb_eTypeError, "can't modify frozen object");
	}

	rg_vector2 *v;
	Data_Get_Struct(self, rg_vector2, v);
	rg_vector2_set_magnitude(v, v, NUM2DBL(size));
	return size;
}

/* 
 *  call-seq:
 *    angle -> Float
 *
 *  The angle of the receiver in radians.
 */
static VALUE rg_vector2_rb_angle(VALUE self)
{
	rg_vector2 *v;
	Data_Get_Struct(self, rg_vector2, v);
	return rb_float_new(rg_vector2_angle(v));
}

/* 
 *  call-seq:
 *    angle = new_angle
 *
 *  Set the angle of the receiver in radians, preserving magnitude.
 */
static VALUE rg_vector2_rb_set_angle(VALUE self, VALUE angle)
{
	if(OBJ_FROZEN(self))
	{
		rb_raise(rb_eTypeError, "can't modify frozen object");
	}

	rg_vector2 *v;
	Data_Get_Struct(self, rg_vector2, v);
	rg_vector2_set_angle(v, v, NUM2DBL(angle));
	return angle;
}

/* 
 *  call-seq:
 *    angle_deg -> Float
 *
 *  The angle of a the receiver in degrees.
 */
static VALUE rg_vector2_rb_angle_deg(VALUE self)
{
	rg_vector2 *v;
	Data_Get_Struct(self, rg_vector2, v);
	return rb_float_new(rg_vector2_angle_deg(v));
}

/* 
 *  call-seq:
 *    angle_deg = new_angle
 *
 *  Set the angle of the receiver in degrees, preserving magnitude.
 */
static VALUE rg_vector2_rb_set_angle_deg(VALUE self, VALUE angle)
{
	if(OBJ_FROZEN(self))
	{
		rb_raise(rb_eTypeError, "can't modify frozen object");
	}

	rg_vector2 *v;
	Data_Get_Struct(self, rg_vector2, v);
	rg_vector2_set_angle(v, v, DEG2RAD(NUM2DBL(angle)));
	return angle;
}

/* 
 *  call-seq:
 *    self + other -> Vector2
 *
 *  Sum of two Vector2s (component wise addition).
 */
static VALUE rg_vector2_rb_add(VALUE self, VALUE other)
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
static VALUE rg_vector2_rb_subtract(VALUE self, VALUE other)
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
 *    self * scalar -> Vector2
 *
 *  Multiply both components of the receiver by the scalar.
 */
static VALUE rg_vector2_rb_scalar_multiply(VALUE self, VALUE vscalar)
{
	rg_vector2 *vec, *result;
	Data_Get_Struct(self, rg_vector2, vec);

	VALUE vresult = Data_Make_Struct(cVector2, rg_vector2, NULL, free, result);
	rg_vector2_multiply_scalar(result, vec, NUM2DBL(vscalar));

	return vresult;
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
 *  Returns the dot product between receiver and other_vector2.
 *  The dot product is the sum of the products of the components:
 *   a.x*b.x + a.y*b.y
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
 *    unit -> Vector2
 *
 *  Returns a Vector2 with the same angle as the receiver, but magnitude 1.0.
 *  (A vector with magnitude = 1 is called a "unit vector" or "normalized vector".)
 */
static VALUE rg_vector2_rb_unit(VALUE self)
{
	rg_vector2 *a, *b;
	Data_Get_Struct(self, rg_vector2, a);
	VALUE rb_vector2 = Data_Make_Struct(cVector2, rg_vector2, NULL, free, b);
	
	rg_vector2_normalize(b, a);
	return rb_vector2;	
}

/* 
 *  call-seq:
 *    unit! -> self
 *
 *  Sets the magnitude of the receiver to 1.0.
 */
static VALUE rg_vector2_rb_unit_bang(VALUE self)
{
	if(OBJ_FROZEN(self))
	{
		rb_raise(rb_eTypeError, "can't modify frozen object");
	}

	rg_vector2 *a;
	Data_Get_Struct(self, rg_vector2, a);
	rg_vector2_normalize(a, a);
	return self;
}

/* returns vpivot if it's a Vector2, or a new Vector2 with
 * the default x and y if vpivot is nil. If it's anything else,
 * raises a type error.
 */
VALUE get_pivot(VALUE vpivot, double default_x, double default_y)
{
	rg_vector2 *pivot;

	if(NIL_P(vpivot))
	{
		vpivot = Data_Make_Struct(cVector2, rg_vector2, NULL, free, pivot);
		pivot->x = default_x;
		pivot->y = default_y;
		return vpivot;
	}
	else if( rb_obj_is_kind_of( vpivot, rb_class_real(cVector2) ) )
	{
		return vpivot;
	}

	rb_raise( rb_eTypeError, "couldn't convert %s to Vector2",
						rb_obj_classname(vpivot) );

}

/* 
 *  call-seq:
 *    moved_by( change )  ->  Vector2
 *
 *  Move the receiver by change (Vector2).
 */
static VALUE rg_vector2_rb_moved_by(VALUE self, VALUE vchange)
{
	rg_vector2 *vec, *change, *result;
	Data_Get_Struct(self,    rg_vector2, vec);
	Data_Get_Struct(vchange, rg_vector2, change);
	VALUE vresult = Data_Make_Struct(cVector2, rg_vector2, NULL, free, result);
	
	rg_vector2_move_by(result, vec, change);
	return vresult;
}

/* 
 *  call-seq:
 *    moved_to( new_position, pivot=self )  ->  Vector2
 *
 *  Move the receiver such that the pivot point would be at new_position.
 *  I.e. moves the receiver by the vector (new_position - pivot).
 */
static VALUE rg_vector2_rb_moved_to(int argc, VALUE *argv, VALUE self)
{
	rg_vector2 *vec, *pivot, *newpos, *result;
	VALUE vnewpos, vpivot, vresult;

	rb_scan_args(argc, argv, "11", &vnewpos, &vpivot);
	Data_Get_Struct(self,    rg_vector2, vec);
	Data_Get_Struct(vnewpos, rg_vector2, newpos);
	vpivot = get_pivot(vpivot, vec->x,vec->y);
	Data_Get_Struct(vpivot,  rg_vector2, pivot);
	vresult = Data_Make_Struct(cVector2, rg_vector2, NULL, free, result);
	
	rg_vector2_move_to(result, vec, pivot, newpos);
	return vresult;
}

/* 
 *  call-seq:
 *    scaled_by( factor, pivot=Vector2[0,0] )  ->  result
 *
 *    scale::   Uniform or non-uniform (component-wise) scale factor
 *              [required Numeric or Vector2]
 *    Returns:: New Vector2 with the scale applied
 *              [Vector2]
 *
 *  Apply the scale to the receiver, scaling from the pivot point.
 *
 *  If scale is a Numeric, it is applied with scalar multiplication for
 *  uniform transformation.
 *
 *  If scale is a Vector2, it is applied with component-wise multiplication for
 *  non-uniform transformation. 
 *  I.e. Vector2[self.x * scale.x, self.y * scale.y]
 *  (Non-uniform transformation can change the angle of the Vector2.)
 */
static VALUE rg_vector2_rb_scaled_by(int argc, VALUE *argv, VALUE self)
{
	rg_vector2 *vec, *pivot, *result;
	VALUE vfactor, vpivot, vresult;

	rb_scan_args(argc, argv, "11", &vfactor, &vpivot);
	vpivot = get_pivot(vpivot, 0,0);
	Data_Get_Struct(self,   rg_vector2, vec);
	Data_Get_Struct(vpivot, rg_vector2, pivot);
	vresult = Data_Make_Struct(cVector2, rg_vector2, NULL, free, result);

	if( TYPE(vfactor) == T_FIXNUM || TYPE(vfactor) == T_FLOAT )
	{
		rg_vector2_scale_by(result, vec, pivot, NUM2DBL(vfactor));
	}
	else if( rb_obj_is_kind_of( vfactor, rb_class_real(cVector2) ) )
	{
		rg_vector2 *factors;
		Data_Get_Struct(vfactor, rg_vector2, factors);
		rg_vector2_scale_by_nonuniform(result, vec, pivot, factors);
	}

	return vresult;
}

/* 
 *  call-seq:
 *    scaled_to( new_scale, pivot=Vector2[0,0] )  ->  result
 *
 *    new_scale:: Uniform or non-uniform (component-wise) scale factor
 *                [required Numeric or Vector2]
 *    Returns::   New Vector2 with the given scale
 *                [Vector2]
 *
 *  Apply the scale to the receiver, scaling from the pivot point.
 *
 *  If scale is a Numeric, it is applied with scalar multiplication for
 *  uniform transformation.
 *
 *  If scale is a Vector2, it is applied with component-wise multiplication for
 *  non-uniform transformation. 
 *  I.e. Vector2[self.x * scale.x, self.y * scale.y]
 *  (Non-uniform transformation can change the angle of the Vector2.)
 */
static VALUE rg_vector2_rb_scaled_to(int argc, VALUE *argv, VALUE self)
{
	rg_vector2 *vec, *pivot, *result;
	VALUE vnewscale, vpivot, vresult;

	rb_scan_args(argc, argv, "11", &vnewscale, &vpivot);
	vpivot = get_pivot(vpivot, 0,0);
	Data_Get_Struct(self,   rg_vector2, vec);
	Data_Get_Struct(vpivot, rg_vector2, pivot);
	vresult = Data_Make_Struct(cVector2, rg_vector2, NULL, free, result);

	if( TYPE(vnewscale) == T_FIXNUM || TYPE(vnewscale) == T_FLOAT )
	{
		rg_vector2_scale_to(result, vec, pivot, NUM2DBL(vnewscale));
	}
	else if( rb_obj_is_kind_of( vnewscale, rb_class_real(cVector2) ) )
	{
		rg_vector2 *newscale;
		Data_Get_Struct(vnewscale, rg_vector2, newscale);
		rg_vector2_scale_to_nonuniform(result, vec, pivot, newscale);
	}

	return vresult;
}

/* 
 *  call-seq:
 *    rotated_by( angle, pivot=Vector2[0,0] )  ->  Vector2
 *
 *  Returns a duplicate of the receiver, rotated by angle (radians) around
 *  the pivot point.
 */
static VALUE rg_vector2_rb_rotated_by(int argc, VALUE *argv, VALUE self)
{
	rg_vector2 *vec, *pivot, *result;
	VALUE vangle, vpivot, vresult;

	rb_scan_args(argc, argv, "11", &vangle, &vpivot);
	vpivot = get_pivot(vpivot, 0,0);
	Data_Get_Struct(self,   rg_vector2, vec);
	Data_Get_Struct(vpivot, rg_vector2, pivot);
	vresult = Data_Make_Struct(cVector2, rg_vector2, NULL, free, result);
	
	rg_vector2_rotate_by(result, vec, pivot, NUM2DBL(vangle));
	return vresult;
}

/* 
 *  call-seq:
 *    rotated_to( new_angle, pivot=Vector2[0,0] )  ->  Vector2
 *
 *  Returns a duplicate of the receiver, rotated around the pivot point
 *  such that the angle of the new Vector2 relative to the pivot equals new_angle.
 *
 *  I.e. If you conceive of the result being a point in space, a vector connecting
 *  the pivot point to the result would have an angle of new_angle (measured from the
 *  positive X axis).
 *
 *  I.e. (result - pivot).angle == new_angle
 */
static VALUE rg_vector2_rb_rotated_to(int argc, VALUE *argv, VALUE self)
{
	rg_vector2 *vec, *pivot, *result;
	VALUE vnewangle, vpivot, vresult;

	rb_scan_args(argc, argv, "11", &vnewangle, &vpivot);
	vpivot = get_pivot(vpivot, 0,0);
	Data_Get_Struct(self,   rg_vector2, vec);
	Data_Get_Struct(vpivot, rg_vector2, pivot);
	vresult = Data_Make_Struct(cVector2, rg_vector2, NULL, free, result);
	
	rg_vector2_rotate_to(result, vec, pivot, NUM2DBL(vnewangle));
	return vresult;
}

/* 
 *  call-seq:
 *    projected(Vector2 other) -> Vector2
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
	rb_define_method(cVector2, "x=",              rg_vector2_rb_set_x, 1);
	rb_define_method(cVector2, "y",               rg_vector2_rb_y, 0);
	rb_define_method(cVector2, "y=",              rg_vector2_rb_set_y, 1);
	rb_define_method(cVector2, "magnitude",       rg_vector2_rb_magnitude, 0);
	rb_define_method(cVector2, "magnitude=",      rg_vector2_rb_set_magnitude,1);
	rb_define_method(cVector2, "angle",           rg_vector2_rb_angle, 0);
	rb_define_method(cVector2, "angle_deg",       rg_vector2_rb_angle_deg, 0);
	rb_define_method(cVector2, "angle=",          rg_vector2_rb_set_angle,1);
	rb_define_method(cVector2, "angle_deg=",      rg_vector2_rb_set_angle_deg,1);
	rb_define_method(cVector2, "+",               rg_vector2_rb_add, 1);
	rb_define_method(cVector2, "-",               rg_vector2_rb_subtract, 1);
	rb_define_method(cVector2, "*",               rg_vector2_rb_scalar_multiply, 1);
	rb_define_method(cVector2, "+@",              rg_vector2_rb_unary_plus, 0);
	rb_define_method(cVector2, "-@",              rg_vector2_rb_unary_minus, 0);
	rb_define_method(cVector2, "dot",             rg_vector2_rb_dotproduct, 1);
	rb_define_method(cVector2, "unit",            rg_vector2_rb_unit, 0);
	rb_define_method(cVector2, "unit!",           rg_vector2_rb_unit_bang, 0);
	rb_define_method(cVector2, "moved_by",        rg_vector2_rb_moved_by, 1);
	rb_define_method(cVector2, "moved_to",        rg_vector2_rb_moved_to, -1);
	rb_define_method(cVector2, "scaled_by",       rg_vector2_rb_scaled_by, -1);
	rb_define_method(cVector2, "scaled_to",       rg_vector2_rb_scaled_to, -1);
	rb_define_method(cVector2, "rotated_by",      rg_vector2_rb_rotated_by, -1);
	rb_define_method(cVector2, "rotated_to",      rg_vector2_rb_rotated_to, -1);
	rb_define_method(cVector2, "projected",       rg_vector2_rb_projected, 1);
	rb_define_method(cVector2, "to_a",            rg_vector2_rb_to_a, 0);
	rb_define_method(cVector2, "to_s",            rg_vector2_rb_to_s, 0);
	rb_define_method(cVector2, "inspect",         rg_vector2_rb_inspect, 0);
}
