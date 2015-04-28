/*
 * Road.cpp
 *
 *  Created on: Sep 25, 2014
 */

#include "Road.h"

unsigned long Road::roadCounter;

Road::Road(const string name,double length,double speedLimit,int nbBands,Node* startingPoint,Node* endPoint) {
	this->name = name;
	this->length = length;
	this->speedLimit = speedLimit;
	this->nbBands = nbBands;
	this->startingPoint = startingPoint;
	this->endPoint = endPoint;
	this->minTravelTime = (length/speedLimit * ROAD_MINTT_MULT)+ROAD_MINTT_ADD;
	driversCount = 0;

	//consider the average length of a car to be 3.5 ; hence the maximum capacity for a single lane is length/car length
	//for simplicity's sake, each lane is considered to not interfere with each other ; as such the total capacity is the following:
	capacity = (length / (CAR_AVG_LENGTH+ CAR_SPACING)) * ROAD_CAPACITY_PERC;
	if (nbBands != 0)
		capacity*=this->nbBands;
	else
		capacity*=0.5;
	if (capacity==0)
		capacity=1;

	monitor = NULL;
	monitored = false;

	id = roadCounter;
	roadCounter++;
}

Road::~Road() {
	if(monitored){
		delete(monitor);
	}
}

double Road::getAbsTravelTime(){
	return minTravelTime * ( 1 + (ALPHA * (pow(getFlow()/capacity,BETA))) );
}

double Road::getTravelTime(){
	double absoluteTT = getAbsTravelTime();
	//return value is "absolute" calculated value with added noise (of TT_VARIANCE % of the absolute value)
	return std::min(std::max(generateGaussianNoise(absoluteTT * TT_VARIANCE, absoluteTT),minTravelTime), 1000*minTravelTime);
}

void Road::addDriver(double time){
	driversCount++;
	if(monitored)
		monitor->addInfosEntry(time,driversCount);
}

void Road::rmDriver(double time){
	if(driversCount>0){
		driversCount--;
		if(monitored)
			monitor->addInfosEntry(time,driversCount);
	}
}

Node* Road::getEndPoint() {
	return endPoint;
}

double Road::getLength() {
	return length;
}

const std::string& Road::getName() {
	return name;
}

double Road::getSpeedLimit() {
	return speedLimit;
}

double Road::getCapacity() {
	return capacity;
}

int Road::getNbBands() {
	return nbBands;
}

Node* Road::getStartingPoint() {
	return startingPoint;
}

const double Road::getMinTravelTime() {
	return minTravelTime;
}

const unsigned long Road::getId() {
	return id;
}

long Road::getFlow(){
	return driversCount;
}

long Road::getDriversCount(){
	return driversCount;
}

void Road::addMonitor(RoadMonitor* m){
	monitor = m;
	if (monitor != NULL){
		monitored = true;
		monitor->addDefaultData(capacity,minTravelTime);
	}
}

RoadMonitor* Road::getMonitor(){
	return monitor;
}
