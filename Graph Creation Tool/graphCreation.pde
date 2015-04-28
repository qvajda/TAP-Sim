/*Graph Creation Tool - v0.8
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
	
			/*for(int i = 0 ; i < dir_buttons.length ; i+=1){
				dir_buttons[i].draw();
			}*/
	
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

class myColor{
	int r,g,b,t,s;
	myColor(int _r, int _g, int _b, int _t, int _s){
		r = _r;
		g = _g;
		b = _b;
		t = _t;
		s = _s;
	}
	
	void set(){
		stroke(r, g, b, t);//set color and transparency	
		strokeWeight(s);//set size
	}
	
	void changeCol(int _r, int _g, int _b){
		r = _r;
		g = _g;
		b = _b;
	}
	
	void changeTrans(int _t){
		t = _t;
	}
	
	void doFill(){
		fill(r,g,b,t);
	}
	
	void changeSize(int _s){
		s = _s;
	}
}

//performs a modulo b ; while avoiding returning negative values
int mod(int a, int b){
	if (a < 0){
		return b-((-a)%b);
	}else{
		return a%b;
	}
}

myColor col_black = new myColor(0,0,0,255,1);
myColor col_thick_black = new myColor(0,0,0,255,4);
myColor col_thick_grey = new myColor(64,64,64,255,4);
myColor col_thick_shaded_grey = new myColor(64,64,64,150,4);
myColor col_light_grey = new myColor(224,224,224,200,1);
myColor col_shaded_red = new myColor(255,51,60,150,1);
myColor col_thick_shaded_red = new myColor(200,51,60,150,4);
myColor col_red = new myColor(149,25,0,255,1);
myColor col_big_red = new myColor(149,25,0,255,2);
myColor col_green = new myColor(87,149,0,255,1);
myColor col_shaded_green = new myColor(0,204,102,150,1);
myColor col_oliv = new myColor(153,153,0,255,1);
myColor col_yelo = new myColor(255,255,51,255,1);
myColor col_orng = new myColor(255,128,0,255,1);
myColor col_big_orng = new myColor(255,128,0,255,2);
myColor col_shaded_orng = new myColor(255,128,0,150,1);
myColor col_dark_red = new myColor(102,0,0,255,1);
myColor col_light_blue = new myColor(153,204,255,200,1);

myColor col_button_base = new myColor(225, 212, 192, 200, 1);
myColor col_button_high = new myColor(245, 237, 227, 200, 2);
myColor col_button_sel = new myColor(205, 191, 172, 200, 1);

myColor col_trans = new myColor(250,250,250,0,0);

class ColorMap{
	myColor[] colors;
	double[] values;
	
	int t;
	int s;	
	
	ColorMap(){
		colors = new myColor[0];
		values = new double[0];
		t = 1;
		s = 1;
	}

	ColorMap(int _t, int _s){
		colors = new myColor[0];
		values = new double[0];
		t = _t;
		s = _s;
	}

	void addMapping(myColor col, double val){
		boolean done = false;
		for(int i = 0;i<values.length; i+=1){
			if(values[i] == val){
				colors[i] = col;
				done = true;
			}
		}
		if(!done){
			int i = values.length;
			colors = append(colors,col);
			values = append(values,val);
			while(i!=0 && values[i-1]>val){
				values[i] = values[i-1];
				colors[i] = colors[i-1];
				values[i-1] = val;
				colors[i-1]= col;
				i-=1;
			}
		}
	}

	myColor mapColor(double val){
		if(values.length == 0 || values[0]>val){
			return col_trans;
		}else if(val >= values[values.length - 1]){
			
			return getGradient(1,col_trans,colors[colors.length - 1]);
		}
		int i = 0;
		boolean found = false;
		while (!found){
			found = (values[i]<=val && values[i+1]>val);
			i+=1;
		}
		i-=1;
		
		double interval = values[i+1]-values[i];
		double newVal = (val - values[i])/interval;
		return getGradient(newVal,colors[i],colors[i+1]);
		
	}
	
