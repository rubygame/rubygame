/* Copyright (c) 2008  John Croisant
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 
#include "chipmunk.h"

#include "ruby.h"
#include "rb_chipmunk.h"

VALUE c_cpMatrix;

static VALUE
rb_cpMatrixForAngle(VALUE self, VALUE angle)
{
	return VNEW(cpvforangle(NUM2DBL(angle)));
}

static VALUE
rb_cpMatrixAlloc(VALUE klass)
{
	cpMatrix *m = malloc(sizeof(cpMatrix));
	return Data_Wrap_Struct(klass, NULL, free, m);
}

static VALUE
rb_cpMatrixInitialize(VALUE self, VALUE row1, VALUE row2)
{
	cpMatrix *m = MGET(self);

	Check_Type(row1, T_ARRAY);
	Check_Type(row2, T_ARRAY);

	m->m00 = NUM2DBL( RARRAY(row1)->ptr[0] );
	m->m01 = NUM2DBL( RARRAY(row1)->ptr[1] );
	m->m02 = NUM2DBL( RARRAY(row1)->ptr[2] );

	m->m10 = NUM2DBL( RARRAY(row2)->ptr[0] );
	m->m11 = NUM2DBL( RARRAY(row2)->ptr[1] );
	m->m12 = NUM2DBL( RARRAY(row2)->ptr[2] );
	
	return self;
}

static VALUE
rb_cpMatrixTranslate(VALUE class, VALUE x, VALUE y)
{
	return MNEW( cpMatrixTranslate(NUM2DBL(x), NUM2DBL(y)) );
}

static VALUE
rb_cpMatrixRotate(VALUE class, VALUE angle)
{
	return MNEW( cpMatrixRotate(NUM2DBL(angle)) );
}

static VALUE
rb_cpMatrixScale(VALUE class, VALUE x, VALUE y)
{
	return MNEW( cpMatrixScale(NUM2DBL(x), NUM2DBL(y)) );
}

static VALUE
rb_cpMatrixShear(VALUE class, VALUE x, VALUE y)
{
	return MNEW( cpMatrixShear(NUM2DBL(x), NUM2DBL(y)) );
}


static VALUE
rb_cpMatrixToString(VALUE self)
{
	char str[256];
	cpMatrix *m = MGET(self);
	
	snprintf(str, 256,
	         "#<CP::Matrix [% .3f, % .3f, % .3f] [% .3f, % .3f, % .3f]>",
	         m->m00, m->m01, m->m02,  m->m10, m->m11, m->m12 );
	
	return rb_str_new2(str);
}

static VALUE
rb_cpMatrixMultiply(VALUE self, VALUE other)
{
	cpMatrix *a = MGET(self);

	VALUE oklass = rb_obj_class(other);

	if( c_cpMatrix == oklass ){
		cpMatrix *b = MGET(other);
		return MNEW( cpMmultm(*a, *b) );
	}
	else if( c_cpVect == oklass ) {
		cpVect *v = VGET(other);
		return VNEW( cpMmultv(*a, *v) );
	} else {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected CP::Matrix or CP::Vect)",
		          rb_obj_classname(other) );
		return Qnil;
	}
}

static VALUE
rb_cpMatrixGetAt(VALUE self, VALUE row, VALUE col)
{
	cpMatrix *m = MGET(self);

	int r = NUM2INT(row);
	int c = NUM2INT(col);

	if( r < 0 || r > 1 ) {
		rb_raise( rb_eIndexError, "Matrix row index out of bounds: %d (expected 0..1)", r );
	}

	if( c < 0 || c > 2 ) {
		rb_raise( rb_eIndexError, "Matrix column index out of bounds: %d (expected 0..2)", r );
	}

	cpFloat f;

	switch(r) {
		case 0:
			switch(c) {
				case 0:  f = m->m00; break;
				case 1:  f = m->m01; break;
				case 2:  f = m->m02; break;
			}
		case 1:
			switch(c) {
				case 0:  f = m->m10; break;
				case 1:  f = m->m11; break;
				case 2:  f = m->m12; break;
			}
	}

	return rb_float_new(f);
}

static VALUE
rb_cpMatrixSetAt(VALUE self, VALUE row, VALUE col, VALUE new_val)
{
	cpMatrix *m = MGET(self);

	int r = NUM2INT(row);
	int c = NUM2INT(col);
	cpFloat f = NUM2DBL(new_val);

	if( r < 0 || r > 1 ) {
		rb_raise( rb_eIndexError, "Matrix ROW index out of bounds: %d (expected 0..1)", r );
	}

	if( c < 0 || c > 2 ) {
		rb_raise( rb_eIndexError, "Matrix COLUMN index out of bounds: %d (expected 0..2)", r );
	}

	switch(r) {
		case 0:
			switch(c) {
				case 0:  m->m00 = f; break;
				case 1:  m->m01 = f; break;
				case 2:  m->m02 = f; break;
			}
		case 1:
			switch(c) {
				case 0:  m->m10 = f; break;
				case 1:  m->m11 = f; break;
				case 2:  m->m12 = f; break;
			}
	}

	return self;
}

void
Init_cpMatrix(void)
{
	c_cpMatrix = rb_define_class_under(m_Chipmunk, "Matrix", rb_cObject);

	rb_define_alloc_func(c_cpMatrix, rb_cpMatrixAlloc);
	rb_define_method(c_cpMatrix, "initialize", rb_cpMatrixInitialize, 2);

	rb_define_singleton_method(c_cpMatrix, "translate", rb_cpMatrixTranslate, 2);
	rb_define_singleton_method(c_cpMatrix, "rotate", rb_cpMatrixRotate, 1);
	rb_define_singleton_method(c_cpMatrix, "scale", rb_cpMatrixScale, 2);
	rb_define_singleton_method(c_cpMatrix, "shear", rb_cpMatrixShear, 2);

	rb_define_const(c_cpMatrix, "IDENTITY", MNEW(cpmident));
	
	rb_define_method(c_cpMatrix, "*", rb_cpMatrixMultiply, 1);
	rb_define_method(c_cpMatrix, "to_s", rb_cpMatrixToString, 0);
	rb_define_method(c_cpMatrix, "[]", rb_cpMatrixGetAt, 2);
	rb_define_method(c_cpMatrix, "[]=", rb_cpMatrixSetAt, 3);
}
