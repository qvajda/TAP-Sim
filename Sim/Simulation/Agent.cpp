/*
 * Agent.cpp
 *
 *  Created on: Sep 25, 2014
 */

#include "Agent.h"

Agent::Agent(TrafficNetwork* net,Node* n, long myId) {
	node = n;
	network = net;
	id = myId;
	moving = false;
	routes = RoutesQ();
	crtRoad = NULL;

	travelTime = 0;
	travelDist = 0;
	enterTime = 0;

}

Agent::Agent(TrafficNetwork* net, long myId) {
	node = NULL;
	network = net;
	id = myId;
	moving = false;
	routes = RoutesQ();
	crtRoad = NULL;

	travelTime = 0;
	travelDist = 0;
	enterTime = 0;
}

void Agent::addRoute(long destId,double startTime, bool isRelative){
	routes.push(Route(destId,startTime,isRelative));
}

Event Agent::handleEvent(Event& event){
	if(moving){
		travelDist += crtRoad->getLength();
		reachedNode(event.time);
	}
	Event nxtEvent = Event();
	nxtEvent.agent = this;

	switch (event.type){

	case ENTER_NET:
		moving = true;
		enterTime = event.time;
	case ENTER_ROAD:
		crtRoad = nextRoad(event.time);
		nxtEvent.time = event.time + crtRoad->getTravelTime();
		if(crtRoad->getEndPoint()->getId() == routes.front().destId){
			//next event will be reaching destination
			nxtEvent.type = LEAVE_NET;
		}else{
			nxtEvent.type = ENTER_ROAD;
		}
		enterRoad(event.time);
		break;

	case LEAVE_NET:
		//when route's destination has been reached
		travelTime += event.time - enterTime;
		routes.pop();
		moving = false;
		if(!routes.empty() and routes.front().anchor(event.time) <= event.time){
			//another route exists, and is available right now
			///create a bogus event to chain with the current one
			nxtEvent.time = event.time;
			nxtEvent.type = ENTER_NET;
			nxtEvent = handleEvent(nxtEvent);
		}else if(routes.empty()){
			//no other route exist
			nxtEvent.time = event.time;
			nxtEvent.type = NO_MORE_EVENT;
		}else{
			//next route is not yet available ; stop moving until it is
			nxtEvent.time = routes.front().departureTime;
			nxtEvent.type = ENTER_NET;
		}

		break;
	case INIT_EVENT:
		nxtEvent.type = ENTER_NET;
		nxtEvent.time = routes.front().anchor(event.time);
		break;
	}
	return nxtEvent;
}

void Agent::reachedNode(const double time){
	//update last node visited
	node = crtRoad->getEndPoint();
	crtRoad->rmDriver(time);
}

void Agent::enterRoad(const double time){
	//update number of agent on road
	crtRoad->addDriver(time);
}

void Agent::setCrtNode(Node* n){
	node = n;
}

long Agent::getDestId(){
	if(!moving){
		return -1;
	}
	return routes.front().destId;
}

double Agent::getTravelTime(){
	double res = travelTime;
	travelTime = 0;
	return res;
}

double Agent::getTravelDist(){
	double res = travelDist;
	travelDist = 0;
	return res;
}
long Agent::getId(){
	return id;
}

Agent::~Agent() {
}

