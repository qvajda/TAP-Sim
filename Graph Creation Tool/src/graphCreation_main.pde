//target ../graphCreation.pde
//include myColor.pde
//include myPoint.pde
//include segment.pde
//include Line.pde
//include Button.pde
//include Node.pde
//include Road.pde
//include IOHandling.pde
//include dataVis.pde
/*
Graph Creation Tool - v0.8
Author : Quentin-Emmanuel VAJDA
*/

int fps = 30;

int size_x = 1050;
int size_y = 550;

int margin = 25;
int frame_size_x = size_x - 2*margin;
int frame_size_y = size_y - 2*margin;

int _LEFT_ = 1;
int _RIGHT_ = -1;

int fontSize = 12;

int selectionDist = 10;
int squaredSelectionDist = 100;

int DIR_LEFT = 1;
int DIR_RIGHT = 2;
int DIR_TOP = 3;
int DIR_BOT = 4;

int button_spacing = 5;

int NO_BUTTON = -1;
int ADD_TWO_WAY = 0;
int ADD_SINGLE_WAY = 1;
int DEL_ROAD = 2;
int DEL_NODE = 3;
int SEL_TOOL = 4;
int MODFY_ST = 5;
int MODFY_NODE = 6;

nullNode = new Node(0,0);
nullRoad = new Road(nullNode, nullNode, 0, "", 0);

Button nullButton = new Button(0,0,0,0,"",NO_BUTTON,col_trans,col_trans,col_trans);
Button[] buttons;
Button selectedButton;

Node[] nodes;
Node selectedNode;

boolean hasSelectedNode;

int xShift;
int yShift;
double scaling;

int framesSinceMoved;

String displayedInfo;

boolean shiftHeld;

//nodes types
int NODE_UNDEF = 0;
int NODE_RESI = 1;
int NODE_WORK = 2;
int NODE_COMM = 3;

interface JavaScript {
	String getStreetName();
	int getSpeedLimit();
	int getNodeType();
	void loadEntriesFor(double t,Road r);
}

void bindJavascript(JavaScript js) {
	javascript = js;
}

JavaScript javascript;

void setup() {  // this is run once.

	// set the background color
	background(255);

	//set refresh rate
	frameRate(fps);

	size_x = screen.width - 24;
	size_y = screen.height - 300;
	// canvas size (Integers only, please.)
	size(int(size_x),int(size_y));
	
	text("",0,0);
	textSize(fontSize);
	fill(0,0,0);

	// smooth edges
	smooth();

	// set the width of the line. 
	strokeWeight(1);
	//init buttons
	buttons = new Button[6];
	int x = margin + 20;
	int y = margin + 2;
	buttons[0] = new Button(x,y,80,24,"Selection",SEL_TOOL,col_button_base,col_button_high,col_button_sel);
	buttons[1] = new Button(0,0,80,24,"Two Way st.",ADD_TWO_WAY,col_button_base,col_button_high,col_button_sel);
	buttons[1].moveToRel(buttons[0],DIR_RIGHT);
	buttons[2] = new Button(0,0,80,24,"One Way st.",ADD_SINGLE_WAY,col_button_base,col_button_high,col_button_sel);
	buttons[2].moveToRel(buttons[1],DIR_RIGHT);
	buttons[3] = new Button(0,0,80,24,"Modify st.",MODFY_ST,col_button_base,col_button_high,col_button_sel);
	buttons[3].moveToRel(buttons[2],DIR_RIGHT);
	buttons[4] = new Button(0,0,80,24,"Modify node",MODFY_NODE,col_button_base,col_button_high,col_button_sel);
	buttons[4].moveToRel(buttons[3],DIR_RIGHT);
	buttons[5] = new Button(0,0,80,24,"Delete Node",DEL_NODE,col_button_base,col_button_high,col_button_sel);
	buttons[5].moveToRel(buttons[4],DIR_RIGHT);
	buttons[6] = new Button(0,0,80,24,"Delete st.",DEL_ROAD,col_button_base,col_button_high,col_button_sel);
	buttons[6].moveToRel(buttons[5],DIR_RIGHT);
	
	selectedButton = buttons[0];
	buttons[0].select();
	
	nodes = new Nodes[0];
	hasSelectedNodes = false;
	xShift =0;
	yShift =0;

	framesSinceMoved =0;
	
	setHasRoadsStats(false);

	shiftHeld = false;
	scaling = 1;
	displayedInfo = "";
}

