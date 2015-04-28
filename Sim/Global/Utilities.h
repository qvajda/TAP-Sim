/*
 * Utilities.h
 *
 *  Created on: Jan 21, 2015
 */

#ifndef GLOBAL_UTILITIES_H_
#define GLOBAL_UTILITIES_H_

#include <math.h>
#include <stdlib.h>
#include "Defines.h"


//based on : http://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
//generates random number following a gaussian of average 0 and variance 1
double generateGaussianNoise(const double &variance, const double &avg = 0);

//same as above, but no value under the variance
double generatePositiveGaussianNoise(const double &variance, const double &avg = 0);

int generateGaussianInt(const int &variance, const int &avg = 0);

double getUniformProb();

bool probPoll(double p);

#endif /* GLOBAL_UTILITIES_H_ */
