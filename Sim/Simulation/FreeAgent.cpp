/*
 * FreeAgent.cpp
 *
 *  Created on: Sep 25, 2014
 */

#include "FreeAgent.h"

FreeAgent::FreeAgent(TrafficNetwork* net,Node* n, long myId) : Agent(net,n,myId) {
}

FreeAgent::FreeAgent(TrafficNetwork* net, long myId) : Agent(net,myId) {
}

FreeAgent::~FreeAgent() {
}

Road* FreeAgent::nextRoad(const double time){
	//determines next road to be taken

	//simplest decision scheme ; follow shortest path predetermined by network
	Road* nxtRoad = network->nextRoadInSP(node->getId(),routes.front().destId);

	return nxtRoad;
}

