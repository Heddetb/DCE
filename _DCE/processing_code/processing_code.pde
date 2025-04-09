import nl.tue.id.oocsi.*;
import ddf.minim.*;
import java.util.ArrayList;
import processing.core.PVector;
import javax.swing.JOptionPane;

OOCSI oocsi = new OOCSI(this, "helloo", "oocsi.id.tue.nl"); // Change "helloo" to an original name

Minim minim;
AudioPlayer chopSound, pickaxeSound, rockSound;

// Scene Management
int scene = 1; // 1 = Trees, 2 = Wall, 3 = Flower, 4= Maze

// Tree Variables
int numTrees = 6;
float[] treeAngles = new float[numTrees];
boolean allTreesFallen = false;
int chopCount = 0;

// Wall Variables
boolean wallCollapsed = false;
ArrayList<PVector> fallingRocks = new ArrayList<>();
int rocksFallen = 0;
int wallHits = 0;
int requiredWallHits = 5; // Increase difficulty
boolean collapseStarted = false;

// Flower Variables
int waterCount = 0;
boolean flowerGrown = false;
String message = "";
float flowerHeight = 0;
boolean growing = false;
ArrayList<PVector> raindrops = new ArrayList<>();
int requiredWaterings = 4;

// Gyro Variables
float gyroThreshold = 2.0; // Detect movement
float previousGyroValue = 0;

// PLAYER MOVEMENT 
float d1 = 0, d2 = 0, d3 = 0; // Variables for OOCSI input
int finish = 0; // Track when the player finishes the maze

boolean up, down, left, right;
int playersDirection = 0; // 0 = right, 1 = left, 2 = up, 3 = down

int mazeSize = 56; //56x56 maze - Make sure this number and the number of rows & columns in tab "MAZE GRID" are the same
int cellSize = 15; // Square size for an individual cell in the grid - Increasing/decreasing changes the maze size
int ballSize = cellSize * 3; // Ball is the size of x number of cells

float playerX, playerY;  // Player's position (changed to float for smooth movement)
float speed = 10; // Move 2 pixels per frame

color backGr = #4fAC58;   //green (grass) 
color mazeWall = #6B7278;  // gray (rocks) 

PImage playerImage; // Declare a variable to hold the player image
PImage asteroidImage; // Declare a variable to hold the asteroid image

float asteroidY = -100; // Initial Y position of the asteroid
float asteroidX ; // Initial X position of the asteroid

