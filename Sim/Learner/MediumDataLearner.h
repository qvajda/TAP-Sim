/*
 * MediumDataLearner.h
 *
 *  Created on: Sep 25, 2014
 */

#ifndef MEDIUMDATALEARNER_H_
#define MEDIUMDATALEARNER_H_

#include <math.h> //fmod
#include "NetworkLearner.h"
#include "../Global/Defines.h"
#include "../Global/Weights.h"
#include "SimpleRoadInfo.h"

class MediumDataLearner: public NetworkLearner {
private:
	Weights weights;
	MediumRoadInfos infos;
	double intervalLength;

	int formatIntervalIndex(int i);

public:
	MediumDataLearner(const long nbRoads, const int nbIntervals, const Weights ws);
	virtual ~MediumDataLearner();

	void setWeights(const Weights new_ws);

	virtual void exitedRoad(Road* r, const double time, const double length);
	virtual void enteredRoad(Road* r, const double time);

	virtual double getPredTime(Road* r, const double time);
	virtual bool isFullyLearned(Road* r, const double time);
};

#endif /* MEDIUMDATALEARNER_H_ */
