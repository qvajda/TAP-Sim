/*
 * TrafficNetwork.h
 *
 *  Created on: Sep 15, 2014
 */

#ifndef TRAFFICNETWORK_H_
#define TRAFFICNETWORK_H_

#include <vector>
#include <string>
#include <iostream>
#include <jansson.h>
#include "Node.h"
#include "RoadMonitor.h"
#include "TwinRoad.h"

typedef std::string string;
typedef std::vector<Node* > NodeVec;
typedef std::pair<double,Node* > RoutePair;
typedef std::vector<RoutePair> RouteVec;
typedef std::vector<RouteVec> RouteMatrix;

class TrafficNetwork {
private:
	string name;
	string fileName;
	long nbNodes;
	NodeVec nodes;

	RouteMatrix shortestRoutes;
	bool everythingOk;//flag marking whether an input file has been correctly read
	bool monitered;
	bool firstSaved;

public:
	TrafficNetwork(const long nbNodes, const string name, bool monitered);
	TrafficNetwork(const string fileName, const string name, bool monitered);
	virtual ~TrafficNetwork();

	bool loadFromFile(const string fileName);
	bool saveToFile(const string fileName, bool newWeek = false);
	void addRoad(const long startNodeId, const long endNodeId,const string roadName, const double length,const double speedLimit, const int nbBands);

	void initShortestRouteMatrix();

	long getNbNodes();

	Road* nextRoadInSP(const long crtId, const long destId);
	bool isNextNodeInSp(const long crtId, const long nxtId, const long destId);
	double minTravelTime(const long crtId, const long destId);
	Node* getNode(const long id);
	std::vector<double>getMinTTVec();

	bool isCreated();

};

#endif /* TRAFFICNETWORK_H_ */
