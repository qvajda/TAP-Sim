/*
 * ExploringHandler.cpp
 *
 *  Created on: Feb 2, 2015
 */

#include "ExploringHandler.h"

ExploringHandler::ExploringHandler(RequestHandler* otherHandler,double prob):
RequestHandler(otherHandler->getNetwork(),otherHandler->getLearners(),otherHandler->getLearnersWeights()), otherHandler(otherHandler), explProb(prob) {}

ExploringHandler::~ExploringHandler() {
	delete(otherHandler);
}

Road* ExploringHandler::queryRoad(const long crtId, const long destId, const double time){
	Node* crtNode = network->getNode(crtId);
	Road* nxtRd = NULL;
	std::vector<long> neighborsId = crtNode->getNeighborsId();

	double learnedPerc;
	bool fullyExplored = false;

	double explorationProb = 0.1;
	//With a certain probability the service provider will just explore instead of trying to find greedily the best route
	if(probPoll(explorationProb)){
		std::vector<long> interestingNId (0);
		//find all interesting neighbors ;
		//that is neighbors that are going in the right direction (closer to dest than crt is)
		// and that are not yet fully known/discovered/learned
		double crtMinTravelTime = network->minTravelTime(crtId,destId);
		for(std::vector<long>::iterator i = neighborsId.begin() ; i != neighborsId.end() ; i++){
			learnedPerc = 0;
			for(unsigned learnerI = 0; learnerI < learners.size(); learnerI++){
				if((learners[learnerI])->isFullyLearned(crtNode->roadTo(*i),time))
					learnedPerc += learnersWeights.getWeightAt(learnerI);
			}
			fullyExplored = learnedPerc > FULLY_LEARNED_PERC;
			if(network->minTravelTime(*i,destId) < crtMinTravelTime && !fullyExplored){
				interestingNId.push_back(*i);
			}
		}
		//if any "interesting neighbors" have been found ; pick one at random as the next step in the route
		if(interestingNId.size() > 0){
			int randomIndex = rand() % interestingNId.size();
			nxtRd = crtNode->roadTo(interestingNId[randomIndex]);
		}
	}
	if(nxtRd == NULL){
		nxtRd = otherHandler->queryRoad(crtId,destId,time);
	}
	return nxtRd;
}

