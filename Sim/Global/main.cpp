/*
 * main.cpp
 *
 *  Created on: Jan 19, 2015
 */


#include <ctime>
#include <sys/time.h>
#include <iostream>
#include <fstream>
#include "Defines.h"
#include "Weights.h"
#include "../Learner/NetworkLearner.h"
#include "../Learner/SimplifiedLearner.h"
#include "../Learner/EBackpropLearner.h"
#include "../Learner/MediumDataLearner.h"
#include "../Learner/LVLearner.h"
#include "../ServiceProvider/RequestHandler.h"
#include "../ServiceProvider/AStarHandler.h"
#include "../ServiceProvider/ExploringHandler.h"
#include "../ServiceProvider/ReducedAStarHandler.h"
#include "../Simulation/NetworkSim.h"
#include "../TrafficNetwork/TrafficNetwork.h"
#include "../TrafficNetwork/Road.h"


typedef std::vector<Agent*> AgentsVec;

/***********************************************************************/


int showUsage(){
	std::cout << "Usage: ./TAPSim <network_file> <other_option>" << std::endl << std::endl
			<< "Where:"<< std::endl
			<< "<network_file> : the file containing information about the traffic network to simulate"<< std::endl << std::endl
			<< "<other_option> : list of other option ; can contain the following:"<< std::endl<< std::endl<< "\t"
			<< "--preset <preset_id> : load a preset (with all necessary options covered) ;"<<std::endl<<"\t"
			<< "any options set this way will be overridden by any other options used"<< std::endl<<"\t"
			<< "-simplified : Use simplified learner ;only keeping an average travel time for each road"<< std::endl<<"\t"
			<< "--medium <nb_intervals> : Use more advanced learner ; keeping average travel time over multiple time interval"<< std::endl<<"\t"
			<< "--mediumWs <weights> : Use alternative weights vector in medium learner ; specified by a list of floats whose sum should be 1"<< std::endl<<"\t"
			<< "--lastV <nb_entries> <weights> : Use last visited learner ; keeping only the nb_entries last passage through each road as data - needs to specify the weights ;"<< std::endl<<"\t"
			<< "--eBackprop <learning_factor> : Use error back-propagation learner with specified learning factor ;"<< std::endl<<"\t"
			<< "-eBackprop : Use error back-propagation learner with default learning factor ;"<< std::endl<<"\t"
			<< "--learnerWs <weights> : Set weights of learners - only if multiple learners , weights should be given in same order as learners were set up ;"<< std::endl<<"\t"
			<< "-simpleR : Use simplest route generation mode ;"<<std::endl<<"\t"
			<< " each agent has a single OD pair randomly generated and a departure time within the day"<< std::endl<<"\t"
			<< "-smarteR : Use smart(er) route generation mode ;"<<std::endl<<"\t"
			<< "-realR : Use realistic(ish) route generation mode ;"<<std::endl<<"\t"
			<< "-A* : Use a request handler using basic A* behavior to find shortest route."<< std::endl<<"\t"
			<< "--RedA* <depth> : Use a request handler using reduced A* behavior to find shortest route with given depth."<< std::endl<<"\t"
			<< "-RedA* : Use a request handler using reduced A* behavior to find shortest route with default depth."<< std::endl<<"\t"
			<< "--Expl <expl_prob> : Adds exploration behavior to request handler with given probability"<< std::endl<<"\t"
			<< "-Expl : Adds exploration behavior to request handler with default probability"<< std::endl<<"\t"
			<< "--depth <pos_int> : Set depth to be used by request handler of type A* (without this set the default value is 1)"<< std::endl<<"\t"
			<< "-marginal : Set request handler to use marginal travel time cost ;"<<std::endl<<"\t"
			<< "--agents <nbFreeAgents> <nbInformedAgents> <nbDirectedAgents> : Set number of (each type of) agents to be used"<< std::endl<<"\t"
			<< "--seed <pos_int> : Set seed of the random number generator"<< std::endl<<"\t"
			<< "--days <pos_int> : Set number of (virtual) days the simulation will run for"<< "\t"
			<< "-v : Set verbosity to true ; more information will be displayed throughout execution"<< "\t"
			<< "--o <output_file_prefix> : Set prefix (including path) for output file (if not set, none is produced)"<< std::endl;
	return 0;
}

