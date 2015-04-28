CC=g++
CFLAGS=-c -Wall -O3
LDFLAGS=
LIBFLAGS=`pkg-config --cflags --libs jansson`
SOURCES= ./Global/main.cpp ./Global/Utilities.cpp ./Global/Weights.cpp ./Learner/NetworkLearner.cpp ./Learner/SimplifiedLearner.cpp ./Learner/EBackpropLearner.cpp ./Learner/LVLearner.cpp ./Learner/MediumDataLearner.cpp ./ServiceProvider/RequestHandler.cpp ./ServiceProvider/AStarHandler.cpp ./ServiceProvider/ReducedAStarHandler.cpp ./ServiceProvider/ExploringHandler.cpp ./Simulation/Event.cpp ./Simulation/NetworkSim.cpp ./Simulation/Agent.cpp ./Simulation/FreeAgent.cpp ./Simulation/DirectedAgent.cpp ./Simulation/InformedAgent.cpp ./TrafficNetwork/Node.cpp ./TrafficNetwork/Road.cpp ./TrafficNetwork/TwinRoad.cpp ./TrafficNetwork/RoadMonitor.cpp ./TrafficNetwork/TrafficNetwork.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=TAPSim

#./Learner/BigDataLearner.cpp

default : $(EXECUTABLE)
all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS) 
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@ $(LIBFLAGS)

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@ $(LIBFLAGS)

clean:
	rm -v -f $(OBJECTS) 
