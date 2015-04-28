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
