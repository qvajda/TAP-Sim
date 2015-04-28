class NodesFrame{
	Node[][][] nodesMat;
	int crtX;
	int crtY;
	
	int nCols;
	int nRows;
	
	NodesFrame(){
		nodesMat = new Node[1][1][0];
		crtX = 0;
		crtY = 0;
		nCols = 1;
		nRows = 1;
	}

	void shift(int dir){
		nxtX = crtX;
		nxtY = crtY;
		switch (dir){
		case DIR_LEFT :
			nxtX+=-1;
			break;
		case DIR_RIGHT:
			nxtX+=1;
			break;
		case DIR_TOP  :
			nxtY+=-1;
			break;
		case DIR_BOT  :	
			nxtY+=1;
			break;
		}
		
		if(nxtX >= nCols){
			//add a column at the end of matrix
			nodesMat = append(nodesMat, new Nodes[nRows][0]);
			nCols += 1;
		}else if(nxtY >= nRows){
			//add a row at the end
			for(int i = 0; i < nCols ; i+=1){
				nodesMat[i] = append(nodesMat[i], new Nodes[0]);
			}
			nRows += 1;
		}else if(nxtX < 0){
			//add a column at the start of matrix
			nodesMat = splice(nodesMat, new Nodes[nRows][0], 0);
			nxtX = 0;
			nCols += 1;
		}else if(nxtY < 0){
			//add a row at the start
			for(int i = 0; i < nCols ; i+=1){
				nodesMat[i] = splice(nodesMat[i], new Nodes[0], 0);
			}
			nxtY = 0;
			nCols += 1;
		}
		crtX = nxtX;
		crtY = nxtY;
	}

	void draw(){
		for(int i = 0; i < nCols; i+=1){
			for(int j = 0; j < nRows; j+=1){
				int translate_x = (i-crtX)*frame_size_x;
				int translate_y = (j-crtY)*frame_size_y;
				pushMatrix();
				translate(translate_x,translate_y);
				for(int k = 0; k < nodesMat[i][j].length; k+=1){
					nodesMat[i][j][k].draw();
				}
				popMatrix();
			}
		}
	}
	
	int getLength(){		
		return nodesMat[crtX][crtY].length;
	}
	
	Node at(int index){
		return nodesMat[crtX][crtY][index];
	}
	
	void addNode(Node n){
		nodesMat[crtX][crtY] = append(nodesMat[crtX][crtY], n);
	}
	
	int shiftWCrtX(int _posX){
		int posX = _posX;
		int shiftI = 0;
		while(posX > size_x - margin){
			shiftI += 1;
			posX += -frame_size_x;
		}
		while(posX < margin){
			shiftI += -1;
			posX += frame_size_x;
		}
		return shiftI;
	}
	
	int shiftWCrtY(int _posY){
		int posY = _posY;
		int shiftI = 0;
		while(posY > size_y - margin){
			shiftI += 1;
			posY += -frame_size_y;
		}
		while(posY < margin){
			shiftI += -1;
			posY += frame_size_y;
		}
		return shiftI;
	}

	void delNode(myPoint mPos){
		Node n = closestNode(mPos);
		if(mPos.dist(n) < selectionDist){
			int x = crtX + shiftWCrtX(mPos.x);
			int y = crtY + shiftWCrtY(mPos.y);
			for(int i = 0; i<nodesMat[x][y].length; i+=1){
				if(nodesMat[x][y][i] == n){
					for(int j = i+1; j < nodesMat[x][y].length; j+=1){
						nodesMat[x][y][j-1] = nodesMat[x][y][j];
					}
					nodesMat[x][y] = shorten(nodesMat[x][y]);
					if(i < nodesMat[x][y].length){
						nodesMat[x][y][i].delRoadTo(n);
					}
				}else{
					nodesMat[x][y][i].delRoadTo(n);
				}
			}
			for(int i = 0; i<nCols; i+=1){
				for(int j = 0; j<nRows; j+=1){
					if(i!=x && j!=y){
						for(int k = 0; k<nodesMat[i][j].length; k+=1){
							nodesMat[i][j][k].delRoadTo(n);
						}
					}
				}	
			}
		}
	}
	
	void delRoad(myPoint mPos){
		Road r = closestRoad(mPos);
		if(r!=nullRoad && r.squaredDist(mPos) < squaredSelectionDist){
			int x = crtX + shiftWCrtX(mPos.x);
			int y = crtY + shiftWCrtY(mPos.y);
			Node n1 = closestNode(r.a);
			Node n2 = closestNode(r.b);
			n1.delRoadTo(n2);		
		}
	}

	Node closestNode(myPoint _p){
		int x = crtX + shiftWCrtX(_p.x);
		int y = crtY + shiftWCrtY(_p.y);
		Node n = nodesMat[x][y][0];
		myPoint p = new myPoint(mod(_p.x - margin,frame_size_x)+margin,mod(_p.y - margin,frame_size_y)+margin );
		for(int i = 1; i<nodesMat[x][y].length;i+=1){
			if(p.isCloser(nodesMat[x][y][i],n)){
				n = nodesMat[x][y][i];
			}
		}
		return n;
	}
	
	
	Road closestRoad(myPoint p){
		int x = crtX + shiftWCrtX(p.x);
		int y = crtY + shiftWCrtY(p.y);
		Road r = nullRoad;
		double dist2 = -1;
		for(int i = 0; i<nodesMat[x][y].length;i+=1){
			for(int j = 0; j<nodesMat[x][y][i].roads.length;j+=1){
				d = nodesMat[x][y][i].roads[j].squaredDist(p);
				if(dist2 == -1 || d < dist2){
					r = nodesMat[x][y][i].roads[j];
					dist2 = d;
				}
			}
		}
		return r;
	}
	
	void deselectAllRoads(myPoint mPos){
		int x = crtX + shiftWCrtX(mPos.x);
		int y = crtY + shiftWCrtY(mPos.y);
		for(int i = 0; i<nodesMat[x][y].length; i+=1){
			for(int j = 0; j<nodesMat[x][y][i].roads.length;j+=1){
				nodesMat[x][y][i].roads[j].deselectVisual();
			}
		}
	}
	
	double[] getAbsolutePos(Node n){
		//test if in crt frame
		double[] res = new double[2];
		res[0] = 0;
		res[1] = 0;
		boolean found = false;
		for(int i = 0 ; i < nodesMat[crtX][crtY].length && !found; i+=1){
			found = (nodesMat[crtX][crtY][i] == n)
		}
		//test if in another frame
		for(int i = 0; i < nCols && !found; i+=1){
			for(int j = 0; j < nRows && !found; j+=1){
				for(int k = 0 ; k < nodesMat[i][j].length && !found; k+=1){
					if (nodesMat[i][j][k] == n){
						found = true;
						res[0]= (i-crtX)*frame_size_x;
						res[1]= (j-crtY)*frame_size_y;
					}
				}
			}
		}
		return res;
	}

	void addRoad(Node a, Node b, int speedLimit,String name){
		Road r = new Road(a,b,speedLimit,name);
		double[] shifts = getAbsolutePos(b);
		r.shiftEnd(shifts[0],shifts[1]);
		
		a.addRoad(r,b);
		
	}
}
