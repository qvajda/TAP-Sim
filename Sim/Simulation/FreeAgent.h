/*
 * FreeAgent.h
 *
 *  Created on: Sep 25, 2014
 */

#ifndef FREEAGENT_H_
#define FREEAGENT_H_

#include "Agent.h"
#include "../TrafficNetwork/TrafficNetwork.h"
#include "../TrafficNetwork/Node.h"

class FreeAgent: public Agent {

protected:
	virtual Road* nextRoad(const double time); //determines next road to be taken
public:
	FreeAgent(TrafficNetwork* net,Node* n, long myId);
	FreeAgent(TrafficNetwork* net, long myId);
	virtual ~FreeAgent();
};

#endif /* FREEAGENT_H_ */
