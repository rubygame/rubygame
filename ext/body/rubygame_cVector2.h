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

void rg_vector2_move_by(rg_vector2 *result, rg_vector2 *original, rg_vector2 *change);

void rg_vector2_move_to(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, rg_vector2 *newpos);

// create an vector2 with magnitude magnitude and rotation rad (in radian)
void rg_vector2_set_polar(rg_vector2 *result, double magnitude, double rad);

// rotate an vector2 to angle rad (radians)
void rg_vector2_set_angle(rg_vector2 *result, rg_vector2 *a, double rad);

void rg_vector2_rotate_by(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double angle);

void rg_vector2_rotate_to(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double angle);

// resize an vector2 to magnitude
void rg_vector2_set_magnitude(rg_vector2 *result, rg_vector2 *a, double magnitude);

void rg_vector2_scale_by(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double factor);

void rg_vector2_scale_to(rg_vector2 *result, rg_vector2 *original, rg_vector2 *center, double new_scale);

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
