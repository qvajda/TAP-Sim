/*
 * NetworkSim.cpp
 *
 *  Created on: Sep 25, 2014
 */

#include "NetworkSim.h"

NetworkSim::NetworkSim(TrafficNetwork* net, RequestHandler* s) {
	network = net;
	nbNode = network->getNbNodes();
	service = s;

	agents = AgentsVec(0);
	events = EventsQ();

	time = 0;

}

void NetworkSim::populateQueue(){
	Event e = Event();
	e.time = time;
	e.type = INIT_EVENT;
	for(AgentsVec::iterator agentI = agents.begin(); agentI != agents.end(); agentI++){
		e.agent = *agentI;
		events.push((*agentI)->handleEvent(e));
	}
}

void NetworkSim::simulate(const double duration){
	double endTime = time + duration;
	Event e,nxtE;
	if(!events.empty())
		e = events.top();
	while(!events.empty() && e.time < endTime){
		//move forward in time until next event occurs and handle it
		time = e.time;
		nxtE = e.agent->handleEvent(e);
		events.pop();
		if(nxtE.type != NO_MORE_EVENT){
			events.push(nxtE);
		}

		if(!events.empty())
			e = events.top();
	}
	time = endTime;
}

void NetworkSim::addSimplestRoutes(Agent* a){
	long startId = rand() % nbNode;
	a->setCrtNode(network->getNode(startId));

	long endId = startId;
	while (endId == startId)
			endId = rand() % nbNode;
	double departureTime = rand() % DAY_SEC;

	a->addRoute(endId,departureTime);
}

void NetworkSim::addSmarterRoutes(Agent* a, int nbDays, bool weekly){
	long homeId = rand() % nbNode;
	a->setCrtNode(network->getNode(homeId));

	long workId = homeId;
	while (workId == homeId)
		workId = rand() % nbNode;
	long otherId;

	double minTimeToWork = network->minTravelTime(homeId,workId);
	double morningDeparture = (generateGaussianNoise(1800,32400)) - minTimeToWork; //gaussian(30min variance, 9h avg) is the starting time at work
	double departureTime, timeAtWork;
	bool working;

	for(int i = 0; i < nbDays; i++){
		working = probPoll(0.05);//chance of not working that day
		if(((weekly && (i%7<5)) || !weekly ) || !working){//if during the week or not using week concept or not working that day
			//trip from home to work
			//has a 5% chance to do an intermediary stop
			if(probPoll(0.05)){
				departureTime = (DAY_SEC*i) + generateGaussianNoise(1800,morningDeparture);
				otherId = homeId;
				while (otherId == homeId || otherId == workId)
					otherId = rand() % nbNode;
				a->addRoute(otherId,departureTime);
				a->addRoute(workId,generatePositiveGaussianNoise(900,1800),true);
			}else{
				departureTime = (DAY_SEC*i) + generateGaussianNoise(1800,morningDeparture);
				a->addRoute(workId,departureTime);
			}

			//trip from work to home
			//has a 10% chance to do an intermediary stop
			timeAtWork = generateGaussianNoise(1800,28800); //time spent at work this day
			if(probPoll(0.1)){
				otherId = workId;
				while (otherId == homeId || otherId == workId)
					otherId = rand() % nbNode;
				a->addRoute(otherId,timeAtWork,true);
				a->addRoute(homeId,generatePositiveGaussianNoise(900,1800),true);
			}else{
				a->addRoute(homeId,timeAtWork,true);
			}
		}else{//weekend/non-working day
			departureTime = (DAY_SEC*i) + generateGaussianNoise(3600,morningDeparture+1800);
			int nbStops = abs(generateGaussianInt(2,2));
			for(int j = 0; j<nbStops; j++){
				otherId = homeId;
				while (otherId == homeId || otherId == workId)
					otherId = rand() % nbNode;
				if(j==0){
					a->addRoute(otherId,departureTime);
				}else{
					a->addRoute(otherId,generateGaussianNoise(3600,5400),true);
				}
			}
			a->addRoute(homeId,generateGaussianNoise(3600,5400),true);
		}

		//15% chance to go out in the evening
		if(probPoll(0.15)){
			departureTime = (DAY_SEC*i) + generateGaussianNoise(2400,73800);//gaussian of average 20h and variance 45min
			otherId = homeId;
			while (otherId == homeId)
				otherId = rand() % nbNode;
			a->addRoute(otherId,departureTime);
			a->addRoute(homeId,generatePositiveGaussianNoise(1200,2700),true);
		}

	}
}

long NetworkSim::getANode(double p ,char type, long diff1, long diff2){
	long id = diff1;
	bool test = probPoll(p);

	while (id == diff1 || id == diff2 || ! ((test && network->getNode(id)->getType() == type) || (!test && network->getNode(id)->getType() != type)) ){
		test = probPoll(p);
		id = rand() % nbNode;
	}
	return id;
}

