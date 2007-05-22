#ifndef _RUBYGAME_MCOLLIDABLE_H
#define _RUBYGAME_MCOLLIDABLE_H

extern VALUE rg_collidable_rb_collide_single(VALUE, VALUE);
extern VALUE rg_collidable_rb_collide(int, VALUE*, VALUE);

extern void Init_rg_mCollidable();

extern VALUE mCollidable;

#endif
