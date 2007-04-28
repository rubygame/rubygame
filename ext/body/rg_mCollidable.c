#include <ruby.h>
#include <math.h>
#include "rg_cFtor.h"
#include "rg_cSegment.h"
#include "rg_cRect.h"
#include "rg_cCircle.h"
#include "rg_mCollidable.h"
#include "defines.h"

static VALUE mRubygame;
static VALUE mBody;
static VALUE mCollidable;

static VALUE rg_cCircle;
static VALUE rg_cRect;
static VALUE rg_cSegment;
static VALUE rg_cFtor;
static ID rg_id_call;

int rg_collidable_type(VALUE class)
{
	if (class == rg_cFtor)    return  1;
	if (class == rg_cSegment) return  2;
	if (class == rg_cRect)    return  4;
	if (class == rg_cCircle)  return  8;
	return 0;
}

// ruby bail out if non-C-classes are involved
int rg_collidable_crb_collide(VALUE a, VALUE b)
{
	VALUE colliders = rb_iv_get(mCollidable, "@colliders");
	VALUE key = rb_ary_new3(2, CLASS_OF(a), CLASS_OF(b));
	VALUE collider  = rb_hash_aref(colliders, key);
	if (NIL_P(collider)) {
		rb_raise(rb_eArgError,"Could not collide %s with %s",
			rb_class2name(CLASS_OF(a)),
			rb_class2name(CLASS_OF(b))
		);
		return -1;
	}
	return RTEST(rb_funcall(collider, rg_id_call, 2, a, b)) ? 1 : 0;
}

// returns -1 on error, 0 if no collision and 1 if collides
int rg_collidable_cc_collide(int ta, int tb, void *a, void *b)
{
	if (ta > tb) {
		void *tmp;
		tmp = a;
		a = b;
		b = tmp;
	}
	switch(ta | tb) {
		case  1: return rg_collidable_collide_ftor_ftor((rg_ftor*)a, (rg_ftor*)b);
		case  2: return rg_collidable_collide_segment_segment((rg_segment*)a,(rg_segment*)b);
		case  3: return rg_collidable_collide_ftor_segment((rg_ftor*)a,(rg_segment*)b);
		case  4: return rg_collidable_collide_rect_rect((rg_rect*)a,(rg_rect*)b);
		case  5: return rg_collidable_collide_ftor_rect((rg_ftor*)a,(rg_rect*)b);
		case  6: return rg_collidable_collide_segment_rect((rg_segment*)a,(rg_rect*)b);
		// case 7 would be ternary
		case  8: return rg_collidable_collide_circle_circle((rg_circle*)a,(rg_circle*)b);
		case  9: return rg_collidable_collide_ftor_circle((rg_ftor*)a,(rg_circle*)b);
		case 10: return rg_collidable_collide_segment_circle((rg_segment*)a,(rg_circle*)b);
		// case 11 would be ternary
		case 12: return rg_collidable_collide_rect_circle((rg_rect*)a,(rg_circle*)b);
		// case 13-14 would be ternary, case 15 quaternary
		default: return -1;
	}
}

int rg_collidable_collide_ftor_ftor(rg_ftor *a, rg_ftor *b)
{
	return ((fabs(a->x - b->x) < MAX_DELTA) && (fabs(a->y - b->y) < MAX_DELTA));
}

int rg_collidable_collide_ftor_segment(rg_ftor *a, rg_segment *b)
{
	double x = (a->x - b->start.x)/b->vec.x;
	return (x >= 0 && x <= 1 && fabs(x - ((a->y - b->start.y)/b->vec.y)) < MAX_DELTA);
}

