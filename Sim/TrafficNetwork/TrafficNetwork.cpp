/*
 * TrafficNetwork.cpp
 *
 *  Created on: Sep 15, 2014
 */

#include "TrafficNetwork.h"

/*
 * format given length in given metric to meters
 * */
double formatLength(double length,int metric){
	double l = length;
	switch(metric){
	case KPH:case KPS:
		l= l * 1000;
		break;
	case MPS: case MPH: default:
		//nothing to do : already in meters
		break;
	}
	return l;
}

/*
 * format given length in given metric to meters/seconds
 * */
double formatSpeedLimit(double speedLimit,int metric){
	double sl = speedLimit;
	switch(metric){
	case KPH:
		sl/=3.6;
		break;
	case KPS:
		sl*=1000;
		break;
	case MPH:
		sl/=3600;
		break;
	case MPS: default:
		//nothing to do : already in meters/seconds
		break;
	}
	return sl;
}

TrafficNetwork::TrafficNetwork(const long _nbNodes,const string _name, bool monitered) {
	nbNodes = _nbNodes;
	this->monitered = monitered;
	name = _name;
	nodes = NodeVec(nbNodes);
	long i;
	for(i=0 ; i<nbNodes ; i++){
		nodes[i] = new Node(i);
	}
	initShortestRouteMatrix();
	everythingOk = true;
	fileName = "";
	firstSaved = true;
}

TrafficNetwork::TrafficNetwork(const string fileName, const string _name, bool monitered) {
	name = _name;
	this->monitered = monitered;
	everythingOk = loadFromFile(fileName);
	this->fileName = fileName;
	if(!everythingOk){
		nodes = NodeVec(0);
	}
	initShortestRouteMatrix();
	firstSaved = true;
}

void TrafficNetwork::initShortestRouteMatrix(){
	//Dijkstra implementation
	shortestRoutes = RouteMatrix(nbNodes);
	Node* srcNode,*u;
	long srcId,uId,i,j;
	RouteVec routePrev = RouteVec(nbNodes);
	std::vector<bool> marks = std::vector<bool>(nbNodes);
	double minDist,newDist;
	std::vector<long> neighborsIds;

	for(i=0 ; i<nbNodes ; i++){
		shortestRoutes[i] = RouteVec(nbNodes);
	}

	for(NodeVec::iterator nodeIt = nodes.begin() ; nodeIt != nodes.end(); ++nodeIt){
		srcNode = *nodeIt;
		srcId = srcNode->getId();
		for(i = 0; i<nbNodes ; i++){
			marks[i]=false;
			routePrev[i] = RoutePair(-1,nodes[i]);
		}

		routePrev[srcId] = RoutePair(0,srcNode);
		marks[srcId] = true;
		for(i = 0; i<nbNodes ; i++){
			//find node with smallest distance to srcNode
			minDist = -1;
			for(long j = 0; j<nbNodes ; j++){
				if(!marks[j] and routePrev[j].first != -1 and
						(routePrev[j].first < minDist or minDist == -1)){
					minDist = routePrev[j].first;
					u = nodes[j];
				}
			}
			if(minDist == -1){
				u = nodes[srcId];
				minDist = 0;
			}
			uId = u->getId();
			marks[uId] = true;
			neighborsIds = u->getNeighborsId();
			for (std::vector<long>::iterator nId = neighborsIds.begin() ; nId != neighborsIds.end() ; nId++){
				newDist = routePrev[uId].first + u->costTo(*nId);
				if(routePrev[*nId].first == -1 or newDist < routePrev[*nId].first){
					routePrev[*nId] = RoutePair(newDist,u);
				}
			}
		}

		//"invert" routePrev to have a vector of pair
		//<minDistance, next node in route from source> instead of
		// <minDistance, previous node in route from source>
		for(i = 0; i<nbNodes ; i++){
			marks[i]=false;
		}
		marks[srcId]=true;
		shortestRoutes[srcId][srcId] = RoutePair(0,nodes[srcId]);
		for(i = 0; i<nbNodes ; i++){
			if(!marks[i]){
				j=i;
				//travel backwards from j to src or another node for which the next node from the start is already known
				while(!marks[routePrev[j].second->getId()]){
					j=routePrev[j].second->getId();
				}

				//if we traveled all the way back
				if(routePrev[j].second == srcNode){
					shortestRoutes[srcId][i] = RoutePair(routePrev[i].first,nodes[j]);
					//update route to j (a direct neighbor of source) at the same time
					if(j!=i){
						shortestRoutes[srcId][j] = RoutePair(routePrev[j].first,nodes[j]);
						marks[j]=true;
					}
				}else{
					//if we found a previously visited node on the way
					shortestRoutes[srcId][i] = RoutePair(routePrev[i].first,
							shortestRoutes[srcId][routePrev[j].second->getId()].second);
					//update route to j at the same time
					if(j!=i){
						shortestRoutes[srcId][j] = RoutePair(routePrev[j].first,
							shortestRoutes[srcId][routePrev[j].second->getId()].second);
						marks[j]=true;
					}
				}
				marks[i]=true;
			}
		}
	}
}

