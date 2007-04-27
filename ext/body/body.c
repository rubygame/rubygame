// Rubygame::Body.type(Rubygame::Body::Ftor[2,2])

#include <ruby.h>
#include "rg_cFtor.h"
#include "rg_cSegment.h"
#include "rg_cRect.h"
#include "rg_cCircle.h"

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

int rg_body_collide(*a, *b)
{
	
}

int rg_body_collide_ftor_ftor(rg_ftor *a, rg_ftor *b)
{
}

static VALUE rg_body_rb_type(VALUE class, VALUE obj)
{
	return INT2FIX(rg_body_type(CLASS_OF(obj)));
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
}