int rg_collidable_collide_ftor_rect(rg_ftor *a, rg_rect *b)
{
	// it works by relocating the whole to Origin and then project the
	// point on the spanning vectors and see if it fits in
	rg_ftor r;
	rg_ftor_subtract(&r, a, &b->topleft);
	double x = rg_ftor_dotproduct(&r, &b->horizontal)/rg_ftor_magnitude2(&b->horizontal);
	double y = rg_ftor_dotproduct(&r, &b->vertical)/rg_ftor_magnitude2(&b->vertical);
	return (0 <= x && x <= 1 && 0 <= y && y <= 1);
}

int rg_collidable_collide_ftor_circle(rg_ftor *a, rg_circle *b)
{
	rg_ftor r;
	rg_ftor_subtract(&r, a, &b->center);
	return ((r.x*r.x+r.y*r.y-b->radius*b->radius) < MAX_DELTA);
}

int rg_collidable_collide_segment_segment(rg_segment *a, rg_segment *b)
{
	return 0;
}

int rg_collidable_collide_segment_rect(rg_segment *a, rg_rect *b)
{
	rg_segment top_b;
	rg_rect_top(&top_b, b);
	if (rg_collidable_collide_segment_segment(&top_b, a)) return 1;
	rg_segment right_b;
	rg_rect_right(&right_b, b);
	if (rg_collidable_collide_segment_segment(&right_b, a)) return 1;
	rg_segment bottom_b;
	rg_rect_top(&bottom_b, b);
	if (rg_collidable_collide_segment_segment(&bottom_b, a)) return 1;
	rg_segment left_b;
	rg_rect_top(&left_b, b);
	if (rg_collidable_collide_segment_segment(&left_b, a)) return 1;

	return 0;
}

int rg_collidable_collide_segment_circle(rg_segment *a, rg_circle *b)
{
	return 0;
}

int rg_collidable_collide_rect_rect(rg_rect *a, rg_rect *b)
{
	rg_segment top_a;
	rg_rect_top(&top_a, a);
	if (rg_collidable_collide_segment_rect(&top_a, b)) return 1;
	rg_segment right_a;
	rg_rect_right(&right_a, a);
	if (rg_collidable_collide_segment_rect(&right_a, b)) return 1;
	rg_segment bottom_a;
	rg_rect_top(&bottom_a, a);
	if (rg_collidable_collide_segment_rect(&bottom_a, b)) return 1;
	rg_segment left_a;
	rg_rect_top(&left_a, a);
	if (rg_collidable_collide_segment_rect(&left_a, b)) return 1;
	return 0;
}

int rg_collidable_collide_rect_circle(rg_rect *a, rg_circle *b)
{
	rg_segment top_a;
	rg_rect_top(&top_a, a);
	if (rg_collidable_collide_segment_circle(&top_a, b)) return 1;
	rg_segment right_a;
	rg_rect_right(&right_a, a);
	if (rg_collidable_collide_segment_circle(&right_a, b)) return 1;
	rg_segment bottom_a;
	rg_rect_top(&bottom_a, a);
	if (rg_collidable_collide_segment_circle(&bottom_a, b)) return 1;
	rg_segment left_a;
	rg_rect_top(&left_a, a);
	if (rg_collidable_collide_segment_circle(&left_a, b)) return 1;
	return 0;
}

int rg_collidable_collide_circle_circle(rg_circle *a, rg_circle *b)
{
	rg_ftor r;
	rg_ftor_subtract(&r, &a->center, &b->center);
	return ((rg_ftor_magnitude(&r)-MAX_DELTA) <= (a->radius+b->radius));
}

void rg_collidable_extract_struct(void **strct, VALUE class, VALUE x)
{
	if (class == rg_cFtor) {
		Data_Get_Struct(x, rg_ftor, *strct);
	} else if (class == rg_cSegment)  {
		Data_Get_Struct(x, rg_segment, *strct);
	} else if (class == rg_cRect) {
		Data_Get_Struct(x, rg_rect, *strct);
	} else if (class == rg_cCircle) {
		Data_Get_Struct(x, rg_circle, *strct);
	} else {
		rb_warn("couldn't extract struct");
	}
}

