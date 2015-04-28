/*
 * Event.h
 *
 *  Created on: Feb 8, 2015
 */

#ifndef SIMULATION_EVENT_H_
#define SIMULATION_EVENT_H_

class Agent;

struct Event{
	int type;
	Agent* agent;
	double time;
};

bool operator<(const Event& ev1, const Event& ev2);

#endif /* SIMULATION_EVENT_H_ */
