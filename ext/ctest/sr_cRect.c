#include "ruby.h"

#define SR_BOOL(e) ((e) ? Qtrue : Qfalse)
VALUE sr_cRect;
typedef struct {
	double left;
	double top;
	double right;
	double bottom;
} C_RECT;

static ID sr_id_t;
static ID sr_id_l;
static ID sr_id_b;
static ID sr_id_r;

static int sr_rect_collide_value(C_RECT *rect, VALUE other);
static int sr_rect_collide_rect(C_RECT *rect, double t, double l, double b, double r);
static int sr_rect_collide_point(C_RECT *rect, double x, double y);


static VALUE sr_rect_singleton_new(int argc, VALUE *argv, VALUE class)
{
	C_RECT *rect;
	VALUE   rb_rect;
	rect    = ALLOC(C_RECT);
	rb_rect = Data_Wrap_Struct(sr_cRect, NULL, free, rect);
	rb_obj_call_init(rb_rect, argc, argv);
	return rb_rect;
}

static VALUE sr_rect_init(self, left, top, width, height)
	VALUE self, left, top, width, height;
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	rect->top    = NUM2DBL(top);
	rect->left   = NUM2DBL(left);
	rect->right  = rect->left+NUM2DBL(width);
	rect->bottom = rect->top+NUM2DBL(height);
	return self;
}

/*** GETTERS ******************************************************************/

static VALUE sr_rect_left(VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	return rb_float_new(rect->left);
}

static VALUE sr_rect_top(VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	return rb_float_new(rect->top);
}

static VALUE sr_rect_right(VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	return rb_float_new(rect->right);
}

static VALUE sr_rect_bottom(VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	return rb_float_new(rect->bottom);
}

static VALUE sr_rect_center_x(VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	return rb_float_new((rect->left+rect->right)/2);
}

static VALUE sr_rect_center_y(VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	return rb_float_new((rect->top+rect->bottom)/2);
}

static VALUE sr_rect_width(VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	return rb_float_new(rect->right-rect->left);
}

static VALUE sr_rect_height(VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	return rb_float_new(rect->bottom-rect->top);
}


/*** SETTERS ******************************************************************/

static VALUE sr_rect_set_left(VALUE self, VALUE value)
{
	C_RECT *rect;
	double c_val;
	c_val = NUM2DBL(value);
	Data_Get_Struct(self, C_RECT, rect);

	if (c_val > rect->right) {
		rect->left  = rect->right;
		rect->right = c_val;
	} else {
		rect->left = c_val;
	}
	return rb_float_new(rect->left);
}

static VALUE sr_rect_set_top(VALUE self, VALUE value)
{
	C_RECT *rect;
	double c_val;
	c_val = NUM2DBL(value);
	Data_Get_Struct(self, C_RECT, rect);

	if (c_val > rect->bottom) {
		rect->top    = rect->bottom;
		rect->bottom = c_val;
	} else {
		rect->top = c_val;
	}
	return rb_float_new(rect->top);
}

static VALUE sr_rect_set_right(VALUE self, VALUE value)
{
	C_RECT *rect;
	double c_val;
	c_val = NUM2DBL(value);
	Data_Get_Struct(self, C_RECT, rect);

	if (c_val < rect->left) {
		rect->right  = rect->left;
		rect->left = c_val;
	} else {
		rect->right = c_val;
	}
	return rb_float_new(rect->left);
}

static VALUE sr_rect_set_bottom(VALUE self, VALUE value)
{
	C_RECT *rect;
	double c_val;
	c_val = NUM2DBL(value);
	Data_Get_Struct(self, C_RECT, rect);

	if (c_val < rect->top) {
		rect->bottom = rect->top;
		rect->top    = c_val;
	} else {
		rect->bottom = c_val;
	}
	return rb_float_new(rect->bottom);
}

static VALUE sr_rect_set_center_x(VALUE self, VALUE value)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	double center_x = NUM2DBL(value);
	double move_x   = center_x-((rect->left+rect->right)/2);
	rect->left  += move_x;
	rect->right += move_x;
	return self;
}

static VALUE sr_rect_set_center_y(VALUE self, VALUE value)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	double center_y = NUM2DBL(value);
	double move_y   = center_y-((rect->top+rect->bottom)/2);
	rect->top    += move_y;
	rect->bottom += move_y;
	return self;
}

static VALUE sr_rect_move_x(VALUE self, VALUE value)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	double move_x = NUM2DBL(value);
	rect->left  += move_x;
	rect->right += move_x;
	return self;
}

static VALUE sr_rect_move_y(VALUE self, VALUE value)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	double move_y = NUM2DBL(value);
	rect->top    += move_y;
	rect->bottom += move_y;
	return self;
}

/* moves right side */
static VALUE sr_rect_move_xy(VALUE self, VALUE by_x, VALUE by_y)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	double move_x = NUM2DBL(by_x);
	double move_y = NUM2DBL(by_y);
	rect->left   += move_x;
	rect->right  += move_x;
	rect->top    += move_y;
	rect->bottom += move_y;
	return self;
}

/* move_by(ftor) */


/*** Stuff   ******************************************************************/
static VALUE sr_rect_inspect(VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	VALUE str;
	char buf[255];
	
	sprintf(buf, "#<Rect:0x tl=%.0f,%.0f br=%.0f,%.0f (%.0fx%.0f)>",
		rect->top,
		rect->left,
		rect->bottom,
		rect->right,
		rect->right-rect->left,
		rect->bottom-rect->top
	);
	str  = rb_str_new2(buf);
	return str;
}

