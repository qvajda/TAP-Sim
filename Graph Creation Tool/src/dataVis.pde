//for data visualization

boolean hasRoadsStats;
int maxDay;
double vis_time;
boolean vis_playing;
double vis_speed;//nb of minutes for every second of play

int giant_fontSize = floor(size_y/8);
int big_fontSize = floor(size_y/18);

Button[] vis_buttons;
int PLAY_PAUSE = 6;
int SPEED_UP = 7;
int SPEED_DOWN = 8;
int NXT_DAY = 9;
int PREV_DAY = 10;

double[] speeds = new int[12];
speeds[0] = 1/60;speeds[1] = 5/60;speeds[2] = 0.25;speeds[3] = 0.5;
speeds[4] = 1;speeds[5] = 2;speeds[6] = 3;speeds[7] = 5;speeds[8] = 10;speeds[9] = 15;speeds[10] = 20;speeds[11] = 30;speeds[12] = 45;speeds[13] = 60;speeds[14] = 90;speeds[15] = 120;
int speedI;

myColor col_visUI_grey = new myColor(0,0,0,90,1);

void setHasRoadsStats(boolean val){
	hasRoadsStats = val;
	if(val){
		maxDay = 0;
		deselectAll();
		selectedButton = buttons[0];//selection tool
		selectedButton.select();
		
		day_time = 0;
		vis_speed = 1;
		speedI = 4;
		vis_time = 0;
		vis_playing = true;
	
		vis_buttons = new Button[5];
		vis_buttons[0] = new Button(margin-20,margin,20,giant_fontSize,"<",PREV_DAY,col_trans,col_trans,col_trans);
		vis_buttons[1] = new Button(margin+(3*giant_fontSize),margin,20,giant_fontSize,">",NXT_DAY,col_trans,col_trans,col_trans);
		vis_buttons[2] = new Button(margin/2,size_y-(2*margin),20,margin,"<<",SPEED_DOWN,col_trans,col_trans,col_trans);
		vis_buttons[3] = new Button(0,0,20,margin,"||",PLAY_PAUSE,col_trans,col_trans,col_trans);
		vis_buttons[3].moveToRel(vis_buttons[2],DIR_RIGHT);
		vis_buttons[4] = new Button(0,0,20,margin,">>",SPEED_UP,col_trans,col_trans,col_trans);
		vis_buttons[4].moveToRel(vis_buttons[3],DIR_RIGHT);
		
		col_map_cap.addMapping(col_trans, 0);
		col_map_cap.addMapping(col_green, 0.2);
		col_map_cap.addMapping(col_oliv, 0.4);
		col_map_cap.addMapping(col_yelo, 0.6);
		col_map_cap.addMapping(col_orng, 0.8);
		col_map_cap.addMapping(col_red, 1);
		col_map_cap.addMapping(col_dark_red, 1.2);
		col_map_cap.addMapping(col_black, 1.4);

		col_map_tt.addMapping(col_trans, 0);
		col_map_tt.addMapping(col_green, 0.3);
		col_map_tt.addMapping(col_oliv, 0.5);
		col_map_tt.addMapping(col_yelo, 0.7);
		col_map_tt.addMapping(col_orng, 0.9);
		col_map_tt.addMapping(col_red, 1.4);
		col_map_tt.addMapping(col_dark_red, 2);
		col_map_tt.addMapping(col_black, 3);
	}
}

Road addRoadInfos(int startId, int endId, double capacity, double lt, int rId){
	Road r = nodes[startId].getRoadTo(nodes[endId]);
	r.addStats(capacity,lt,rId);
	return r;
}

void vis_updateRoads(){
	for(int i = 0;i<nodes.length;i+=1){
		for(int rId = 0 ; rId < nodes[i].roads.length ; rId+=1){
			nodes[i].roads[rId].goTo(vis_time);
		}
	}
}

String timeToStr(double t){
	int hours = floor(t);
	int mins = round((t-hours)*60);
	int secs = round((((t-hours)*60)-mins)*60);
	if(secs<0){
		mins-=1;
		secs +=60;
	}
	return hours+":"+mins+":" +secs;
}

