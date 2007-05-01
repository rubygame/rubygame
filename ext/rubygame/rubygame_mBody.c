#include <ruby.h>
#include <math.h>
#include "rubygame_defines.h"
#include "rubygame_cFtor.h"
#include "rubygame_cSegment.h"
#include "rubygame_cRect.h"
#include "rubygame_cCircle.h"
#include "rubygame_mCollidable.h"
#include "rubygame_mBody.h"

static VALUE mRubygame;
static VALUE mBody;
static VALUE mCollidable;

static VALUE rg_cCircle;
static VALUE rg_cRect;
static VALUE rg_cSegment;
static VALUE rg_cFtor;

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

	rg_cFtor    = rb_define_class_under(mBody, "Ftor", rb_cObject);
	rg_cSegment = rb_define_class_under(mBody, "Segment", rb_cObject);
	rg_cRect    = rb_define_class_under(mBody, "Rect", rb_cObject);
	rg_cCircle  = rb_define_class_under(mBody, "Circle", rb_cObject);

	rb_include_module(rg_cFtor, mCollidable);
	rb_include_module(rg_cSegment, mCollidable);
	rb_include_module(rg_cRect, mCollidable);
	rb_include_module(rg_cCircle, mCollidable);
}
