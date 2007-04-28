typedef struct rg_rect_struct {
	rg_ftor topleft;
	rg_ftor horizontal;
	rg_ftor vertical;
} rg_rect;

void rg_rect_top(rg_segment *seg, rg_rect *rect);

void rg_rect_right(rg_segment *seg, rg_rect *rect);

void rg_rect_bottom(rg_segment *seg, rg_rect *rect);

void rg_rect_left(rg_segment *seg, rg_rect *rect);

void rg_rect_top(rg_segment *seg, rg_rect *rect);

void rg_rect_right(rg_segment *seg, rg_rect *rect);

void rg_rect_bottom(rg_segment *seg, rg_rect *rect);

void rg_rect_left(rg_segment *seg, rg_rect *rect);

void rg_rect_top_mid(rg_ftor *ftor, rg_rect *rect);

void rg_rect_top_right(rg_ftor *ftor, rg_rect *rect);

void rg_rect_mid_right(rg_ftor *ftor, rg_rect *rect);

void rg_rect_bottom_right(rg_ftor *ftor, rg_rect *rect);

void rg_rect_bottom_mid(rg_ftor *ftor, rg_rect *rect);

void rg_rect_bottom_left(rg_ftor *ftor, rg_rect *rect);

void rg_rect_mid_left(rg_ftor *ftor, rg_rect *rect);

void rg_rect_center(rg_ftor *ftor, rg_rect *rect);

void rg_rect_move(rg_rect *rect, rg_ftor *ftor);

void rg_rect_rotate_around(rg_rect *rect, rg_ftor *center, double rad);

void Init_rg_cRect();