static VALUE sr_rect_collide(int argc, VALUE *argv, VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	
	for (int i = 0; i < argc; i++) {
		if (sr_rect_collide_value(rect, argv[i])) {
			return argv[i];
			//return INT2FIX(i); // return the index rather than the object
		}
	}
	return Qnil;
}

static VALUE sr_rect_collide_all(int argc, VALUE *argv, VALUE self)
{
	C_RECT *rect;
	Data_Get_Struct(self, C_RECT, rect);
	VALUE memo = rb_ary_new();
	
	for (int i = 0; i < argc; i++) {
		if (sr_rect_collide_value(rect, argv[i])) {
			rb_ary_push(memo, argv[i]);
		}
	}
	return memo;
}

static int sr_rect_collide_value(C_RECT *rect, VALUE other)
{
	VALUE klass;
	klass = CLASS_OF(other);

	if (klass == sr_cRect) {
		C_RECT *rect2;
		Data_Get_Struct(other, C_RECT, rect2);
	
		return sr_rect_collide_rect(
			rect,
			rect2->top,
			rect2->left,
			rect2->bottom,
			rect2->right
		);
	} else if (klass == rb_cArray) {
		if (RARRAY(other)->len == 2) {
			return sr_rect_collide_point(
				rect,
				NUM2DBL(rb_ary_entry(other, 0)),
				NUM2DBL(rb_ary_entry(other, 1))
			);
		} else if (RARRAY(other)->len == 4) {
			double x,y,w,h;
			x = NUM2DBL(rb_ary_entry(other, 0));
			y = NUM2DBL(rb_ary_entry(other, 1));
			w = NUM2DBL(rb_ary_entry(other, 2));
			h = NUM2DBL(rb_ary_entry(other, 3));
			return sr_rect_collide_rect(rect, y, x, y+h, x+w);
		}
	} else {
		return sr_rect_collide_rect(
			rect,
			NUM2DBL(rb_funcall(other, sr_id_t, 0)),
			NUM2DBL(rb_funcall(other, sr_id_l, 0)),
			NUM2DBL(rb_funcall(other, sr_id_b, 0)),
			NUM2DBL(rb_funcall(other, sr_id_r, 0))
		);
	}
	return 0;
}

static int sr_rect_collide_rect(C_RECT *rect, double t, double l, double b, double r)
{
	return (
		(
			(rect->left <= l && rect->right >= l) || // others left in
			(rect->left <= r && rect->right >= r)    // others right in
		) &&
		(
			(rect->top <= t && rect->bottom >= t) || // others top in
			(rect->top <= b && rect->bottom >= b)    // others bottom in
		)
	);
}

static int sr_rect_collide_point(C_RECT *rect, double x, double y)
{
	return (
		(rect->left <= x && rect->right  >= x) &&
		(rect->top  <= y && rect->bottom >= y)
	);
}

/*
static VALUE sr_rect_is_rect(VALUE self, VALUE other)
{
	//return ((CLASS_OF(other) == sr_cRect) ? Qtrue : Qfalse);
	return Qfalse;
}
*/



void Init_sr_cRect()
{
	sr_cRect = rb_define_class("Rect", rb_cObject);

	rb_define_singleton_method(sr_cRect, "new", sr_rect_singleton_new, -1);

	rb_define_method(sr_cRect, "initialize",  sr_rect_init, 4);
	rb_define_method(sr_cRect, "left",        sr_rect_left, 0);
	rb_define_method(sr_cRect, "top",         sr_rect_top, 0);
	rb_define_method(sr_cRect, "right",       sr_rect_right, 0);
	rb_define_method(sr_cRect, "bottom",      sr_rect_bottom, 0);
	rb_define_method(sr_cRect, "width",       sr_rect_width, 0);
	rb_define_method(sr_cRect, "height",      sr_rect_height, 0);
	rb_define_method(sr_cRect, "center_x",    sr_rect_center_x, 0);
	rb_define_method(sr_cRect, "center_y",    sr_rect_center_y, 0);
	
	rb_define_method(sr_cRect, "left=",       sr_rect_set_left, 1);
	rb_define_method(sr_cRect, "top=",        sr_rect_set_top, 1);
	rb_define_method(sr_cRect, "right=",      sr_rect_set_right, 1);
	rb_define_method(sr_cRect, "bottom=",     sr_rect_set_bottom, 1);
	rb_define_method(sr_cRect, "center_x=",   sr_rect_set_center_x, 1);
	rb_define_method(sr_cRect, "center_y=",   sr_rect_set_center_y, 1);

	rb_define_method(sr_cRect, "move_x",      sr_rect_move_x, 1);
	rb_define_method(sr_cRect, "move_y",      sr_rect_move_y, 1);
	rb_define_method(sr_cRect, "move_xy",     sr_rect_move_xy, 2);

	rb_define_method(sr_cRect, "collide?",    sr_rect_collide, -1);
	rb_define_method(sr_cRect, "collide_all", sr_rect_collide_all, -1);
	//rb_define_method(sr_cRect, "rect?",       sr_rect_is_rect, 1);

	rb_define_method(sr_cRect, "inspect",     sr_rect_inspect, 0);
	
	sr_id_t = rb_intern("t");
	sr_id_l = rb_intern("l");
	sr_id_b = rb_intern("b");
	sr_id_r = rb_intern("r");
}
