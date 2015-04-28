/*
 * RoadMonitor.h
 *
 *  Created on: Feb 18, 2015
 */

#ifndef TRAFFICNETWORK_ROADMONITOR_H_
#define TRAFFICNETWORK_ROADMONITOR_H_

#include "../Global/Defines.h"
#include <jansson.h>
#include <vector>
#include <math.h>

struct RoadMonitorEntry{
	double t;
	long count;

	RoadMonitorEntry() :t(0),count(0) {}
	RoadMonitorEntry(double t, long driversCount) : t(t),count(driversCount) {}

};

//A road monitor, implementation of the observer template, used to record drivers count change on a given road
//The recorded information can then be transformed in a JSON format
class RoadMonitor {
private:
	double cap;
	double defaultTT;
	double t_minus;
	long startId,endId;
	std::vector<RoadMonitorEntry> entries;

public:
	RoadMonitor(long startId, long endId);
	virtual ~RoadMonitor();

	void addInfosEntry(double time, long driversCount);
	void addDefaultData(double capacity, double defaultTT);

	json_t * getInfos();
	void resetInfos(bool newWeek = false);
};

#endif /* TRAFFICNETWORK_ROADMONITOR_H_ */
