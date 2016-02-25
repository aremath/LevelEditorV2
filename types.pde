import java.io.*;

/*
	#############################################
	GLOBAL VARS
	#############################################
*/


public enum Key {
	CONTROL(17),
	SHIFT(16),
	UP(38),
	DOWN(40),
	LEFT(37),
	RIGHT(39);
	
	private int code;
	private Key(int code) {
		this.code  = code;
	}
	public int getValue() {
		return code;
	}
}



//TODO interface? I don't think I'm ever going to have any plain entity objects
/*
	#############################################
	ENTITY CLASSES
	#############################################
*/

public class Entity {
	String name;
	float xpos;
	float ypos;
	PImage currentFrame; 	//some may display multiple frames in multiple places instead of creating new entities??
	int layer;     		//the graphics layer that the object is in. Things in higher layers get drawn later, on top of the rest. player is in layer #TODO decide 'main' layer number
	String[] images;
	PImage[] frames;		//may eventually use a single image, using extract() to find the right parts of it to animate. i.e.
	// this.currentFrame = get(frame, ....) and have a single frame instead of a list #TODO (maybe)
	
	//TODO: if it's solid, I need a collision box to check collision with
	boolean isSolid; //?
	boolean active;
	
	//activator method?
	
	public Entity(int x, int y) {
		this.xpos = x;
		this.ypos = y;
		entityList.add(this);
	}
	
	//overrides compareTo:
	public int compareTo(Entity e) {
		int out = 0;
		if (e.layer < this.layer)  out = 1;
		if (e.layer > this.layer)  out = -1;
		if (e.layer == this.layer) out = 0;
		return out;
	}
	
	//overrides compare:
	public int compare(Entity e0, Entity e1) {
		return e0.layer - e1.layer;
	}
	
	public void activate () {
		
	}
	
}

//TODO public interface. again probably not going to have any straight animateds
public class Animated extends Entity {
	int state;			//TODO use an enum
	int stateCounter;
	int[] numsArray;	//TODO use an enum
	float xvel;
	float yvel;
	boolean active;  //?? #TODO probably turns off for cutscenes and such.
	//some might have hitboxes?
	
	public Animated(int x, int y) {
		super(x, y);
		this.xvel = 0;
		this.yvel = 0;
		this.isSolid = false;
		animList.add(this);
	}
	
	public void stateFunction () {
		
	}
	
}

public class Creature extends Animated {
	int hitpoints;
	int team;
	//int mass;
	int[] hitbox; //[x,y,w,h] RELATIVE TO THE CREATURES XPOS AND YPOS
	int[] critbox; //[x,y,w,h]	//TODO hitboxes as their own datatype?
	int[] cooldownReference;
	int[] cooldowns;
	boolean isStun;
	boolean isInvuln;
	boolean collides;
	boolean isGravity;
	boolean isGrounded;
	boolean knocked;
	//TODO USE AN ENUM
	// many of the states have to be consistent across all creatures so that an attack (which ostensibly doesn't know anything about the state of the entity it's hitting
	//can send it into the correct state so here are the states:
	/* #NOTE:
		states:
		0 - idle, the entity is doing nothing. most ai-driven things will have idle send them right into some other state.
		1 - damaged, attacks will send things into this state if they have >50% hp
		2 - heavily damaged, "" <50% hp
		3 - dying, things get sent here when they have 0 hp. at the end of this state, the creature gets taken out of all of the relevant lists so it doesn't get iterated through. it might spawn a corpse entity which just sits there.
		4 - in air / falling, when things get thrown into the air by whatever, they'll get sent here. probably, they can initialize attacks while falling, so most things won't send the enemy here.
		5 - walking right
		6 - walking left
		
	*/
	
	public Creature(int x, int y) {
		super(x, y);
		this.hitpoints = 0;
		this.team = 0;
		this.hitbox = new int[4];
		this.critbox = new int[4];
		this.isGrounded = false;
		this.isGravity = true;
		this.knocked = false;
		creatureList.add(this);
	}
	
	//TODO make this actually, you know, work
	public void fixxVel () {
		int nextTile;
		int top;
		int bottom;
		int type;
		top = tileCoord(this.ypos + this.hitbox[1]);
		bottom = tileCoord(this.ypos + this.hitbox[1] + this.hitbox[3]);
		if (this.xvel < 0) {
			nextTile = tileCoord(this.xpos + this.hitbox[0] + this.xvel);
			if (nextTile < 0) {
				this.xvel = 0;
				this.xpos = tileSize * (nextTile) - this.hitbox[0] + OFFSET;
			}
			else {
				for (int y = top; y <= bottom; y++) {
					type = tileType(currentLevel[2][nextTile][y]);
					if (type == 0) {
						this.xvel = 0;
						this.xpos = tileSize * (nextTile + 1) - this.hitbox[0] + OFFSET;
					}
				}
			}
		}
		else if (this.xvel > 0) {
			nextTile = tileCoord(this.xpos + this.hitbox[0] + this.hitbox[2] + this.xvel);
			if (nextTile >= currentLevel.length) {
				this.xvel = 0;
				this.xpos = tileSize * nextTile - this.hitbox[0] - this.hitbox[2] - OFFSET;
			}
			else {
				for (int y = top; y <= bottom; y++) {
					//TODO currentLevel[2] is arbitrary
					type = tileType(currentLevel[2][nextTile][y]);
					if (type == 0) {
						this.xvel = 0;
						this.xpos = tileSize * nextTile - this.hitbox[0] - this.hitbox[2] - OFFSET;
					}
				}
			}
		}  
	}
	
