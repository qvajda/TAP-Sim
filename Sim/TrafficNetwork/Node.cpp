/*
 * Node.cpp
 *
 *  Created on: Sep 25, 2014
 */

#include "Node.h"

Node::Node(long id): id(id), type(NODE_UNDEF) {
}

Node::Node(long id, char type): id(id), type(type) {
}

Node::~Node() {
	for(RoadMap::iterator it = rMap.begin(); it != rMap.end(); ++it) {
	  delete(it->second);
	}
}

void Node::addRoad(const long destId,Road* road){
	this->addRoad(RoadPair(destId,road));
}

void Node::addRoad(const RoadPair rPair){
	rMap.insert(rPair);
}

bool Node::hasNeighbor(const long dest){
	return (rMap.find(dest) != rMap.end());
}

Road* Node::roadTo(const long dest){
	if(hasNeighbor(dest)){
	    return (*rMap.find(dest)).second;
	}
	return 0;
}

double Node::costTo(const long dest){
	if(hasNeighbor(dest)){
	    return (*rMap.find(dest)).second->getMinTravelTime();
	}
	return -1;
}

int Node::getNbRoad(){
	return rMap.size();
}

std::vector<long> Node::getNeighborsId(){
	std::vector<long> nId;
	for(RoadMap::iterator it = rMap.begin(); it != rMap.end(); ++it) {
	  nId.push_back(it->first);
	}
	return nId;
}