	myColor getGradient(double perc, myColor lower, myColor upper){
		double pctLower = 1 - perc;
		int r = lower.r*pctLower + upper.r*perc;
		int g = lower.g*pctLower + upper.g*perc;
		int b = lower.b*pctLower + upper.b*perc;
		
		return new myColor(r,g,b,t,s);
	}

}

ColorMap col_map_cap = new ColorMap(255,4);
ColorMap col_map_tt = new ColorMap(255,4);

class myPoint{
	double x,y;
	myColor myCol;
	string myName;

	myPoint(double _x,double _y){
		x = _x;
		y = _y;
		myCol = new myColor(10,15,10,250,5);
		myName = "";
	}

	string toStr(){
		return "("+str(x)+","+str(y)+")";
	}

	void drawGuard(){
		col = new myColor(10,15,10,250,3);
		col.set();
		//legs
		line(x,y,x-5,y+5);
		line(x,y,x+5,y+5);
		
		//torso
		line(x,y,x,y-6);
		
		//arms
		line(x-3,y-4,x+3,y-4)


		col.s = 5;
		col.set();
		//head
		point(x,y-7);
		
	}

	void draw(){
		myCol.set();
		text(myName, x-3, formatY(y) - 7);
		point(x,formatY(y));
	}
	
	void setName(string s){
		myName = s;
	}

	void setCol(int r, int g, int b){
		myCol.changeCol(r,g,b);
	}

	void setTrans(int t){
		myCol .changeTrans(t);
	}

	boolean isSmallerX(myPoint p){
		if (x==p.x){
			return (y<p.y);
		}else{
			return x<p.x;
		}
	}

	double dist(myPoint p){
		return sqrt(squaredDist(p));
	}	

	double squaredDist(myPoint p){
		return pow(p.x-x,2)+pow(p.y-y,2);
	}

	//return true if p1 is closer than p2 to this
	boolean isCloser(myPoint p1, myPoint p2){
		return squaredDist(p1) < squaredDist(p2);
	}

	Line dual(){
		return new Line(x,y);
	}

	Line primal(){
		return new Line(-x,y);
	}
	
	void doVertex(){
		vertex(x, formatY(y));
	}
	
	myPoint midPointTo(myPoint b){
		return new myPoint((x + b.x)/2,(y + b.y)/2);
	}
	
	boolean inbounds(){
		double realX = (x*scaling)-xShift;
		double realY = (y*scaling)-yShift;
		return realX > 0 && realX < size_x && realY > 0 && realY < size_y;
	}
}

class segment{
	myPoint a,b;
	myColor myCol;	

	segment(myPoint _a, myPoint _b){
		a = _a;
		b = _b;
		myCol = new myColor(10, 15, 10, 200,1);
	}
	
	void draw(){
		myCol.set();
		// draw a-b
		line(a.x, a.y, b.x,b.y);
	}
	
	void drawDotted(myColor col){
		col.set();
		int l = floor(getLength());
		for(int i=0; i<=l; i+=6) {
			float x = lerp(a.x, b.x, i/l);

			float y = lerp(a.y, b.y, i/l);

			point(x, y);
		}
	}
	
	void drawDotted(){
		drawDotted(myCol);
	}
	
	void setCol(int r, int g, int b){
		myCol.changeCol(r,g,b);
	}

	double orientationDet(myPoint c){
		double det = (a.x*b.y) + (a.y*c.x) + (b.x*c.y) - (c.x*b.y) - (a.y*b.x) - (a.x*c.y);
		return det;
	}	

	int orientation(myPoint c){
		/*
		Uses determinant method to find wether point c is :
		- to the left (negative return value)
		- to the right (positive return value)
		- on the line containing ab (return 0)
		*/
		int returnValue = 0;
		double det = orientationDet(c);
		if (det < 0){
			returnValue = _LEFT_;
		}else if(det > 0){
			returnValue = _RIGHT_;
		}
		return returnValue;
	}
	
