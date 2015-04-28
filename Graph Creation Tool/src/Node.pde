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
