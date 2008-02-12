/* Copyright (c) 2007 Scott Lembcke
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
 
extern VALUE m_Chipmunk;

extern VALUE c_cpVect;
extern VALUE c_cpBB;
extern VALUE c_cpBody;
extern VALUE m_cpShape;
extern VALUE c_cpCircleShape;
extern VALUE c_cpSegmentShape;
extern VALUE c_cpPolyShape;
extern VALUE m_cpJoint;
extern VALUE c_cpSpace;
extern VALUE c_cpContact;

extern ID id_parent;

static inline VALUE
VNEW(cpVect v)
{
	cpVect *ptr = malloc(sizeof(cpVect));
	*ptr = v;
	return Data_Wrap_Struct(c_cpVect, NULL, &free, ptr);	
}

// We must ensure we null the contact reference after the callback is done.
static inline VALUE
CONTACTNEW(cpContact * v)
{
	cpContact * new_v = (cpContact *)malloc(sizeof(cpContact));
	memcpy(new_v, v, sizeof(cpContact));
	return Data_Wrap_Struct(c_cpContact, NULL, &free, new_v);
}

static inline VALUE
BBNEW(cpBB b)
{
	cpBB *bb = malloc(sizeof(cpBB));
	*bb = b;
	return Data_Wrap_Struct(c_cpBB, NULL, free, bb);
}


//static inline VALUE
//VWRAP(cpVect *v, VALUE parent)
//{
//	VALUE rb_v = Data_Wrap_Struct(c_cpVect, NULL, NULL, v);
//	rb_ivar_set(rb_v, id_parent, parent);
//	
//	return rb_v;	
//}

#define GETTER_TEMPLATE(func_name, klass, klass_name, type)\
static inline type *\
func_name(VALUE self)\
{\
	if(!rb_obj_is_kind_of(self, klass))\
		rb_raise(rb_eTypeError, "wrong argument type %s (expected CP::klass_name)", rb_obj_classname(self));\
	type *ptr;\
	Data_Get_Struct(self, type, ptr);\
	return ptr;\
}\

GETTER_TEMPLATE(VGET , c_cpVect , Vec2 , cpVect )
GETTER_TEMPLATE(BBGET, c_cpBB   , BB   , cpBB   )
GETTER_TEMPLATE(BODY , c_cpBody , Body , cpBody )
GETTER_TEMPLATE(SHAPE, m_cpShape, Shape, cpShape)
GETTER_TEMPLATE(JOINT, m_cpJoint, Joint, cpJoint)
GETTER_TEMPLATE(SPACE, c_cpSpace, Space, cpSpace)
GETTER_TEMPLATE(CONTACT, c_cpContact, Contact, cpContact)

void Init_chipmunk(void);
void Init_cpVect();
void Init_cpBB();
void Init_cpBody();
void Init_cpShape();
void Init_cpJoint();
void Init_cpSpace();
void Init_cpContact();
