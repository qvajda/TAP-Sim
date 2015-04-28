/*
 * TwinRoad.cpp
 *
 *  Created on: Feb 18, 2015
 *      Author: adjax
 */

#include "TwinRoad.h"

TwinRoad::TwinRoad(const string name,double length,double speedLimit,int nbBands,Node* startingPoint,Node* endPoint):
Road(name,length,speedLimit,nbBands,startingPoint,endPoint) {
	twin = NULL;
}

TwinRoad::~TwinRoad() {
}

void TwinRoad::setTwin(TwinRoad* r){
	if(twin == NULL){
		twin = r;
	}
}

long TwinRoad::getFlow(){
	long flow = driversCount;
	if(twin != NULL)
		flow += twin->getDriversCount();
	return flow;
}
