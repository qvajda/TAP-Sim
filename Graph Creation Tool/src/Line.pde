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
