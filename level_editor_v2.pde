import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;  //TODO: are all of these really necessary?


// String levelname = "0.lvl";
String levelname = "0.txt";
String thisPath = "C:\\Users\\Ross\\Documents\\Programming\\random processing things\\level_editor_v2\\";

boolean cameraControl = true;

int selectedTile = 0;

boolean controlC = false;
int[][] controlCArray;

LevelViewer lvl;
//TODO eventually set up a main.pde file that runs either code from level_editor.pde or game.pde (can't have conflicting setup and draw functions)

void setup() {
	size(640, 320);
	frameRate(60);
	
	colorMode(HSB);
	
	readLevel(levelname);
	
	tilesetImage = loadImage("./data/tileset1.png");
	tileset = getTileset(tilesetImage);
	
	characterImage = loadImage("./data/3x5Text.png");
	//characters = getCharacters(characterImage);
	//printCurrentLevelRepresentation();
	
	//TODO: scrollable
	Menu tileButtons = new ScrollableMenu(DEFAULT_SEP, DEFAULT_SEP, TILE_MENU_WIDTH, TILE_MENU_HEIGHT * 6, TILE_MENU_WIDTH, (TILE_MENU_HEIGHT - DEFAULT_SEP) * NTILES, false);
	//tileButton t = new tileButton(tileButtons.xpos, tileButtons.ypos, TILE_MENU_WIDTH, TILE_MENU_HEIGHT, 0, tileButtons);
	//System.out.println(TILE_MENU_HEIGHT * NTILES);
	
	//make a tile button for each tile
	for (int tile = 0; tile < NTILES; tile ++){
		tileButton t = new tileButton(tileButtons.xpos, tileButtons.ypos + tile * (TILE_MENU_HEIGHT - DEFAULT_SEP), TILE_MENU_WIDTH, TILE_MENU_HEIGHT, tile, tileButtons);
	}
	
	Menu tiles = new Menu(tileButtons.xpos + tileButtons.xSize + DEFAULT_SEP,DEFAULT_SEP, tileSize * TILE_VIEWER_WIDTH, tileSize * TILE_VIEWER_HEIGHT, false);
	lvl = new LevelViewer(DEFAULT_SEP,DEFAULT_SEP, tiles.xSize - DEFAULT_SEP, tiles.ySize - DEFAULT_SEP, currentLevel, tiles);
	
	
	//writeLevel(levelname);
}

void draw() {
	
	background(backgroundColor);
	
	cameraControl = lvl.mouseOver;
	
	for (int menuIter = 0; menuIter < menuList.size(); menuIter ++) {
		menuItem current = menuList.get(menuIter);
		current.drawM();
		if ((current.mouseOver) && (mousePressed)) {
			current.continousClick();
		}
	}
	
	if (changeList.size() > MAX_CHANGES) {
		changeList.remove(changeList.get(0));
	}
}

void keyPressed() {
	if (key == CODED) {
		if (cameraControl) {
			if (keyCode == LEFT) {
				if (lvl.cameraX > cameraXmin) {
					lvl.cameraX -= tileSize;
				}
			}
			if (keyCode == UP) {
				if (lvl.cameraY > cameraYmin) {
					lvl.cameraY -= tileSize;
				}
			}
			if (keyCode == RIGHT) {
				if (lvl.cameraX < cameraXmax) {
					lvl.cameraX += tileSize;
				}
			}
			if (keyCode == DOWN) {
				lvl.cameraY += tileSize;
				if (lvl.cameraX < cameraYmax) {
				}
			}
		}
	}
	else {
		//TODO: the keycode for an ascii character is the decimal ascii number associated with that character so == (int)'z' should work
		// control + z
		if (keyCode == 90) {
			if ((keysDown[CONTROL]) && (changeList.size() > 0)){
				//System.out.println("ctrl + z pressed");
				changeList.get(changeList.size() - 1).undo();
			}
		}
		//control + c
		if (keyCode == 67) {
			if ((keysDown[CONTROL]) && (lvl.shiftSelected)) {
				controlCArray = lvl.shiftTiles.clone();
				controlC = true;
			}
		}
		//control + x
		if (keyCode == 88) {
			if ((keysDown[CONTROL]) && (lvl.shiftSelected)) {
			
				
				controlCArray = lvl.shiftTiles.clone();
				//TODO: shiftX and shiftY are not correct
				lvl.setArea(lvl.shiftLayer, lvl.shiftX, lvl.shiftY, lvl.shiftTiles[0].length, lvl.shiftTiles.length, 0);
				controlC = true;
				
			}
		}
		//control + v
		if (keyCode == 86) {
			if ((keysDown[CONTROL]) && (controlC)) {
				
				lvl.areaCopy(controlCArray);
			}
		}
		
	}
	
	keysDown[keyCode] = true;
	//TODO: ctrl + z
}

