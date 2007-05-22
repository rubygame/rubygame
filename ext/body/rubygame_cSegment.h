#ifndef _RUBYGAME_CSEGMENT_H
#define _RUBYGAME_CSEGMENT_H

typedef struct rg_segment_struct {
	rg_ftor start;
	rg_ftor vec;
} rg_segment;

extern VALUE rg_cSegment;

void Init_rg_cSegment();

void rg_segment_move(rg_segment *seg, rg_ftor *ftor);

#endif