bool TrafficNetwork::saveToFile(const string out_prefix, bool newWeek){
	bool everythingOK = true;
	int metric = KPH; //save in KPH such that it can be used by external tool (and be human readable)
	std::vector<long> nIds;
	long crtId;
	char crtType;
	string out_fileName = (out_prefix+"_roads_stats.json");

	json_t *root = NULL;

	if(firstSaved){
		if(fileName != ""){
			json_error_t error;

			root = json_load_file(fileName.c_str(), 0, &error);

			if(!root){
				std::cout<<std::endl<<"WARNING: while opening "<<fileName<<" at line "<<error.line<<" - "<<error.text<<std::endl;
				root= NULL;
			}

			if(!json_is_object(root)){
				std::cout<<std::endl<<"WARNING: input file "<<fileName<<" has not the correct structure - expected root to be an object"<<std::endl;
				json_decref(root);
				root = NULL;
			}

			if(!root){
				std::cout<<"File "<<fileName<<" could not be using during saving process"<<std::endl<<"\t --> reverting to saving network based on stored data (possibility for loss of positional infos)"<<std::endl;
			}
		}

		if(!root){
			root = json_object();
			if ( root ) {
				json_object_set_new(root, "metric" ,json_integer(metric));
				json_t *_nodes = json_array();
				json_t *_roads = json_array();
				for(NodeVec::iterator it= nodes.begin() ; it!=nodes.end(); ++it){
					json_t * _node = json_object();
					crtId = (*it)->getId();
					crtType = (*it)->getType();
					json_object_set_new(_node,"id",json_integer(crtId));
					json_object_set_new(_node,"type",json_integer(crtType));
					json_array_append_new(_nodes,_node);
					nIds = (*it)->getNeighborsId();
					for(std::vector<long>::iterator jt = nIds.begin(); jt != nIds.end(); ++jt){
						Road r = *((*it)->roadTo(*jt));
						json_t * _road = json_object();
						json_object_set_new(_road,"name",json_string(r.getName().c_str()));
						json_object_set_new(_road,"startId",json_integer(crtId));
						json_object_set_new(_road,"endId",json_integer(r.getEndPoint()->getId()));
						json_object_set_new(_road,"speedLimit",json_integer(r.getSpeedLimit()*3.6)); //x3.6 to go from MPS to KPH
						json_object_set_new(_road,"length",json_real(r.getLength()/1000)); // /1000 to go from M to K
						json_object_set_new(_road,"nbBands",json_integer(r.getNbBands()));

						json_array_append_new(_roads,_road);
					}
				}
				json_object_set_new(root, "nodes" ,_nodes);
				json_object_set_new(root, "roads" ,_roads);
			}else{
				std::cout<<"ERROR: Could not create 'root' during saving process"<<std::endl;
				return false;
			}

		}
	}else{
		json_error_t error;

		root = json_load_file(out_fileName.c_str(), 0, &error);

		if(!root){
			std::cout<<std::endl<<"ERROR: while opening "<<out_fileName<<" at line "<<error.line<<" - "<<error.text<<std::endl;
			root= NULL;
			return false;
		}

		if(!json_is_object(root)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - expected root to be an object"<<std::endl;
			json_decref(root);
			root = NULL;
			return false;
		}
	}

	json_t *roadsInfos;
	if(monitered){
		bool first = false;
		if(firstSaved){
			roadsInfos = json_array();
			int nbRoads = json_array_size(json_object_get(root,"roads"));
			for(int i = 0; i < nbRoads; i++){
				json_array_append_new(roadsInfos,json_object());
			}
			json_object_set(root,"roadsInfos",roadsInfos);
			json_object_set_new(root,"timePrecision",json_integer(TIME_PRECISION));
			json_object_set_new(root,"time_index",json_integer(0));
			json_object_set_new(root,"driversCount_index",json_integer(1));
			firstSaved = false;
			first = true;
		}else
			roadsInfos = json_object_get(root,"roadsInfos");
		json_t *infos;
		for(NodeVec::iterator it= nodes.begin() ; it!=nodes.end(); ++it){
			nIds = (*it)->getNeighborsId();
			for(std::vector<long>::iterator jt = nIds.begin(); jt != nIds.end(); ++jt){
				Road* r = ((*it)->roadTo(*jt));
				infos = r->getMonitor()->getInfos();
				if(first){
					json_object_update(json_array_get(roadsInfos,r->getId()),infos);
				}else{
					json_array_extend(json_object_get(json_array_get(roadsInfos,r->getId()),"data"),json_object_get(infos,"data"));
				}
				r->getMonitor()->resetInfos(newWeek);
				json_object_clear(infos);
				json_decref(infos);
			}
		}
	}

	//actually save
	if(!(json_dump_file(root,out_fileName.c_str(),JSON_COMPACT) == 0)){
	//if(!(json_dump_file(root,out_fileName.c_str(),JSON_INDENT(2)) == 0)){ //<== to have pretty JSON file
		everythingOK = false;
		std::cout<< "Could not open file : "<<out_fileName << " to write down network "<< name <<std::endl;
	}
	if(monitered){
		json_array_clear(roadsInfos);
	}
	json_object_clear(root);
	json_decref(root);
	if(newWeek){
		firstSaved = true;
	}
	return everythingOK;
}

