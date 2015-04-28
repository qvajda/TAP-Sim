/*
 * LVLearner.cpp
 *
 *  Created on: Feb 20, 2015
 */

#include "LVLearner.h"

LVLearner::LVLearner(const long nbRoads, const int qSize, const Weights ws):
NetworkLearner(nbRoads), infos(nbRoads,new InfosQ(qSize)), qSize(qSize), ws(ws){}

LVLearner::~LVLearner() {
	for(Infos::iterator i = infos.begin() ; i != infos.begin();i++){
		delete(*i);
	}
}

void LVLearner::exitedRoad(Road* r, const double time, const double length){
	infos[r->getId()]->pop_front();
	infos[r->getId()]->push_back(infoEntry(time,length));
}

void LVLearner::enteredRoad(Road* r, const double time){
	//nothing to do
}

double LVLearner::getPredTime(Road* r, const double time){
	InfosQ* entries = infos[r->getId()];
	double usedWeight = 0;
	double pred = 0;
	double w;

	//weighted sum of recorded entries
	for(int i = 0 ; i< qSize ; i++){
		if(entries->at(i).real){
			w = ws.getWeightAt(qSize-i);
			pred+= w * entries->at(i).travelTime;
			usedWeight += w;
		}
	}

	//any unused weight is assigned to base value of minTravelTime
	pred += (1-usedWeight) * r->getMinTravelTime();

	return pred;
}

bool LVLearner::isFullyLearned(Road* r, const double time){
	return (fmod((infos[r->getId()])->back().time,DAY_SEC) <= LV_TIME_CERTAINTY);
}