void keyReleased() {
	keysDown[keyCode] = false;
	
}


//TODO: during draw if mousePressed or something so you can click and drag
void mousePressed() {
	//get the lowest level of menu item that is selected
	for (int i = 0; i < menuList.size(); i++){
		if (menuList.get(i).mouseOver){
			menuList.get(i).onClick();
			
		}
		
	}
	
}

void mouseWheel(MouseEvent event) {
	float e = event.getCount();
	//System.out.println(e);
	for (int i = 0; i < menuList.size(); i++){
		if ((menuList.get(i).mouseOver) && (menuList.get(i).scrollable)){
			
			menuList.get(i).onScroll(e);	
		}
		
	}
}

/*
	#############################################
	FUNCTIONS - FILE I/O
	#############################################
*/

//TODO store data in a bin file so that it's harder to just access, and faster to access
public void readLevel (String levelname) {
	try {
		String line = null;
		int currentLayer = 0;
		
		//read the text file specified by levelname
		FileReader reader = new FileReader(thisPath + levelname);
		BufferedReader bufferedReader = new BufferedReader(reader);
		
		int lineIter = 0;
		
		System.out.println("read initialized");
		
		while ((line = bufferedReader.readLine()) != null) {
			//why is this a bunch of arrays of 0s when 0.lvl is defined? There's no additional file...
			System.out.println(line);
			if ((line.charAt(0) == '#') && (line.charAt(1) == 'L')){
				//System.out.println("layer");
				if (Character.getNumericValue(line.charAt(2)) <= MAX_LAYERS) {
					System.out.println("layer: " + line.charAt(2));
					currentLayer = Character.getNumericValue(line.charAt(2));
					lineIter = 0;
				}
			}
			//if there's a '#' but not an 'L', we know to skip that line and switch to the next mode
			else if (line.charAt(0) == '#') {
				System.out.println("done with layers");
				break;
			}
			//if there's not '#' then it's a data line
			else {
				//read in csv values using line.split
				String[] splitLine = line.split(",");
				for (int i = 0; i < splitLine.length; i++) {
					currentLevel[currentLayer][lineIter][i] = Integer.parseInt(splitLine[i]);
					// System.out.println(splitLine[i]);
				}
				
				lineIter ++;
			}
		}
		
		System.out.println("done reading file");
		
		bufferedReader.close();
		
	}
	catch(FileNotFoundException ex) {
		System.out.println("File not found: " + levelname);
	}
	catch(IOException ex) {
		System.out.println("Error reading file: " + levelname);
	}
	//write the current level map
	
}

public void writeLevel(String Levelname) {
	//read the current level map to the file levelname
	//TODO what if the file already exists?
	
	try {
		String line = "";
		
		FileWriter writer = new FileWriter(thisPath + "out.txt");
		BufferedWriter bufferedWriter = new BufferedWriter(writer);
		
		for (int l = 0; l < currentLevel.length; l++){
			//write the header of the info to the file
			line += "#L";
			line += Integer.toString(l);
			bufferedWriter.write(line);
			bufferedWriter.newLine();
			line = "";
			
			//write the data of each layer to the file
			for (int y = 0; y < currentLevel[0].length; y++) {
				for (int x = 0; x < currentLevel[0][0].length; x++) {
					line += Integer.toString(currentLevel[l][y][x]);
					line += ",";
				}
				bufferedWriter.write(line);
				bufferedWriter.newLine();
				line = "";
			}
		}
		
		bufferedWriter.close();
	}
	catch(IOException ex) {
		System.out.println("Error writing to file: " + levelname);  
	}
}

//just an output functon to see the current level
//of course java's println function is slow as fuck
public void printCurrentLevelRepresentation() {
	String line = "";
	
	for (int l = 0; l < currentLevel.length; l++){
		System.out.println("LAYER " + Integer.toString(l));
		for (int y = 0; y < currentLevel[0].length; y++){
			for (int x = 0; x < currentLevel[0][0].length; x++){
				line += Integer.toString(currentLevel[l][y][x]);
				line += ",";
			}
			System.out.println(line);
			line = "";
		}
	}
}	