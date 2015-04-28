/*
 * LVLearner.h ==> Last Visited Learner
 *
 *  Created on: Feb 20, 2015
 */

#ifndef LEARNER_LVLEARNER_H_
#define LEARNER_LVLEARNER_H_

#include "NetworkLearner.h"
#include "../Global/Defines.h"
#include "../Global/Weights.h"
#include <deque>
#include <vector>
#include <math.h> //fmod

//each entry stored is composed of the travel time and the timestamp at which it was recorded. If real flag set to false, it is a default value added at initialization of the learner
struct infoEntry{
	double time;
	double travelTime;
	bool real;

	 infoEntry() : time(0),travelTime(0),real(false){}
	 infoEntry(double t, double tt) : time(t),travelTime(tt),real(true){}

	 void set(double t, double tt){
		 time = t;
		 travelTime = tt;
		 real = true;
	 }
};

typedef std::deque<infoEntry> InfosQ;
typedef std::vector<InfosQ*> Infos;

class LVLearner: public NetworkLearner {
private:
	Infos infos;
	int qSize;

	Weights ws;

public:
	LVLearner(const long nbRoads, const int qSize, const Weights ws);
	virtual ~LVLearner();

	virtual void exitedRoad(Road* r, const double time, const double length);
	virtual void enteredRoad(Road* r, const double time);

	virtual double getPredTime(Road* r, const double time);
	virtual bool isFullyLearned(Road* r, const double time);
};

#endif /* LEARNER_LVLEARNER_H_ */
