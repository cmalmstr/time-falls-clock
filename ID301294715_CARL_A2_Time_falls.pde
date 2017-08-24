/* Visualization of the passing of time as a continous stream ending in a "waterfall". The hour and minute is visible in the stream and hangs on as long as their value is true.
Author: Carl Malmstroem
SFUID:301294715 */
       
                                                             
int streamH = 300;                            //Integer controlling the width of the stream. Shouldn't be less than twice the numsize integer
int pov = 1000;                               //Integer controlling the point of view, higher values results in more perspective. Suggested range 0-1500
float numsize = 15;                           //Controls the size of the numbers and other graphic elements in the stream
int lines = 1000;                             //Controls the number of lines to be drawn and animated in the stream. Too high a value will make the animation stutter
int secs = 20;                                //Sets the number of ticking numbers to be drawn and animated in the stream. Too high a value will make the animation stutter
int depth = 10;                               //Sets the perceived depth of the stream

                                              //Initializing variables to hold information about the hour to be displayed. Used to control its value, position and animation as the spent hour is falling down
float hourX = 0;                              
float hourY = 0;
float hourDeg = 0;
int lasthour = 0;
float lasthourX = 0;
float lasthourY = 0;
float lasthourDeg = 0;
boolean hourFall = false;
                                              //Initializing variables to hold information about the minute to be displayed. Used to control its value, position and animation as the spent minute is falling down
float minx = 0;
float minY = 0;
float minDeg = 0;
int lastmin = 0;
float lastminX = 0;
float lastminY = 0;
float lastminDeg = 0;
boolean minFall = false;
                                              //Initializing variables to hold information about the lines and ticking numbers to be animated. Used to control their values, positions and animation as they fall down
float[] xmax;
int[] secNum = new int[secs];
float[] secX = new float[secs];
float[] secY = new float[secs];  
float[] secDeg = new float[secs];
float[] secSpd = new float[secs];
float[] lineX = new float[lines];
float[] lineY = new float[lines];    
float[] lineSpd = new float[lines];


void setup(){
  size( 1200, 800 );
  
  hourY = newPos();                                    //Getting a randomized starting position from the function written to do so
  hourDeg = newDeg();                                  //Getting a randomized starting degree from the function written to do so
  minY = newPos();                                     //Getting a randomized starting position from the function written to do so
  minDeg = newDeg();                                   //Getting a randomized starting degree from the function written to do so
  
  xmax = new float[height+1];                          //Variable is used to store the end (maximum x-value) of the graphic plane to be drawn (for each value of y)
  float slope = float(pov) / float(height);            //Calculating the slope to be used for the selected point of view
  for( int i=0; i<=height; i++ ){                      //Calculating the end of the plane (x-wise) using the slope and filling the xmax-array    
    xmax[i] = 9*float(width)/10 - i*slope;
  }
  
  for( int i=0; i<lines; i++ ){                        //Generating the attributes of the lines to be drawn using appropriate function calls to generate random positions and speeds
    lineX[i] = random( 0, xmax[height/2]);
    lineY[i] = newPos();
    lineSpd[i] = newSpeed();
  }
  for( int i=0; i<secs; i++ ){                         //Generating the attributes of the ticking numbers to be drawn using appropriate function calls to generate random positions, degrees and speeds
    secX[i] = random( 0, xmax[height/2]);
    secY[i] = newPos();
    secDeg[i] = newDeg();
    secSpd[i] = newSpeed();
    secNum[i] = int(random( 0, 60));                   //The number is not connected to the actual second, but rather a random value within the range
  }
}


