/*
 * Road.h
 *
 *  Created on: Sep 25, 2014
 */

#ifndef ROAD_H_
#define ROAD_H_

#include <string>
#include "RoadMonitor.h"
#include "../Global/Defines.h"
#include "../Global/Utilities.h"
#include <math.h>       /* pow */
#include <algorithm>    // std::max


typedef std::string string;

class Node;

class Road {

private:
	string name;			// street name
	double length;	 		// given in meters
	double speedLimit; 		// stored in meters per seconds
	int nbBands;			// number of circulation bands
	Node* startingPoint;
	Node* endPoint;
	double minTravelTime;	// given in seconds

	unsigned long id;

	RoadMonitor* monitor;
	bool monitored;

protected:
	long driversCount;
	double capacity;

	double getAbsTravelTime();
	virtual long getFlow();

public:

	Road(const string name,double length,double speedLimit,int nbBands,Node* startingPoint,Node* endPoint);
	virtual ~Road();

	Node* getEndPoint();
	double getLength();
	const std::string& getName();
	double getSpeedLimit();
	int getNbBands();
	Node* getStartingPoint();
	const double getMinTravelTime();
	const unsigned long getId();
	double getTravelTime();
	long getDriversCount();
	double getCapacity();

	void addDriver(double time);
	void rmDriver(double time);

	void addMonitor(RoadMonitor* m);
	RoadMonitor* getMonitor();

	static unsigned long roadCounter;
};

#endif /* ROAD_H_ */
