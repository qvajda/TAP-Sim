/*
 * ExploringAStarHandler.h
 *
 *  Created on: Feb 2, 2015
 *      Author: adjax
 */

#ifndef SERVICEPROVIDER_EXPLORINGHANDLER_H_
#define SERVICEPROVIDER_EXPLORINGHANDLER_H_

#include<vector>
#include "RequestHandler.h"

class ExploringHandler: public RequestHandler {
private:
	RequestHandler* otherHandler;
	double explProb;

public:
	ExploringHandler(RequestHandler* otherHandler,double explProb);
	virtual ~ExploringHandler();

	virtual Road* queryRoad(const long crtId, const long destId, const double time);
};

#endif /* SERVICEPROVIDER_EXPLORINGHANDLER_H_ */
