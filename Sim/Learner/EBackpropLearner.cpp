/*
 * EBackpropLearner.cpp
 *
 *  Created on: Mar 7, 2015
 */

#include "EBackpropLearner.h"

EBackpropLearner::EBackpropLearner(const long nbRoads,double learningFactor):
NetworkLearner(nbRoads),predictedTT(nbRoads,0),learnedFlags(nbRoads,false),learningFactor(learningFactor) {}

void EBackpropLearner::exitedRoad(Road* r, const double time, const double length){
	if(predictedTT[r->getId()] == 0){
		predictedTT[r->getId()] = r->getMinTravelTime();
	}
	//update prediction
	double error = length - predictedTT[r->getId()];
	predictedTT[r->getId()] += error*learningFactor;

	//update fully learned factor ; if error percentage is smaller than EBP_PRECISION constant, then the road is considered fully learned
	double errorPerc = abs(error)/length;
	learnedFlags[r->getId()] = errorPerc < EBP_PRECISION;
}

void EBackpropLearner::enteredRoad(Road* r, const double time){
	//nothing to do
}

double EBackpropLearner::getPredTime(Road* r, const double time){
	double pred = predictedTT[r->getId()];

	if(!learnedFlags[r->getId()] || pred < r->getMinTravelTime()){
		//if not learned ; add basic min travel time heuristic to the prediction
		pred = (std::max(pred,r->getMinTravelTime())*0.5) + 0.5*r->getMinTravelTime() ;
	}
	return pred;
}

bool EBackpropLearner::isFullyLearned(Road* r, const double time){
	return learnedFlags[r->getId()];
}

EBackpropLearner::~EBackpropLearner() {
}

