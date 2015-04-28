/*
 * AStarHandler.h
 *
 *  Created on: Feb 23, 2015
 */

#ifndef SERVICEPROVIDER_ASTARHANDLER_H_
#define SERVICEPROVIDER_ASTARHANDLER_H_

#include "RequestHandler.h"
#include<map>
#include<queue>

struct AStarEntry{
	long came_from;
	double g_score;//cost from start
	double f_score;//cost to end
	bool mark;

	AStarEntry(long c, double g, double f):came_from(c),g_score(g),f_score(f),mark(false){}
	AStarEntry():came_from(0),g_score(0),f_score(0),mark(false){}
};

struct AStarPrioEntry{
	long id;
	double f_score;
	AStarPrioEntry(long i,double f):id(i),f_score(i){}
};

bool operator<(const AStarPrioEntry& e1, const AStarPrioEntry& e2);

class AStarHandler: public RequestHandler {
public:
	AStarHandler(TrafficNetwork* net, std::vector<NetworkLearner*> ls, Weights learnersWeights, int d = 1);
	virtual ~AStarHandler();

	virtual Road* queryRoad(const long crtId, const long destId, const double time);
	};

#endif /* SERVICEPROVIDER_ASTARHANDLER_H_ */