	boolean isLeft(myPoint c){
		return orientation(c) == _LEFT_;
	}
	
	boolean isRight(myPoint c){
		return orientation(c) == _RIGHT_;
	}
	
	void setTrans(int t){
		myCol .changeTrans(t);
	}
	
	Line toLine(){
		double slope;
		if(b.x != a.x){
			slope = (((size_y - b.y) - (size_y - a.y))/(b.x - a.x));	
		}else{
			slope = (((size_y - b.y) - (size_y - a.y))/(b.x - a.x + 0.000001));
		}
		double offset = (-a.x*slope) + (size_y - a.y);
		return new Line(slope,offset)
	}
	
	Line halfSpaceSplit(){
		myPoint midpoint = a.midPointTo(b);
		double slope = -1/new segment(a,b).toLine().k;
		//y=slope*x + offset
		//offset = y-slope*x
		double offset = formatY(midpoint.y)-(slope*midpoint.x);
		return new Line(slope,offset);
	}

	myPoint midP(){
		return a.midPointTo(b);
	}
	
	double angle(){
		//myPoint temp = new myPoint(b.x-a.x,b.y-a.y);
		return atan2(b.y-a.y,b.x-a.x);
	}
	
	double squaredDist(myPoint p){
		double l = a.squaredDist(b);
		double t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l;
		if (t < 0){
			 return p.squaredDist(a);
		}
		if (t > 1){
			 return p.squaredDist(b);
		}
		return p.squaredDist( new myPoint(a.x + t * (b.x - a.x),a.y + t * (b.y - a.y)));
	}
	
	double dist(myPoint p){
		return sqrt(squaredDist(p));
	}
	
	double getLength(){
		return a.dist(b);
	}
}

class Line{
	//a line s.t y = kx + l
	double k; //slope
	double l;
	
	segment seg;//used to draw
	
	Line(double _k, double _l){
		k = _k;
		l = _l;
		
		myPoint p1 = new myPoint(0,l);
		myPoint p2 = new myPoint(size_x,yAtx(size_x));
		seg = new segment(p1,p2);
	}

	void draw(){
		seg.draw();
	}

	myPoint dual(){
		return new myPoint(-k,l);
	}
	
	myPoint primal(){
		return new myPoint(-k,l);
	}
	
	void setCol(int r, int g , int b){
		seg.setCol(r,g,b);
	}
	
	double yAtx(double x){
		return (k*x) + l;
	}
}

class Button{
	String msg;
	myColor baseCol, highlightCol, selectedCol;
	bool highlighted;
	int baseTrans;	

	boolean selected;

	double textX;
	double textY;
	
	double x;
	double y;
	double width;
	double height;
	
	int id;
	
	Button(double _x, double _y, double _width, double _height, String s, int _id, myColor base, myColor highlight, myColor sel){
		selected = false;
		width = _width;
		height = _height;
		
		msg = s;
		
		moveTo(_x,_y);
		
		baseCol = base;
		highlightCol = highlight;
		selectedCol = sel;
		highlighted = false;
	
		id = _id;
	}
	
	void setBaseTrans(int t){
		/*baseTrans = t;
		if(selected){
			myCol.changeTrans(baseTrans+50);
		}else{
			myCol.changeTrans(baseTrans);
		}*/
	}
	
	void moveTo(double _x, double _y){
		x = _x;
		y = _y;
		
		textX = x + (width - textWidth(msg))/2;
		textY = y + (height*0.5)  + (fontSize*0.5);
	}
	