void draw_network(){
	pushMatrix();
	translate(-xShift,-yShift);
	scale(scaling);
	for(int i = 0 ; i < nodes.length ; i+=1){
		nodes[i].draw();
	}
	
	if((selectedButton.id == ADD_TWO_WAY || selectedButton.id == ADD_SINGLE_WAY) && hasSelectedNode){
		selectedNode.drawDottedLineTo(shiftX(mouseX),shiftY(mouseY));
	}
	popMatrix();
}

void drawDisplayedInfo(){
	if(displayedInfo != ""){
		textAlign(RIGHT);
		double tw = textWidth(displayedInfo);
		col_shaded_red.set();
		col_light_grey.doFill();
		if(!hasRoadsStats){
			rect(size_x-tw-margin-3,margin-fontSize-3,tw+6,fontSize*2);
		}else{
			rect(size_x-tw-margin-3,margin-fontSize-3,tw+6,fontSize*3 +5);
		}
		
		col_black.doFill();
		text(displayedInfo,size_x-margin,margin);
		displayedInfo = "";
		textAlign(LEFT);
	}
}

void draw() {
	if(!hasRoadsStats){
		if(framesSinceMoved<fps){
			framesSinceMoved+=1;
			background(250);
			for(int i = 0 ; i < buttons.length ; i+=1){
				buttons[i].draw();
			}
	
			draw_network();
			drawDisplayedInfo()
		}
	}else if(vis_playing || framesSinceMoved<fps){
		framesSinceMoved+=1;
		background(250);
		draw_network();
		vis_draw();
		drawDisplayedInfo()
	}
}

void mouseClicked() {
	framesSinceMoved=0;
	if (mouseButton == LEFT){
		if(!hasRoadsStats){
			boolean pressedButton = false;
			for(int i = 0 ; i < buttons.length && !pressedButton; i+=1){
				if(buttons[i].isClicked()){
					deselectAll();
					selectedButton = buttons[i];
					selectedButton.select();
					pressedButton = true;
				}
			}
	
			if(!pressedButton){
				switch(selectedButton.id){
				case ADD_TWO_WAY : case ADD_SINGLE_WAY :
					addTwo_singleWayHandler();
					break;
				case DEL_ROAD:
					delRoadHandler();
					break;
				case DEL_NODE:
					delNodeHandler();
					break;
				case MODFY_ST:
					modifyStreetHandler();
					break;
				case MODFY_NODE:
					modifyNodeHandler();
					break;
				case NO_BUTTON:case SEL_TOOL:
					break;
				}
			}
		}else{
			vis_mouseClicked();
		}
	}else if (mouseButton == RIGHT){
		//nothing
	}else if(mouseButton == CENTER){
		//nothing
	}
}

void mouseDragged(){
	if (mouseButton == LEFT){
		framesSinceMoved=0;
		xShift += (pmouseX-mouseX);
		yShift += (pmouseY-mouseY);
	}else if (mouseButton == RIGHT){
		//nothing
	}else if(mouseButton == CENTER){
		//nothing
	}
}

void addTwo_singleWayHandler(){
	if(nodes.length == 0){
		nodes = append(nodes,new Node(shiftX(mouseX),shiftY(mouseY),javascript.getNodeType()));
		selectedNode = nodes[0];
		hasSelectedNode = true;
		nodes[0].select();
	}else if(hasSelectedNode){
		//test if close to another node
		myPoint mPos = new myPoint(shiftX(mouseX),shiftY(mouseY));
		Node n = closestNode(mPos);
		//if not add node
		if(mPos.dist(n) > selectionDist){
			n = new Node(shiftX(mouseX),shiftY(mouseY),javascript.getNodeType());
			nodes = append(nodes,n);			
		}
		if(n!=selectedNode){
			//add road between the two nodes if they are different
			int speedLimit = 50;
			String name = "";
			int nbBands = 1;

			if(javascript != null){
				name = javascript.getStreetName();
				speedLimit = javascript.getSpeedLimit();
				nbBands = javascript.getNbBands();
			}

			selectedNode.addRoad(new Road(selectedNode,n,speedLimit,name,nbBands),n);
			if (selectedButton.id == ADD_TWO_WAY){
				n.addRoad(new Road(n,selectedNode,speedLimit,name,nbBands),selectedNode);
			}
			selectedNode.deselect();
			hasSelectedNode = false;
		}
	}else{
		//if within given distance of one of the node -> select it
		myPoint mPos = new myPoint(shiftX(mouseX),shiftY(mouseY));
		Node n = closestNode(mPos);
		if(mPos.dist(n) < selectionDist){
			hasSelectedNode = true;
			selectedNode = n;
			n.select();				
		}
	}
}