void vis_draw(){
	if(hasRoadsStats){
		if(vis_playing && frameCount%fps == 0){
			vis_time += vis_speed/60;
			if(vis_time>(maxDay*24)){
				vis_time = (maxDay*24)-(1/3600);//23h59m59s on the last day
				vis_playing = false;
			}
			vis_updateRoads();
		}
		col_visUI_grey.doFill();
		//draw day indicator
		textSize(giant_fontSize);
		text("DAY "+floor(vis_time/24),margin,margin+giant_fontSize);
		textSize(big_fontSize);
		
		//draw time, speed
		double day_time = vis_time%24;
		String s = timeToStr(day_time) + " \t+";
		if(vis_speed>=1){
			s+=floor(vis_speed) + "m/s";
		}else{
			s+= floor(60*vis_speed)+"s/s";
		}
		text(s,margin/2,size_y-(2*margin));
		textSize(fontSize);

		//draw next/previous day, speed-up/down & pause buttons
		if(vis_time<(maxDay-1)*24){
			vis_buttons[1].draw();
		}
		if(vis_time>=24){
			vis_buttons[0].draw();
		}
		for(int i = 2 ; i < vis_buttons.length ; i+=1){
			vis_buttons[i].draw();
		}

		//draw  timeline & "slider"
		double split = (day_time/24)*size_x;
		col_visUI_grey.set();
		col_shaded_red.doFill();
		rect(0,size_y-margin,split,margin);
		col_light_grey.doFill();
		rect(split,size_y-margin,size_x-split,margin);
		col_thick_grey.set();
		line(split,size_y,split,size_y-margin-2);
		
		if(mouseY>=size_y-margin){
			col_visUI_grey.set();
			col_visUI_grey.doFill();
			line(mouseX,size_y,mouseX,size_y-margin);
			text(timeToStr((mouseX/size_x)*24),mouseX-10,size_y-margin-3);
		}
	}
}

void vis_mouseClicked(){
	//check for day change buttons
	//check for speed & pause buttons
	//handle moving slider
	boolean pressedButton = false;
	for(int i = 0 ; i < vis_buttons.length && !pressedButton; i+=1){
		if(vis_buttons[i].isClicked()){
			switch(vis_buttons[i].id){
			case PREV_DAY :
				if(vis_time>=24){
					vis_time = max(0,(floor(vis_time/24)-1)*24);
					vis_updateRoads();
				}
				break;
			case NXT_DAY:
				if(vis_time<(maxDay-1)*24){
					vis_time = (floor(vis_time/24)+1)*24;
					if(vis_time>(maxDay*24)){
						vis_time = (maxDay*24)-(1/3600);//23h59m59s on the last day
						vis_playing = false;
					}
					vis_updateRoads();
				}
				break;
			case PLAY_PAUSE:
				vis_playing = !vis_playing;
				if(vis_playing){
					vis_buttons[3].msg = "||";
				}else{
					vis_buttons[3].msg = "|>";
				}
				break;
			case SPEED_UP:
				speedI = min(speedI+1,speeds.length-1);
				vis_speed = speeds[speedI];
				break;
			case SPEED_DOWN:
				speedI = max(speedI-1,0);
				vis_speed = speeds[speedI];
				break;
			}
			pressedButton = true;
		}
	}
	if(!pressedButton && mouseY>=size_y-margin){
		vis_time = ((mouseX/size_x) + floor(vis_time/24))*24 ;
		vis_updateRoads();
	}
}

void vis_mouseMoved(){
	for(int i = 0 ; i < vis_buttons.length; i+=1){
		vis_buttons[i].mouseMoved();
	}
}

void vis_keyReleased(){
	switch (keyCode){
		case UP:
			break;
		case DOWN:
			break;
		case LEFT:
			if(shiftHeld){
				if(vis_time>=24){
					vis_time = max(0,(floor(vis_time/24)-1)*24);
					vis_updateRoads();
				}
			}else{
				speedI = max(speedI-1,0);
				vis_speed = speeds[speedI];
			}
			break;
		case RIGHT:
			if(shiftHeld){
				if(vis_time<maxDay*23){
					vis_time = (floor(vis_time/24)+1)*24;
					if(vis_time>(maxDay*24)){
						vis_time = (maxDay*24)-(1/3600);//23h59m59s on the last day
						vis_playing = false;
					}
					vis_updateRoads();
				}
			}else{
				speedI = min(speedI+1,speeds.length-1);
				vis_speed = speeds[speedI];
			}
			break;
		case SHIFT:
			shiftHeld = false;
			break;
		case 32:
			vis_playing = !vis_playing;
			if(vis_playing){
				vis_buttons[3].msg = "||";
			}else{
				vis_buttons[3].msg = "|>";
			}
			break;
	}

}
