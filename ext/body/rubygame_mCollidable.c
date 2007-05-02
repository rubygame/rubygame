/*
	FIXME: bodies totally included in another body don't yet
	collide.
*/

#include <ruby.h>
#include <math.h>
#include "rubygame_cFtor.h"
#include "rubygame_cSegment.h"
#include "rubygame_cRect.h"
#include "rubygame_cCircle.h"
#include "rubygame_mCollidable.h"
#include "rubygame_defines.h"

static VALUE mRubygame;
static VALUE mBody;
static VALUE mCollidable;

static VALUE rg_cCircle;
static VALUE rg_cRect;
static VALUE rg_cSegment;
static VALUE rg_cFtor;
static ID rg_id_call;
static ID rg_id_body;

int rg_collidable_collide_bodies(VALUE a, VALUE b)
{
	void *p_a;
	void *p_b;
	VALUE ca = CLASS_OF(a);
	VALUE cb = CLASS_OF(b);
	int   ta = rg_collidable_type(ca);
	int   tb = rg_collidable_type(cb);

	// use body attribute if present
	if (ta == 0 && rb_respond_to(a, rg_id_body)) {
		a  = rb_funcall(a, rg_id_body, 0);
		ca = CLASS_OF(a);
		ta = rg_collidable_type(ca);
	}
	if (tb == 0 && rb_respond_to(b, rg_id_body)) {
		b  = rb_funcall(b, rg_id_body, 0);
		cb = CLASS_OF(b);
		tb = rg_collidable_type(cb);
	}
	
	if (ta && tb) {
		rg_collidable_extract_struct(&p_a, ca, a);
		rg_collidable_extract_struct(&p_b, cb, b);
		
		return rg_collidable_cc_collide(ta, tb, p_a, p_b);
	} else {
		return rg_collidable_crb_collide(a, b);
	}
}

int rg_collidable_type(VALUE class)
{
	if (class == rg_cFtor)    return  1;
	if (class == rg_cSegment) return  2;
	if (class == rg_cRect)    return  4;
	if (class == rg_cCircle)  return  8;
	return 0;
}

