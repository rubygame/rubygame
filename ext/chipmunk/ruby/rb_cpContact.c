/* 
 * The copyright status of this file is uncertain. Derived from a patch by "Tom Lea"
 * posted on the Chipmunk forums, thread: "Additional Ruby Bindings for Collision Functions".
 * Accessed on 2008-02-05.
 *
 * http://www.slembcke.net/forums/viewtopic.php?f=6&t=51&sid=40834b00213a5c8f87ea5de6f03ca8e6
 *
 */

#include "chipmunk.h"

#include "ruby.h"
#include "rb_chipmunk.h"

VALUE c_cpContact;

static VALUE
rb_cpContactGetp(VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return VNEW(CONTACT(self)->p);
}

static VALUE
rb_cpContactGetn(VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return VNEW(CONTACT(self)->n);
}

static VALUE
rb_cpContactGetr1(VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return VNEW(CONTACT(self)->r1);
}

static VALUE
rb_cpContactGetr2(VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return VNEW(CONTACT(self)->r2);
}

static VALUE
rb_cpContactGetdist(VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return rb_float_new(CONTACT(self)->dist);
}

static VALUE
rb_cpContactGetnMass(VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return rb_float_new(CONTACT(self)->nMass);
}

static VALUE
rb_cpContactGettMass(VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return rb_float_new(CONTACT(self)->tMass);
}

static VALUE
rb_cpContactGetbounce(VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return rb_float_new(CONTACT(self)->bounce);
}

static VALUE
rb_cpContactGetjnAcc (VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return rb_float_new(CONTACT(self)->jnAcc);
}

static VALUE
rb_cpContactGetjtAcc (VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return rb_float_new(CONTACT(self)->jtAcc);
}

static VALUE
rb_cpContactGetjBias (VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return rb_float_new(CONTACT(self)->jBias);
}

static VALUE
rb_cpContactGetbias (VALUE self)
{
	if(!CONTACT(self))
	{
		rb_raise(rb_eArgError, "Contact gone.");
		return Qnil;
	}
	return rb_float_new(CONTACT(self)->bias);
}


void
Init_cpContact(void)
{
	c_cpContact = rb_define_class_under(m_Chipmunk, "Contact", rb_cObject);
   
	rb_define_method(c_cpContact, "p", rb_cpContactGetp, 0);
	rb_define_method(c_cpContact, "n", rb_cpContactGetn, 0);
	rb_define_method(c_cpContact, "dist", rb_cpContactGetdist, 0);
	rb_define_method(c_cpContact, "r1", rb_cpContactGetr1, 0);
	rb_define_method(c_cpContact, "r2", rb_cpContactGetr2, 0);
	rb_define_method(c_cpContact, "nMass", rb_cpContactGetnMass, 0);
	rb_define_method(c_cpContact, "tMass", rb_cpContactGettMass, 0);
	rb_define_method(c_cpContact, "bounce", rb_cpContactGetbounce, 0);
	rb_define_method(c_cpContact, "jnAcc", rb_cpContactGetjnAcc, 0);
	rb_define_method(c_cpContact, "jtAcc", rb_cpContactGetjtAcc, 0);
	rb_define_method(c_cpContact, "jBias", rb_cpContactGetjBias, 0);
	rb_define_method(c_cpContact, "bias", rb_cpContactGetbias, 0);
}
