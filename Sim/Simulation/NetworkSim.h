/*
 * NetworkSim.h
 *
 *  Created on: Sep 25, 2014
 */

#ifndef NETWORKSIM_H_
#define NETWORKSIM_H_

#include "Agent.h"
#include "DirectedAgent.h"
#include "InformedAgent.h"
#include "FreeAgent.h"
#include "Event.h"
#include "../TrafficNetwork/TrafficNetwork.h"
#include "../ServiceProvider/RequestHandler.h"
#include "../Global/Defines.h"
#include "../Global/Utilities.h"
#include <queue>
#include <vector>
#include <stdlib.h>
#include <iostream>//TODO REMOVEME

typedef std::vector<Agent*> AgentsVec;
typedef std::priority_queue<Event> EventsQ;

class NetworkSim {
private:
	AgentsVec agents;
	EventsQ events;
	RequestHandler* service;
	TrafficNetwork* network;
	long nbNode;
	double time;

	void populateQueue();

	long getANode(double p ,char type, long diff1=-1, long diff2=-1);//gets a node (id) of given type with probability p that is different from diff1 and diff2 ; 1-p to be of another type

	void addSimplestRoutes(Agent* a);//Add the most basic route possible to a ;
	//a randomly selected OriginDestination pair with a random departure within a day
	void addSmarterRoutes(Agent* a, int nbDays, bool weekly = false);
	//takes into account the type of each node
	void addRealisticRoutes(Agent* a, int nbDays, bool weekly = false);

public:
	NetworkSim(TrafficNetwork* net, RequestHandler* s);
	virtual ~NetworkSim();

	void simulate(const double duration);

	void addAgents(const unsigned long nbFreeAgents, const unsigned long nbInformedAgents, const unsigned long nbDirectedAgents, const int routesType, const int nbDays, bool weekly = false);
	void showTravelTimes();

	bool hasEmptyQueue();

	AgentsVec getAgents();
};

#endif /* NETWORKSIM_H_ */