void draw(){
  background( 255 );                                                                     //Clearing the background
  
  int drawline = 0;                                                                      //The plane will be drawn using line graphics and this integer is used to count which line to be drawn
  int landmass = (height-streamH) / 2;                                                   //Calculating the height of land to be displayed on each side of the stream, this is dependent on the set stream height
  stroke( 0, 190, 0 );                                                                   //Green color used for the grassy landmass
  for(drawline=0; drawline<=landmass; drawline++ ){                                      //Loops to draw the lines of the uppermost landmass
    line( 0, drawline, xmax[drawline], drawline);                                        //Drawing the lines from left edge of screen to the previously calculated xmax
  }
  stroke( 145, 145, 100 );                                                               //Yellow-ish color to be used on the riverside
  for(drawline=landmass; drawline<=landmass+depth; drawline++ ){                         //Loops to draw the lines for the riverside
    line( 0, drawline, xmax[landmass], drawline);                                        //Drawing the lines from left edge of screen to the xmax of the uppermost edge of the riverside, to create the appearance of depth
  }
  stroke( 120, 190, 230 );                                                               //Blue color to be used for the stream
  for(drawline=landmass+depth; drawline<=landmass+depth+streamH; drawline++ ){           //Loops to draw the lines for the stream
    line( 0, drawline, xmax[drawline-depth], drawline);                                  //Drawing the lines from left edge of screen to the previously calculated xmax (taking into account the offset caused by the depth effect)
  }
  stroke( 0, 190, 0 );                                                                   //Green color used for the grassy landmass
  for(drawline=landmass+streamH; drawline<=height; drawline++ ){                         //Loops to draw the lines of the lowermost landmass
    line( 0, drawline, xmax[drawline], drawline);                                        //Drawing the lines from left edge of screen to the previously calculated xmax
  }
  noStroke();                                                                            //Removing stroke and setting a dark fill color to be used for the drawing of the exposed edge of the plane
  fill( 100, 100, 70 );
  beginShape( POLYGON );                                                                 //Creates a polygon with corners at each point where the plane drawn changes direction
  vertex( xmax[0], 0 );
  vertex( xmax[0]+depth*3, 0 );                                                          //Using depth to set the thickness of the plane
  vertex( xmax[height]+depth*3, height );                                                //Using depth to set the thickness of the plane
  vertex( xmax[height], height );
  vertex( xmax[landmass+streamH], landmass+streamH );
  vertex( xmax[landmass+streamH], landmass+depth+streamH );
  vertex( xmax[landmass], landmass+depth );
  vertex( xmax[landmass], landmass );
  endShape( CLOSE );
  
  for( int i=0; i<lines; i++ ){                                                          //Loop to draw all the moving lines in the stream
    if( lineY[i]<height ){                                                               //Checking that the line hasn't fallen off the screen yet
      if( lineX[i]<xmax[int(lineY[i])] ){                                                //Checking that the line hasn't reached the edge of the plane yet
        drawer( lineX[i], lineY[i], 0, 2 );                                              //Calling the draw-function
        lineX[i] = lineX[i] + lineSpd[i];                                                //Advances the x-position of the line so it will have moved forward for the next draw-loop
        lineY[i] = lineY[i];
      }
      else {                                                                             //This code will be run if the line has reached the edge of the plane but not fallen out of screen yet (ie it's in freefall down the waterfall)
        drawer( lineX[i], lineY[i], random( 60, 100 ), 2 );                              //Draw the line with a random slanting angle downwards
        lineX[i] = lineX[i] + random( -20, 20 );                                         //The x-position is allowed some randomization to make it more organic
        lineY[i] = lineY[i] + lineSpd[i];                                                //Advances the y-position of the line so it will have moved downward for the next draw-loop
      }
    }
    else {                                                                               //This code will be run if the line has fallen out of view
     lineX[i] = 0 ;                                                                      //Resetting the line at the left edge of the screen
     lineY[i] = newPos();                                                                //Generating a new random y-position in the stream
     lineSpd[i] = newSpeed();                                                            //Generating a new random speed for the line
    }
  }
  
  for( int i=0; i<secs; i++ ){                                                           //Loop to draw all the moving ticking numbers in the stream
    if( secY[i]<height ){                                                                //Checking that the number hasn't fallen off the screen yet
      if( secX[i]<xmax[int(secY[i])] ){                                                  //Checking that the number hasn't reached the edge of the plane yet
        drawNum( secNum[i], secX[i], secY[i], secDeg[i], 1.5 );                          //Calling the draw-function, passing on the actual number to be drawn
        secX[i] = secX[i] + secSpd[i];                                                   //Advances the x-position of the number so it will have moved forward for the next draw-loop
        secY[i] = secY[i];
        if( secNum[i]<59 ){                                                              //Checking that the number won't advance out of range for the next iteration
          secNum[i]++;                                                                   //Advancing the actual number to be drawn to make the numbers "tick"
        }
        else {                                                                           //This code will run if the number has reached it's max value
          secNum[i] = 0;                                                                 //Resets the number
        }
      }
      else {                                                                             //This code will be run if the number has reached the edge of the plane but not fallen out of screen yet (ie it's in freefall down the waterfall)                                                                           
        drawNum( secNum[i], secX[i], secY[i], random( 60, 100 ), 1.5 );                  //Draw the number with a random slanting angle downwards
        secX[i] = secX[i] + random( -20, 20 );                                           //The x-position is allowed some randomization to make it more organic
        secY[i] = secY[i] + secSpd[i];                                                   //Advances the y-position of the number so it will have moved downward for the next draw-loop
        if( secNum[i]<59 ){                                                              //The number is still ticking while falling so the iterative loop is present here as well
           secNum[i]++;
        }
        else {
          secNum[i] = 0;
        }
      }
    }
    else {                                                                               //This code will be run if the line has fallen out of view
     secX[i] = 0;                                                                        //Resetting the number at the left edge of the screen
     secY[i] = newPos();                                                                 //Generating a new random y-position in the stream
     secDeg[i] = newDeg();                                                               //Generating a new random degree to be used for drawing the number
     secSpd[i] = newSpeed();                                                             //Generating a new random speed for the number
     secNum[i] = int(random( 0, 60 ));                                                   //Generating a new number value to use
    }
  }  
  
  if( minute() == 59 ){                                                                  //Checking if the current hour is coming to an end (and the hour value will be hanging on the edge of the plane, as its position is dependent on the minute)
    lasthour = hour();                                                                   //Saving the current hour and its attributesto be used for drawing the spent hour in free fall
    lasthourY = hourY;
    lasthourX = xmax[int(lasthourY)];                                                    //X-position is at the edge of the plane (xmax)
    lasthourDeg = hourDeg + random( -10, 10 );                                           //Adding a random slant to make the hour more animated and organic in its movement in the stream
    drawNum( lasthour, lasthourX, lasthourY, lasthourDeg, 1 );                           //Drawing the hour value at the edge of the screen
  }
  else if( minute() == 0 ){                                                              //We are entering a new hour which means that the last hour is spent and should be sent down the waterfall
    hourFall = true;                                                                     //I change this boolean state to initiate the fall
    if( hourY == lasthourY){                                                             //The new hour to be drawn needs a new position and slant, but to keep this from chaning for the entire first minute of the hour this if-statement is added so that it will only change once
      hourY = newPos();                                                                  //Generating new y-position in the stream
      hourDeg = newDeg();                                                                //Generating new slant for the new hour
    }
    drawNum( hour(), minute()*xmax[int(hourY)]/60, hourY, hourDeg, 1 );                  //Drawing of the new hour value, the x-position is dependent on the minute but will in this case be zero
    hourDeg = hourDeg + random( -10, 10 );                                               //Adding a random slant to make the hour more animated and organic in its movement in the stream
  }
  else {                                                                                 //This is the default drawing code for the hour, it will be called for minutes 1-58 of each hour
    drawNum( hour(), minute()*xmax[int(hourY)]/60, hourY, hourDeg, 1 );                  //Drawing of the hour using number drawing function which takes the hour value as an argument
    hourDeg = hourDeg + random( -10, 10 );                                               //Adding a random slant to make the hour more animated and organic in its movement in the stream
  }

  if( second() == 59 ){                                                                  //Checking if the current minute is coming to an end (and the minute value will be hanging on the edge of the plane, as its position is dependent on the second)
    lastmin = minute();                                                                  //Saving the current minute and its attributesto be used for drawing the spent minute in free fall
    lastminY = minY;
    lastminX = xmax[int(lastminY)];                                                      //X-position is at the edge of the plane (xmax)
    lastminDeg = minDeg + random( -10, 10 );                                             //Adding a random slant to make the hour more animated and organic in its movement in the stream
    drawNum( lastmin, lastminX, lastminY, lastminDeg, 1 );                               //Drawing the minute value at the edge of the screen
  }
  else if( second() == 0 ){                                                              //We are entering a new minute which means that the last minute is spent and should be sent down the waterfall
    minFall = true;                                                                      //I change this boolean state to initiate the fall
    if( minY == lastminY){                                                               //The new minute to be drawn needs a new position and slant, but to keep this from chaning for the entire first second of the minute this if-statement is added so that it will only change once
    minY = newPos();                                                                     //Generating new y-position in the stream
    minDeg = newDeg();                                                                   //Generating new slant for the new minute
    }
    drawNum( minute(), second()*xmax[int(minY)]/60, minY, minDeg, 1 );                   //Drawing of the new minute value, the x-position is dependent on the second but will in this case be zero
    minDeg = minDeg + random( -10, 10 );                                                 //Adding a random slant to make the minute more animated and organic in its movement in the stream
  }
  else {                                                                                 //This is the default drawing code for the minute, it will be called for seconds 1-58 of each minute
    drawNum( minute(), second()*xmax[int(minY)]/60, minY, minDeg, 1 );                   //Drawing of the minute using number drawing function which takes the minute value as an argument
    minDeg = minDeg + random( -10, 10 );                                                 //Adding a random slant to make the minute more animated and organic in its movement in the stream
  }
  
  if( hourFall ){                                                                        //This code will run once the hourFall boolean has been set to true, which happens at minute 0 of each hour
   drawNum( lasthour, lasthourX, lasthourY, lasthourDeg, 1 );                            //Drawing of the spent hour using the stored attributes of that hour
   lasthourDeg = lasthourDeg + random( -10, 20 );                                        //Adding a random slant each iteration to make the fall more organic
   lasthourY = lasthourY + height/80;                                                    //Advancing the y-position with a speed dependent on the window size, this controls the speed of the spent hour value's fall
   if(  lasthourY > height ){                                                            //When the spent hour value has exited the screen the state of the boolean is changed so the code won't run again until the next hour has passed
     hourFall = false;
   }
  }  
  if( minFall ){                                                                         //This code will run once the minFall boolean has been set to true, which happens at second 0 of each minute
   drawNum( lastmin, lastminX, lastminY, lastminDeg, 1 );                                //Drawing of the spent minute using the stored attributes of that minute
   lastminDeg = lastminDeg + random( -10, 20 );                                          //Adding a random slant each iteration to make the fall more organic
   lastminY = lastminY + height/80;                                                      //Advancing the y-position with a speed dependent on the window size, this controls the speed of the spent minute value's fall
   if(  lastminY > height ){                                                             //When the spent minute value has exited the screen the state of the boolean is changed so the code won't run again until the next minute has passed
     minFall = false;
   }
  }
}

