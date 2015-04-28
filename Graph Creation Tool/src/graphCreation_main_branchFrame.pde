//target ../graphCreation.pde
//include myColor.pde
//include myPoint.pde
//include segment.pde
//include Poly.pde
//include Line.pde
//include Button.pde
//include Node.pde
//include Road.pde
//include NodesFrame.pde
/*
Graph Creation Tool - v0.3b
Author : Quentin-Emmanuel VAJDA
*/

int size_x = 1200;
int size_y = 600;

int margin = 100;
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

nullNode = new Node(0,0);
nullRoad = new Road(nullNode, nullNode, 0, "");

Button nullButton = new Button(0,0,0,0,"",NO_BUTTON);
Button[] buttons;
Button selectedButton;

Button[] dir_buttons;

NodesFrame nodes;
Node selectedNode;

boolean hasSelectedNode;

void setup() {  // this is run once.

	// set the background color
	background(255);

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
	buttons = new Button[5];
	int x = 20+margin;
	int y = 10;
	buttons[0] = new Button(x,y,80,24,"Selection",SEL_TOOL);
	buttons[1] = new Button(0,0,80,24,"Two Way st.",ADD_TWO_WAY);
	buttons[1].moveToRel(buttons[0],DIR_RIGHT);
	buttons[2] = new Button(0,0,80,24,"One Way st.",ADD_SINGLE_WAY);
	buttons[2].moveToRel(buttons[1],DIR_RIGHT);
	buttons[3] = new Button(0,0,80,24,"Delete st.",DEL_ROAD);
	buttons[3].moveToRel(buttons[2],DIR_RIGHT);
	buttons[4] = new Button(0,0,80,24,"Delete Node",DEL_NODE);
	buttons[4].moveToRel(buttons[3],DIR_RIGHT);
	
	selectedButton = nullButton;
	
	dir_buttons = new Button[4];
	dir_buttons[0] = new Button(0,margin,margin,size_y-2*margin,"Left",DIR_LEFT);
	dir_buttons[1] = new Button(margin,0,size_x - 2*margin,margin,"Top",DIR_TOP);
	dir_buttons[2] = new Button(size_x - margin,margin,margin,size_y-2*margin,"Right",DIR_RIGHT);
	dir_buttons[3] = new Button(margin,size_y-margin,size_x-2*margin,margin,"Bot",DIR_BOT);
	dir_buttons[0].setBaseTrans(35);
	dir_buttons[1].setBaseTrans(35);
	dir_buttons[2].setBaseTrans(35);
	dir_buttons[3].setBaseTrans(35);

	nodes = new NodesFrame();
	hasSelectedNodes = false;
	
}

void draw() {
	background(250);
	for(int i = 0 ; i < buttons.length ; i+=1){
		buttons[i].draw();
	}
	
	for(int i = 0 ; i < dir_buttons.length ; i+=1){
		dir_buttons[i].draw();
	}

	nodes.draw();
}

void mousePressed() {
	if (mouseButton == LEFT){
		boolean pressedButton = false;
		for(int i = 0 ; i < buttons.length && !pressedButton; i+=1){
			if(buttons[i].isClicked()){
				deselectAll();
				selectedButton = buttons[i];
				selectedButton.select();
				pressedButton = true;
			}
		}
		for(int i = 0 ; i < dir_buttons.length && !pressedButton; i+=1){
			if(dir_buttons[i].isClicked()){
				nodes.shift(dir_buttons[i].id);
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
			case NO_BUTTON:
				break;
			}
		}
	}else if (mouseButton == RIGHT){
		nodes.shift(DIR_RIGHT);
		//nothing
	}else if(mouseButton == CENTER){
		//nothing
	}
}

void addTwo_singleWayHandler(){
	if(nodes.getLength() == 0 && !hasSelectedNode){
		nodes.addNode(new Node(mouseX,formatY(mouseY)));
		selectedNode = nodes.at(0);
		hasSelectedNode = true;
		selectedNode.select();
	}else if(hasSelectedNode){
		//test if close to another node
		myPoint mPos = new myPoint(mouseX,mouseY);
		Node n = nodes.closestNode(mPos);
		//if not add node
		if(mPos.dist(n) > selectionDist){
			n = new Node(mouseX,formatY(mouseY));
			nodes.addNode(n);			
		}
		//add road between the two nodes
		int speedLimit = 50; //TODO
		String name = "cake st.";
		nodes.addRoad(selectedNode,n,speedLimit,name);
		//selectedNode.addRoad(new Road(selectedNode,n,speedLimit,name),n);
		if (selectedButton.id == ADD_TWO_WAY){
			nodes.addRoad(n,selectedNode,speedLimit,name);
			//n.addRoad(new Road(n,selectedNode,speedLimit,name),selectedNode);
		}
		selectedNode.deselect();
		hasSelectedNode = false;
	}else{
		//if within given distance of one of the node -> select it
		myPoint mPos = new myPoint(mouseX,mouseY);
		Node n = nodes.closestNode(mPos);
		if(mPos.dist(n) < selectionDist){
			hasSelectedNode = true;
			selectedNode = n;
			n.select();				
		}
	}
}

void delNodeHandler(){
	//if within given distance of one of the node -> delete it and all road connected to it
	myPoint mPos = new myPoint(mouseX,mouseY);
	nodes.delNode(mPos);
}

void delRoadHandler(){
	//if within given distance of one of the roads -> delete it
	myPoint mPos = new myPoint(mouseX,mouseY);
	nodes.delRoad(mPos);
}

void mouseMoved(){
	for(int i = 0 ; i < dir_buttons.length ; i+=1){
		if(dir_buttons[i].isClicked()){
			dir_buttons[i].select();
		}else{
			dir_buttons[i].deselect();
		}
	}
	
	switch(selectedButton.id){
	case SEL_TOOL :
	case ADD_TWO_WAY : case ADD_SINGLE_WAY : case DEL_NODE :
		myPoint mPos = new myPoint(mouseX,mouseY);
		Node n = nodes.closestNode(mPos);
		if(mPos.squaredDist(n) < squaredSelectionDist){
			n.selectVisual();
		}else if(!hasSelectedNode || n != selectedNode){
			n.deselectVisual();
		}
		if(selectedButton.id != SEL_TOOL){
			break;
		}
	case DEL_ROAD :
		myPoint mPos = new myPoint(mouseX,mouseY);
		Road r = nodes.closestRoad(mPos);
		nodes.deselectAllRoads(mPos);
		if(r!=nullRoad && r.squaredDist(mPos) < squaredSelectionDist){
			r.selectVisual();
		}
		break;
	case NO_BUTTON :
		break;
	}
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
}
