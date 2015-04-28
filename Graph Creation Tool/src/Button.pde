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
