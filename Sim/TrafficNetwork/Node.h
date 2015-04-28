/*
 * Node.h
 *
 *  Created on: Sep 25, 2014
 */

#ifndef NODE_H_
#define NODE_H_

#include "Road.h"
#include "../Global/Defines.h"
#include <vector>
#include <map>

typedef std::map <long,Road*> RoadMap;
typedef std::pair<long, Road*> RoadPair;

class Node {
private:
	long id;
	RoadMap rMap;
	char type;

public:
	Node(long id);
	Node(long id, char type);
	virtual ~Node();

	void addRoad(const long destId,Road* road);
	void addRoad(const RoadPair rPair);
	int getNbRoad();
	bool hasNeighbor(const long destId);
	Road* roadTo(const long dest);
	double costTo(const long dest);
	std::vector<long> getNeighborsId();//Get list of all neighboring nodes' ID

	long getId() const{
		return id;
	}

	char getType() const{
		return type;
	}

};

#endif /* NODE_H_ */