void delNodeHandler(){
	//if within given distance of one of the node -> delete it and all road connected to it
	myPoint mPos = new myPoint(shiftX(mouseX),shiftY(mouseY));
	Node n = closestNode(mPos);
	if(mPos.dist(n) < selectionDist){
		for(int i = 0; i<nodes.length; i+=1){
			if(nodes[i] == n){
				for(int j = i+1; j < nodes.length; j+=1){
					nodes[j-1] = nodes[j];
				}
				nodes = shorten(nodes);
				if(i <nodes.length){
					nodes[i].delRoadTo(n);
				}
			}else{
				nodes[i].delRoadTo(n);
			}
		}			
	}
}

void delRoadHandler(){
	//if within given distance of one of the roads -> delete it
	myPoint mPos = new myPoint(shiftX(mouseX),shiftY(mouseY));
	Road r = closestRoad(mPos);
	if(r!=nullRoad && r.squaredDist(mPos) < squaredSelectionDist){
		Node n1 = closestNode(r.a);
		Node n2 = closestNode(r.b);
		n1.delRoadTo(n2);
	}
}

void modifyStreetHandler(){
	myPoint mPos = new myPoint(shiftX(mouseX),shiftY(mouseY));
	Road r = closestRoad(mPos);
	if(r!=nullRoad && r.squaredDist(mPos) < squaredSelectionDist){
		int speedLimit = 50;
		int nbBands = 1;
		String name = "";

		if(javascript != null){
			name = javascript.getStreetName();
			speedLimit = javascript.getSpeedLimit();
			nbBands = javascript.getNbBands();
		}
		r.name = name;
		r.speedLimit = speedLimit;
		r.nbBands = nbBands;
	}
}

void modifyNodeHandler(){
	myPoint mPos = new myPoint(shiftX(mouseX),shiftY(mouseY));
	Node n = closestNode(mPos);
	if(n!=nullNode && mPos.squaredDist(n) < squaredSelectionDist && javascript != null){
		n.setType(javascript.getNodeType());
	}
}

void mouseMoved(){
	framesSinceMoved = 0;
	
	switch(selectedButton.id){
	case ADD_TWO_WAY : case ADD_SINGLE_WAY :
	case SEL_TOOL :case DEL_NODE : case MODFY_NODE:
		myPoint mPos = new myPoint(shiftX(mouseX),shiftY(mouseY));
		Node n = nullNode;
		for(int i = 0; i<nodes.length;i+=1){
			if(nodes[i].inbounds() && mPos.squaredDist(nodes[i])<squaredSelectionDist && mPos.isCloser(nodes[i],n)){
				n = nodes[i];
			}else if((!hasSelectedNode || nodes[i] != selectedNode)){
				nodes[i].deselectVisual();
			}
		}
		if(n != nullNode){
			n.selectVisual();
		}
		if(selectedButton.id != SEL_TOOL){
			break;
		}
	case MODFY_ST : case DEL_ROAD :
		myPoint mPos = new myPoint(shiftX(mouseX),shiftY(mouseY));
		Road r = closestRoad(mPos);
		deselectAllRoads();
		if(r!=nullRoad && r.squaredDist(mPos) < squaredSelectionDist){
			r.selectVisual();
		}
		break;
	case NO_BUTTON :
		break;
	}
	
	if(!hasRoadsStats){
		for(int i = 0 ; i < buttons.length; i+=1){
			buttons[i].mouseMoved();
		}
	}else{
		vis_mouseMoved();
	}
}