bool TrafficNetwork::loadFromFile(const string fileName){
	int nbBands;
	long currentNode,otherNode;
	string roadName;
	double roadLength;
	double roadSpeedLimit;
	int metric;

	json_t *root;
	json_error_t error;

	root = json_load_file(fileName.c_str(), 0, &error);

	if(!root){
		std::cout<<std::endl<<"ERROR: while opening "<<fileName<<" at line "<<error.line<<" - "<<error.text<<std::endl;
		return false;
	}

	if(!json_is_object(root)){
		std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - expected root to be an object"<<std::endl;
		json_decref(root);
		return false;
	}

	json_t *_metric, *_roads, *_nodes;
	_metric = json_object_get(root,"metric");

	if(!json_is_integer(_metric)){
		std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'metric' field not present or wrong type"<<std::endl;
		json_decref(root);
		return false;
	}
	metric = json_integer_value(_metric);

	_nodes = json_object_get(root,"nodes");
	if(!json_is_array(_nodes)){
		std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'nodes' field not present or not an array"<<std::endl;
		json_decref(root);
		return false;
	}

	size_t n = json_array_size(_nodes);
	nbNodes = n;
	nodes = NodeVec(nbNodes);
	json_t *nodeId,*_node, *nodeType;
	for(size_t i = 0; i < n; i++){
		_node = json_array_get(_nodes,i);
		if(!json_is_object(_node)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - expected node "<<i<<" to be an object"<<std::endl;
			json_decref(root);
			return false;
		}
		nodeId = json_object_get(_node,"id");
		if(!json_is_integer(nodeId)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'id' field of node "<<i<<" not present or wrong type"<<std::endl;
			json_decref(root);
			return false;
		}
		nodeType = json_object_get(_node,"type");
		if(json_is_integer(nodeType)){
			nodes[i] = new Node(json_integer_value(nodeId),json_integer_value(nodeType));
		}else{
			nodes[i] = new Node(json_integer_value(nodeId));
		}

	}

	_roads = json_object_get(root,"roads");
	if(!json_is_array(_roads)){
		std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'roads' field not present or not an array"<<std::endl;
		json_decref(root);
		return false;
	}

	n = json_array_size(_roads);
	json_t *_roadName,*_roadSpeedLimit,*_roadNbBands,*_roadLength,*_road,*startId,*endId;
	for(size_t i = 0; i < n; i++){
		_road = json_array_get(_roads,i);
		if(!json_is_object(_road)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - expected road "<<i<<" to be an object"<<std::endl;
			json_decref(root);
			return false;
		}

		_roadName = json_object_get(_road,"name");
		if(!json_is_string(_roadName)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'name' field of road "<<i<<" not present or wrong type"<<std::endl;
			json_decref(root);
			return false;
		}
		roadName = json_string_value(_roadName);

		_roadSpeedLimit = json_object_get(_road,"speedLimit");
		if(!json_is_integer(_roadSpeedLimit)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'speedLimit' field of road "<<i<<" not present or wrong type"<<std::endl;
			json_decref(root);
			return false;
		}
		roadSpeedLimit = formatSpeedLimit(json_integer_value(_roadSpeedLimit),metric);

		_roadLength = json_object_get(_road,"length");
		if(!json_is_real(_roadLength)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'length' field of road "<<i<<" not present or wrong type"<<std::endl;
			json_decref(root);
			return false;
		}
		roadLength = formatLength(json_real_value(_roadLength),metric);

		_roadNbBands = json_object_get(_road,"nbBands");
		if(!json_is_integer(_roadNbBands)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'nbBands' field of road "<<i<<" not present or wrong type"<<std::endl;
			json_decref(root);
			return false;
		}
		nbBands = json_integer_value(_roadNbBands);

		startId = json_object_get(_road,"startId");
		if(!json_is_integer(startId)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'startId' field of road "<<i<<" not present or wrong type"<<std::endl;
			json_decref(root);
			return false;
		}
		currentNode = json_integer_value(startId);

		endId = json_object_get(_road,"endId");
		if(!json_is_integer(endId)){
			std::cout<<std::endl<<"ERROR: input file "<<fileName<<" has not the correct structure - 'endId' field of road "<<i<<" not present or wrong type"<<std::endl;
			json_decref(root);
			return false;
		}
		otherNode = json_integer_value(endId);
		addRoad(currentNode, otherNode, roadName, roadLength, roadSpeedLimit,nbBands);
	}
	//clean up
	json_array_clear(_nodes);
	json_object_clear(_road);
	json_array_clear(_roads);
	json_object_clear(root);
	json_decref(root);
	return true;
}