	void moveToRel(Button b,int dir){
		double newX;
		double newY;
		switch(dir){
		case DIR_LEFT:
			newY = b.y;
			newX = b.x - button_spacing - width;
			break;
		case DIR_RIGHT:
			newY = b.y;
			newX = b.x + button_spacing + b.width;
			break;
		case DIR_BOT:
			newX = b.x;
			newY = b.y + button_spacing + b.height;
			break;
		case DIR_TOP:
			newX = b.x;
			newY = b.y - button_spacing - height;
			break;
		}
		moveTo(newX,newY);
	}

	void mouseMoved(){		
		//println("button "+id);
		if(isClicked()){
			highlighted = true;
		}else{
			highlighted = false;
		}
	}	

	void draw(){
		if(highlighted){
			highlightCol.set();
			highlightCol.doFill();
		}else if(selected){
			selectedCol.set();
			selectedCol.doFill();
		}else{
			baseCol.set();
			baseCol.doFill();
		}
		rect(x,y,width,height);
		col_black.doFill();
		text(msg,textX,textY);
	}

	boolean isClicked(){
		return (x < mouseX && mouseX < (x+width) && y < mouseY && mouseY < (y+height));
	}
	
	void select(){
		selected = true;
	}

	void deselect(){
		selected = false;
	}
}

class Node extends myPoint{
	Road[] roads;
	Node[] neighbors;
	boolean selected;
	int circleSize;
	myColor circleCol,fillCol, selectedCol, unselectedCol;
	boolean filled;
	
	int myType;
	
	Node(double x,double y){
		super(x,y);
		roads = new Road[0];
		neighbors = new Node[0];
		myCol.changeSize(4);
		selected = false;
		circleSize = 10;
		filled = true;
	
		circleCol = new myColor(15,15,15,200,1);
		unselectedCol = col_light_grey;
		selectedCol = col_shaded_red;
		fillCol = unselectedCol;
		myType = NODE_UNDEF;
	}
	
	Node(double x,double y,int newType){
		super(x,y);
		roads = new Road[0];
		neighbors = new Node[0];
		myCol.changeSize(4);
		selected = false;
		circleSize = 10;
		filled = true;
	
		circleCol = new myColor(15,15,15,200,1);
		myType = newType;
		switch(myType){
			case NODE_UNDEF:
				unselectedCol = col_light_grey;
				break;
			case NODE_RESI:
				unselectedCol = col_shaded_green;
				break;
			case NODE_WORK:
				unselectedCol = col_shaded_orng;
				break;
			case NODE_COMM:
				unselectedCol = col_light_blue;
				break;
			default:
				break;
		}
		selectedCol = col_shaded_red;
		fillCol = unselectedCol;
	}
	
	void draw(){
		if(inbounds()){
			super.draw();
			circleCol.set();
			if(filled){
				fillCol.doFill();
			}else{
				noFill();
			}
		
			ellipse(x,y,circleSize,circleSize);
		
			for(int i = 0; i< roads.length; i+=1){
				roads[i].draw();
			}
		}else{
			for(int i = 0; i< roads.length; i+=1){
				if(roads[i].b.inbounds()){
					roads[i].draw();
				}
			}
		}
	}
	
	void setType(int newType){
		myType = newType;
		switch(myType){
			case NODE_UNDEF:
				unselectedCol = col_light_grey;
				break;
			case NODE_RESI:
				unselectedCol = col_shaded_green;
				break;
			case NODE_WORK:
				unselectedCol = col_shaded_orng;
				break;
			case NODE_COMM:
				unselectedCol = col_light_blue;
				break;
			default:
				break;
		}
		if(!selected){
			fillCol = unselectedCol;
		}
	}	
	
	void drawRoadTo(double x, double y){
		new segment(this,new myPoint(x,y)).draw();	
	}
	
	void drawDottedLineTo(double _x, double _y){
		new segment(this,new myPoint(_x,_y)).drawDotted();
	}
	
	Road getRoadTo(Node neigh){
		for(int i = 0; i<neighbors.length; i+=1){
			if(neighbors[i] == neigh){
				return roads[i];
			}
		}
		return 0;
	}

