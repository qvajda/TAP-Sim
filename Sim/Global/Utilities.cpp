/*
 * Utilities.cpp
 *
 *  Created on: Jan 21, 2015
 *
 */

#include "Utilities.h"

double generateGaussianNoise()
{
	static bool haveSpare = false;
	static double rand1, rand2;

	if(haveSpare)
	{
		haveSpare = false;
		return sqrt(rand1) * sin(rand2);
	}

	haveSpare = true;

	rand1 = rand() / ((double) RAND_MAX);
	if(rand1 < 1e-100) rand1 = 1e-100;
	rand1 = -2 * log(rand1);
	rand2 = (rand() / ((double) RAND_MAX)) * TWO_PI;

	return sqrt(rand1) * cos(rand2);
}

double generateGaussianNoise(const double &variance, const double &avg)
{
	return (variance*generateGaussianNoise())+avg;
}

double generatePositiveGaussianNoise(const double &variance, const double &avg){
	return (variance*abs(generateGaussianNoise()))+avg;
}


int generateGaussianInt(const int &variance, const int &avg){
	return (int)(variance*generateGaussianNoise())+avg;
}

double getUniformProb(){
	return rand() / ((double) RAND_MAX);
}

bool probPoll(double p){
	return getUniformProb() <= p;
}
