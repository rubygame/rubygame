#ifndef _COLLISION_MATH_H
#define _COLLISION_MATH_H

#include "rubygame_cVector2.h"
#include "rubygame_cSegment.h"
#include "rubygame_cRect.h"
#include "rubygame_cCircle.h"

extern int rg_collidable_type(VALUE class);
extern void rg_collidable_extract_struct(void **strct, VALUE class, VALUE x);

extern int rg_collidable_cc_collide(int ta, int tb, void *a, void *b);
extern int rg_collidable_crb_collide(VALUE a, VALUE b);
extern int rg_collidable_collide_vector2_vector2(rg_vector2 *a, rg_vector2 *b);
extern int rg_collidable_collide_vector2_segment(rg_vector2 *a, rg_segment *b);
extern int rg_collidable_collide_vector2_rect(rg_vector2 *a, rg_rect *b);
extern int rg_collidable_collide_vector2_circle(rg_vector2 *a, rg_circle *b);
extern int rg_collidable_collide_segment_segment(rg_segment *a, rg_segment *b);
extern int rg_collidable_collide_segment_rect(rg_segment *a, rg_rect *b);
extern int rg_collidable_collide_segment_circle(rg_segment *a, rg_circle *b);
extern int rg_collidable_collide_rect_rect(rg_rect *a, rg_rect *b);
extern int rg_collidable_collide_rect_circle(rg_rect *a, rg_circle *b);
extern int rg_collidable_collide_circle_circle(rg_circle *a, rg_circle *b);

#endif