float newPos(){                                                                          //Function to generate a new random y-position for objects to be drawn in the stream
 return random( (height-streamH)/2+numsize, (height-streamH)/2+streamH-numsize ); 
}
float newSpeed(){                                                                        //Function to generate a new random movement speed for objects to be drawn in the stream
 return random( width/80, width/60 ); 
}
float newDeg(){                                                                          //Function to generate a new slant for objects to be drawn in the stream
 return random( -30, 30 ); 
}

void drawNum( int number, float x, float y, float deg, float sizefactor ){               //Function handling the drawing of all numbers, arguments control value to be drawn, position, slant and a sizefactor which changes the strokeweight
 switch( number ){                                                                       //This long switch checks which value to be drawn and uses subordinate functions to draw each digit individually. It also adds a separation between the digits
   case 0:
     draw0( x, y, deg, sizefactor );
     break;
   case 1:
     draw1( x, y, deg, sizefactor );
     break;
   case 2:
     draw2( x, y, deg, sizefactor );
     break;
   case 3:
     draw3( x, y, deg, sizefactor );
     break;
   case 4:
     draw4( x, y, deg, sizefactor );
     break;
   case 5:
     draw5( x, y, deg, sizefactor );
     break;
   case 6:
     draw6( x, y, deg, sizefactor );
     break;
   case 7:
     draw7( x, y, deg, sizefactor );
     break;
   case 8:
     draw8( x, y, deg, sizefactor );
     break;
   case 9:
     draw9( x, y, deg, sizefactor );
     break;
   case 10:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw0( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 11:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw1( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 12:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw2( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 13:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw3( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 14:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw4( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 15:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw5( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 16:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw6( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 17:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw7( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 18:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw8( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 19:
     draw1( x-3*numsize/4, y, deg, sizefactor );
     draw9( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 20:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw0( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 21:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw1( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 22:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw2( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 23:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw3( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 24:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw4( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 25:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw5( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 26:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw6( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 27:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw7( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 28:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw8( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 29:
     draw2( x-3*numsize/4, y, deg, sizefactor );
     draw9( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 30:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw0( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 31:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw1( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 32:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw2( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 33:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw3( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 34:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw4( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 35:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw5( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 36:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw6( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 37:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw7( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 38:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw8( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 39:
     draw3( x-3*numsize/4, y, deg, sizefactor );
     draw9( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 40:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw0( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 41:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw1( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 42:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw2( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 43:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw3( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 44:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw4( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 45:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw5( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 46:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw6( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 47:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw7( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 48:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw8( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 49:
     draw4( x-3*numsize/4, y, deg, sizefactor );
     draw9( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 50:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw0( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 51:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw1( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 52:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw2( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 53:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw3( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 54:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw4( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 55:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw5( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 56:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw6( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 57:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw7( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 58:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw8( x+3*numsize/4, y, deg, sizefactor );
     break;
   case 59:
     draw5( x-3*numsize/4, y, deg, sizefactor );
     draw9( x+3*numsize/4, y, deg, sizefactor );
     break;
   default:
     break;
 }
}

void draw0( float x, float y, float deg, float sizefactor ){          //Function to draw the zero using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( numsize/2, -numsize/2 );
  vertex( -numsize/2, -numsize/2 );
  vertex( -numsize/2, numsize/2 );
  vertex( numsize/2, numsize/2 );
  vertex( numsize/2, -numsize/2 );
  endShape ();
  popMatrix(); 
}

void draw1( float x, float y, float deg, float sizefactor ){          //Function to draw the one using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( -numsize/4, -numsize/2+numsize/6 );
  vertex( 0, -numsize/2 );
  vertex( 0, numsize/2 );
  endShape ();
  popMatrix();
}

void draw2( float x, float y, float deg, float sizefactor ){          //Function to draw the two using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( -numsize/2, -numsize/2 );
  vertex( numsize/2, -numsize/2 );
  vertex( numsize/2, 0 );
  vertex( -numsize/2, 0 );
  vertex( -numsize/2, numsize/2 );
  vertex( numsize/2, numsize/2 );
  endShape ();
  popMatrix();
}

void draw3( float x, float y, float deg, float sizefactor ){          //Function to draw the three using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( -numsize/2, -numsize/2 );
  vertex( numsize/2, -numsize/2 );
  vertex( numsize/2, 0 );
  vertex( -numsize/2, 0 );
  vertex( numsize/2, 0 );
  vertex( numsize/2, numsize/2 );
  vertex( -numsize/2, numsize/2 );
  endShape ();
  popMatrix();
}

void draw4( float x, float y, float deg, float sizefactor ){          //Function to draw the four using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( -numsize/2, -numsize/2 );
  vertex( -numsize/2, 0 );
  vertex( numsize/2, 0 );
  vertex( numsize/2, -numsize/2 );
  vertex( numsize/2, numsize/2 );
  endShape ();
  popMatrix(); 
}

void draw5( float x, float y, float deg, float sizefactor ){          //Function to draw the five using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( numsize/2, -numsize/2 );
  vertex( -numsize/2, -numsize/2 );
  vertex( -numsize/2, 0 );
  vertex( numsize/2, 0 );
  vertex( numsize/2, numsize/2 );
  vertex( -numsize/2, numsize/2 );
  endShape ();
  popMatrix();
}

void draw6( float x, float y, float deg, float sizefactor ){          //Function to draw the six using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( numsize/2, -numsize/2 );
  vertex( -numsize/2, -numsize/2 );
  vertex( -numsize/2, numsize/2 );
  vertex( numsize/2, numsize/2 );
  vertex( numsize/2, 0 );
  vertex( -numsize/2, 0 );
  endShape ();
  popMatrix();
}

void draw7( float x, float y, float deg, float sizefactor ){          //Function to draw the seven using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( -numsize/2, -numsize/2 );
  vertex( numsize/2, -numsize/2 );
  vertex( numsize/2, numsize/2 );
  endShape ();
  popMatrix();
}

void draw8( float x, float y, float deg, float sizefactor ){          //Function to draw the eight using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( numsize/2, 0 );
  vertex( numsize/2, -numsize/2 );
  vertex( -numsize/2, -numsize/2 );
  vertex( -numsize/2, numsize/2 );
  vertex( numsize/2, numsize/2 );
  vertex( numsize/2, 0 );
  vertex( -numsize/2, 0 );
  endShape ();
  popMatrix(); 
}

void draw9( float x, float y, float deg, float sizefactor ){          //Function to draw the nine using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( -numsize/2, numsize/2 );
  vertex( numsize/2, numsize/2 );
  vertex( numsize/2, -numsize/2 );
  vertex( -numsize/2, -numsize/2 );
  vertex( -numsize/2, 0 );
  vertex( numsize/2, 0 );
  endShape ();
  popMatrix();
}

void drawer( float x, float y, float deg, float sizefactor ){          //Function to draw the line using vertices for each corner
  noFill();
  stroke( 80, 150, 190 );
  strokeWeight( numsize/(10*sizefactor) );                            //Sizefactor changes the strokeweight to put emphasis on the actual hour and minute rather than lines and random numbers drawn in the stream
  
  pushMatrix();
  translate( x, y );
  rotate( radians(deg) );
  beginShape();
  vertex( -numsize/2, 0 );
  vertex( numsize/2, 0 );
  endShape ();
  popMatrix();  
}


