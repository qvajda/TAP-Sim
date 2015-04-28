/*
 * SimplifiedLearner.h
 *
 *  Created on: Sep 25, 2014
 */

#ifndef SIMPLIFIEDLEARNER_H_
#define SIMPLIFIEDLEARNER_H_

#include "NetworkLearner.h"
#include "../Global/Defines.h"
#include "SimpleRoadInfo.h"


class SimplifiedLearner: public NetworkLearner {
private:
	SimpleRoadInfos infos;
public:
	SimplifiedLearner(const long nbRoads);
	virtual ~SimplifiedLearner();

	virtual void exitedRoad(Road* r, const double time, const double length);
	virtual void enteredRoad(Road* r, const double time);

	virtual double getPredTime(Road* r, const double time);
	virtual bool isFullyLearned(Road* r, const double time);
};

#endif /* SIMPLIFIEDLEARNER_H_ */
