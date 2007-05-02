#define MAX_DELTA 0.0001
#define FEQUAL(a,b) (fabs((a)-(b)) < MAX_DELTA)
#define FBETWEEN(a,b,c) ((((b)-MAX_DELTA) <= (a)) && ((a) <= ((c)+MAX_DELTA)))
#define RAD2DEG(x) ((x)*180/M_PI)
#define DEG2RAD(x) ((x)/180*M_PI)
