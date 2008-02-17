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
 
#include <math.h>

#include "chipmunk.h"

cpVect
cpBBClampVect(const cpBB bb, const cpVect v)
{
	cpFloat x = cpfmin(cpfmax(bb.l, v.x), bb.r);
	cpFloat y = cpfmin(cpfmax(bb.b, v.y), bb.t);

	if( v.p ) {
		return cpp(x, y);
	} else {
		return cpv(x, y);
	}
}

cpVect
cpBBWrapVect(const cpBB bb, const cpVect v)
{
	cpFloat ix = fabsf(bb.r - bb.l);
	cpFloat modx = fmodf(v.x - bb.l, ix);
	cpFloat x = (modx > 0.0f) ? modx : modx + ix;
	
	cpFloat iy = fabsf(bb.t - bb.b);
	cpFloat mody = fmodf(v.y - bb.b, iy);
	cpFloat y = (mody > 0.0f) ? mody : mody + iy;
	
	if( v.p ) {
		return cpp(x + bb.l, y + bb.b);
	} else {
		return cpv(x + bb.l, y + bb.b);
	}
	
}

/* Return the height of the given BB from bottom to top. */
cpFloat
cpBBGetHeight(const cpBB bb)
{
	return (bb.t - bb.b);
}

/* Return the width of the given BB from left to right. */
cpFloat
cpBBGetWidth(const cpBB bb)
{
	return (bb.r - bb.l);
}

/* Return the center point of the given BB. */
cpVect
cpBBGetCenter(const cpBB bb)
{
	return cpp( (bb.l + bb.r)*0.5, (bb.b + bb.t)*0.5 );
}

/* Return a new BB which is the given BB moved by V */
cpBB
cpBBMove(const cpBB bb, const cpVect v)
{
	cpBB newbb = { bb.l + v.x, bb.b + v.y, bb.r + v.x, bb.t + v.y };
	return newbb;
}

/* Return a new BB which is B moved to be contained in A.
 * If B is larger than A on either dimension, the new
 * BB will be centered on A's center on that dimension.
 */
cpBB
cpBBClamp(const cpBB a, const cpBB b)
{
	cpVect  ac = cpBBGetCenter(a);
	cpVect  bc = cpBBGetCenter(b);

	cpVect move;

	if( cpBBGetWidth(b) > cpBBGetWidth(a) ) {
		/* If B is wider, move so its center X is same as A's */
		move.x = ac.x - bc.x;
	}
	else {
		if( b.l < a.l ) {
			/* If B is too far to the left, move so its left is same as A's */
			move.x = a.l - b.l;
		}
		else if( b.r > a.r ) {
			/* If B is too far to the right, move so its right is same as A's */
			move.x = a.r - b.r;
		}
	}

	if( cpBBGetHeight(b) > cpBBGetHeight(a) ) {
		/* If B is taller, move so its center Y is same as A's */
		move.y = ac.y - bc.y;
	}
	else {
		if( b.b < a.b ) {
			/* If B is too far down, move so its bottom is same as A's */
			move.y = a.b - b.b;
		}
		else if( b.t > a.t ) {
			/* If B is too far up, move so its top is same as A's */
			move.y = a.t - b.t;
		}
	}

	return cpBBMove(b, move);
}

/* Return a new BB which is the given BB expanded by D in each direction.
 * The new width (and height) will be D*2 greater than the old.
 */
cpBB
cpBBGrow(const cpBB bb, const cpFloat d)
{
	cpBB newbb = { bb.l - d, bb.b - d, bb.r + d, bb.t + d };
	return newbb;
}

/* Return a new BB which contains both A and B. */
cpBB
cpBBUnion(const cpBB a, const cpBB b)
{
	cpBB newbb = { cpfmin(a.l, b.l), cpfmin(a.b, b.b), cpfmax(a.r, b.r), cpfmax(a.t, b.t) };
	return newbb;
}

/* Return a new BB which is the intersection of A and B.
 * If A and B do not intersect, returns BB {0,0,0,0}
 */
cpBB
cpBBIntersection(const cpBB a, const cpBB b)
{
	cpBB newbb = {0,0,0,0};

	if( cpBBintersects(a, b) ) {
		newbb.l = cpfmax(a.l, b.l);
		newbb.b = cpfmax(a.b, b.b);
		newbb.r = cpfmin(a.r, b.r);
		newbb.t = cpfmin(a.t, b.t);
	}

	return newbb;
}
