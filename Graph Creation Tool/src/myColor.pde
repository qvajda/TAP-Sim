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
