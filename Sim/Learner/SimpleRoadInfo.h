/*
 * SimpleRoadInfo.h
 *
 *  Created on: Jan 15, 2015
 *      Author: adjax
 */

#ifndef LEARNER_SIMPLEROADINFO_H_
#define LEARNER_SIMPLEROADINFO_H_

#include <vector>

//The entries stored in simplified and medium learner are used to keep a tally of travel times, the counter of tt added and the current average of them all
struct SimpleRoadInfo{
	double avgLength,totalLength;
	unsigned long long counter;

	SimpleRoadInfo() : avgLength(0),totalLength(0),counter(0) {}

	void addInfo(double tripLength){
		totalLength+=tripLength;
		counter++;
		avgLength = totalLength/counter;
	}
};

typedef std::vector<SimpleRoadInfo> SimpleRoadInfos; //used in 1 dimension vector by simplified learner
typedef std::vector<std::vector<SimpleRoadInfo> > MediumRoadInfos; //used in 2 dimension matrix by medium learner (one sub-vector per interval)

#endif /* LEARNER_SIMPLEROADINFO_H_ */
