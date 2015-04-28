/*
 * EBackpropLearner.h
 *
 *  Created on: Mar 7, 2015
 */

#ifndef LEARNER_EBACKPROPLEARNER_H_
#define LEARNER_EBACKPROPLEARNER_H_

#include "NetworkLearner.h"
#include <vector>
#include <algorithm>    // std::max

class EBackpropLearner: public NetworkLearner {
private:
	std::vector<double> predictedTT;
	std::vector<bool> learnedFlags;
	double learningFactor;
public:
	EBackpropLearner(const long nbRoads,double learningFactor = 0.9);
	virtual ~EBackpropLearner();

	virtual void exitedRoad(Road* r, const double time, const double length);
	virtual void enteredRoad(Road* r, const double time);

	virtual double getPredTime(Road* r, const double time);
	virtual bool isFullyLearned(Road* r, const double time);
};

#endif /* LEARNER_EBACKPROPLEARNER_H_ */
