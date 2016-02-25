//imports?

int MAX_LAYERS 	= 5;
int MAX_WIDTH 	= 1024;
int MAX_HEIGHT 	= 1024;

//in px
int DEFAULT_SEP 		= 10;	//the default separation between menu "things"
int TILE_MENU_WIDTH 	= 50;
int TILE_MENU_HEIGHT 	= 30;

//in tiles
int TILE_VIEWER_WIDTH	= 20;
int TILE_VIEWER_HEIGHT	= 10;

int MAX_CHANGES = 20;

int MAX_KEYS = 500;

int [][][] currentLevel = new int[MAX_LAYERS][MAX_HEIGHT][MAX_WIDTH];

boolean[] keysDown = new boolean[MAX_KEYS];


//Global Lists
ArrayList<Entity> entityList = new ArrayList<Entity>();
ArrayList<Animated> animList = new ArrayList<Animated>();
ArrayList<Creature> creatureList = new ArrayList<Creature>();
ArrayList<Menu> menuList = new ArrayList<Menu>();
ArrayList<Change> changeList = new ArrayList<Change>();

PImage tilesetImage;
PImage[] tileset;

PImage characterImage;
PImage[] characters;

float OFFSET = 0.01;

int tileSize = 16;
int NTILES = 30;

int CHARACTER_HEIGHT = 5;
int CHARACTER_WIDTH = 3;

//CAMERA VARIABLES
int cameraX = 0;
int cameraY = 0;

int cameraXmin = 0;
int cameraYmin = 0;

int cameraXmax = MAX_WIDTH * tileSize;
int cameraYmax = MAX_HEIGHT * tileSize;


//COLORS
color alphaOnly = color(0,0,0,0);
color backgroundColor = color(200, 200, 200, 255);
color selectColor = color(255, 0, 0, 255);


//Menu Colors
/*
//HSL
color baseMenuColor = color(210, 130, 100, 255);
color mouseMenuColor = color(210, 130, 130, 255);
color selectMenuColor = color(210, 130, 170, 255);
color selectMouseMenuColor = color(210, 130, 200, 255);
*/

//RGB
color menuBorderColor = color(29,79,131,255);
color baseMenuColor = color(49, 99, 151, 255);
color mouseMenuColor = color(66, 129, 194, 255);
color selectMenuColor = color(127, 169, 213, 255);
color selectMouseMenuColor = color(172, 199, 228, 255);

//TODO player should have its own class
Creature player;