	void addRoad(Road r, Node neigh){
		/*boolean found = false;
		for(int i = 0; i<neighbors.length && !found; i+=1){
			if(neighbors[i] == neigh){
				found = true;
			}
		}*/
		if(!inNeighbors(neigh)){
			roads = append(roads,r);
			neighbors = append(neighbors,neigh);
		}
	}
	
	boolean inNeighbors(Node n){
		for(int i = 0; i<neighbors.length; i+=1){
			if(neighbors[i] == n){
				return true;
			}
		}
		return false;
	}

	void delRoadTo(Node n){
		for(int i = 0; i<neighbors.length; i+=1){
			if(neighbors[i] == n){
				for(int j = i+1; j < neighbors.length; j+=1){
					neighbors[j-1] = neighbors[j];
					roads[j-1] = roads[j];
				}
				neighbors = shorten(neighbors);
				roads = shorten(roads);
			}
		}
	}	

	void select(){
		selected = true;
		selectVisual();
	}

	void deselect(){
		selected = false;
		deselectVisual();
	}
	
	void selectVisual(){
		circleSize=15;
		circleCol.changeCol(150,25,36);
		fillCol = selectedCol;
	}

	void deselectVisual(){
		circleSize=10;
		circleCol.changeCol(15,15,15);
		fillCol = unselectedCol;
	}
	
	void setUnselectedCol(myColor col){
		unselectedCol = col;
		fillCol = unselectedCol;
	}
	
	boolean checkReachability(){
		if(neighbors.length>0){
			for(int i = 0 ; i < nodes.length ; i+=1){
				if(nodes[i].inNeighbors(this)){
					return true;
				}
			}
		}
		return false;
	}
}

class RoadStat{	
	double t,usedCap;
	
	RoadStat(double _t, double _usedCap){
		t = _t;
		usedCap = _usedCap;
	}
}

class Road extends segment{
	int speedLimit;
	String name;
	double length;
	int nbBands;

	myPoint arrowHead;
	int arrowSize;
	
	boolean drawText;

	boolean hasStats;
	double capacity;
	RoadStat[] stats;
	double capUsage;//percentage of current usage of capacity
	String capUsage_str;

	RoadStat prevStat;
	int prevI;
	segment dataVis;
	double lastT;
	int id;
	
	
	Road(Node _a, Node _b, int _speedLimit, String _name, int _nbBands){
		super(_a,_b);
		name = _name;
		speedLimit = _speedLimit;
		nbBands = _nbBands;
		length = a.dist(b);

		a = shortenedStart(5);
		b = shortenedEnd(5);
		//create arrow head
		arrowHead = shortenedEnd(10);
		arrowSize = 2;		

		drawText = false;

		shiftRight();
	}
	
	void shiftEnd(double shiftX,double shiftY){
		b.x+=shiftX;
		b.y+=shiftY;
	}
	
	myPoint shortenedEnd(double short){
		double d = a.dist(b) - short ;
		double theta = angle();
		return new myPoint(d*cos(theta) + a.x,d*sin(theta) + a.y);
	}
	
	myPoint shortenedStart(double short){
		return shortenedEnd(a.dist(b) - short);
	}
	
	void draw(){
		if(hasStats){
			dataVis.draw();
		}
		super.draw();
		if(hasStats){
			col_light_grey.set();
		}
		strokeWeight(arrowSize);
		line(arrowHead.x, arrowHead.y, b.x,b.y);
		if(drawText){
			//text(name,10,size_y - 20);
			displayedInfo = toStr();
			/*textAlign(CENTER);
			col_black.doFill();
			text(toStr(),shiftX(mouseX),shiftY(mouseY)-fontSize);
			textAlign(LEFT);*/
		}
	}

