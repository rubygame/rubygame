// Rubygame::Body.collide(Rubygame::Body::Ftor[2,2], Rubygame::Body::Ftor[2,2])

#include <ruby.h>
#include <math.h>
#include "rg_cFtor.h"
#include "rg_cSegment.h"
#include "rg_cRect.h"
#include "rg_cCircle.h"
#include "body.h"

#define MAX_DELTA 0.001

static VALUE mRubygame;
static VALUE mBody;

static VALUE rg_cCircle;
static VALUE rg_cRect;
static VALUE rg_cSegment;
static VALUE rg_cFtor;

int rg_body_type(VALUE class)
{
	if (class == rg_cFtor)    return  1;
	if (class == rg_cSegment) return  2;
	if (class == rg_cRect)    return  4;
	if (class == rg_cCircle)  return  8;
	return 0;
}

// returns -1 on error, 0 if no collision and 1 if collides
int rg_body_collide(int ta, int tb, void *a, void *b)
{
	switch(ta | tb) {
		case  1: return rg_body_collide_ftor_ftor((rg_ftor*)a, (rg_ftor*)b);
		case  2: return rg_body_collide_segment_segment((rg_segment*)a,(rg_segment*)b);
		case  3: return rg_body_collide_ftor_segment((rg_ftor*)a,(rg_segment*)b);
		case  4: return rg_body_collide_rect_rect((rg_rect*)a,(rg_rect*)b);
		case  5: return rg_body_collide_ftor_rect((rg_ftor*)a,(rg_rect*)b);
		case  6: return rg_body_collide_segment_rect((rg_segment*)a,(rg_rect*)b);
		// case 7 would be ternary
		case  8: return rg_body_collide_circle_circle((rg_circle*)a,(rg_circle*)b);
		case  9: return rg_body_collide_ftor_circle((rg_ftor*)a,(rg_circle*)b);
		case 10: return rg_body_collide_segment_circle((rg_segment*)a,(rg_circle*)b);
		// case 11 would be ternary
		case 12: return rg_body_collide_rect_circle((rg_rect*)a,(rg_circle*)b);
		// case 13-14 would be ternary, case 15 quaternary
		default: return -1;
	}
}

int rg_body_collide_ftor_ftor(rg_ftor *a, rg_ftor *b)
{
	return ((fabs(a->x - b->x) < MAX_DELTA) && (fabs(a->y - b->y) < MAX_DELTA));
}

int rg_body_collide_ftor_segment(rg_ftor *a, rg_segment *b)
{
	double x = (a->x - b->start.x)/b->vec.x;
	return (x >= 0 && x <= 1 && fabs(x - ((a->y - b->start.y)/b->vec.y)) < MAX_DELTA);
}

int rg_body_collide_ftor_rect(rg_ftor *a, rg_rect *b)
{
	// it works by relocating the whole to Origin and then project the
	// point on the spanning vectors and see if it fits in
	rg_ftor r;
	rg_ftor_subtract(&r, a, &b->topleft);
	double x = rg_ftor_dotproduct(&r, &b->horizontal)/rg_ftor_magnitude2(&b->horizontal);
	double y = rg_ftor_dotproduct(&r, &b->vertical)/rg_ftor_magnitude2(&b->vertical);
	return (0 <= x && x <= 1 && 0 <= y && y <= 1);
}

int rg_body_collide_ftor_circle(rg_ftor *a, rg_circle *b)
{
	rg_ftor r;
	rg_ftor_subtract(&r, a, &b->center);
	return ((r.x*r.x+r.y*r.y-b->radius*b->radius) < MAX_DELTA);
}

int rg_body_collide_segment_segment(rg_segment *a, rg_segment *b)
{
	return 0;
}

int rg_body_collide_segment_rect(rg_segment *a, rg_rect *b)
{
	return 0;
}

int rg_body_collide_segment_circle(rg_segment *a, rg_circle *b)
{
	return 0;
}

int rg_body_collide_rect_rect(rg_rect *a, rg_rect *b)
{
	return 0;
}

int rg_body_collide_rect_circle(rg_rect *a, rg_circle *b)
{
	return 0;
}

int rg_body_collide_circle_circle(rg_circle *a, rg_circle *b)
{
	rg_ftor r;
	rg_ftor_subtract(&r, &a->center, &b->center);
	return ((rg_ftor_magnitude(&r)-MAX_DELTA) <= (a->radius+b->radius));
}

void rg_body_extract_struct(void *strct, VALUE class, VALUE x)
{
	if (class == rg_cFtor) {
		Data_Get_Struct(x, rg_ftor, strct);
	} else if (class == rg_cSegment)  {
		Data_Get_Struct(x, rg_segment, strct);
	} else if (class == rg_cRect) {
		Data_Get_Struct(x, rg_rect, strct);
	} else if (class == rg_cCircle) {
		Data_Get_Struct(x, rg_circle, strct);
	}
}

static VALUE rg_body_rb_type(VALUE class, VALUE obj)
{
	return INT2FIX(rg_body_type(CLASS_OF(obj)));
}

static VALUE rg_body_rb_collide(VALUE class, VALUE a, VALUE b)
{
	void *p_a;
	void *p_b;
	VALUE ca = CLASS_OF(a);
	VALUE cb = CLASS_OF(b);
	int   ta = rg_body_type(ca);
	int   tb = rg_body_type(cb);
	rg_body_extract_struct(p_a, ca, a);
	rg_body_extract_struct(p_b, cb, b);

	return INT2FIX(rg_body_collide(ta, tb, p_a, p_b));
}

void Init_body()
{
	Init_rg_cFtor();
	Init_rg_cSegment();
	Init_rg_cRect();
	Init_rg_cCircle();

	mRubygame = rb_define_module("Rubygame");
	mBody     = rb_define_module_under(mRubygame, "Body");

	rg_cCircle  = rb_define_class_under(mBody, "Circle", rb_cObject);
	rg_cRect    = rb_define_class_under(mBody, "Rect", rb_cObject);
	rg_cSegment = rb_define_class_under(mBody, "Segment", rb_cObject);
	rg_cFtor    = rb_define_class_under(mBody, "Ftor", rb_cObject);

	rb_define_singleton_method(mBody, "type", rg_body_rb_type, 1);
	rb_define_singleton_method(mBody, "collide?", rg_body_rb_collide, 2);
}