	public void fixyVel () {
		int nextTile;
		int left;
		int right;
		int type;
		left = tileCoord(this.xpos + this.hitbox[0]);
		right = tileCoord(this.xpos + this.hitbox[0] + this.hitbox[2]);
		if (this.yvel < 0) {
			nextTile = tileCoord(this.ypos + this.hitbox[1] + this.yvel);
			for (int x = left; x <= right; x++) {
				type = tileType(currentLevel[2][x][nextTile]);
				if (type == 0) {
					this.yvel = 0;
					this.ypos = tileSize * nextTile - this.hitbox[1] + OFFSET;
				}
			}
		}
		else if (this.yvel > 0) {
			nextTile = tileCoord(this.ypos + this.hitbox[1] + this.hitbox[3] + this.yvel);
			for (int x = left; x <= right; x++) {
				type = tileType(currentLevel[2][x][nextTile]);
				if (type == 0) {
					this.yvel = 0;
					this.isGrounded = true;  //#TODO: check grounded somewhere else
					this.ypos = tileSize * nextTile - this.hitbox[1] - this.hitbox[3] - OFFSET;
				}
			}
		}  
	}
	
	public void fixVel () {
		//TODO if this.colllides?
		this.fixxVel();
		this.fixyVel();
	}
	
	
	
	
}

/*
	#############################################
	FUNCTIONS - ENTITIES
	#############################################
*/

public float getDist(Entity e1, Entity e2) {
	double d = Math.pow(Math.pow(e2.xpos - e1.xpos,2) + Math.pow(e2.ypos - e1.ypos,2),0.5);
	return (float)d;
}

//better since the middle of the hitbox is more likely to be relevant for determining position
public float getDist(float x1, float y1, float x2, float y2) {
	double d = Math.pow(Math.pow(x2 - x1,2) + Math.pow(y2 - y1,2),0.5);
	return (float)d;
}

//getHitBox
//returns an arraylist of two arraylists. the first is a list of the creatures whose hitboxes intersect the
//rectangle defined by x,y starting positions, and width and height
//the second is a list of creatures whose critboxes intersect this rectangle
public ArrayList<ArrayList<Creature>> getHitBox(int x, int y, int w, int h) {
	
	ArrayList<Creature> hit = new ArrayList<Creature>();
	ArrayList<Creature> crit = new ArrayList<Creature>();
	for (int i = 0; i < creatureList.size(); i++) {
		Creature currentCreature = creatureList.get(i);
		if ((x + w < currentCreature.xpos + currentCreature.hitbox[0])
		|| (currentCreature.xpos + currentCreature.hitbox[0] + currentCreature.hitbox[2] < x) 
		|| (y + h < currentCreature.ypos + currentCreature.hitbox[1]) 
		|| (currentCreature.ypos + currentCreature.hitbox[1] + currentCreature.hitbox[3] < y)) {
			
		}
		//#TODO fix this to a 'not' if statement.
		else {
			hit.add(currentCreature);
		}
		
		if ((x + w < currentCreature.xpos + currentCreature.critbox[0])
		|| (currentCreature.xpos + currentCreature.critbox[0] + currentCreature.critbox[2] < x) 
		|| (y + h < currentCreature.ypos + currentCreature.critbox[1]) 
		|| (currentCreature.ypos + currentCreature.critbox[1] + currentCreature.critbox[3] < y)) {
			
		}
		//#TODO fix this to a 'not' if statement.
		else {
			crit.add(currentCreature);
		}
		
	}
	
	ArrayList<ArrayList<Creature>> out = new ArrayList<ArrayList<Creature>>();
	out.add(hit);
	out.add(crit);
	return out;
}