int rg_collidable_collide_bodies(VALUE a, VALUE b)
{
	void *p_a;
	void *p_b;
	VALUE ca = CLASS_OF(a);
	VALUE cb = CLASS_OF(b);
	int   ta = rg_collidable_type(ca);
	int   tb = rg_collidable_type(cb);
	
	if (ta && tb) {
		rg_collidable_extract_struct(&p_a, ca, a);
		rg_collidable_extract_struct(&p_b, cb, b);
		
		return rg_collidable_cc_collide(ta, tb, p_a, p_b);
	} else {
		return rg_collidable_crb_collide(a, b);
	}
}

/*** RUBY STUFF ***************************************************************/
static VALUE rg_collidable_rb_type(VALUE class, VALUE obj)
{
	return INT2FIX(rg_collidable_type(CLASS_OF(obj)));
}

/*
static VALUE rg_collidable_rb_collide(VALUE class, VALUE a, VALUE b)
{
	void *p_a;
	void *p_b;
	VALUE ca = CLASS_OF(a);
	VALUE cb = CLASS_OF(b);
	int   ta = rg_collidable_type(ca);
	int   tb = rg_collidable_type(cb);
	rg_collidable_extract_struct(p_a, ca, a);
	rg_collidable_extract_struct(p_b, cb, b);

	return INT2FIX(rg_collidable_collide(ta, tb, p_a, p_b));
}
*/

static VALUE rg_collidable_rb_collide_single(VALUE self, VALUE other)
{
	switch(rg_collidable_collide_bodies(self, other)) {
		case -1:
			rb_raise(rb_eArgError,"Could not collide %s with %s",
				rb_class2name(CLASS_OF(self)),
				rb_class2name(CLASS_OF(other))
			);
		case 0:
			return Qnil;
		case 1:
			return other;
		default:
			rb_raise(rb_eNotImpError,"Unexpected return value from collide_bodes.");
	}
	return Qnil;			
}

static VALUE rg_collidable_rb_collide(int argc, VALUE *argv, VALUE self)
{
	VALUE rb_objects, rb_stop_after;
	rb_scan_args(argc, argv, "11", &rb_objects, &rb_stop_after);
  
	int stop_after = NIL_P(rb_stop_after) ? FIX2INT(rb_stop_after) : 1;
	int items      = RARRAY(rb_objects)->len;
	VALUE entry;
	VALUE results  = rb_ary_new();
	for (int i=0; i<items; i++) {
		entry = rb_ary_entry(rb_objects, i);
		if (rg_collidable_collide_bodies(self, entry)) {
			if (rb_block_given_p()) {
				rb_ary_push(results, rb_yield(entry));
			} else {
				rb_ary_push(results, entry);
			}
		}
	}
	return results;
}

static VALUE rg_collidable_rb_collide_key(int argc, VALUE *argv, VALUE self)
{
	return Qnil;
}

void Init_rg_mCollidable()
{
	ID rg_id_call = rb_intern("call");

	mRubygame   = rb_define_module("Rubygame");
	mBody       = rb_define_module_under(mRubygame, "Body");
	mCollidable = rb_define_module_under(mBody, "Collidable");
	
	rb_iv_set(mCollidable, "@colliders", rb_hash_new());

	rg_cFtor    = rb_define_class_under(mBody, "Ftor", rb_cObject);
	rg_cSegment = rb_define_class_under(mBody, "Segment", rb_cObject);
	rg_cRect    = rb_define_class_under(mBody, "Rect", rb_cObject);
	rg_cCircle  = rb_define_class_under(mBody, "Circle", rb_cObject);

	rb_define_method(mCollidable, "collide?", rg_collidable_rb_collide_single, 1);
	rb_define_method(mCollidable, "collide", rg_collidable_rb_collide, -1);
	rb_define_method(mCollidable, "collide_key", rg_collidable_rb_collide_key, -1);
}
