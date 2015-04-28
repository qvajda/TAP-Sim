/*
 * AStarHandler.cpp
 *
 *  Created on: Feb 23, 2015
 */

#include "AStarHandler.h"

bool operator<(const AStarPrioEntry& e1, const AStarPrioEntry& e2){
	return e1.f_score > e2.f_score;
}

AStarHandler::AStarHandler(TrafficNetwork* net, std::vector<NetworkLearner*> ls, Weights learnersWeights, int d):
RequestHandler(net,ls, learnersWeights){}

AStarHandler::~AStarHandler() {
}

Road* AStarHandler::queryRoad(const long crtId, const long destId, const double time){
	std::map<long,AStarEntry> entries;
	entries[crtId] = AStarEntry(crtId,0,network->minTravelTime(crtId,destId));
	std::priority_queue<AStarPrioEntry> openset;
	openset.push(AStarPrioEntry(crtId,network->minTravelTime(crtId,destId)));

	std::vector<long> neighborsId;

	bool found = false;
	long current;

	double tentative_g_score;

	while (!openset.empty() && !found){
		current = openset.top().id;//the node in openset having the lowest f_score[] value
		openset.pop();
		if (current == destId)
			found = true;

		entries[current].mark = true; //add current to closedset
		neighborsId = network->getNode(current)->getNeighborsId();
		for(std::vector<long>::iterator nId = neighborsId.begin() ; nId != neighborsId.end() ; nId++){
			if (entries.find(*nId) == entries.end() || (!entries[*nId].mark)){ //if nId not yet treated
				tentative_g_score = entries[current].g_score + queryPrediction(network->getNode(current)->roadTo(*nId),time+entries[current].g_score);
				if (entries.find(*nId) == entries.end()){
					entries[*nId] = AStarEntry(current,tentative_g_score,tentative_g_score + network->minTravelTime(*nId,destId));
					openset.push(AStarPrioEntry(*nId,tentative_g_score + network->minTravelTime(*nId,destId)));
				}else if(tentative_g_score < entries[*nId].g_score){
					entries[*nId] = AStarEntry(current,tentative_g_score,tentative_g_score + network->minTravelTime(*nId,destId));
				}
			}
		}
	}

	//cycle back to beginning of the path
	while(entries[current].came_from != crtId){
		current = entries[current].came_from;
	}
	return network->getNode(crtId)->roadTo(current);
}