//getHitLine
public ArrayList<ArrayList<Creature>> getHitLine(int x1, int y1, int x2, int y2) {
	ArrayList<Creature> hit = new ArrayList<Creature>();
	ArrayList<Creature> crit = new ArrayList<Creature>();
	for (int i=0; i<creatureList.size(); i++) {
		Creature currentCreature = creatureList.get(i);
		if ((lineIntersectsLine(x1, y1, x2, y2,
		(int)currentCreature.xpos + (int)currentCreature.hitbox[0], 
		(int)currentCreature.ypos + (int)currentCreature.hitbox[1], 
		(int)currentCreature.xpos + (int)currentCreature.hitbox[0] + (int)currentCreature.hitbox[2], 
		(int)currentCreature.ypos + (int)currentCreature.hitbox[1]))
		||
        (lineIntersectsLine(x1, y1, x2, y2,
		(int)currentCreature.xpos + (int)currentCreature.hitbox[0],
		(int)currentCreature.ypos + (int)currentCreature.hitbox[1],
		(int)currentCreature.xpos + (int)currentCreature.hitbox[0],
		(int)currentCreature.ypos + (int)currentCreature.hitbox[1] + (int)currentCreature.hitbox[3]))
		||
        (lineIntersectsLine(x1, y1, x2, y2,
		(int)currentCreature.xpos + (int)currentCreature.hitbox[0],
		(int)currentCreature.ypos + (int)currentCreature.hitbox[1] + (int)currentCreature.hitbox[3],
		(int)currentCreature.xpos + (int)currentCreature.hitbox[0] + (int)currentCreature.hitbox[2],
		(int)currentCreature.ypos + (int)currentCreature.hitbox[1] + (int)currentCreature.hitbox[3]))
		||
        (lineIntersectsLine(x1, y1, x2, y2,
		(int)currentCreature.xpos + (int)currentCreature.hitbox[0] + (int)currentCreature.hitbox[2],
		(int)currentCreature.ypos + (int)currentCreature.hitbox[1],
		(int)currentCreature.xpos + (int)currentCreature.hitbox[0] + (int)currentCreature.hitbox[2],
		(int)currentCreature.ypos + (int)currentCreature.hitbox[1] + (int)currentCreature.hitbox[3]))) {
			hit.add(currentCreature);
		}
		
		if ((lineIntersectsLine(x1, y1, x2, y2,
		(int)currentCreature.xpos + (int)currentCreature.critbox[0], 
		(int)currentCreature.ypos + (int)currentCreature.critbox[1], 
		(int)currentCreature.xpos + (int)currentCreature.critbox[0] + (int)currentCreature.critbox[2], 
		(int)currentCreature.ypos + (int)currentCreature.critbox[1]))
		||
        (lineIntersectsLine(x1, y1, x2, y2,
		(int)currentCreature.xpos + (int)currentCreature.critbox[0],
		(int)currentCreature.ypos + (int)currentCreature.critbox[1],
		(int)currentCreature.xpos + (int)currentCreature.critbox[0],
		(int)currentCreature.ypos + (int)currentCreature.critbox[1] + (int)currentCreature.critbox[3]))
		||
        (lineIntersectsLine(x1, y1, x2, y2,
		(int)currentCreature.xpos + (int)currentCreature.critbox[0],
		(int)currentCreature.ypos + (int)currentCreature.critbox[1] + (int)currentCreature.critbox[3],
		(int)currentCreature.xpos + (int)currentCreature.critbox[0] + (int)currentCreature.critbox[2],
		(int)currentCreature.ypos + (int)currentCreature.critbox[1] + (int)currentCreature.critbox[3]))
		||
        (lineIntersectsLine(x1, y1, x2, y2,
		(int)currentCreature.xpos + (int)currentCreature.critbox[0] + (int)currentCreature.critbox[2],
		(int)currentCreature.ypos + (int)currentCreature.critbox[1],
		(int)currentCreature.xpos + (int)currentCreature.critbox[0] + (int)currentCreature.critbox[2],
		(int)currentCreature.ypos + (int)currentCreature.critbox[1] + (int)currentCreature.critbox[3]))) {  
			crit.add(currentCreature);
		}
	}
	ArrayList<ArrayList<Creature>> out = new ArrayList<ArrayList<Creature>>();
	out.add(hit);
	out.add(crit);
	return out;
}

//getHitCircle
//returns an arraylist of creatures hit and crit by a circle with radius r at x, y
//I think right now this is actually a RECTANGLE #TODO
public ArrayList<ArrayList<Creature>> getHitCircle(int r, int x, int y) {
	ArrayList<Creature> hit = new ArrayList<Creature>();
	ArrayList<Creature> crit = new ArrayList<Creature>();
	for (int i = 0; i < creatureList.size(); i++) {
		Creature currentCreature = creatureList.get(i);
		int top = y - r;
		int bottom = y + r;
		int right = x + r;
		int left = x - r;
		if (((top < currentCreature.hitbox[1] + currentCreature. hitbox[3]) || (bottom > currentCreature.hitbox[1])) && ((right > currentCreature.hitbox[0]) || (left < currentCreature.hitbox[0] + currentCreature.hitbox[2]))) {
			hit.add(currentCreature);
		}
		if (((top < currentCreature.critbox[1] + currentCreature. critbox[3]) || (bottom > currentCreature.critbox[1])) && ((right > currentCreature.critbox[0]) || (left < currentCreature.critbox[0] + currentCreature.critbox[2]))) {
			crit.add(currentCreature);
		}
	}
	ArrayList<ArrayList<Creature>> out = new ArrayList<ArrayList<Creature>>();
	out.add(hit);
	out.add(crit);
	return out;
} 