int showUsageLearner(std::string l){
	std::cout << "ERROR : network "<<l<<" learner set multiple times !" << std::endl;
	return 0;
}

int showUsageHandler(){
	std::cout << "ERROR : service provider/request handler set multiple times !" << std::endl;
	return 0;
}

int showUsageRoutesType(){
	std::cout << "ERROR : routes type set multiple times !" << std::endl;
	return 0;
}

int showUsageMediumWeights(){
	std::cout << "ERROR : Can't set multiple weights for medium learner !" << std::endl;
	return 0;
}
int showUsageLearnersWeights(){
	std::cout << "ERROR : Can't set multiple weights for learners / no weights to be set if only one learner !" << std::endl;
	return 0;
}

int main(int argc, char *argv[])
{
  struct timeval start,end;
  gettimeofday(&start, NULL);
  int i;
  std::string arg,out_prefix;
  bool hasOut_prefix = false;
  unsigned int seed = time(NULL);
  bool verbose = false;

  if (argc == 1)
  {
	  return showUsage();
  }

  arg=argv[1];
  if(arg == "-help" || arg == "--help" || arg == "-Help" || arg == "--Help" || arg == "-h" || arg == "--h")
	  return showUsage();

  for(i=2;i<argc;i++){
  	  arg = argv[i];
  	  if(arg == "--o"){
  		  hasOut_prefix = true;
  	  }
  }
  std::cout<<"Reading network file ('"<<argv[1]<<"') ...";
  std::cout.flush();
  /* Create instance object of network */
  TrafficNetwork* network = new TrafficNetwork(argv[1],"Traffic Network 1",hasOut_prefix);
  if(!network->isCreated())
	  return 1;
  std::cout<<"Done"<<std::endl;

  std::cout<<"Reading configuration parameters...";
  /* Read inline parameters */

  // ============= learner  =============
  std::vector<NetworkLearner*> learners(0);
  bool hasSimplifiedLearner=false;
  bool hasMediumLearner=false;
  bool hasLVLearner=false;
  bool hasEBackpropLearner=false;
  std::vector<double> learnersWs(0);

  // ============= requestHandler =============
  RequestHandler* service = NULL;
  bool exploring = false;
  double explProb = DEFAULT_EXPL_PROB;
  int serviceType = -1;
  int depth = DEFAULT_DEPTH;
  bool useMarginal = false;

  // ============= sim =============
  NetworkSim* simulation = NULL;

  bool isMediumLearner = false;
  //for medium learner :
  int nbInterval = 24*4; //intervals of 15mins
  std::vector<double> wVec(0,0);
  wVec.push_back(0.05);
  wVec.push_back(0.2);
  wVec.push_back(0.5);
  wVec.push_back(0.2);
  wVec.push_back(0.05);
  Weights ws(wVec,-2);
  bool hasOtherWeights = false;

  int preset = -1;

  unsigned long nbFreeAgents = 0;
  unsigned long nbInformedAgents = 0;
  unsigned long nbDirectedAgents = 0;

  int nbDays = 0;

  int routesType = -1;
  for(i=2;i<argc;i++){
	  arg = argv[i];
	  if (arg == "--preset"){
		  preset = atoi(argv[i+1]);
		  i++;
	  }else if (arg == "-simplified"){
		  if(!hasSimplifiedLearner){
			  learners.push_back(new SimplifiedLearner(Road::roadCounter));
			  hasSimplifiedLearner = true;
		  }else{
			  return showUsageLearner("simplified");
		  }
	  }else if (arg == "-eBackprop"){
		  if(!hasEBackpropLearner){
			  learners.push_back(new EBackpropLearner(Road::roadCounter));
			  hasEBackpropLearner = true;
		  }else{
			  return showUsageLearner("error back-propagation");
		  }
	  }else if (arg == "--eBackprop"){
		  if(!hasEBackpropLearner){
			  learners.push_back(new EBackpropLearner(Road::roadCounter,atoi(argv[i+1])));
			  i++;
			  hasEBackpropLearner = true;
		  }else{
			  return showUsageLearner("error back-propagation");
		  }
	  }else if (arg == "--lastV"){
		  if(!hasLVLearner){
			  int nbEntries = atoi(argv[i+1]);
			  i++;
			  std::vector<double> w(0);
			  if(nbEntries != 1){
				  double weight;
				  for(int j=0; j<nbEntries; j++){
					  weight = atof(argv[i+1]);
					  i++;
					  w.push_back(weight);
				  }
			  }else{
				  w.push_back(1);
			  }
			  Weights lastV_weights(w);
			  learners.push_back(new LVLearner(Road::roadCounter,nbEntries,lastV_weights));
			  hasLVLearner=true;
		  }else{
			  return showUsageLearner("last visited");
		  }
	  }else if (arg == "--medium"){
		  if(!hasMediumLearner){
			  nbInterval = atoi(argv[i+1]);
			  i++;
			  isMediumLearner = true;
			  hasMediumLearner = true;
		  }else{
			  return showUsageLearner("medium");
		  }
	  }else if (arg == "--mediumWs"){
		  if(!hasOtherWeights == -1){
			  std::vector<double> w(0);
			  double wsSum = 0;
			  double weight;
			  while(wsSum != 1){
				  weight = atof(argv[i+1]);
				  i++;
				  wsSum+=weight;
				  w.push_back(weight);
			  }
			  ws = Weights(w,-w.size()/2);
			  hasOtherWeights = true;
		  }else{
			  return showUsageMediumWeights();
		  }
	  }else if (arg == "--learnerWs"){
		  if(learnersWs.size() == 0){
			  double weight;
			  int learnerCount = learners.size();
			  if(hasMediumLearner)
				  learnerCount++;
			  if(learnerCount>1){
				  for(int j = 0; j<learnerCount; j++){
					  weight = atof(argv[i+1]);
					  i++;
					  learnersWs.push_back(weight);
				  }
			  }else{
				  return showUsageLearnersWeights();
			  }
		  }else{
			  return showUsageLearnersWeights();
		  }
	  }else if (arg == "-simpleR"){
		  if(routesType == -1){
			  routesType = SIMPLESTROUTES;
		  }else{
			  return showUsageRoutesType();
		  }
	  }else if (arg == "-smartR"){
		  if(routesType == -1){
			  routesType = SMARTERROUTES;
		  }else{
			  return showUsageRoutesType();
		  }
	  }else if (arg == "-realR"){
		  if(routesType == -1){
			  routesType = REALROUTES;
		  }else{
			  return showUsageRoutesType();
		  }
	  }else if (arg == "-A*"){
		  if(serviceType == -1){
			  serviceType = ASTAR;
		  }else{
			  return showUsageHandler();
		  }
	  }else if (arg == "-RedA*"){
		  if(serviceType == -1){
			  serviceType = REDUCED_ASTAR;
		  }else{
			  return showUsageHandler();
		  }
	  }else if (arg == "--RedA*"){
		  if(serviceType == -1){
			  serviceType = REDUCED_ASTAR;
			  depth = atoi(argv[i+1]);
			  i++;
		  }else{
			  return showUsageHandler();
		  }
	  }else if (arg == "-Expl" && !exploring){
		  exploring= true;
	  }else if (arg == "--Expl" && !exploring){
		  exploring= true;
		  explProb = atof(argv[i+1]);
		  i++;
	  }else if (arg == "-marginal" && !useMarginal){
		  useMarginal = true;
	  }else if (arg == "--agents"){
		  nbFreeAgents = atoi(argv[i+1]);
		  i++;
		  nbInformedAgents = atoi(argv[i+1]);
		  i++;
		  nbDirectedAgents = atoi(argv[i+1]);
		  i++;
	  }else if (arg == "--seed"){
		  seed = atoi(argv[i+1]);
		  i++;
	  }else if (arg == "--days"){
		  nbDays = atoi(argv[i+1]);
		  i++;
	  }else if (arg == "--o"){
		  out_prefix = argv[i+1];
		  hasOut_prefix=true;
		  i++;
	  }else if (arg == "-v"){
		  verbose = true;
	  }else{
		  std::cout<<"WARNING: Read argument :'"<<arg<<"' -> unusable"<<std::endl;
	  }
  }
  if(isMediumLearner){
	  learners.push_back(new MediumDataLearner(Road::roadCounter,nbInterval,ws));
  }
  srand ( seed );

  //Test for preset
  switch(preset){
  case 0:
	  std::cout<<"WARNING: Using debug/testing preset"<<std::endl;
	  if(learners.size() == 0){
		  learners.push_back(new SimplifiedLearner(Road::roadCounter));
	  }

	  if(serviceType == -1){
		  serviceType = REDUCED_ASTAR;
	  }

	  if(nbFreeAgents == 0 && nbInformedAgents == 0 && nbDirectedAgents == 0){
		  nbFreeAgents = 1;
		  nbDirectedAgents = 1;
	  }

	  if(routesType == -1){
		  routesType = SIMPLESTROUTES;
	  }
	  if(nbDays == 0){
		  nbDays = 1;
	  }
	  break;
  case 1:
	  if(learners.size() == 0){
		  learners.push_back(new SimplifiedLearner(Road::roadCounter));
	  }

	  if(serviceType == -1){
		  serviceType = REDUCED_ASTAR;
	  }

	  if(nbFreeAgents == 0 && nbInformedAgents == 0 && nbDirectedAgents == 0){
		  nbFreeAgents = 900;
		  nbDirectedAgents = 100;
	  }

	  if(routesType == -1){
		  routesType = SIMPLESTROUTES;
	  }
	  if(nbDays == 0){
		  nbDays = 1;
	  }
	  break;
  case 2:
	  if(learners.size() == 0){
		  learners.push_back(new MediumDataLearner(Road::roadCounter,nbInterval,ws));
  	  }

  	  if(serviceType == -1){
  		  serviceType = ASTAR;
  	  }

  	  if(nbFreeAgents == 0 && nbInformedAgents == 0 && nbDirectedAgents == 0){
  		  nbFreeAgents = 900;
  		  nbDirectedAgents = 100;
  	  }

  	  if(routesType == -1){
  		  routesType = SMARTERROUTES;
  	  }
	  if(nbDays == 0){
		  nbDays = 7;
	  }
  	  break;
  default:
	  break;
  }

  //Test if all parameters are set
  if(learners.size() == 0 or (nbFreeAgents == 0 && nbInformedAgents == 0 && nbDirectedAgents == 0) or serviceType == -1){
	  return showUsage();
  }

  if(learners.size() != 0){
	  if(learners.size() != learnersWs.size()){
		  if(learnersWs.size()!=0){
			  std::cout<<"WARNING: Learners weights set are incoherent ; reverting to default value - all learners have equal weight"<<std::endl;
		  }

		  learnersWs = std::vector<double>(learners.size(),1/learners.size());
	  }
	  switch(serviceType){
	  case ASTAR:
		  if(!exploring){
			  service = new AStarHandler(network, learners, Weights(learnersWs));
		  }else{
			  service = new ExploringHandler(new AStarHandler(network, learners, Weights(learnersWs)),explProb);
		  }
		  break;
	  case REDUCED_ASTAR:
		  if(!exploring){
			  service = new ReducedAStarHandler(network, learners, Weights(learnersWs), depth);
		  }else{
			  service = new ExploringHandler(new ReducedAStarHandler(network, learners, Weights(learnersWs), depth),explProb);
		  }
		  break;
	  default:
		  break;
	  }
	  service->setMarginalUsage(useMarginal);
  }
  	//launching the simulation
	std::cout<<"Done"<<std::endl<<"Initializing simulation..."<<std::endl;

	simulation = new NetworkSim(network,service);
	//Create agents with correct routes type
	simulation->addAgents(nbFreeAgents,nbInformedAgents,nbDirectedAgents,routesType,nbDays);

	std::cout<<"Done"<<std::endl<<"Launching simulation..."<<std::endl;

	//for travel time monitoring
	double total_tt = 0;
	double dayTotal_tt = 0;
	double totalFree_tt = 0;
	double dayFree_tt = 0;
	double totalInformed_tt = 0;
	double dayInformed_tt = 0;
	double totalDir_tt = 0;
	double dayDir_tt = 0;

	//for traveled distance monitoring
	double total_di = 0;
	double dayTotal_di = 0;
	double totalFree_di = 0;
	double dayFree_di = 0;
	double totalInformed_di = 0;
	double dayInformed_di = 0;
	double totalDir_di = 0;
	double dayDir_di = 0;

	std::ofstream fileOut;
	bool openedAgentsStat = false;
	if(hasOut_prefix){
		fileOut.open((out_prefix+"_agents_stats.txt").c_str());
		if ( fileOut.is_open() ) {
			openedAgentsStat = true;
			fileOut<<seed<<" "<<nbFreeAgents<<" "<<nbInformedAgents<<" "<<nbDirectedAgents<<" "<<nbDays<<std::endl;
		}else{
			std::cout<< "WARNING: Could not open file '"<<out_prefix<<"_agents_stats.txt' to write down agents statistics ; proceeding without saving data" <<std::endl;
		}
	}

	double travelTime,travelDist;
	AgentsVec agents = simulation->getAgents();
	//Launch simulation
	int week = 0;
	char weekChar[21];
	sprintf(weekChar,"%d",week);
	for(int day = 0 ; day < nbDays ; day++){
		simulation->simulate(86400);
		if(hasOut_prefix){
			if(day == (week*7)+6 or day == nbDays-1){
				network->saveToFile(out_prefix+"_week"+weekChar,true);
				week+=1;
				sprintf(weekChar,"%d",week);
			}else{
				//network->saveToFile(out_prefix+"_week"+weekChar);
			}
		}
		//show (partial) results if verbose
		if(verbose){
			std::cout<<"######################## Day "<<day+1<<" ########################"<<std::endl;
			dayTotal_tt = 0;
			dayFree_tt = 0;
			dayInformed_tt = 0;
			dayDir_tt = 0;

			dayTotal_di = 0;
			dayFree_di = 0;
			dayInformed_di = 0;
			dayDir_di = 0;
			for(unsigned long i=0 ; i < nbFreeAgents ; i++){
				travelTime = agents[i]->getTravelTime();
				travelDist = agents[i]->getTravelDist();

				total_tt += travelTime;
				dayTotal_tt += travelTime;
				totalFree_tt += travelTime;
				dayFree_tt += travelTime;

				total_di += travelDist;
				dayTotal_di += travelDist;
				totalFree_di += travelDist;
				dayFree_di += travelDist;
				if(openedAgentsStat){
					fileOut<<i<<" "<<day<<" "<<travelTime<<" "<<travelDist<<std::endl;
				}
			}
			for(unsigned long i=nbFreeAgents ; i < nbFreeAgents+nbInformedAgents ; i++){
				travelTime = agents[i]->getTravelTime();
				travelDist = agents[i]->getTravelDist();

				total_tt += travelTime;
				dayTotal_tt += travelTime;
				totalInformed_tt += travelTime;
				dayInformed_tt += travelTime;

				total_di += travelDist;
				dayTotal_di += travelDist;
				totalInformed_di += travelDist;
				dayInformed_di += travelDist;
				if(openedAgentsStat){
					fileOut<<i<<" "<<day<<" "<<travelTime<<" "<<travelDist<<std::endl;
				}
			}
			for(unsigned long i=nbFreeAgents+nbInformedAgents ; i < nbFreeAgents+nbInformedAgents+nbDirectedAgents ; i++){
				travelTime = agents[i]->getTravelTime();
				travelDist = agents[i]->getTravelDist();

				total_tt += travelTime;
				dayTotal_tt += travelTime;
				totalDir_tt += travelTime;
				dayDir_tt += travelTime;

				total_di += travelDist;
				dayTotal_di += travelDist;
				totalDir_di += travelDist;
				dayDir_di += travelDist;
				if(openedAgentsStat){
					fileOut<<i<<" "<<day<<" "<<travelTime<<" "<<travelDist<<std::endl;
				}
			}
			if(nbFreeAgents !=0){
				std::cout<<"(Day) Total travel time of free agents: "<<dayFree_tt<<" ; average: "<<dayFree_tt/nbFreeAgents<<std::endl;
				std::cout<<"(Day) Total traveled distance of free agents: "<<dayFree_di<<" ; average: "<<dayFree_di/nbFreeAgents<<std::endl;
			}
			if(nbInformedAgents !=0){
				std::cout<<"(Day) Total travel time of informed agents: "<<dayInformed_tt<<" ; average: "<<dayInformed_tt/nbInformedAgents<<std::endl;
				std::cout<<"(Day) Total traveled distance of informed agents: "<<dayInformed_di<<" ; average: "<<dayInformed_di/nbInformedAgents<<std::endl;
			}
			if(nbDirectedAgents !=0){
				std::cout<<"(Day) Total travel time of directed agents: "<<dayDir_tt<<" ; average: "<<dayDir_tt/nbDirectedAgents<<std::endl;
				std::cout<<"(Day) Total traveled distance of directed agents: "<<dayDir_di<<" ; average: "<<dayDir_di/nbDirectedAgents<<std::endl;
			}
			std::cout<<"(Day) Total travel time of all agents: "<<dayTotal_tt<<" ; average: "<<dayTotal_tt/(nbFreeAgents + nbInformedAgents + nbDirectedAgents)<<std::endl;
			std::cout<<"(Day) Total traveled distance of all agents: "<<dayTotal_di<<" ; average: "<<dayTotal_di/(nbFreeAgents + nbInformedAgents + nbDirectedAgents)<<std::endl;

		}else if(openedAgentsStat){
			for(AgentsVec::iterator agentI = agents.begin(); agentI != agents.end(); agentI++){
				travelTime = (*agentI)->getTravelTime();
				travelDist = (*agentI)->getTravelDist();
				fileOut<<(*agentI)->getId()<<" "<<day<<" "<<travelTime<<" "<<travelDist<<std::endl;
			}
		}
	}

	//show final results
	if(verbose){
		std::cout<<"######################## Final Results ########################"<<std::endl;
		if(nbFreeAgents !=0){
		  std::cout<<"Total travel time of free agents: "<<totalFree_tt<<" ; average: "<<totalFree_tt/nbFreeAgents<<std::endl;
		  std::cout<<"Total traveled distance of free agents: "<<totalFree_di<<" ; average: "<<totalFree_di/nbFreeAgents<<std::endl;
		}
		if(nbInformedAgents !=0){
		  std::cout<<"Total travel time of informed agents: "<<totalInformed_tt<<" ; average: "<<totalInformed_tt/nbInformedAgents<<std::endl;
		  std::cout<<"Total traveled distance of informed agents: "<<totalInformed_di<<" ; average: "<<totalInformed_di/nbInformedAgents<<std::endl;
		}
		if(nbDirectedAgents !=0){
		  std::cout<<"Total travel time of directed agents: "<<totalDir_tt<<" ; average: "<<totalDir_tt/nbDirectedAgents<<std::endl;
		  std::cout<<"Total traveled distance of directed agents: "<<totalDir_di<<" ; average: "<<totalDir_di/nbDirectedAgents<<std::endl;
		}
		std::cout<<"Total travel time of all agents: "<<total_tt<<" ; average: "<<total_tt/(nbFreeAgents + nbInformedAgents + nbDirectedAgents)<<std::endl;
		std::cout<<"Total traveled distance of all agents: "<<total_di<<" ; average: "<<total_di/(nbFreeAgents + nbInformedAgents + nbDirectedAgents)<<std::endl;
	}

	if(openedAgentsStat){
		fileOut.close();
	}

	gettimeofday(&end, NULL);
	long seconds  = end.tv_sec  - start.tv_sec;
	long useconds = end.tv_usec - start.tv_usec;
	if (useconds<0){
	  useconds+=1000000;
	  seconds--;
	}

	long myTime []= {seconds, useconds};

	std::cout<<"Total computation time (in seconds) = "<<std::endl<<myTime[0]<<"."<<myTime[1]<<std::endl<<"Used seed : "<<seed<<std::endl;

	if(service != NULL)
		delete service;
	for(std::vector<NetworkLearner*>::iterator learner = learners.begin(); learner != learners.end(); learner++){
		if((*learner) != NULL){
			delete(*learner);
		}
	}
	if(simulation != NULL)
		delete simulation;
	if(network != NULL){
		delete network;
	}

	return 0;
}
