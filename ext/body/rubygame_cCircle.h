#ifndef _RUBYGAME_CCIRCLE_H
#define _RUBYGAME_CCIRCLE_H

typedef struct rg_circle_struct {
	rg_ftor center;
	double radius;
} rg_circle;

extern VALUE rg_cCircle;

void Init_rg_cCircle();

#endif
