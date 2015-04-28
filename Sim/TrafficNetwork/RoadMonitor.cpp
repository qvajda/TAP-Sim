/*
 * RoadMonitor.cpp
 *
 *  Created on: Feb 18, 2015
 */

#include "RoadMonitor.h"

RoadMonitor::RoadMonitor(long startId, long endId): cap(0), defaultTT(0),t_minus(0), startId(startId), endId(endId) {
	entries = std::vector<RoadMonitorEntry>(0);
}

RoadMonitor::~RoadMonitor() {
}

json_t * RoadMonitor::getInfos(){
	json_t* infos = json_object();
	json_object_set_new(infos, "startId",json_integer(startId));
	json_object_set_new(infos, "endId",json_integer(endId));
	json_object_set_new(infos,"capacity",json_real(cap));

	json_object_set_new(infos, "data",json_array());

	for(std::vector<RoadMonitorEntry>::iterator it = entries.begin();it!=entries.end();it++){
		json_t *entry = json_array();
		json_array_append_new(entry,json_integer(((*it).t/3600)*TIME_PRECISION));// /3600 to go from sec to h
		json_array_append_new(entry,json_integer((*it).count));

		json_array_append_new(json_object_get(infos,"data"),entry);
	}
	return infos;
}
void RoadMonitor::resetInfos(bool newWeek){
	//reinitialize entries (done after each day) ; only resetting default information after each week
	std::vector<RoadMonitorEntry>().swap(entries);
	if(newWeek){
		t_minus+= (DAY_SEC*7);
		addInfosEntry(t_minus,0);
	}
}

void RoadMonitor::addInfosEntry(double time, long driversCount){
	entries.push_back(RoadMonitorEntry(time-t_minus,driversCount));
}

void RoadMonitor::addDefaultData(double capacity, double defaultTT){
	cap = capacity;
	this->defaultTT = defaultTT;
	addInfosEntry(0,0);
}
