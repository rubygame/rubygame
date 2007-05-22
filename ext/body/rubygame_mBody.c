#include <ruby.h>
#include <math.h>
#include "rubygame_defines.h"
#include "rubygame_cFtor.h"
#include "rubygame_cSegment.h"
#include "rubygame_cRect.h"
#include "rubygame_cCircle.h"
#include "rubygame_mCollidable.h"
#include "rubygame_mBody.h"

VALUE mRubygame;
VALUE mBody;

void Init_rubygame_body()
{
	Init_rg_cFtor();
	Init_rg_cSegment();
	Init_rg_cRect();
	Init_rg_cCircle();

	Init_rg_mCollidable();

	mRubygame   = rb_define_module("Rubygame");
	mBody       = rb_define_module_under(mRubygame, "Body");
	mCollidable = rb_define_module_under(mBody, "Collidable");

	rb_include_module(rg_cFtor, mCollidable);
	rb_include_module(rg_cSegment, mCollidable);
	rb_include_module(rg_cRect, mCollidable);
	rb_include_module(rg_cCircle, mCollidable);
}
