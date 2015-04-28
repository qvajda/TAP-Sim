# TAP-Sim
=========

##CONTENTS

Master thesis implementation - Traffic Assignment Problem : Shortest Path Optimization in Directed Graph with Multi-agent Population and Central (partial) Authority

Split into three parts:
	* Sim - The actual C++ simulation (requires [jansson](http://www.digip.org/jansson/) library) ; also contains the JSON file used as input in the result generation/analysis part of the thesis.
	* Graph Creation Tool - The processing.js applet to create/edit/visualize graphs used as input for the simulation (requires [processing.js](http://processingjs.org/)). Also contains the python(3.3) script used to "assemble" the separate .pde files composing the applet
	* OSMImport - The python (3.3) script used to import, filter and transform a .osm file ([exported from OpenStreetMap](https://www.openstreetmap.org/export)) to a JSON file compatible with the simulation and graph creation tool (requires [OSM filter](http://wiki.openstreetmap.org/wiki/Osmfilter))

The master thesis can also be found here in pdf format.

##INSTALLATION:

A (rudimentary) makefile is present and should be used to create the binary called **TAPSim**
It requires the installation of the JSON IO handling for C/C++ called [jansson](http://www.digip.org/jansson/)

##UNINSTALLATION:

Use *make clean* and delete **TAPSim** binary file

##USE:

*path_to_binary/TAPSim* <network_file> <other_option>

Where:
<network_file> : the file containing information about the traffic network to simulate

<other_option> : list of other option ; can contain the following:

	*--preset* <preset_id> : load a preset (with all necessary options covered) ;
	any options set this way will be overridden by any other options used
	*-simplified* : Use simplified learner ;only keeping an average travel time for each road
	*--medium* <nb_intervals> : Use more advanced learner ; keeping average travel time over multiple time interval
	*--mediumWs* <weights> : Use alternative weights vector in medium learner ; specified by a list of floats whose sum should be 1
	*--lastV* <nb_entries> <weights> : Use last visited learner ; keeping only the nb_entries last passage through each road as data - needs to specify the weights ;
	*--eBackprop* <learning_factor> : Use error back-propagation learner with specified learning factor ;
	*-eBackprop* : Use error back-propagation learner with default learning factor ;
	*--learnerWs* <weights> : Set weights of learners - only if multiple learners , weights should be given in same order as learners were set up ;
	*-simpleR* : Use simplest route generation mode ; each agent has a single *OD* pair randomly generated and a departure time within the day
	*-smarteR* : Use smart(er) route generation mode ;
	*-realR* : Use realistic(ish) route generation mode ;
	*-A** : Use a request handler using basic A* behavior to find shortest route.
	*--RedA** <depth> : Use a request handler using reduced A* behavior to find shortest route with given depth.
	*-RedA** : Use a request handler using reduced A* behavior to find shortest route with default depth.
	*--Expl* <expl_prob> : Adds exploration behavior to request handler with given probability
	*-Expl* : Adds exploration behavior to request handler with default probability
	*--depth* <pos_int> : Set depth to be used by request handler of type A* (without this set the default value is 1)
	*-marginal* : Set request handler to use marginal travel time cost ;
	*--agents* <nbFreeAgents> <nbInformedAgents> <nbDirectedAgents> : Set number of (each type of) agents to be used
	*--seed* <pos_int> : Set seed of the random number generator
	*--days* <pos_int> : Set number of (virtual) days the simulation will run for	-v : Set verbosity to true ; more information will be displayed throughout execution
	*--o*"" <output_file_prefix> : Set prefix (including path) for output file (if not set, none is produced)
