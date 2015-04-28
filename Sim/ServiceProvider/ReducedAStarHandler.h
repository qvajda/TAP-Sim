/*
 * ReducedAStarHandler.h
 *
 *  Created on: Jan 8, 2015
 */

#ifndef SERVICEPROVIDER_REDUCEDASTARHANDLER_H_
#define SERVICEPROVIDER_REDUCEDASTARHANDLER_H_

#include <stdlib.h>
#include <vector>
#include "RequestHandler.h"
#include "../Global/Defines.h"
#include "../Global/Utilities.h"

class ReducedAStarHandler: public RequestHandler {
private:
	int depth;

	double depthQuery(const long crtId, const long destId, const double time, const int depth);

public:
	ReducedAStarHandler(TrafficNetwork* net, std::vector<NetworkLearner*> ls, Weights learnersWeights, int d = 1);
	virtual ~ReducedAStarHandler();

	virtual Road* queryRoad(const long crtId, const long destId, const double time);
};

#endif /* SERVICEPROVIDER_REDUCEDASTARHANDLER_H_ */
