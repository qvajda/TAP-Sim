/*
 * TwinRoad.h
 *
 *  Created on: Feb 18, 2015
 *      Author: adjax
 */

#ifndef TRAFFICNETWORK_TWINROAD_H_
#define TRAFFICNETWORK_TWINROAD_H_

#include "Road.h"

//Twin roads are a couple of road segment going in either direction and sharing a single lane
//each of them knows the opposite one such that it can compute the total capacity usage of the lane
class TwinRoad: public Road {
private:
	Road* twin;
protected:
	virtual long getFlow();
public:
	TwinRoad(const string name,double length,double speedLimit,int nbBands,Node* startingPoint,Node* endPoint);
	virtual ~TwinRoad();

	void setTwin(TwinRoad* r);
};

#endif /* TRAFFICNETWORK_TWINROAD_H_ */