	void shiftRight(){
		double theta = angle() - HALF_PI;
		
		double shiftX = (-2.5)*cos(theta);
		double shiftY = (-2.5)*sin(theta);
		
		a = new myPoint(a.x + shiftX, a.y + shiftY);
		b = new myPoint(b.x + shiftX, b.y + shiftY);
		
		arrowHead.x += shiftX;
		arrowHead.y+=shiftY;
	}
	
	void selectVisual(){
		myCol.changeSize(2);
		if(!hasStats){
			myCol.changeCol(150,25,36);
		}else{
			myCol.changeCol(120,120,120);
		}
		arrowSize = 4;
		drawText = true;
	}

	void deselectVisual(){
		myCol.changeCol(10,15,10);
		myCol.changeSize(1);
		arrowSize = 2;
		drawText = false;
	}
	
	String toStr(){
		String str = name+" ("+speedLimit+"kph ; "+nbBands+"lane(s) ; "+ int(length) +"m )";
		if(hasStats){
			str+=capUsage_str;
		}
		return str;
	}

	void addStats(double cap, double lt, int _id){
		capacity = cap;
		lastT = lt;
		id = _id;
		maxDay = max(maxDay,ceil(lastT/24));
		dataVis = new segment(a,b);
		loadFrom(0);
		hasStats = true;
	}

	void statUpdate(){
		capUsage = prevStat.usedCap/capacity;
		capUsage_str = "\n"+prevStat.usedCap+" / "+int(capacity);
		dataVis.myCol = col_map_cap.mapColor(capUsage);
	}

	void loadFrom(double t){
		stats = new RoadStat[0];
		//javascript call
		javascript.loadEntriesFor(t,this);
		prevStat = stats[0];
		prevI = 0;
		statUpdate();
	}

	void addEntry(double t, int driversCount){
		stats = append(stats, new RoadStat(t, driversCount));
	}

	void goTo(double t){
		if(hasStats){
			if(t>=stats[stats.length -1].t || t<stats[0].t){//if out of bounds of currently loaded entries
				loadFrom(t);
			}else if(prevI != stats[stats.length-2] && t>=stats[prevI+1].t && t<stats[prevI+2].t){
				prevI+=1;
				prevStat = stats[prevI];
				statUpdate();
			}else if(!(t>=stats[prevI].t && t<stats[prevI+1].t)){ //if last entry is not correct anymore
				//binary search to find correct entry
				int imin = 0,imax = stats.length-2,imid;
				while (imin<=imax){
					imid = floor((imin+imax)/2);
					if(t>=stats[imid].t && t<stats[imid+1].t){
						//found correct entry in imid:
						prevI = imid;
						prevStat = stats[prevI];
						statUpdate();
						break;
					}else if(t<stats[imid].t){
						imax = imid-1;
					}else{
						imin = imid+1;
					}
				}
			}
		}
	}
}

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

//for data visualization

boolean hasRoadsStats;
int maxDay;
double vis_time;
boolean vis_playing;
double vis_speed;//nb of minutes for every second of play

int giant_fontSize = floor(size_y/8);
int big_fontSize = floor(size_y/18);

Button[] vis_buttons;
int PLAY_PAUSE = 6;
int SPEED_UP = 7;
int SPEED_DOWN = 8;
int NXT_DAY = 9;
int PREV_DAY = 10;

double[] speeds = new int[12];
speeds[0] = 1/60;speeds[1] = 5/60;speeds[2] = 0.25;speeds[3] = 0.5;
speeds[4] = 1;speeds[5] = 2;speeds[6] = 3;speeds[7] = 5;speeds[8] = 10;speeds[9] = 15;speeds[10] = 20;speeds[11] = 30;speeds[12] = 45;speeds[13] = 60;speeds[14] = 90;speeds[15] = 120;
int speedI;

myColor col_visUI_grey = new myColor(0,0,0,90,1);