//lineIntersectsLine
//determines if the line defined by (x11, y11) (x12, y12)
//intersects the line defined by (x21, y21) (x22, y22)
public boolean lineIntersectsLine (int x11, int y11, int x12, int y12, 
int x21, int y21, int x22, int y22) {
	int q = (y11 - y21) * (x22 - x11) - (x11 - x21) * (y22 - y21);
	int d = (x12 - x11) * (y22 - y21) - (y12 - y11) * (x22 - x21);
	
	if (d == 0) {
		return false;
	}
	
	float r = q/d;
	
	q = (y11 - y21) * (x12 - x11) - (x11 - x21) * (y12 - y11);
	
	float s = q/d;
	
	if ((r < 0) || (r > 1) || (s > 0) || (s > 1)) {
		return false;
	}
	
	return true;
}

//isOnscreen
//tests if an entity is on the screen and thus should be displayed (with a buffer around the edge to ensure smooth transistion)
public boolean isOnscreen (Entity e) {
	if ((e.xpos >= cameraX - 32) && 
	(e.xpos <= cameraX + width + 32) && 
	(e.ypos >= cameraY - 32) && 
	(e.ypos <= cameraY + height + 32)) { //TODO 32 is arbitrary
		return true;
	}
	else {
		return false;
	}
}

//TODO class tile (int physicsType, int artIndex)

/*
	#############################################
	MENU CLASSES
	#############################################
*/

//TODO class menuItem (needs variables so menuItem as an interface just isn't working out)
public abstract class menuItem {
	
	float xpos;
	float ypos;
	float xSize;
	float ySize;
	
	boolean isClicked;
	boolean isSelected;
	boolean mouseOver;
	
	public abstract void drawM();
	
	public abstract void onClick();
	
	public abstract void continousClick();
	
	public float[] relMousePos() {
		float[] out = new float[2];
		if ((mouseX < this.xpos) || (mouseX > this.xpos + this.xSize)) {
			out[0] = -1;
			this.mouseOver = false;
		}
		else {
			out[0] = mouseX - this.xpos;
		}
		
		if ((mouseY < this.ypos) || (mouseY > this.ypos + this.ySize)) {
			out[1] = -1;
			this.mouseOver = false;
		}
		else {
			out[1] = mouseY - this.ypos;
		}
		
		if ((out[0] >= 0) && (out[1] >= 0)) {
			this.mouseOver = true;
		}
		
		return out;
	}
	
	
}

/*
	public class scrollBar extends menuItem {
	int offset;
	ScrollableMenu parent;
	
	public scrollBar(ScrollableMenu p) {
	this.parent = p;
	}
	
	public void drawM() {
	//TODO: something something offset
	
	}
	
	public void onClick() {
	
	}
	}
*/

public class Button extends menuItem {
	
	public Button(float x, float y, float w, float h, Menu p){
		this.xpos = x;
		this.ypos = y;
		this.xSize = w;
		this.ySize = h;
		p.items.add(this);
	}
	
	public void onClick() {
		this.isClicked = true;
	}
	
	public void drawM() {
		//to ensure it's only pressed once per click
		//if this.isClicked && !mousePressed
		//this. isClicked = false;
		//do the thing
	}
	
	public void continousClick() {
		
	}
	
	
}

public class tileButton extends Button {
	
	int tileType;
	
	public tileButton(float x, float y, float w, float h, int t, Menu p){
		super(x, y, w, h, p);
		this.tileType = t;
		
	}
	
	public void drawM() {
		
		if (selectedTile == this.tileType){
			this.isClicked = true;
		}
		else {
			this.isClicked = false;
		}
		
		float pos[] = this.relMousePos();
		//System.out.println("FAILFISH");
		color c = getMenuColor(this.isClicked, this.mouseOver);
		stroke(menuBorderColor);
		fill(c);
		rect(this.xpos, this.ypos, this.xSize, this.ySize, 5, 5, 0, 0);
		
		image(tileset[this.tileType], this.xpos + (this.xSize - tileSize) / 2, this.ypos + (this.ySize - DEFAULT_SEP - tileSize) / 2);
		
	}
	
	public void onClick() {
		//this.isClicked = true;
		selectedTile = this.tileType;
		
	}
	
	public void continousClick() {
		
	}
}

public class TextInputBox extends menuItem {
	
	
	public void drawM() {
		
	}
	
	public void onClick() {
		this.isClicked = true;
	}
	
	public void continousClick() {
		
	}
	
}

public class TextBox extends menuItem {
	
	
	public void drawM() {
		
	}
	
	public void onClick() {
		this.isClicked = true;
	}
	
	public void continousClick() {
		
	}
	
}

public class LevelViewer extends menuItem {
	
	//public Menu parent;
	
	public int[][][] level;
	int cameraX;
	int cameraY;
	
	int selectedLayer;
	int selectedX;
	int selectedY;
	
	int lastClickX = 0;
	int lastClickY = 0;
	
	int shiftX = 0;
	int shiftY = 0;
	
	int shiftLayer;
	
	int[][] shiftTiles;
	
	boolean shiftSelected;
	
	
	public LevelViewer(float x, float y, float w, float h, int[][][] l, Menu p) {
		this.xpos = x + p.xpos;
		this.ypos = y + p.ypos;
		this.xSize = w;
		this.ySize = h;
		this.level = l;
		
		this.selectedLayer = 2;
		
		p.items.add(this);
		//this.parent = p;
		
		
	}
	
