/*
 * ReducedAStarHandler.cpp
 *
 *  Created on: Jan 8, 2015
 */

#include "ReducedAStarHandler.h"

ReducedAStarHandler::ReducedAStarHandler(TrafficNetwork* net, std::vector<NetworkLearner*> ls, Weights learnersWeights, int d):
RequestHandler(net,ls, learnersWeights),depth(d) {}

double ReducedAStarHandler::depthQuery(const long crtId, const long destId, const double time, const int depth){
	//handle variable depth
	//if depth 0 or destination reached no more prediction step ; returns heuristic value (0 if at destination)
	if(depth == 0 || crtId == destId){
		return network->minTravelTime(crtId,destId);
	}

	//if depth > 0 add another level of prediction to total sum and call lower level
	Node* crtNode = network->getNode(crtId);
	std::vector<long> neighborsId = crtNode->getNeighborsId();

	double time1,time2,totalTime,bestTime;
	bestTime = -1;

	for(std::vector<long>::iterator nId = neighborsId.begin() ; nId != neighborsId.end() ; nId++){
		if(! network->isNextNodeInSp(*nId,crtId,destId)){
			time1 = queryPrediction(crtNode->roadTo(*nId),time);
			time2 = depthQuery((long)*nId,destId,time + time1, depth-1);

			if(time2 != -1){
				totalTime = time1 + time2;
				if(bestTime == -1 || totalTime < bestTime){
					bestTime = totalTime;
				}
			}
		}
	}

	return bestTime;
}

Road* ReducedAStarHandler::queryRoad(const long crtId, const long destId, const double time){
	Node* crtNode = network->getNode(crtId);
	Road* nxtRd = NULL;
	std::vector<long> neighborsId = crtNode->getNeighborsId();

	double time1,time2,totalTime,bestTime;
	bestTime = -1;
	for(std::vector<long>::iterator nId = neighborsId.begin() ; nId != neighborsId.end() ; nId++){
		if(*nId == destId || !network->isNextNodeInSp(*nId,crtId,destId)){
			time1 = queryPrediction(crtNode->roadTo((long)*nId),time);
			time2 = depthQuery((long)*nId,destId,time + time1, depth-1);

			if(time2 != -1){//there should always be at least a non -1 neighbors
				totalTime = time1 + time2;
				if(bestTime == -1 || totalTime < bestTime){
					bestTime = totalTime;
					nxtRd = crtNode->roadTo((long)*nId);
				}
			}
		}
	}
	return nxtRd;
}

ReducedAStarHandler::~ReducedAStarHandler() {
}

