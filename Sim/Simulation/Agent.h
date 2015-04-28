/*
 * Agent.h
 *
 *  Created on: Sep 25, 2014
 */

#ifndef AGENT_H_
#define AGENT_H_

#include "../Global/Defines.h"
#include "Event.h"
#include "../TrafficNetwork/Node.h"
#include "../TrafficNetwork/TrafficNetwork.h"
#include "../TrafficNetwork/Road.h"
#include <queue>

struct Event;

struct Route{
	long destId;
	double departureTime;
	bool relativeTime;

	Route(long d, double t) : destId(d),departureTime(t),relativeTime(false){}
	Route(long d, double t, bool r) : destId(d),departureTime(t),relativeTime(r){}
	Route() : destId(-1),departureTime(-1),relativeTime(false){}

	double anchor(double time){
		if(relativeTime){
			relativeTime = false;
			departureTime += time;
		}
		return departureTime;
	}
};

typedef std::queue<Route> RoutesQ;

class Agent {
private:
	long id;
	bool moving;

	double travelTime;
	double enterTime;
	double travelDist;

protected:
	TrafficNetwork* network;
	Road* crtRoad;
	Node* node;
	RoutesQ routes;

	void enterRoad(const double time); //performs necessary updates after entering a road
	virtual Road* nextRoad(const double time)=0; //determines next road to be taken
	virtual void reachedNode(const double time);//performs any necessary updates after reaching a node
	long getDestId();//return destination node id of current route (or -1 if not moving/no other routes)

public:
	Agent(TrafficNetwork* net,Node* n, long myId);
	Agent(TrafficNetwork* net, long myId);
	virtual ~Agent();

	void setCrtNode(Node* n);

	void addRoute(long destId,double startTime, bool isRelative = false);
	Event handleEvent(Event& event);//handle an event and returns the next one concerning this agent(if any)

	double getTravelTime(); //returns travel time since last call to this function (or instance creation)
	double getTravelDist(); //returns traveled distance since last call to this function (or instance creation)
	long getId();
};

#endif /* AGENT_H_ */