	public void drawM() {
		//TODO draw other layers too
		//TODO only partially draw tiles that are at the edge
		//TODO draw a border around the whole thing?
		int[][] tiles = getOnscreenTiles(this.level[2], (int) this.xSize, (int) this.ySize, this.cameraX, this.cameraY);
		PImage tileImage;
		int xoffset = -(this.cameraX % tileSize);
		int yoffset = -(this.cameraY % tileSize);
		for (int y = 0; y < tiles.length; y++) {
			for (int x = 0; x < tiles[0].length; x++) {
				int currentTile = tiles[y][x];
				tileImage = tileset[currentTile];
				image(tileImage, this.xpos + tileSize*(x - 1) + xoffset, this.ypos + tileSize*(y - 1) + yoffset);
			}
		}
		
		drawMouseBox();
	}
	
	public void drawMouseBox () {
		float[] pos = relMousePos();
		//if ((pos[0] >= 0) && (pos[1] >= 0)){
		if (this.mouseOver) {
			this.selectedX = tileCoord(pos[0] + this.cameraX);
			this.selectedY = tileCoord(pos[1] + this.cameraY);
			stroke(selectColor);
			noFill();
			if (keysDown[SHIFT]) {
				int xsize = Math.abs(lastClickX - selectedX) + 1;
				int ysize = Math.abs(lastClickY - selectedY) + 1;
				int xc = min(lastClickX, selectedX);
				int yc = min(lastClickY, selectedY);
				
				//TODO make sure this can't overflow the boundaries
				rect(this.xpos + xc * tileSize - this.cameraX, this.ypos + yc * tileSize - this.cameraY, tileSize * xsize, tileSize * ysize);
			}
			else {
				rect(this.xpos + snapToGrid(pos[0]), this.ypos + snapToGrid(pos[1]), tileSize, tileSize);
			}
			
			
		}
		
		if (this.shiftSelected) {
			
			int xsize = Math.abs(lastClickX - shiftX) + 1;
			int ysize = Math.abs(lastClickY - shiftY) + 1;
			int xc = min(lastClickX, shiftX);
			int yc = min(lastClickY, shiftY);
			
			stroke(selectColor);
			noFill();
			//TODO make sure this can't overflow the boundaries
			rect(this.xpos + xc * tileSize - this.cameraX, this.ypos + yc * tileSize - this.cameraY, tileSize * xsize, tileSize * ysize);
		}
	}
	
	public void onClick () {
		if (keysDown[SHIFT]) {
			
			int xsize = lastClickX - selectedX;
			int ysize = lastClickY - selectedY;
			
			//int xsize = selectedX - lastClickX;
			//int ysize = selectedY - lastClickY;
			
			//you can't make a selection box smaller than 2x2
			//TODO: n x 1 selection boxes
			if ((xsize != 0) && (ysize != 0)) {
				shiftSelected = true;
				
				this.shiftLayer = selectedLayer;
				
				this.shiftX = selectedX;
				this.shiftY = selectedY;
				
				int xsign = xsize / Math.abs(xsize);
				int ysign = ysize / Math.abs(ysize);
				
				xsize = Math.abs(xsize);
				ysize = Math.abs(ysize);
				
				this.shiftTiles = new int[ysize + 1][xsize + 1];
				
				int xcoord;
				int ycoord;
				
				int xstart = 0;
				if (xsign < 0) {
					xstart = this.shiftTiles[0].length - 1;
				}
				
				int ystart = 0;
				if (ysign < 0) {
					ystart = this.shiftTiles.length - 1;
				}
				
				for (int y = 0; y <= ysize; y++)
				{
					for (int x = 0; x <= xsize; x++) {
						
						xcoord = selectedX + x * xsign;
						ycoord = selectedY + y * ysign;
						if ((ycoord > 0) && (xcoord > 0) && (ycoord < this.level[0].length) && (xcoord < this.level[0][0].length)) {
							this.shiftTiles[ystart + y * ysign][xstart + x * xsign] = this.level[this.shiftLayer][ycoord][xcoord];
							//System.out.println(this.shiftTiles[y][x]);
						}
					}
				}
				SelectChange s = new SelectChange(this);
			}
			else {
				this.shiftSelected = false;
			}
		}
	}
	
	public void continousClick() {
		if (keysDown[SHIFT]) {
			
			
		}
		
		else {
			if (mouseButton == LEFT) {
				if (this.level[selectedLayer][selectedY][selectedX] != selectedTile){
					LevelChange c = new LevelChange(this.level[selectedLayer][selectedY][selectedX], selectedTile, selectedLayer, selectedX, selectedY);
					level[selectedLayer][selectedY][selectedX] = selectedTile;
				}
				//TODO if you click outside a shift selected area, it sets shiftSelected to false
				
				if (!shiftSelected) {
					lastClickX = selectedX;
					lastClickY = selectedY;
				}
				
				
			}
			else if (mouseButton == RIGHT) {
				selectedTile = level[selectedLayer][selectedY][selectedX];
				shiftSelected = false;
			}
			
		}
	}
	