void keyPressed(){
	framesSinceMoved = 0;
	switch (keyCode){
		case SHIFT:
			shiftHeld = true;
			break;
	}
}

void keyReleased(){
	framesSinceMoved = 0;
	if(key=='+'){
		scaling+=0.1;
	}else if(key=='-'){
		scaling-=0.1;
	}else if(shiftHeld && (key=='c' || key=='C')){
		scaling=1;
		xShift=0;
		yShift=0;
	}
	if(!hasRoadsStats){
		int bIndex = keyCode - '1';
		if(bIndex >= 0 && bIndex < buttons.length){
			deselectAll();
			selectedButton = buttons[bIndex];
			selectedButton.select();
		}else{
			switch (keyCode){
				case UP:
					shift(DIR_TOP);
					break;
				case DOWN:
					shift(DIR_BOT);
					break;
				case LEFT:
					shift(DIR_LEFT);
					break;
				case RIGHT:
					shift(DIR_RIGHT);
					break;
				case SHIFT:
					shiftHeld = false;
					break;
			}
		}
	}else{
		vis_keyReleased();
	}
}


void shift(int dir){
	switch (dir){
	case DIR_RIGHT :
		xShift+=frame_size_x;
		break;
	case DIR_LEFT :
		xShift+=-frame_size_x;
		break;
	case DIR_TOP :
		yShift+=-frame_size_y;
		break;
	case DIR_BOT :
		yShift+=frame_size_y;
		break;
	}
}

void shiftBy(int dir, int amount){
	switch (dir){
	case DIR_RIGHT :
		xShift+=amount;
		break;
	case DIR_LEFT :
		xShift+=-amount;
		break;
	case DIR_TOP :
		yShift+=-amount;
		break;
	case DIR_BOT :
		yShift+=amount;
		break;
	}
}

double shiftX(double mX){
	return (mX+xShift)/scaling;
}

double shiftY(double mY){
	return (mY+yShift)/scaling;
}

Node closestNode(myPoint p){
	Node n = nullNode;
	if(nodes.length>0){
		n = nodes[0];
		for(int i = 1; i<nodes.length;i+=1){
			if(nodes[i].inbounds() && p.isCloser(nodes[i],n)){
				n = nodes[i];
			}
		}
	}
	return n;
}

Road closestRoad(myPoint p){
	Road r = nullRoad;
	double dist2 = -1;
	for(int i = 0; i<nodes.length;i+=1){
		for(int j = 0; j<nodes[i].roads.length;j+=1){
			d = nodes[i].roads[j].squaredDist(p);
			if(dist2 == -1 || d < dist2){
				r = nodes[i].roads[j];
				dist2 = d;
			}
		}
	}
	return r;
}

double formatY(double y){
	//return size_y - y;
	return y;
}

void deselectAll(){
	selectedButton.deselect();
	selectedButton = nullButton;
	if(hasSelectedNode){
		selectedNode.deselect();
		hasSelectedNode = false;
	}
	deselectAllRoads();
}

void deselectAllRoads(){
	for(int i = 0; i<nodes.length;i+=1){
		for(int j = 0; j<nodes[i].roads.length;j+=1){
			nodes[i].roads[j].deselectVisual();
		}
	}
}

Node[] getNodes(){
	return nodes;
}

void addNode(double x, double y, int nodeType){
	int type=NODE_UNDEF;
	if(nodeType){
		type = nodeType;
	}
	nodes = append(nodes,new Node(x,y,type));
}

int checkReachabilities(){
	int count = 0;
	for(int i = 0 ; i < nodes.length ; i+=1){
		if(!nodes[i].checkReachability()){
			nodes[i].setUnselectedCol(col_red);
			count+=1;
		}else{
			nodes[i].setType(nodes[i].myType);
		}
	}
	return count;
}

void addRoad(String name, int startId, int endId, int speedLimit, int nbBands){
	nodes[startId].addRoad(new Road(nodes[startId],nodes[endId],speedLimit,name,nbBands),nodes[endId]);
}

void addRoad(String name, int startId, int endId, int speedLimit, int nbBands, double length){
	Road r = new Road(nodes[startId],nodes[endId],speedLimit,name,nbBands);
	if(length)
		r.length = length;
	nodes[startId].addRoad(r,nodes[endId]);
}
