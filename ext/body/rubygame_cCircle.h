#ifndef _RUBYGAME_CCIRCLE_H
#define _RUBYGAME_CCIRCLE_H

typedef struct {
	rg_ftor center;
	double radius;
} rg_circle;

extern VALUE cCircle;

void Init_Circle();

#endif
