/*
 * SimplifiedLearner.cpp
 *
 *  Created on: Sep 25, 2014
 */

#include "SimplifiedLearner.h"

SimplifiedLearner::SimplifiedLearner(const long n): NetworkLearner(n) {
	infos = SimpleRoadInfos(nbRoads);
}

void SimplifiedLearner::exitedRoad(Road* r, const double time, const double length){
	infos[r->getId()].addInfo(length);
}

void SimplifiedLearner::enteredRoad(Road* r, const double time){
	//nothing to do
}

double SimplifiedLearner::getPredTime(Road* r, const double time){
	double pred = infos[r->getId()].avgLength;
	unsigned long long count = (infos[r->getId()]).counter;

	if(count == 0){
		pred = r->getMinTravelTime(); //if no information learned at all ; only use basic heuristic to predict travel time
	}else if(count < MIN_INFO_THRESHOLD){
		pred = (pred + r->getMinTravelTime())/2; //if not enough info learned ; add heuristic to prediction (with 0.5 weight)

	}

	return pred;
}

bool SimplifiedLearner::isFullyLearned(Road* r, const double time){
	return (infos[r->getId()]).counter >= INFO_CERTAINTY_THRESHOLD;
}

SimplifiedLearner::~SimplifiedLearner() {
}
