/*
 * InformedAgent.h
 *
 *  Created on: Jan 27, 2015
 */

#ifndef SIMULATION_INFORMEDAGENT_H_
#define SIMULATION_INFORMEDAGENT_H_

#include "FreeAgent.h"
#include "../TrafficNetwork/Node.h"
#include "../TrafficNetwork/TrafficNetwork.h"

class InformedAgent: public FreeAgent {
protected:
	virtual Road* nextRoad(const double time); //determines next road to be taken
public:
	InformedAgent(TrafficNetwork* net,Node* n, long myId);
	InformedAgent(TrafficNetwork* net, long myId);
};

#endif /* SIMULATION_INFORMEDAGENT_H_ */
