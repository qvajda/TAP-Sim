/*
 * DirectedAgent.h
 *
 *  Created on: Sep 25, 2014
 *      Author: adjax
 */

#ifndef DIRECTEDAGENT_H_
#define DIRECTEDAGENT_H_

#include "Agent.h"
#include "../Learner/NetworkLearner.h"
#include "../ServiceProvider/RequestHandler.h"
#include "../TrafficNetwork/TrafficNetwork.h"
#include "../TrafficNetwork/Node.h"

class DirectedAgent: public Agent {
private:
	RequestHandler* service;
	double prevTime;

protected:
	virtual Road* nextRoad(const double time);
	virtual void reachedNode(const double time);

public:
	DirectedAgent(TrafficNetwork* net,Node* n, long myId, RequestHandler* s);
	DirectedAgent(TrafficNetwork* net, long myId, RequestHandler* s);
	virtual ~DirectedAgent();
};

#endif /* DIRECTEDAGENT_H_ */