	public void areaCopy(int[][] cpy) {
		
		AreaChange a = new AreaChange(cpy[0].length, cpy.length, selectedLayer, selectedX, selectedY);
		
		for (int y = 0; y < cpy.length; y++) {
			for (int x = 0; x < cpy[0].length; x++) {
				
				if ((selectedX + x < this.level[0][0].length) && (selectedY + y < this.level[0].length)) {
					a.prevTiles[y][x] = this.level[selectedLayer][selectedY + y][selectedX + x];
					//System.out.println(a.prevTiles[y][x]);
					this.level[selectedLayer][selectedY + y][selectedX + x] = cpy[y][x];
					//System.out.println(a.prevTiles[y][x]);
					a.changeTiles[y][x] = cpy[y][x];
				}
				
			}
		}
		
	}
	
	//TODO
	public void setArea(int l, int xstart, int ystart, int w, int h, int value) {
		System.out.println("setArea Called");
		System.out.printf("starting from %d,%d, going to %d,%d\n", xstart, ystart, xstart + w, ystart + h);
		System.out.printf("%d, %d", selectedX, selectedY);
		AreaChange a = new AreaChange(w, h, l, xstart, ystart);
		
		for (int y = ystart; y < h; y++) {
			for (int x = xstart; x < w; x++) {
				if ((x < this.level[0][0].length) && (y < this.level[0].length))  {
					a.prevTiles[y][x] = this.level[l][y][x];
					this.level[l][y][x] = value;
					a.changeTiles[y][x] = value;
					
				}
			}
		}
	}
	
}

public class Menu extends menuItem {
	
	//public Menu parent;
	
	boolean visibleBG;
	boolean scrollable;
	
	ArrayList<menuItem> items;
	
	public Menu(float x, float  y, float  w, float  h, boolean bg) {
		this.xpos = x;
		this.ypos = y;
		this.xSize = w;
		this.ySize = h;
		menuList.add(this);
		this.items = new ArrayList<menuItem>();
		this.visibleBG = bg;
		this.scrollable = false;
	}
	
	public void drawM() {
		
		float[] q = relMousePos();
		
		color c = getMenuColor(this.isClicked, this.mouseOver);
		stroke(c);
		
		if (visibleBG){
			fill(c);
		}
		else {
			noFill();
		}
		
		rect(this.xpos, this.ypos, this.xSize, this.ySize);
		
		
		for (int i = 0; i < this.items.size(); i++) {
			this.items.get(i).drawM();	
		}
	}
	
	public void onClick() {
		for (int i = 0; i < this.items.size(); i++){
			//this.items.get(i).isSelected = true;
			//others.isSelected = false;
			
			if (this.items.get(i).mouseOver){
				this.items.get(i).onClick();
				
			}
			
		}
		
	}
	
	public void continousClick() {
		for (int i = 0; i < this.items.size(); i++){
			if (this.items.get(i).mouseOver){
				this.items.get(i).continousClick();
			}	
		}
	}
	
	public void onScroll(float e) {
		
	}
	
}

public class ScrollableMenu extends Menu {
	//scrollBar yScroller;
	//scrollBar xScroller?
	float maxXSize;
	float maxYSize;
	
	float yOffset;
	float newYOffset;
	
	public ScrollableMenu(float x, float  y, float  w, float  h, float maxX, float maxY, boolean bg) {
		super(x, y, w, h, bg);
		this.maxXSize = maxX;
		this.maxYSize = maxY;
		menuList.add(this);
		this.items = new ArrayList<menuItem>();
		//this.yScroller = new scrollBar(this);
		this.scrollable = true;
		this.yOffset = 0;
		this.newYOffset = 0;
	}
	
	public void drawM() {
		
		float[] q = relMousePos();
		
		color c = getMenuColor(this.isClicked, this.mouseOver);
		stroke(c);
		
		if (visibleBG){
			fill(c);
		}
		else {
			noFill();
		}
		
		rect(this.xpos, this.ypos, this.xSize, this.ySize);
		
		menuItem currentItem;
		for (int i = 0; i < this.items.size(); i++) {
			//TODO: instead of actually changing the position, it would be more stable to be able to display them differently
			currentItem = this.items.get(i);
			
			currentItem.ypos -= this.newYOffset;
			if (currentItem.ypos + currentItem.ySize > this.ySize) {
				
			}
			else if (currentItem.ypos < this.ypos) {
				
			}
			else {
				currentItem.drawM();
			}
		}
		this.yOffset += this.newYOffset;
		this.newYOffset = 0;
	}
	
