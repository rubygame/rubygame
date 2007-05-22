#ifndef _RUBYGAME_CFTOR_H
#define _RUBYGAME_CFTOR_H

typedef struct {
	double x;
	double y;
} rg_ftor;

extern VALUE cFtor;

// sum of two ftors
void rg_ftor_add(rg_ftor *result, rg_ftor *a, rg_ftor *b);

// difference of two ftors
void rg_ftor_subtract(rg_ftor *result, rg_ftor *a, rg_ftor *b);

// -(a,b) = (-a,-b)
void rg_ftor_negate(rg_ftor *result, rg_ftor *a);

// create an ftor with magnitude magnitude and rotation rad (in radian)
void rg_ftor_magnitude_and_rotation(rg_ftor *result, double magnitude, double rad);

// rotate an ftor to angle rad (radians)
void rg_ftor_rotated_to(rg_ftor *result, rg_ftor *a, double rad);

// rotate an ftor by angle rad  (radians)
void rg_ftor_rotated_by(rg_ftor *result, rg_ftor *a, double rad);

// treat ftor as position vector and rotate it around center by rad (radian)
void rg_ftor_rotated_around(rg_ftor *result, rg_ftor *original, rg_ftor *center, double rad);

// resize an ftor to magnitude
void rg_ftor_resized_to(rg_ftor *result, rg_ftor *a, double magnitude);

// resize an ftor by a factor
void rg_ftor_resized_by(rg_ftor *result, rg_ftor *a, double factor);

// the norm of a vector
void rg_ftor_normalized(rg_ftor *result, rg_ftor *a);

// the magnitude to the power of 2 of a vector, e.g. magnitude(3,4) = 25
double rg_ftor_magnitude2(rg_ftor *a);

// the magnitude of a vector, e.g. magnitude(3,4) = 5
double rg_ftor_magnitude(rg_ftor *a);

// the dot product of two vectors, a.b = a1*b1 + ... an*bn
double rg_ftor_dotproduct(rg_ftor *a, rg_ftor * b);

// the angle of a vector (relative to x axis)
double rg_ftor_angle(rg_ftor *a);

// the angle of a vector (relative to x axis) in degree
double rg_ftor_angle_deg(rg_ftor *a);

// the angle between two vectors
double rg_ftor_angle_between(rg_ftor *a, rg_ftor *b);

void Init_Ftor();

#endif
