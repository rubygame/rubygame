#ifndef _RUBYGAME_CSEGMENT_H
#define _RUBYGAME_CSEGMENT_H

typedef struct {
	rg_vector2 start;
	rg_vector2 vec;
} rg_segment;

extern VALUE cSegment;

void Init_Segment();

void rg_segment_move(rg_segment *seg, rg_vector2 *vector2);

#endif