	public void onScroll(float scrollAmount) {
		//TODO: as global int scrollspeed?
		this.newYOffset += 10 * scrollAmount;
		
		//TODO: or scroll velocity then have friction and stuff
		//TODO: this is awful
		//TODO: fix the thing where it shifts when you get to the bottom or the top.
		//TODO: offset per ITEM, then scroll on item per thing
		
		//if the scroll would put the scrollbar above the top	
		if (this.yOffset + this.newYOffset < 0) {
			this.newYOffset = yOffset;
			//System.out.println("can't scroll past the top");
		}
		//if it would put the scrollbar below the bottom
		else if (this.yOffset + this.newYOffset + this.ySize > this.maxYSize) {
			//this.newYOffset = this.maxYSize - this.ySize - this.yOffset;
			this.newYOffset = 0;
			//System.out.println("can't scroll past the bottom");
		}
		
		//System.out.println(this.newYOffset);
		//System.out.println(this.newYOffset);
	}
	
	public void continousClick() {
		for (int i = 0; i < this.items.size(); i++){
			if (this.items.get(i).mouseOver){
				this.items.get(i).continousClick();	
			}	
		}
	}
	
}

//Classes for ctrl + z functionality
public class Change {
	
	public void undo(){
		
	}
	
}


public class LevelChange extends Change {
	
	//TODO keep track of the level that the change was on instead of just doing currentLevel.
	
	int prevTile;
	int changeTile;
	
	//int[][][] layer;
	
	int tileL;
	int tileX;
	int tileY;
	
	public LevelChange(int pt, int ct, int l, int x, int y) {
		this.prevTile = pt;
		this.changeTile = ct;
		this.tileL = l;
		this.tileX = x;
		this.tileY = y;
		
		changeList.add(this);
	}
	
	public void undo() {
		currentLevel[this.tileL][this.tileY][this.tileX] = prevTile;
		changeList.remove(this);
	}
	
	
}

public class SelectChange extends Change {
	LevelViewer viewer;
	
	public SelectChange(LevelViewer l) {
		this.viewer = l;
		changeList.add(this);
	}
	
	public void undo() {
		this.viewer.shiftSelected = false;
		changeList.remove(this);
	}
	
	
}

public class AreaChange extends Change {
	int[][] prevTiles;
	int[][] changeTiles;
	
	//int[][][] layer;
	
	int tileL;
	int tileX;
	int tileY;
	
	
	
	
	public AreaChange(int xsize, int ysize, int l, int x, int y) {
		this.prevTiles = new int[ysize][xsize];
		this.changeTiles = new int[ysize][xsize];
		
		this.tileL = l;
		this.tileX = x;
		this.tileY = y;
		
		changeList.add(this);
	}
	
	public void undo() {
		
		//System.out.println(this.prevTiles.length);
	
		for (int y = 0; y < this.prevTiles.length; y++) {
			for (int x = 0; x < this.prevTiles[0].length; x++) {
				
				//System.out.println(currentLevel.length);
				
				if ((this.tileX + x < currentLevel[0][0].length) && (this.tileY + y < currentLevel[0].length)) {
					//System.out.println(prevTiles[y][x]);
					currentLevel[this.tileL][this.tileY + y][this.tileX + x] = prevTiles[y][x];
				}
				
			}
		}
		
		changeList.remove(this);
		
	}
	
}

/*
	#############################################
	FUNCTIONS - VECTORS
	#############################################
*/


//#TODO
public float getMouseAngle() {
	double theta; //range -pi to pi
	float playerScreenX = player.xpos + player.hitbox[0] + player.hitbox[2]/2 - cameraX;
	float playerScreenY = player.ypos + player.hitbox[1] + player.hitbox[3]/2 - cameraY;
	theta = Math.atan2((double) (mouseX - playerScreenX), (double) (mouseY - playerScreenY));
	return (float)theta;
}


//magnitudeAsVector
//returns a float array of the X and Y components of a vector with magnitude m along the vector [x y]

public float[] magnitudeAsVector(float m, float x, float y) {
	float[] out = new float[2];
	double mag1 = Math.pow(Math.pow(x, 2) + Math.pow(y, 2), 0.5);
	float unitX = x / (float)mag1;
	float unitY = y / (float)mag1;
	out[0] = m*unitX;
	out[1] = m*unitY;
	return out;
}



/*
	#############################################
	FUNCTIONS - TILES
	#############################################
*/


//TODO: general "breakimage(image, height, width)" function

//getTileset
//takes a tileset image, and makes all the tiles in it into separate images and outputs that list in an array.
public PImage[] getTileset (PImage tilesetImage) {
	PImage[] output = new PImage[(tilesetImage.width/tileSize)*(tilesetImage.height/tileSize)];
	int nextEmpty = 1;
	for (int i=0; i<tilesetImage.width/tileSize; i++) {
		for (int j=0; j<tilesetImage.height/tileSize; j++) {
			//output[nextEmpty] = createImage(tileSize, tileSize, ARGB);
			//output[nextEmpty] = get(i*tileSize, j*tileSize, tileSize, tileSize);
			output[nextEmpty] = extract(tilesetImage, i*tileSize, j*tileSize, tileSize, tileSize);
			if (output[nextEmpty] != null){
				nextEmpty++;
			}
			//nextEmpty ++;
		}
	}
	output[0] = blankTile();
	return output;
}

