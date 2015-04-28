/*
 * Weights.h
 *
 *  Created on: Jan 15, 2015
 */

#ifndef GLOBAL_WEIGHTS_H_
#define GLOBAL_WEIGHTS_H_

#include "Defines.h"
#include <vector>

// A vector of weights with a possible offset (such that the effective index of the weights doesn't start at 0)
class Weights {
private:
	std::vector<double> ws;
	int offset; //index used are offset ; so that the weight at position -1 can be possible
	double totalWeight;

public:
	Weights(std::vector<double> weights,int offset = 0);
	virtual ~Weights();

	double getWeightAt(int i); //return weight at relative index i
	int getBeginIndex();
	int getEndIndex();//largest index (non inclusive) up to which getWeightAt will return a weight
	const double getTotalWeight() const{
		return totalWeight;
	}
};

#endif /* GLOBAL_WEIGHTS_H_ */
