/*
 * RequestHandler.h
 *
 *  Created on: Sep 25, 2014
 */

#ifndef REQUESTHANDLER_H_
#define REQUESTHANDLER_H_

#include<vector>
#include "../Global/Weights.h"
#include "../Global/Defines.h"
#include "../Learner/NetworkLearner.h"
#include "../TrafficNetwork/Road.h"
#include "../TrafficNetwork/TrafficNetwork.h"

class RequestHandler {
protected:
	std::vector<NetworkLearner*> learners;
	Weights learnersWeights;
	TrafficNetwork* network;
	bool useMarginal;

	double queryPrediction(Road* r, const double time);
public:
	RequestHandler(TrafficNetwork* net, std::vector<NetworkLearner*> ls, Weights learnersWeights);
	virtual ~RequestHandler();

	void setMarginalUsage(bool val);

	virtual void exitedRoad(Road* r, const double time, const double length);
	virtual void enteredRoad(Road* r, const double time);

	virtual Road* queryRoad(const long crtId, const long destId, const double time)=0;

	std::vector<NetworkLearner*> getLearners();
	Weights getLearnersWeights();
	TrafficNetwork* getNetwork();
};

#endif /* REQUESTHANDLER_H_ */
