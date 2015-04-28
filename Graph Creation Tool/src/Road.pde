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