void setHasRoadsStats(boolean val){
	hasRoadsStats = val;
	if(val){
		maxDay = 0;
		deselectAll();
		selectedButton = buttons[0];//selection tool
		selectedButton.select();
		
		day_time = 0;
		vis_speed = 1;
		speedI = 4;
		vis_time = 0;
		vis_playing = true;
	
		vis_buttons = new Button[5];
		vis_buttons[0] = new Button(margin-20,margin,20,giant_fontSize,"<",PREV_DAY,col_trans,col_trans,col_trans);
		vis_buttons[1] = new Button(margin+(3*giant_fontSize),margin,20,giant_fontSize,">",NXT_DAY,col_trans,col_trans,col_trans);
		vis_buttons[2] = new Button(margin/2,size_y-(2*margin),20,margin,"<<",SPEED_DOWN,col_trans,col_trans,col_trans);
		vis_buttons[3] = new Button(0,0,20,margin,"||",PLAY_PAUSE,col_trans,col_trans,col_trans);
		vis_buttons[3].moveToRel(vis_buttons[2],DIR_RIGHT);
		vis_buttons[4] = new Button(0,0,20,margin,">>",SPEED_UP,col_trans,col_trans,col_trans);
		vis_buttons[4].moveToRel(vis_buttons[3],DIR_RIGHT);
		
		col_map_cap.addMapping(col_trans, 0);
		col_map_cap.addMapping(col_green, 0.2);
		col_map_cap.addMapping(col_oliv, 0.4);
		col_map_cap.addMapping(col_yelo, 0.6);
		col_map_cap.addMapping(col_orng, 0.8);
		col_map_cap.addMapping(col_red, 1);
		col_map_cap.addMapping(col_dark_red, 1.2);
		col_map_cap.addMapping(col_black, 1.4);

		col_map_tt.addMapping(col_trans, 0);
		col_map_tt.addMapping(col_green, 0.3);
		col_map_tt.addMapping(col_oliv, 0.5);
		col_map_tt.addMapping(col_yelo, 0.7);
		col_map_tt.addMapping(col_orng, 0.9);
		col_map_tt.addMapping(col_red, 1.4);
		col_map_tt.addMapping(col_dark_red, 2);
		col_map_tt.addMapping(col_black, 3);
	}
}

Road addRoadInfos(int startId, int endId, double capacity, double lt, int rId){
	Road r = nodes[startId].getRoadTo(nodes[endId]);
	r.addStats(capacity,lt,rId);
	return r;
}

void vis_updateRoads(){
	for(int i = 0;i<nodes.length;i+=1){
		for(int rId = 0 ; rId < nodes[i].roads.length ; rId+=1){
			nodes[i].roads[rId].goTo(vis_time);
		}
	}
}

String timeToStr(double t){
	int hours = floor(t);
	int mins = round((t-hours)*60);
	int secs = round((((t-hours)*60)-mins)*60);
	if(secs<0){
		mins-=1;
		secs +=60;
	}
	return hours+":"+mins+":" +secs;
}

