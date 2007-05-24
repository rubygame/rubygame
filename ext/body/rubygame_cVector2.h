#ifndef _RUBYGAME_CFTOR_H
#define _RUBYGAME_CFTOR_H

typedef struct {
	double x;
	double y;
} rg_vector2;

extern VALUE cVector2;

// sum of two vector2s
void rg_vector2_add(rg_vector2 *result, rg_vector2 *a, rg_vector2 *b);

// difference of two vector2s
void rg_vector2_subtract(rg_vector2 *result, rg_vector2 *a, rg_vector2 *b);

// -(a,b) = (-a,-b)
void rg_vector2_negate(rg_vector2 *result, rg_vector2 *a);

// create an vector2 with magnitude magnitude and rotation rad (in radian)
void rg_vector2_set_polar(rg_vector2 *result, double magnitude, double rad);

// rotate an vector2 to angle rad (radians)
void rg_vector2_set_angle(rg_vector2 *result, rg_vector2 *a, double rad);

// rotate an vector2 by angle rad  (radians)
void rg_vector2_rotate(rg_vector2 *result, rg_vector2 *a, double rad);

// treat vector2 as position vector and rotate it around center by rad (radian)
void rg_vector2_rotate_around(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double rad);

// resize an vector2 to magnitude
void rg_vector2_set_magnitude(rg_vector2 *result, rg_vector2 *a, double magnitude);

// resize an vector2 by a factor
void rg_vector2_scale(rg_vector2 *result, rg_vector2 *a, double factor);

// treat vector2 as position vector and scale it away from the center by factor
void rg_vector2_scale_around(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double factor);

// the norm of a vector
void rg_vector2_normalize(rg_vector2 *result, rg_vector2 *a);

// the magnitude to the power of 2 of a vector, e.g. magnitude(3,4) = 25
double rg_vector2_magnitude_squared(rg_vector2 *a);

// the magnitude of a vector, e.g. magnitude(3,4) = 5
double rg_vector2_magnitude(rg_vector2 *a);

// the dot product of two vectors, a.b = a1*b1 + ... an*bn
double rg_vector2_dotproduct(rg_vector2 *a, rg_vector2 * b);

// the angle of a vector (relative to x axis)
double rg_vector2_angle(rg_vector2 *a);

// the angle of a vector (relative to x axis) in degree
double rg_vector2_angle_deg(rg_vector2 *a);

// the angle between two vectors
double rg_vector2_angle_between(rg_vector2 *a, rg_vector2 *b);

void Init_Vector2();

#endif
