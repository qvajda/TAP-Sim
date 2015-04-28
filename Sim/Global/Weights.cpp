/*
 * Weights.cpp
 *
 *  Created on: Jan 15, 2015
 */

#include "Weights.h"

Weights::Weights(std::vector<double> weights,int offset): ws(weights),offset(offset) {
	totalWeight=0;
	for(std::vector<double>::iterator j=ws.begin();j!=ws.end();++j)
	    totalWeight += *j;
}

double Weights::getWeightAt(int i){
	int j = i - offset;
	if (j < 0 || (unsigned)j >= ws.size()){
		return 0;
	}else{
		return ws[j];
	}
}

int Weights::getBeginIndex(){
	return offset;
}

int Weights::getEndIndex(){
	return ws.size() + offset;
}

Weights::~Weights() {
}