void vis_draw(){
	if(hasRoadsStats){
		if(vis_playing && frameCount%fps == 0){
			vis_time += vis_speed/60;
			if(vis_time>(maxDay*24)){
				vis_time = (maxDay*24)-(1/3600);//23h59m59s on the last day
				vis_playing = false;
			}
			vis_updateRoads();
		}
		col_visUI_grey.doFill();
		//draw day indicator
		textSize(giant_fontSize);
		text("DAY "+floor(vis_time/24),margin,margin+giant_fontSize);
		textSize(big_fontSize);
		
		//draw time, speed
		double day_time = vis_time%24;
		String s = timeToStr(day_time) + " \t+";
		if(vis_speed>=1){
			s+=floor(vis_speed) + "m/s";
		}else{
			s+= floor(60*vis_speed)+"s/s";
		}
		text(s,margin/2,size_y-(2*margin));
		textSize(fontSize);

		//draw next/previous day, speed-up/down & pause buttons
		if(vis_time<(maxDay-1)*24){
			vis_buttons[1].draw();
		}
		if(vis_time>=24){
			vis_buttons[0].draw();
		}
		for(int i = 2 ; i < vis_buttons.length ; i+=1){
			vis_buttons[i].draw();
		}

		//draw  timeline & "slider"
		double split = (day_time/24)*size_x;
		col_visUI_grey.set();
		col_shaded_red.doFill();
		rect(0,size_y-margin,split,margin);
		col_light_grey.doFill();
		rect(split,size_y-margin,size_x-split,margin);
		col_thick_grey.set();
		line(split,size_y,split,size_y-margin-2);
		
		if(mouseY>=size_y-margin){
			col_visUI_grey.set();
			col_visUI_grey.doFill();
			line(mouseX,size_y,mouseX,size_y-margin);
			text(timeToStr((mouseX/size_x)*24),mouseX-10,size_y-margin-3);
		}
	}
}

void vis_mouseClicked(){
	//check for day change buttons
	//check for speed & pause buttons
	//handle moving slider
	boolean pressedButton = false;
	for(int i = 0 ; i < vis_buttons.length && !pressedButton; i+=1){
		if(vis_buttons[i].isClicked()){
			switch(vis_buttons[i].id){
			case PREV_DAY :
				if(vis_time>=24){
					vis_time = max(0,(floor(vis_time/24)-1)*24);
					vis_updateRoads();
				}
				break;
			case NXT_DAY:
				if(vis_time<(maxDay-1)*24){
					vis_time = (floor(vis_time/24)+1)*24;
					if(vis_time>(maxDay*24)){
						vis_time = (maxDay*24)-(1/3600);//23h59m59s on the last day
						vis_playing = false;
					}
					vis_updateRoads();
				}
				break;
			case PLAY_PAUSE:
				vis_playing = !vis_playing;
				if(vis_playing){
					vis_buttons[3].msg = "||";
				}else{
					vis_buttons[3].msg = "|>";
				}
				break;
			case SPEED_UP:
				speedI = min(speedI+1,speeds.length-1);
				vis_speed = speeds[speedI];
				break;
			case SPEED_DOWN:
				speedI = max(speedI-1,0);
				vis_speed = speeds[speedI];
				break;
			}
			pressedButton = true;
		}
	}
	if(!pressedButton && mouseY>=size_y-margin){
		vis_time = ((mouseX/size_x) + floor(vis_time/24))*24 ;
		vis_updateRoads();
	}
}

void vis_mouseMoved(){
	for(int i = 0 ; i < vis_buttons.length; i+=1){
		vis_buttons[i].mouseMoved();
	}
}

void vis_keyReleased(){
	switch (keyCode){
		case UP:
			break;
		case DOWN:
			break;
		case LEFT:
			if(shiftHeld){
				if(vis_time>=24){
					vis_time = max(0,(floor(vis_time/24)-1)*24);
					vis_updateRoads();
				}
			}else{
				speedI = max(speedI-1,0);
				vis_speed = speeds[speedI];
			}
			break;
		case RIGHT:
			if(shiftHeld){
				if(vis_time<maxDay*23){
					vis_time = (floor(vis_time/24)+1)*24;
					if(vis_time>(maxDay*24)){
						vis_time = (maxDay*24)-(1/3600);//23h59m59s on the last day
						vis_playing = false;
					}
					vis_updateRoads();
				}
			}else{
				speedI = min(speedI+1,speeds.length-1);
				vis_speed = speeds[speedI];
			}
			break;
		case SHIFT:
			shiftHeld = false;
			break;
		case 32:
			vis_playing = !vis_playing;
			if(vis_playing){
				vis_buttons[3].msg = "||";
			}else{
				vis_buttons[3].msg = "|>";
			}
			break;
	}

}
