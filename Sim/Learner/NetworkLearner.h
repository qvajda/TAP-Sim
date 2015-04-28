/*
 * NetworkLearner.h
 *
 *  Created on: Sep 25, 2014
 */

#ifndef NETWORKLEARNER_H_
#define NETWORKLEARNER_H_

#include "../Global/Defines.h"
#include "../TrafficNetwork/Road.h"
#include <math.h>       /* pow */

class NetworkLearner {
protected:
	long nbRoads;
	double getPredictedFlow(Road* r, const double time);
public:
	NetworkLearner(const long nbRoads);
	virtual ~NetworkLearner();

	virtual void exitedRoad(Road* r, const double time, const double length)=0; //update learned information after an agent has exited a road segment
	virtual void enteredRoad(Road* r, const double time)=0; //update learned information after an agent enter a road segment

	virtual double getPredTime(Road* r, const double time)=0; //get the prediction for a given road at a given time
	virtual bool isFullyLearned(Road* r, const double time)=0; //determines if a prediction for given arguments would be based on "fully learned" data

	double getMarginalPredTime(Road* r, const double time); //get the prediction for a given road, with added marginal costs
};

#endif /* NETWORKLEARNER_H_ */