//getCharacters
public PImage[] getCharacters (PImage characterset) {
	PImage[] output = new PImage[(characterImage.width/CHARACTER_WIDTH)*(characterImage.height/CHARACTER_HEIGHT)];
	int nextEmpty = 0;
	for (int i=0; i<characterImage.width/CHARACTER_WIDTH; i++) {
		for (int j=0; j<characterImage.height/CHARACTER_HEIGHT; j++) {
			output[nextEmpty] = extract(characterImage, i*CHARACTER_WIDTH, j*CHARACTER_HEIGHT, CHARACTER_WIDTH, CHARACTER_HEIGHT);
			if (output[nextEmpty] != null){
				nextEmpty++;
			}
		}
	}
	return output;
	
}

//Extract:
// takes a sizey by sizex chunk of a PImage and returns it as a new PImage
public PImage extract (PImage source, int startx, int starty, int sizex, int sizey) {
	boolean isEmpty = true;
	PImage out = createImage(sizex, sizey, ARGB);
	source.loadPixels();
	out.loadPixels();
	for (int x = 0; x < sizex; x++) {
		for (int y = 0; y < sizey; y++) {
			int loc = starty*source.width + startx + y*source.width + x;
			float h = hue(source.pixels[loc]);
			float s = saturation(source.pixels[loc]);
			float b = brightness(source.pixels[loc]);
			float a = alpha(source.pixels[loc]);
			
			//if there's a white pixel, treat it as an empty pixel
			if (b == 255) {
				a = 0;
			}
			//if there's a nonwhite pixel, the tile isn't empty
			else {
				isEmpty = false;
				
			}
			
			int outLoc = y*sizex + x;
			
			out.pixels[outLoc] = color(h, s, b, a);
		}
	}
	if (!isEmpty){
		return out;
	}
	else {
		return null;
	}
}

public PImage blankTile() {
	PImage out = createImage(tileSize, tileSize, ARGB);
	out.loadPixels();
	for (int i = 0; i < out.pixels.length; i++) {
		out.pixels[i] = alphaOnly;
	}
	return out;
}

//getTileID
//returns the integer ID of the tile that is under the x-y coords given
public int getTileID (int l, float x, float y) {
	float normalizedx = x/tileSize;
	float normalizedy = y/tileSize;
	//System.out.println(normalizedx);
	//System.out.println(normalizedy);
	return currentLevel[l][(int)normalizedx][(int)normalizedy];  //make sure it references the right level #TODO
}

public int snapToGrid (float n) {
	n /= tileSize;
	return ((int) n) * tileSize;
}

public int tileCoord (float n) {
	return (int) (((int) n) / tileSize);
}


public int tileType(int id) {
	//0 - solid
	//-1 - not solid
	//1 - downslope
	//2 - upslope
	//maybe more later?
	//TODO use an enum
	return 0;
	/*
		if (java.util.Arrays.binarySearch(solid1, id) >= 0) {
		return 0;
		}
		else {
		return -1;
		}
	*/
}

//returns an int array with the tiletype of the tiles
//[above, right, below, left] of the tile at x,y in levellist
//TODO use an enum
public int[] checkTile(int l, int x, int y) {
	int[] out = new int[4];
	if (y > 0) {
		out[0] = tileType(currentLevel[l][x][y-1]);
	}
	else {
		out[0] = 0;
	}
	if (x < currentLevel.length) {
		out[1] = tileType(currentLevel[l][x+1][y]);
	}
	else {
		out[1] = 0;
	}
	if (y < currentLevel[0].length) {
		out[2] = tileType(currentLevel[l][x][y+1]);
	}
	else {
		out[2] = 0;
	}
	if (x > 0) {
		out[3] = tileType(currentLevel[l][x-1][y]);
	}
	else {
		out[3] = 0;
	}
	return out;
}


//TODO get onscreen tiles takes int width, int height
public int[][] getOnscreenTiles (int[][] l, int w, int h, int camX, int camY) {
	int outWidth = (int)(w/tileSize + 1);
	int outHeight = (int)(h/tileSize + 1);
	
	int camTileX = (int)(camX/tileSize) - 1;
	int camTileY = (int)(camY/tileSize) - 1;
	
	int[][] out = new int[outHeight][outWidth];
	
	/*
		System.out.println(cameraTileX);
		System.out.println(cameraTileY);
		
		System.out.println(outHeight);
		System.out.println(outWidth);
	*/
	
	for (int x = camTileX; x < camTileX + outWidth; x++) {
		for (int y = camTileY; y < camTileY + outHeight; y++) {
			if ((x >= 0) && (y >= 0) && (x < l[0].length) && (y < l.length)) {
				out[y - camTileY][x - camTileX] = l[y][x];
				
			}
			else {
				out[y - camTileY][x - camTileX] = 0;
			}
			
		}
	}
	return out;
}

public color getMenuColor(boolean isClicked, boolean mouseOver) {
	if ((isClicked) && (mouseOver)) {
		return selectMouseMenuColor;
	}
	else if (mouseOver) {
		return mouseMenuColor;
	}
	else if (isClicked) {
		return selectMenuColor;
	}
	else {
		return baseMenuColor;
		
	}
	
}		