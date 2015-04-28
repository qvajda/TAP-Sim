int KPH = 1;
double dist_scaling = 1/1000; // 1pixel = 1/1000km (=1m)

int nodeId(Node n){
	int id = -1;
	boolean found = false;
	for(int i = 0;i<nodes.length && !found;i+=1){
		if(nodes[i]==n){
			id = i;
			found=true;
		}
	}
	return id;
}

/*String saveToFile(){
	String[] lines = new String[1];
	lines[0] = nodes.length +" "+KPH;
	int l;
	int destId;
	Road r;
	for(int i = 0;i<nodes.length;i+=1){
		l = lines.length;
		lines = expand(lines,(l+1+nodes[i].roads.length));
		lines[l] = String(nodes[i].roads.length);
		for(int rId = 0 ; rId < nodes[i].roads.length ; rId+=1){
			r = nodes[i].roads[rId];
			destId = nodeId(nodes[i].neighbors[rId]);
			lines[l+1+rId] = String(formatStrToWrite(r.name) +" "+ destId +" "+ (r.length/1000) +" "+ r.speedLimit + " " + r.nbBands);
		}
	}
	//added positional information about graph network
	l = lines.length;
	lines = expand(lines,l+nodes.length);
	for(int i = 0;i<nodes.length;i+=1){
		lines[l+i] = nodes[i].x +" "+ nodes[i].y;
	}
	
	return join(lines,"\n");
}

void loadFromFile(String content){
	String lines = split(content,"\n");
	String[] splittedLine = split(lines[0],' ');
	int nbNodes = int(splittedLine[0]);
	if(int(splittedLine[1]) != KPH){
		println("WARNING ; wrong metric used in loaded graph -> speedlimits will be incorrect");
	}
	nodes = new Nodes[nbNodes];
	xShift=0;
	yShift=0;
	int lPointer = 1;
	
	//skip roads information
	for(int i = 0;i<nodes.length;i+=1){
		lPointer+=1+int(lines[lPointer]);
	}
	//read positional data
	for(int i = 0;i<nodes.length;i+=1){
		splittedLine = split(lines[lPointer+i],' ');
		nodes[i] = new Node(int(splittedLine[0]),int(splittedLine[1]));
	}
	//add roads
	lPointer = 1;
	int nbRoads;
	int destId;
	int speedLimit;
	int rNbBands;
	String rName;
	for(int i = 0;i<nodes.length;i+=1){
		nbRoads = int(lines[lPointer]);
		lPointer+=1;
		for(int rId = 0 ; rId <nbRoads ; rId+=1){
			splittedLine = split(lines[lPointer+rId],' ');
			rName = formatStrToRead(splittedLine[0]);
			destId = int(splittedLine[1]);
			speedLimit = int(splittedLine[3]);
			rNbBands = int(splittedLine[4]);
			nodes[i].addRoad(new Road(nodes[i],nodes[destId],speedLimit,rName,rNbBands),nodes[destId]);
		}
		lPointer+=nbRoads;
	}
}*/

String formatStrToRead(String s){
	String[] ss = split(s,"\_");
	return join(ss,' ');
}

String formatStrToWrite(String s){
	String[] ss = split(s,' ');
	return join(ss,"\_");
}
