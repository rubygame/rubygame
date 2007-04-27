int rg_body_type(VALUE class);

int rg_body_collide(int ta, int tb, void *a, void *b);
int rg_body_collide_ftor_ftor(rg_ftor *a, rg_ftor *b);
int rg_body_collide_ftor_segment(rg_ftor *a, rg_segment *b);
int rg_body_collide_ftor_rect(rg_ftor *a, rg_rect *b);
int rg_body_collide_ftor_circle(rg_ftor *a, rg_circle *b);
int rg_body_collide_segment_segment(rg_segment *a, rg_segment *b);
int rg_body_collide_segment_rect(rg_segment *a, rg_rect *b);
int rg_body_collide_segment_circle(rg_segment *a, rg_circle *b);
int rg_body_collide_rect_rect(rg_rect *a, rg_rect *b);
int rg_body_collide_rect_circle(rg_rect *a, rg_circle *b);
int rg_body_collide_circle_circle(rg_circle *a, rg_circle *b);

void Init_body();