void swap_rows(int len, double *x, double *y)
{
	int i;
	double tmp;
	for (i = 0; i < len; i++) {
		tmp  = *(x+i);
		*(x+i) = *(y+i);
		*(y+i) = tmp;
	}
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

// ruby bail out if non-C-classes are involved
int rg_collidable_crb_collide(VALUE a, VALUE b)
{
	VALUE colliders = rb_iv_get(mCollidable, "@colliders");
	VALUE key = rb_ary_new3(2, CLASS_OF(a), CLASS_OF(b));
	VALUE collider  = rb_hash_aref(colliders, key);
	if (NIL_P(collider)) {
		rb_raise(rb_eArgError,"Could not collide %s with %s (crb_collide)",
			rb_class2name(CLASS_OF(a)),
			rb_class2name(CLASS_OF(b))
		);
		return -1;
	}
	return RTEST(rb_funcall(collider, rg_id_call, 2, a, b)) ? 1 : 0;
}

int rg_collidable_collide_ftor_ftor(rg_ftor *a, rg_ftor *b)
{
	return (FEQUAL(a->x, b->x) && FEQUAL(a->y, b->y));
}

int rg_collidable_collide_ftor_segment(rg_ftor *a, rg_segment *b)
{
	double x = (a->x - b->start.x)/b->vec.x;
	return (x >= 0 && x <= 1 && FEQUAL(x, ((a->y - b->start.y)/b->vec.y)));
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
	return FBETWEEN(r.x*r.x+r.y*r.y,0,b->radius*b->radius);
}

// I'm sure this could be done far more elegantly
int rg_collidable_collide_segment_segment(rg_segment *a, rg_segment *b)
{
	/*
		We only have to check if the system of linear equations:
		(a->start.x + K*a->vec.x) - (b->start.x + J*b->vec.x) = 0
		(a->start.y + K*a->vec.y) - (b->start.y + J*b->vec.y) = 0
		K and J must be between 0 and 1.

	a1 b1 c1 -> a.vec.x, -b.vec.x, b.start.x-a.start.x
	a2 b2 c2 -> a.vec.y, -b.vec.y, b.start.y-a.start.y
	*/
	double x[3] = { a->vec.x, -b->vec.x, b->start.x-a->start.x };
	double y[3] = { a->vec.y, -b->vec.y, b->start.y-a->start.y };

	// set equation[1][0] to 0
	if (x[0] == 0) {
		if (y[0] != 0) swap_rows(3, x, y);
	} else {
		if (y[1] != 0) {
			double f = y[0]/x[0];
			y[0] = 0;
			y[1] -= f*x[1];
			y[2] -= f*x[2];
		}
	}

	if (x[1] != 0 && y[1] != 0) {
		x[2] -= y[2]*x[1]/y[1];
		x[1] = 0;
	}
	
	if (x[0] != 0) {
		x[2] /= x[0];
	}
	if (y[1] != 0) {
		y[2] /= y[1];
		return (FBETWEEN(x[2], 0, 1) && FBETWEEN(y[2], 0, 1));
	} else if (y[2] == 0) {
		if (rg_collidable_collide_ftor_segment(&a->start, b)) return 1;
		rg_ftor end;
		rg_ftor_add(&end, &a->start, &a->vec);
		return (rg_collidable_collide_ftor_segment(&end, b));
	} else {
		return 0;
	}

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

int rg_collidable_collide_segment_circle(rg_segment *seg, rg_circle *circle)
{

	double a = (seg->vec.x*seg->vec.x+seg->vec.y*seg->vec.y);
	double b = (
		2*(seg->start.x-circle->center.x)*seg->vec.x +
		2*(seg->start.y-circle->center.y)*seg->vec.y
	);
	double c = (
		pow(seg->start.x-circle->center.x,2) +
		pow(seg->start.y-circle->center.y,2) -
		circle->radius*circle->radius);
	double D = b*b-4*a*c;
	
	if (a == 0) { // 0 vector
		return rg_collidable_collide_ftor_ftor(&seg->start, &circle->center);
	} else if (D < 0) { // no solution
		return 0;
	} else if (D > 0) {
		double r1, r2;
		D = sqrt(D);
		r1 = (-b+D)/(2*a);
		r2 = (-b-D)/(2*a);
		return (FBETWEEN(r1, 0, 1) || FBETWEEN(r2, 0, 1));
	} else {
		return FBETWEEN((-b/(2*a)), 0, 1);
	}
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

/*** RUBY STUFF ***************************************************************/

/* 
 *  call-seq:
 *    collide?(other_body)  ->  other_body or nil
 *
 *  Test if caller collides with other_body.
 *  Also see Collidable#collide
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

/* 
 *  call-seq:
 *    collide?(list_of_bodies, stop_after=-1)  ->  list of colliding bodies
 *    collide?(list_of_bodies, stop_after=-1) { |colliding_body| } ->  mapped list of colliding bodies
 *
 *  Get all bodies that collide. The optional block is called for every colliding body
 *  and the result of the block will be in the list instead of the body.
 *  The optional stop_after argument allows to specify a maximum count of colliding
 *  bodies, negative numbers are taken as N less than there are bodies (e.g. if you
 *  have 10 bodies and stop_after = -4 it would mean max. 6, -1 means all possible)
 *  Also see Collidable#collide?
 */
static VALUE rg_collidable_rb_collide(int argc, VALUE *argv, VALUE self)
{
	VALUE rb_objects, rb_stop_after;
	rb_scan_args(argc, argv, "11", &rb_objects, &rb_stop_after);
  
	int stop_after = NIL_P(rb_stop_after) ? FIX2INT(rb_stop_after) : 1;
	int items      = RARRAY(rb_objects)->len;
	int i;
	if (stop_after < 0) stop_after += items;
	VALUE entry;
	VALUE results  = rb_ary_new();
	for (i=0; i<items && stop_after>0; i++) {
		entry = rb_ary_entry(rb_objects, i);
		if (rg_collidable_collide_bodies(self, entry)) {
			stop_after--;
			if (rb_block_given_p()) {
				rb_ary_push(results, rb_yield(entry));
			} else {
				rb_ary_push(results, entry);
			}
		}
	}
	return results;
}

/*
 * Document-module: Rubygame::Body::Collidable
 *
 *  Collidable is a mixin for Body representations to add collision
 *  detection.
 */
void Init_rg_mCollidable()
{
	rg_id_call = rb_intern("call");
	rg_id_body = rb_intern("body");

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
	//rb_define_method(mCollidable, "collide_key", rg_collidable_rb_collide_key, -1);
}
