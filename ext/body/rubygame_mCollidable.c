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
#include "collision_math.h"

VALUE mRubygame;
VALUE mBody;
VALUE mCollidable;

VALUE rg_cCircle;
VALUE rg_cRect;
VALUE rg_cSegment;
VALUE rg_cFtor;
ID rg_id_call;
ID rg_id_body;


/* 
 *  call-seq:
 *    collide?(other_body)  ->  other_body or nil
 *
 *  Test if caller collides with other_body.
 *  Also see Collidable#collide
 */
VALUE rg_collidable_rb_collide_single(VALUE self, VALUE other)
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
VALUE rg_collidable_rb_collide(int argc, VALUE *argv, VALUE self)
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
