#ifndef _RUBYGAME_CRECT_H
#define _RUBYGAME_CRECT_H

typedef struct {
	rg_vector2 topleft;
	rg_vector2 horizontal;
	rg_vector2 vertical;
} rg_rect;

extern VALUE cRect;

extern void rg_rect_top(rg_segment *seg, rg_rect *rect);
extern void rg_rect_right(rg_segment *seg, rg_rect *rect);
extern void rg_rect_bottom(rg_segment *seg, rg_rect *rect);
extern void rg_rect_left(rg_segment *seg, rg_rect *rect);
extern void rg_rect_top(rg_segment *seg, rg_rect *rect);
extern void rg_rect_right(rg_segment *seg, rg_rect *rect);
extern void rg_rect_bottom(rg_segment *seg, rg_rect *rect);
extern void rg_rect_left(rg_segment *seg, rg_rect *rect);
extern void rg_rect_top_mid(rg_vector2 *vector2, rg_rect *rect);
extern void rg_rect_top_right(rg_vector2 *vector2, rg_rect *rect);
extern void rg_rect_mid_right(rg_vector2 *vector2, rg_rect *rect);
extern void rg_rect_bottom_right(rg_vector2 *vector2, rg_rect *rect);
extern void rg_rect_bottom_mid(rg_vector2 *vector2, rg_rect *rect);
extern void rg_rect_bottom_left(rg_vector2 *vector2, rg_rect *rect);
extern void rg_rect_mid_left(rg_vector2 *vector2, rg_rect *rect);
extern void rg_rect_center(rg_vector2 *vector2, rg_rect *rect);
extern void rg_rect_move(rg_rect *rect, rg_vector2 *vector2);
extern void rg_rect_rotate_around(rg_rect *rect, rg_vector2 *center, double rad);

extern void Init_Rect();

#endif
