
/* Copyright (c) 2008  John Croisant
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
 
#include "stdio.h"
#include "math.h"

#include "chipmunk.h"

/* Create a matrix to translate (move) by the given distances */
cpMatrix
cpMatrixTranslate( cpFloat x, cpFloat y )
{
	return cpm( 1,0,x,  0,1,y );
}

/* Create a matrix to rotade by the angle */
cpMatrix
cpMatrixRotate( cpFloat angle )
{
	cpFloat c = cos(angle);
	cpFloat s = sin(angle);

	return cpm( c,-s,0,  s,c,0 );
}

/* Create a matrix to scale along x and y axes by the given factors */
cpMatrix
cpMatrixScale( cpFloat x, cpFloat y )
{
	return cpm( x,0,0,  0,y,0 );
}

/* Create a matrix to shear along x and y axes by the given amounts */
cpMatrix
cpMatrixShear( cpFloat x, cpFloat y )
{
	return cpm( 1,x,0,  y,1,0 );
}
