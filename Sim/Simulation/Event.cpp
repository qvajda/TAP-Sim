/*
 * Event.cpp
 *
 *  Created on: Feb 8, 2015
 */

#include "Event.h"

//Highest priority of event should be the one happening first
//-> the one with the smallest time
bool operator<(const Event& ev1, const Event& ev2){
	return ev1.time > ev2.time;
}


