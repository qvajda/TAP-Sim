class Poly{
	myPoint[] points;
	segment[] segments;
	myColor fillCol;
	myColor borderCol;
	boolean stroke;
	boolean drawPts;

	Poly(){
		points = new myPoint[0];
		segments = new segment[0];
		fillCol = new myColor(150,150,150,100,1);
		borderCol = new myColor(150,150,150,250,1);
		stroke = true;
		drawPts = true;
	}

	void flushPoints(){
		points = new myPoint[0];
		segments = new segment[0];
	}
	
	void setDrawPts(boolean newVal){
		drawPts = newVal;
	}
	
	void addPoint(myPoint p){
		points = append(points,p);
		if(points.length>1){
			segments = append(segments,new segment(points[points.length-2],p));
		}
	}
	
	void draw(){
		beginShape();
		if (!stroke){
			noStroke();
		}
		//borderCol.set();
		fillCol.set();
		fillCol.doFill();
		for (int i = 0; i < points.length; i = i+1) {
			//vertex(points[i].x, formatY(points[i].y));
			points[i].doVertex();
		}
		if(points.length > 1){
			points[0].doVertex();
		}
		endShape();
		
		if (drawPts){
			for (int i = 0; i < points.length; i = i+1) {
				points[i].draw();
			}
		}
	}

	//returns true if the point at index i is convex
	boolean isConvex(int index){
		segment seg = segments[mod(i-1,points.length)];
		return seg.isLeft(points[(index+1)%points.length]);
	}
	
	void setFillCol(int r, int g , int b){
		fillCol.changeCol(r,g,b);
	}
	
	void setFillCol(myColor col){
		fillCol = col;
	}
	
	void setFillTrans(int t){
		fillCol.changeTrans(t);
	}
}
