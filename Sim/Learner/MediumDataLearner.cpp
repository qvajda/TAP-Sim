/*
 * MediumDataLearner.cpp
 *
 *  Created on: Sep 25, 2014
 */

#include "MediumDataLearner.h"

MediumDataLearner::MediumDataLearner(const long nbRoads, const int nbIntervals, const Weights ws): NetworkLearner(nbRoads), weights(ws) {
	infos = MediumRoadInfos(nbRoads,SimpleRoadInfos(nbIntervals));
	intervalLength = DAY_SEC / nbIntervals;
}

void MediumDataLearner::exitedRoad(Road* r, const double time, const double length){
	int interval = (fmod(time,DAY_SEC))/intervalLength;
	infos[r->getId()][interval].addInfo(length);
}

void MediumDataLearner::enteredRoad(Road* r, const double time){
	//nothing to do
}

int MediumDataLearner::formatIntervalIndex(int i){
	int j = i;
	int nbInterval = infos[0].size();
	while (j < 0)
		j+= nbInterval;
	return j % nbInterval;

}

double MediumDataLearner::getPredTime(Road* r, const double time){
	int interval = (fmod(time,DAY_SEC))/intervalLength;
	unsigned long long count = infos[r->getId()][interval].counter;
	double usedWeight = weights.getWeightAt(0);
	double pred = infos[r->getId()][interval].avgLength * usedWeight;

	if(count == 0){
		pred = 0;
		usedWeight= 0;
	}else if(count < MIN_INFO_THRESHOLD){
		pred = pred/2;
		usedWeight = usedWeight/2;
	}
	if(count < INFO_CERTAINTY_THRESHOLD){
		//if not enough information to be certain of prediction : add information from neighboring time intervals (if themselves are relevant)
		for(int i = weights.getBeginIndex(); i < weights.getEndIndex(); i++){
			if(i != 0 && infos[r->getId()][formatIntervalIndex(interval+i)].counter > MIN_INFO_THRESHOLD){

				pred += infos[r->getId()][formatIntervalIndex(interval+i)].avgLength * weights.getWeightAt(i);
				usedWeight = weights.getWeightAt(i);
			}
		}
	}else{
		pred = pred/usedWeight;
		usedWeight = weights.getTotalWeight();
	}
	//complete prediction with simple heuristic if not all weight used
	pred += r->getMinTravelTime() * (weights.getTotalWeight() - usedWeight);

	//normalize
	pred = pred/weights.getTotalWeight();

	return pred;
}

bool MediumDataLearner::isFullyLearned(Road* r, const double time){
	int interval = (fmod(time,DAY_SEC))/intervalLength;
	return (infos[r->getId()][interval].counter >= INFO_CERTAINTY_THRESHOLD);
}

void MediumDataLearner::setWeights(const Weights new_ws){
	weights = new_ws;
}

MediumDataLearner::~MediumDataLearner() {
}

