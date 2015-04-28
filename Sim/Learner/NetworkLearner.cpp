/*
 * NetworkLearner.cpp
 *
 *  Created on: Sep 25, 2014
 */

#include "NetworkLearner.h"

NetworkLearner::NetworkLearner(const long nbRoads) {
	this->nbRoads = nbRoads;
}

NetworkLearner::~NetworkLearner() {
}

double NetworkLearner::getPredictedFlow(Road* r, double time){
	double tt = this->getPredTime(r,time);
	if(tt == r->getMinTravelTime()){
		return 0;
	}
	double flow = r->getCapacity() * ( pow(((tt / r->getMinTravelTime())-1)/ALPHA,-BETA) );
	return flow;
}

double NetworkLearner::getMarginalPredTime(Road* r, const double time){
	double tt = this->getPredTime(r,time);
	if(tt == r->getMinTravelTime()){
		return tt;
	}
	//double flow = r->getCapacity() * ( pow( ((tt / r->getMinTravelTime()) - 1)/ALPHA , 1/BETA) ); <=== actual formula doesn't work (probably due to the BETA root)
	int flow = 0;
	while((r->getMinTravelTime() * ( 1 + (ALPHA * (pow(flow/r->getCapacity(),BETA))) ))<tt)
		flow++;

	if(flow>1){
		double tt_dif = tt - (r->getMinTravelTime() * ( 1 + (ALPHA * (pow((flow-1)/r->getCapacity(),BETA))) ));
		tt += (flow-1) * tt_dif;
	}
	return tt;
}

