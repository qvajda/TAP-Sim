class mySet{
	myPoint[] points;
	myPoint[] hVertices;
	segment[] hullSegments;
	boolean inOrder;
	int maxXi;

	mySet(){
		points = new myPoint[0];
		hVertices = new myPoint[0];
		hullSegments = new segment[0];
		inOrder = false;
		maxXi = 0;
	}

	void colorHull(){
		for(int i = 0; i < points.length; i = i + 1){
			points[i].setTrans(100);
		}
		
		for(int i = 0; i < hVertices.length; i = i + 1){
			hVertices[i].setCol(10,150,10);
			hVertices[i].setTrans(250);
		}
		if (inOrder && (hVertices.length > 1)){
			for (int i = 0; i < hVertices.length-1; i = i+1){
				hullSegments = append(hullSegments,new segment(hVertices[i],hVertices[i+1]));
			}
			
			hullSegments = append(hullSegments,new segment(hVertices[hVertices.length-1],hVertices[0]));
		}
	}
	
	segment[] getTopConvexHullSegs(){
		myPoint[] pts = getTopConvexHull();
		segment[] segs = new segment[pts.length - 1];
		for(int i = 0 ; i < pts.length - 1 ; i+=1){
			segs[i] = new segment(pts[i],pts[i+1]);
		}
		return segs;
	}
	
	segment[] getBotConvexHullSegs(){
		myPoint[] pts = getBotConvexHull();
		segment[] segs = new segment[pts.length - 1];
		for(int i = 0 ; i < pts.length - 1 ; i+=1){
			segs[i] = new segment(pts[i],pts[i+1]);
		}
		return segs;
	}

	myPoint[] getTopConvexHull(){
		sortPointsByX();
		int l = points.length;
		myPointsStack top = new myPointsStack();
		if(l>0){
			top.push(points[0]);
		}
		if(l>1){
			top.push(points[1]);
		}
		for(int i = 2; i < l; i = i+1){
			while(!(top.n == 1) && top.lastSegment().orientation(points[i]) == _LEFT_){
				top.pop();
			}
			top.push(points[i]);
		}
		
		hVertices = top.toArray();
		return hVertices;
	}

	void getBotConvexHull(){
		sortPointsByX();
		int l = points.length;
		myPointsStack bot = new myPointsStack();
		if(l>0){
			bot.push(points[0]);
		}
		if(l>1){
			bot.push(points[1]);
		}
		for(int i = 2; i < l; i = i+1){
			while(!(bot.n == 1) && bot.lastSegment().orientation(points[i]) == _RIGHT_){
				bot.pop();
			}
			bot.push(points[i]);
		}
		
		hVertices = bot.toArray();
		return hVertices;
	}

	void performGrahamScanMonotone(){
		sortPointsByX();
		int l = points.length;
		myPointsStack top = new myPointsStack();
		myPointsStack bot = new myPointsStack();
		if(l>0){
			top.push(points[0]);
			bot.push(points[0]);
		}
		if(l>1){
			top.push(points[1]);
			bot.push(points[1]);
		}
		for(int i = 2; i < l; i = i+1){
			while(!(top.n == 1) && top.lastSegment().orientation(points[i]) == _LEFT_){
				top.pop();
			}while(!(bot.n == 1) && bot.lastSegment().orientation(points[i]) == _RIGHT_){
				bot.pop();
			}
			top.push(points[i]);
			bot.push(points[i]);
		}
		
		hVertices = bot.toArray();
		myPoint[] topArray = top.toArray();
		//append top[1:length-1] to the vertices list in reverse order
		for (int i = topArray.length-2; i > 0 ; i = i - 1){
			hVertices = append(hVertices,topArray[i]);
		}
		inOrder = true;
		
		//update maxXi ; the index to the hull vertex with the biggest x value (or y value if multiple point with the same x)
		for (int i = 0; i < hVertices.length; i = i+1) {
			//no need to check y values as the order is counter clockwise
			if (hVertices[i].x > hVertices[maxXi].x){
				maxXi = i;
			}
		}
	}
	
	void addPoint(myPoint p){
		points = append(points,p);
	}
	
	void sortPointsByX(){
		quickSort(points,0,points.length-1);
	}

	void draw(){
		for (int i = 0; i < points.length; i = i+1) {
			points[i].draw();
		}
		for (int i = 0; i < hullSegments.length; i = i+1){
			hullSegments[i].draw();
		}
	}
	
	//quicksort code for processing taken from http://cathyatseneca.github.io/DSAnim/web/quick.html
	void quickSort(myPoint arr[], int left, int right){
		if(left<right){
			int pivotpt=int((left+right)/2);
			myPoint pivot=arr[pivotpt];
			int i=left;
			int j=right-1;
			myPoint tmp;
			tmp=arr[pivotpt];
			arr[pivotpt]=arr[right];
			arr[right]=tmp;
			pivotpt=right;
			while(i<j){
				while(i<right-1 && arr[i].isSmallerX(pivot)){
					i++;
				}
				while(j > 0 && !(arr[j].isSmallerX(pivot))){
					j--;
				}
				if(i<j){
					tmp=arr[i];
					arr[i]=arr[j];
					arr[j]=tmp;
				}
			}
			if(i==j && arr[i].isSmallerX(arr[pivotpt])){
				i++;
			}
			tmp=arr[i];
			arr[i]=arr[pivotpt];
			arr[pivotpt]=tmp;
			quickSort(arr,left,i-1);
			quickSort(arr,i+1,right);
		}
	}
	
	string toStr(){
		string str = "";
		for (int i = 0; i < points.length; i = i+1) {
			str = str+" - "+points[i].toStr();
		}
		return str;
	}
	
	//finds the index of the left-right angular separation in the convex hull vertices corresponding to the specified point
	int findLRSeparation(myPoint p){
		int l = hVertices.length;
		int left,right,middle;
		int returnValue = 0;
		int ref = 0;
		/* The index of the reference CH vertex ;
		 always the leftmost vertex unless point p is to the left of that ;
		 at which point the rightmost point is used */

		if (p.x < hVertices[0].x || (p.x == hVertices[0].x && p.y < hVertices[0].y)){
			ref = maxXi;
		}
		segment seg = new segment(p,hVertices[0+ref]);
	
		left = 0;
		right = l-1;
		middle = int( (right-left)/2);
		while(seg.orientation(hVertices[(middle+ref)%l]) == seg.orientation(hVertices[(middle+1+ref)%l]) &&
			right != left){
			if (seg.orientation(hVertices[(middle+ref)%l]) == _LEFT_){
				left = middle+1;
			}else{
				right = middle;
			}
			middle = left+int( (right-left)/2);
		}
		return ((middle+ref)%l);
	}

	segment[] getTangents(myPoint p){
		int l = hVertices.length;
		segment[] segs = new segment[2];
		if (l == 1){//special case : if only 1 point in set
			segs[0] = new segment(hVertices[0],p);
			segs[1] = new segment(hVertices[0],p);
			return segs;
		}
		
		int sep = findLRSeparation(p);
		int ref = 0;

		if (p.x < hVertices[0].x || (p.x == hVertices[0].x && p.y < hVertices[0].y)){
			ref = maxXi;
		}
		segment seg1,seg2;
	
		left = 0;
		right = mod(sep-ref+1,l);
		if (right == 0){
			right = l-1;
		}
		middle = left+int( (right-left)/2);
		seg1 = new segment(hVertices[mod(middle+ref-1,l)],hVertices[mod(middle+ref,l)]);
		seg2 = new segment(hVertices[mod(middle+ref,l)],hVertices[mod(middle+ref+1,l)]);
		while(!(seg1.orientation(p) == _LEFT_ && seg2.orientation(p) != _LEFT_) &&
			right > left){
			if (seg2.orientation(p) == _LEFT_){
				left = middle+1;
			}else{
				right = middle-1;
			}
			middle = left+int( (right-left)/2);
			seg1 = new segment(hVertices[mod(middle+ref-1,l)],hVertices[mod(middle+ref,l)]);
			seg2 = new segment(hVertices[mod(middle+ref,l)],hVertices[mod(middle+ref+1,l)]);
		}
		segs[0]=new segment(hVertices[mod(middle+ref,l)],p);
		segs[0].setCol(100,10,150);

		left = mod(sep-ref,l);
		if(left==l-1){
			left = 0;
		}
		right = l-1;
		
		middle = left+ceil( (right-left)/2);
		seg1 = new segment(hVertices[mod(middle+ref-1,l)],hVertices[mod(middle+ref,l)]);
		seg2 = new segment(hVertices[mod(middle+ref,l)],hVertices[mod(middle+ref+1,l)]);
		while(!(seg1.orientation(p) != _LEFT_ && seg2.orientation(p) == _LEFT_) &&
			right > left){
			if (seg1.orientation(p) == _LEFT_){
				right = middle-1;
			}else{
				left = middle+1;
			}
			middle = left+ceil( (right-left)/2);
			seg1 = new segment(hVertices[mod(middle+ref-1,l)],hVertices[mod(middle+ref,l)]);
			seg2 = new segment(hVertices[mod(middle+ref,l)],hVertices[mod(middle+ref+1,l)]);
		}
		segs[1]=new segment(hVertices[mod(middle+ref,l)],p);
		segs[1].setCol(100,10,150);

		
		return segs;
	}
	
	myPoint[] getHullPts(){
		return hVertices;
	}

	boolean intersectsHull(segment s){
		boolean res = false;
		int i = 0;
		int orient = 0;
		int orienti = 0;
		
		while(!res && i<hVertices.length){
			orienti = s.orientation(hVertices[i]);
			if(orienti == 0){
				if(!(s.a == hVertices[i] || s.b == hVertices[i])){
					res = true;
				}
			}else{
				if(orient == 0){
					orient = orienti;
				}else if(orient != orienti){
					res = true;
				}
			}
			i+=1;
		}
		return res;
	}
}

class myPointsStack{
	ArrayList points;
	int n;
	myPointsStack(){
		points = new ArrayList();
		n=0;
	}

	void push(myPoint p){
		points.add(p);
		n = n+1;
	}
	
	void pop(){
		if (n>0){
			n = n-1;
			points.remove(n);
		}
	}
	
	segment lastSegment(){
		if (n>1){
			return new segment((myPoint)points.get(n-2),(myPoint)points.get(n-1));
		}
	}
	
	myPoint[] toArray(){
		myPoint[] p = new myPoints[n];
		for (int i = 0; i < n; i = i + 1){
			p[i] = (myPoint) points.get(i);
		}
		return p;
	}
}
