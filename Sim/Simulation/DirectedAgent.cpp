/*
 * DirectedAgent.cpp
 *
 *  Created on: Sep 25, 2014
 *      Author: adjax
 */

#include "DirectedAgent.h"

DirectedAgent::DirectedAgent(TrafficNetwork* net,Node* n, long myId, RequestHandler* s) : Agent(net,n,myId) {
	service = s;
	prevTime = 0;
}

DirectedAgent::DirectedAgent(TrafficNetwork* net, long myId, RequestHandler* s) : Agent(net,myId) {
	service = s;
	prevTime = 0;
}

DirectedAgent::~DirectedAgent() {
}

Road* DirectedAgent::nextRoad(const double time){
	//determines next road to be taken

	prevTime = time;
	return service->queryRoad(node->getId(),routes.front().destId,time);
}

void DirectedAgent::reachedNode(const double time){
	service->exitedRoad(crtRoad,time,time - prevTime);
	Agent::reachedNode(time);
}
