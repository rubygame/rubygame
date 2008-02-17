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


/* I flirted briefly with starting row/column indices at 1
 * like in math class, but consistency with Arrays the rest
 * of the computer programming won out, so they start at 0.
 *
 * Also note that this is actually a 3x2 matrix, not 3x3 as
 * would usually be used. The bottom row, which would always
 * be [0 0 1] for transformation matrices, is just assumed.
 *
 */
typedef struct cpMatrix {
	cpFloat m00,m01,m02,  m10,m11,m12;
} cpMatrix;


/* Identity matrix */
static const cpMatrix cpmident = { 1,0,0,  0,1,0 };


/* Create a new matrix */
static cpMatrix
cpm( cpFloat m00, cpFloat m01, cpFloat m02, cpFloat m10, cpFloat m11, cpFloat m12 )
{
	cpMatrix m = { m00,m01,m02,  m10,m11,m12 };
	return m;
}

/* Multiply two matrices together, returning a new matrix that
 * represents the combined transformation (where P is applied first)
 */
static inline cpMatrix
cpMmultm( cpMatrix o, cpMatrix p )
{
	cpMatrix m;

	m.m00 = (o.m00 * p.m00)  +  (o.m01 * p.m10);
	m.m01 = (o.m00 * p.m01)  +  (o.m01 * p.m11);
	m.m02 = (o.m00 * p.m02)  +  (o.m01 * p.m12)  +  (o.m02);

	m.m10 = (o.m10 * p.m00)  +  (o.m11 * p.m10);
	m.m11 = (o.m10 * p.m01)  +  (o.m11 * p.m11);
	m.m12 = (o.m10 * p.m02)  +  (o.m11 * p.m12)  +  (o.m12);

	return m;
}

/* Apply the transformation matrix to the vect as a vector.
 * Assumes the vect represents a vector, so translation is ignored.
 */
static inline cpVect
cpMmultv( cpMatrix m, cpVect v )
{
	return cpv( (m.m00 * v.x  +  m.m01 * v.y),
	            (m.m10 * v.x  +  m.m11 * v.y) );
}

/* Apply the transformation matrix to the vect as a point.
 * Assumes the vect represents a point, so translation is applied.
 */
static inline cpVect
cpMmultp( cpMatrix m, cpVect v )
{
	return cpp( (m.m00 * v.x  +  m.m01 * v.y  +  m.m02),
	            (m.m10 * v.x  +  m.m11 * v.y  +  m.m12) );
}

cpMatrix cpMatrixTranslate( cpFloat x, cpFloat y );
cpMatrix cpMatrixRotate( cpFloat angle );
cpMatrix cpMatrixScale( cpFloat x, cpFloat y );
cpMatrix cpMatrixShear( cpFloat x, cpFloat y );
