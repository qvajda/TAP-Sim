/*
 * InformedAgent.cpp
 *
 *  Created on: Jan 27, 2015
 */

#include "InformedAgent.h"

InformedAgent::InformedAgent(TrafficNetwork* net,Node* n, long myId) : FreeAgent(net,n,myId) {
}

InformedAgent::InformedAgent(TrafficNetwork* net, long myId) : FreeAgent(net,myId) {
}

Road* InformedAgent::nextRoad(const double time){
	//determines next road to be taken
	//Uses Reduced A* with real route travel time and shortest travel time as heuristic
	// ==> agent is informed about the current state of the roads he has in front of him as he takes the decision of which one to choose
	std::vector<long> neighborsId = node->getNeighborsId();
	long crtId = node->getId();
	long destId = getDestId();
	long bestId = -1;
	double totalTime,bestTime;
	bestTime = -1;
	for(std::vector<long>::iterator nId = neighborsId.begin() ; nId != neighborsId.end() ; nId++){
		if(! network->isNextNodeInSp(*nId,crtId,destId)){
			totalTime = node->roadTo(*nId)->getTravelTime() + network->minTravelTime(*nId,destId);
			if(totalTime < bestTime || bestTime == -1){
				bestId = *nId;
				bestTime = totalTime;
			}
		}
	}

	return node->roadTo(bestId);
}