void TrafficNetwork::addRoad(const long startNodeId, const long endNodeId,
		const string roadName, const double length,const double speedLimit, const int nbBands){
	Node* startNode = nodes[startNodeId];
	Node* endNode = nodes[endNodeId];
	Road* r;
	if(nbBands == 0){
		r = new TwinRoad(roadName,length,speedLimit,nbBands,startNode,endNode);

		//if twin has already been added ; link them together
		if(endNode->hasNeighbor(startNodeId)){
			TwinRoad* twin = (TwinRoad*) endNode->roadTo(startNodeId);
			twin->setTwin((TwinRoad*)r);
			((TwinRoad*)r)->setTwin(twin);
		}
	}else{
		r = new Road(roadName,length,speedLimit,nbBands,startNode,endNode);
	}

	if(monitered){
		RoadMonitor* monitor = new RoadMonitor(startNodeId,endNodeId);
		r->addMonitor(monitor);
	}

	startNode->addRoad(endNodeId,r);
}


bool TrafficNetwork::isNextNodeInSp(const long crtId, const long nxtId, const long destId){
	return shortestRoutes[crtId][destId].second->getId() == nxtId;
}

Road* TrafficNetwork::nextRoadInSP(const long crtId, const long destId){
	return nodes[crtId]->roadTo(shortestRoutes[crtId][destId].second->getId());
}

double TrafficNetwork::minTravelTime(const long crtId, const long destId){
	return shortestRoutes[crtId][destId].first;
}
std::vector<double> TrafficNetwork::getMinTTVec(){
	std::vector<double>minTTs(Road::roadCounter);
	std::vector<long> nIds;
	for(NodeVec::iterator it= nodes.begin() ; it!=nodes.end(); ++it){
		nIds = (*it)->getNeighborsId();
		for(std::vector<long>::iterator jt = nIds.begin(); jt != nIds.end(); ++jt){
			Road* r = (*it)->roadTo(*jt);
			minTTs[r->getId()]= r->getMinTravelTime();
		}
	}
	return minTTs;
}

Node* TrafficNetwork::getNode(const long id){
	return TrafficNetwork::nodes[id];
}

long TrafficNetwork::getNbNodes(){
	return nodes.size();
}

bool TrafficNetwork::isCreated(){
	return everythingOk;
}

TrafficNetwork::~TrafficNetwork() {
	for(NodeVec::iterator it= nodes.begin() ; it!=nodes.end(); ++it){
			delete(*it);
	}
}