float fallSpeed; // Speed at which the asteroid falls
int[][] maze = { 
// 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56 
  {1,1,1,1,1,1,1,1,1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, //1
  {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //2
  {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //3
  {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //4
  {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //5
  {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //6
  {0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //7
  {1,1,1,1,1,1,1,1,1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1}, //8
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //9
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //10
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //11
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //12
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //13
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //14
  {1,0,0,0,0,0,0,1,1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //15
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //16
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //17
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //18
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //19
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //20
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //21
  {1,0,0,0,0,0,0,1,1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1}, //22
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //23
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //24
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //25
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //26
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //27
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //18
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, //29
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //30
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //31
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //32
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //33
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //34
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //35
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //36
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //37
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //38
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //39
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //40
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //41
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}, //42
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0}, //43
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0}, //44
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0}, //45
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0}, //46
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0}, //47
  {1,0,0,0,0,0,0,1,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0}, //48
  {1,0,0,0,0,0,0,1,1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, //49
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //50
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //51
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //52
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //53
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //54
  {1,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, //55
  {1,1,1,1,1,1,1,1,1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, //56
  

};


void setup() {
  size(2000, 1100);
  minim = new Minim(this);
  chopSound = minim.loadFile("chop.mp3");
  pickaxeSound = minim.loadFile("pickaxe.mp3");
  rockSound = minim.loadFile("rock.mp3");
  background(200, 200, 255);
  drawGround();
  
    // Initialize player position
  playerX = cellSize * 4;
  playerY = cellSize * 4 - 10;

  // Load images
  playerImage = loadImage("players.png");
  asteroidImage = loadImage("asteroid flame 2.png");

  // Position the asteroid towards the right
  asteroidX = width - asteroidImage.width * 0.67;
  
  // Calculate asteroid fall speed
  fallSpeed = (height + asteroidImage.height * 0.005) / 1500.0;
  
  // Initialize OOCSI
  oocsi = new OOCSI(this, "rece*verName", "oocsi.id.tue.nl");
  oocsi.subscribe("DCE2025/team-11", "handler");
}

void draw() {
  background(200, 200, 255); // Redraw the background to clear previous frames
  drawGround();
  drawRaindrops();
  
  if (scene == 1) {
    drawTrees();
  } else if (scene == 2) {
    drawWall();
  } else if (scene == 3) {
    drawFlowerScene();
  } else if (scene == 4) {
    drawMaze();
    movePlayer(); // Handles movement
  background(backGr); 
  
  // Implementing functions
  drawMaze();
  movePlayer();
  position();
  
  // Draw the falling asteroid
  drawFallingAsteroid();
}
}
void drawTrees() {
  for (int i = 0; i < numTrees; i++) {
    pushMatrix();
    translate(width / (numTrees + 1) * (i + 1), height - 100);
    rotate(treeAngles[i]);
    drawTree(0, 0);
    popMatrix();
    
    if (allTreesFallen && treeAngles[i] > -HALF_PI) {
      treeAngles[i] -= 0.02;
    }
  }
  
  if (allTreesFallen && treeAngles[numTrees - 1] <= -HALF_PI) {
    delay(1000);
    scene = 2;
    resetGyroState();
  }
}

void drawTree(float x, float y) {
  stroke(100, 50, 0);
  strokeWeight(10);
  line(x, y, x, y - 150);
  fill(34, 139, 34);
  ellipse(x, y - 170, 100, 100);
}

void drawWall() {
  background(120, 120, 120);
  drawFallingRocks();
  
  if (wallCollapsed && !collapseStarted) {
    collapseStarted = true;
    rockSound.rewind();
    rockSound.play();
    
    // Spawn extra rocks when collapse starts
    for (int i = 0; i < 100; i++) {
      fallingRocks.add(new PVector(random(width), random(height / 2)));
    }
  }
  
  if (collapseStarted && fallingRocks.size() > 0) {
    for (PVector rock : fallingRocks) {
      rock.y += random(2, 5);
    }
  }
  
  if (collapseStarted && !rockSound.isPlaying()) {
    delay(1000);
    scene = 3;
    resetGyroState();
  }
}

void drawFallingRocks() {
  fill(60);
  for (PVector rock : fallingRocks) {
    ellipse(rock.x, rock.y, 50, 50);
    rock.y += 2;
  }
}

void drawFlowerScene() {
  if (growing) {
    growFlower();
  }
  
  drawRaindrops();
  
  if (flowerGrown || growing) {
    drawFlower();
  }
  
  if (flowerGrown) {
    fill(0);
    textSize(100);
    text(message, 100, 100);
  }
}

void drawFlower() {
  fill(34, 139, 34);
  rect(width / 2 - 10, height - 100 - flowerHeight, 20, flowerHeight);

  fill(255, 182, 193);
  noStroke();
  ellipse(width / 2, height - 100 - flowerHeight - 40, 60, 60);
  ellipse(width / 2 - 30, height - 100 - flowerHeight - 20, 60, 60);
  ellipse(width / 2 + 30, height - 100 - flowerHeight - 20, 60, 60);
  ellipse(width / 2 - 20, height - 100 - flowerHeight + 30, 60, 60);
  ellipse(width / 2 + 20, height - 100 - flowerHeight + 30, 60, 60);
  fill(255, 255, 0);
  ellipse(width / 2, height - 100 - flowerHeight, 40, 40);
}

void growFlower() {
  if (flowerHeight < 150) {
    flowerHeight += 1;
  } else {
    growing = false;
    flowerGrown = true;
    message = "A map you hold, a path to find,\n" + 
              "With holes that let the light unwind.\n" + 
              "Align the cross where secrets lay,\n" + 
              "Then press to see what’s on display.";  }
}


void drawRaindrops() {
  fill(0, 0, 255);
  for (PVector drop : raindrops) {
    ellipse(drop.x, drop.y, 20, 20);
  }
}

void drawGround() {
  fill(139, 69, 19);
  rect(0, height - 100, width, 100);
}

void drawMaze() { 
  for (int i = 0; i < mazeSize; i++) {
    for (int j = 0; j < mazeSize; j++) {
      if (maze[i][j] == 1) {
        fill(mazeWall);
        noStroke();
        rect(j * cellSize, i * cellSize, cellSize, cellSize);
      }
    }
  }
}

void drawTrain(float x, float y) {
  float trainWidth = ballSize + 15; 
  float trainHeight = ballSize * 0.645;  

  // Scale the image by 200 times
  float scaledWidth = trainWidth * 15;
  float scaledHeight = trainHeight * 15;
  
  // Display the image of the player (train) at the given x, y coordinates with scaling
  image(playerImage, x-420, y -180, scaledWidth, scaledHeight); 
}

void drawFallingAsteroid() {
  float scaledWidth = asteroidImage.width * 0.2;
  float scaledHeight = asteroidImage.height * 0.2;

  // Move asteroid downward
  asteroidY += fallSpeed;
  
  // Reset asteroid & maze if it reaches the bottom
  if (asteroidY > height) {
    asteroidY = 0 - scaledHeight; // Reset to top
    restartMaze(); 
  }
  
  // Display the scaled asteroid image at the updated position
  image(asteroidImage, asteroidX, asteroidY, scaledWidth, scaledHeight);
}

void restartMaze() {
  println("You did not escape the asteroid, try again!"); //happens when players are not fast enough
  
  // Reset the player's position to the starting point
  playerX = cellSize * 4; // Reset playerX to the starting position
  playerY = cellSize * 4 - 10; // Reset playerY to the starting position
  
  // Optionally reset other things like the score or other game elements
}


int lastDetectedTag = 0; 
boolean tagUsed = false; 
void handler(OOCSIEvent event) {
    // Detect tag if not already detected
    if (event.has("tag") && lastDetectedTag == 0) {  
        lastDetectedTag = event.getInt("tag", 0);
        println("Tag detected: " + lastDetectedTag);
    }
    
   // Receive phone movement data
    if (event.has("phone_d1")) d1 = event.getFloat("phone_d1", 0);
    if (event.has("phone_d2")) d2 = event.getFloat("phone_d2", 0);
    if (event.has("phone_d3")) d3 = event.getFloat("phone_d3", 0);

    println("Received - d1: " + d1 + ", d2: " + d2 + ", d3: " + d3);
    
    // Receive gyroscope data and process interactions
    if (event.has("phone_value")) {  
        float gyroValue = event.getFloat("phone_value", 0);
        println("Gyro value received: " + gyroValue + " with last detected tag: " + lastDetectedTag);

    if (gyroValue > gyroThreshold && previousGyroValue < gyroThreshold) {
       if (scene == 1 && lastDetectedTag == 1) {  
                chopTree();
            } else if (scene == 2 && lastDetectedTag == 2) {  
                processWallHit();
            } else if (scene == 3 && lastDetectedTag == 3) {  
                processWaterFlower();
            }
        }
        previousGyroValue = gyroValue;
    }
}


void chopTree() {
  chopSound.rewind();
  chopSound.play();
  chopCount++;
  if (chopCount == numTrees) {
    allTreesFallen = true;
  }
}

void processWallHit() {
  if (wallHits < requiredWallHits) {
    pickaxeSound.rewind();
    pickaxeSound.play();
    fallingRocks.add(new PVector(random(width), random(height / 2)));
    wallHits++;
  }
  
  if (wallHits >= requiredWallHits) {
    wallCollapsed = true;
  }
}

void processWaterFlower() {
  if (waterCount < requiredWaterings) {
    waterCount++;
    raindrops.add(new PVector(random(width), random(height - 100, height)));
  }
  
  if (waterCount >= requiredWaterings) {
    growing = true;
  }
}

void movePlayer() {
    float nextX = playerX;
    float nextY = playerY;

    if (up) {
        nextY -= speed;
        playersDirection = 2; // Up
    }
    if (down) {
        nextY += speed;
        playersDirection = 3; // Down
    }
    if (left) {
        nextX -= speed;
        playersDirection = 1; // Left
    }
    if (right) {
        nextX += speed;
        playersDirection = 0; // Right
    }

    if (canMove(nextX, nextY)) {
        playerX = nextX;
        playerY = nextY;
    } else {
        println("Blocked movement to (" + nextX + ", " + nextY + ")");
    }

    // Drawing object with correct rotation
    pushMatrix();
    translate(playerX + cellSize / 2, playerY + cellSize / 2);
    rotatePlayers();
    drawTrain(-cellSize / 1.25, -cellSize / 1.3); // Draw the player
    popMatrix();
}

boolean canMove(float x, float y) {
    int playersCells = 4; // Train spans 4 cells
    for (int i = 0; i < playersCells; i++) {
        for (int j = 0; j < playersCells; j++) {
            int checkX = (int) (x / cellSize) + j;
            int checkY = (int) (y / cellSize) + i;

            // Check if player reaches finish area
            if (checkX > 55 && checkY >= 43 && checkY <= 48) {
                finish = 1;
                oocsi.channel("DCE2025/team-11").data("final", finish).send(); // Change to your team number
                JOptionPane.showMessageDialog(null, "Congratulations, you escaped from the asteroid!");
            }

            // Prevent moving out of bounds
            if (checkX < 0 || checkX >= mazeSize || checkY < 0 || checkY >= mazeSize) {
                return false;
            }

            // Prevent walking through walls
            if (maze[checkY][checkX] == 1) {
                return false;
            }
        }
    }
    return true;
}
void rotatePlayers() {
    if (playersDirection == 0) rotate(0);         // Right
    if (playersDirection == 1) rotate(-TWO_PI);   // Left
    if (playersDirection == 2) rotate(-HALF_PI);  // Up
    if (playersDirection == 3) rotate(HALF_PI);   // Down
}
void position() {
    if (d1 >= 0.4) down = true; else down = false;
    if (d1 <= -0.4) up = true; else up = false;
    if (d2 <= -0.4) left = true; else left = false;
    if (d2 >= 0.4) right = true; else right = false;
}


void resetGyroState() {
  previousGyroValue = 0;
  lastDetectedTag = 0; 
}

boolean spacePressed = false;

void keyPressed() {
    if (key == ' ' && !spacePressed) { // Check if spacebar is pressed and not already registered
        if (scene == 3 && flowerGrown) { 
            scene = 4; // Start the maze
        }
        spacePressed = true; // Set flag to prevent multiple triggers
    }
}

void keyReleased() {
    if (key == ' ') {
        spacePressed = false; // Reset flag when spacebar is released
    }
}
