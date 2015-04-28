/*
 * RequestHandler.cpp
 *
 *  Created on: Sep 25, 2014
 */

#include "RequestHandler.h"

RequestHandler::RequestHandler(TrafficNetwork* net, std::vector<NetworkLearner*> ls, Weights learnersWeights):
learners(ls), learnersWeights(learnersWeights), network(net), useMarginal(false) {}

void RequestHandler::setMarginalUsage(bool val){
	useMarginal = val;
}

void RequestHandler::exitedRoad(Road* r, const double time, const double length){
	for(std::vector<NetworkLearner*>::iterator learner = learners.begin(); learner != learners.end(); learner++){
		(*learner)->exitedRoad(r,time,length);
	}
}
void RequestHandler::enteredRoad(Road* r, const double time){
	for(std::vector<NetworkLearner*>::iterator learner = learners.begin(); learner != learners.end(); learner++){
		(*learner)->enteredRoad(r,time);
	}
}

RequestHandler::~RequestHandler() {
}

double RequestHandler::queryPrediction(Road* r, const double time){
	double pred = 0;
	for(unsigned i = 0; i < learners.size(); i++){
		if(!useMarginal){
			pred += learners[i]->getPredTime(r,time) * learnersWeights.getWeightAt(i);
		}else{
			pred += learners[i]->getMarginalPredTime(r,time) * learnersWeights.getWeightAt(i);
		}
	}
	return pred;
}

std::vector<NetworkLearner*> RequestHandler::getLearners(){
	return learners;
}

Weights RequestHandler::getLearnersWeights(){
	return learnersWeights;
}

TrafficNetwork* RequestHandler::getNetwork(){
	return network;
}

