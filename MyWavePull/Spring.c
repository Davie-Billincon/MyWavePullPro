#include <math.h>

float spring(float initial_position, float duration, float times, float process){
	float x = M_PI*times*process;
	float k = initial_position*(1 - process)*(1 - process);
	return k*cos(x);
}