void NetworkSim::addRealisticRoutes(Agent* a, int nbDays, bool weekly){
	long homeId = getANode(0.85,NODE_RESI);
	a->setCrtNode(network->getNode(homeId));

	long workId = getANode(0.85,NODE_WORK,homeId);
	long otherId;

	double minTimeToWork = network->minTravelTime(homeId,workId);
	double morningDeparture = (generateGaussianNoise(1200,32400)) - minTimeToWork; //gaussian(30min variance, 9h avg) is the starting time at work
	double departureTime, timeAtWork;
	bool working;

	for(int i = 0; i < nbDays; i++){
		working = probPoll(0.05);//chance of not working that day
		if(((weekly && (i%7<5)) || !weekly ) || !working){//if during the week or not using week concept or not working that day
			//trip from home to work
			//has a 5% chance to do an intermediary stop
			if(probPoll(0.05)){
				departureTime = (DAY_SEC*i) + generateGaussianNoise(600,morningDeparture);
				otherId = getANode(0.85,NODE_COMM,homeId,workId);
				a->addRoute(otherId,departureTime);
				a->addRoute(workId,generatePositiveGaussianNoise(900,1800),true);
			}else{
				departureTime = (DAY_SEC*i) + generateGaussianNoise(600,morningDeparture);
				a->addRoute(workId,departureTime);
			}

			//trip from work to home
			//has a 10% chance to do an intermediary stop
			timeAtWork = generateGaussianNoise(1200,28800); //time spent at work this day
			if(probPoll(0.1)){
				otherId = getANode(0.85,NODE_COMM,homeId,workId);
				a->addRoute(otherId,timeAtWork,true);
				a->addRoute(homeId,generatePositiveGaussianNoise(900,1800),true);
			}else{
				a->addRoute(homeId,timeAtWork,true);
			}
		}else{//weekend or non-working day
			departureTime = (DAY_SEC*i) + generateGaussianNoise(3000,morningDeparture+1800);
			int nbStops = abs(generateGaussianInt(2,2));
			for(int j = 0; j<nbStops; j++){
				otherId = getANode(0.85,NODE_COMM,homeId,workId);
				if(j==0){
					a->addRoute(otherId,departureTime);
				}else{
					a->addRoute(otherId,generateGaussianNoise(3000,5400),true);
				}
			}
			a->addRoute(homeId,generateGaussianNoise(3000,5400),true);
		}

		//15% chance to go out in the evening
		if(probPoll(0.15)){
			departureTime = (DAY_SEC*i) + generateGaussianNoise(2400,73800);//gaussian of average 20h and variance 45min
			otherId = getANode(0.85,NODE_COMM,homeId);
			a->addRoute(otherId,departureTime);
			a->addRoute(homeId,generatePositiveGaussianNoise(1200,2700),true);
		}

	}
}

NetworkSim::~NetworkSim() {
	for(std::vector<Agent*>::iterator a = agents.begin(); a != agents.end(); a++){
		if((*a) != NULL){
			delete(*a);
		}
	}
}

void NetworkSim::addAgents(const unsigned long nbFreeAgents, const unsigned long nbInformedAgents, const unsigned long nbDirectedAgents, const int routesType, const int nbDays, bool weekly){
	Agent * a;
	nbNode= network->getNbNodes();
	unsigned long nbAgents = nbFreeAgents + nbInformedAgents + nbDirectedAgents;
	for(unsigned long j = 0; j < nbAgents ; j++){
		//choose agent type
		if(j<nbFreeAgents){
			a = new FreeAgent(network,agents.size());
		}else if(j < nbInformedAgents + nbFreeAgents){
			a = new InformedAgent(network,agents.size());
		}else if(j < nbInformedAgents + nbFreeAgents + nbDirectedAgents){
			a = new DirectedAgent(network,agents.size(),service);
		}
		//add route to created agent
		switch(routesType){
		case SIMPLESTROUTES:
			addSimplestRoutes(a);
			break;
		case SMARTERROUTES:
			addSmarterRoutes(a, nbDays, weekly);
			break;
		case REALROUTES:
			addRealisticRoutes(a, nbDays, weekly);
			break;
		default:
			break;
		}
		//add agent to list of agent
		agents.push_back(a);
	}

	if(nbFreeAgents!=0)
		std::cout<<"Agents with id from 0 to "<<nbFreeAgents<<" (excluded) are free agents"<<std::endl;
	if(nbInformedAgents!=0)
		std::cout<<"Agents with id from "<<nbFreeAgents<<" to "<<nbInformedAgents+nbFreeAgents<<" (excluded) are informed agents"<<std::endl;
	if(nbDirectedAgents!=0)
		std::cout<<"Agents with id from "<<nbInformedAgents+nbFreeAgents<<" to "<<nbInformedAgents+nbFreeAgents+nbDirectedAgents<<" (excluded) are directed agents"<<std::endl;
	populateQueue();
}

void NetworkSim::showTravelTimes(){
	double total = 0;
	double travelTime;
	for(AgentsVec::iterator agentI = agents.begin(); agentI != agents.end(); agentI++){
		travelTime = (*agentI)->getTravelTime();
		total += travelTime;
		std::cout<<"Agent #"<<(*agentI)->getId()<<" "<<travelTime<<std::endl;
	}
	std::cout<<"Total travel time : "<<total<<std::endl;

}

bool NetworkSim::hasEmptyQueue(){
	return events.empty();
}

AgentsVec NetworkSim::getAgents(){
	return agents;
}

