#ifndef DEFINES_H_
#define DEFINES_H_

//******************** From TrafficNetwork Folder ********************

// --- TrafficNetwork ---

//flags present in file storing network ; defining what metrics is used for road lengths and speed limit
#define MPS 0
#define KPH 1
#define MPH 2
#define KPS 3

// --- Node ---
#define NODE_UNDEF 0
#define NODE_RESI 1
#define NODE_WORK 2
#define NODE_COMM 3



// --- Road ---
#define ALPHA 0.15
#define BETA 4
#define TT_VARIANCE 0.05
#define ROAD_CAPACITY_PERC 0.65
#define ROAD_MINTT_MULT 1.6
#define ROAD_MINTT_ADD 0
#define CAR_AVG_LENGTH 3.5
#define CAR_SPACING 1.5


// --- RoadMonitor ---
#define TIME_PRECISION 10000 //10000 = 4decimals kept

//******************** From Simulation Folder ********************

// --- NetworkSim ---

#define NO_MORE_EVENT -1
#define ENTER_ROAD 0
#define LEAVE_NET 1
#define ENTER_NET 2
#define INIT_EVENT 3

// --- Agent ---

//RequestHandler
#define FULLY_LEARNED_PERC 0.66;

//Learner
#define MIN_INFO_THRESHOLD 10
#define INFO_CERTAINTY_THRESHOLD 100
#define LV_TIME_CERTAINTY 1800 //30mins
#define EBP_PRECISION 0.05

//Global
#define DAY_SEC 86400

//main.cpp
#define ASTAR 1
#define REDUCED_ASTAR 2

#define SIMPLESTROUTES 1
#define SMARTERROUTES 2
#define REALROUTES 3

#define FREEAGENT 1
#define DIRAGENT 2

#define DEFAULT_EXPL_PROB 0.1
#define DEFAULT_DEPTH 1

//Utilities
#define TWO_PI 6.2831853071795864769252866

#endif /* DEFINES_H_ */
