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
