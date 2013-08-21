#import <Cocoa/Cocoa.h>
#include <GLUT/glut.h>
#include "kdtree.h"
#include "maze.h"
#include "newfont.h"
#include "MySound.h"
#include "TheMouse.h"

#define NUMROBOTS 30

extern void drawyouwin(void);
extern void drawyoulose(void);
extern void drawinstructions(void);
extern void drawgamescreen(void);
extern void drawpausedscreen(void);
extern void drawgamemenu(void);

extern int health;
extern int robotskilled;

extern float menuselrotatetime;

enum gamestatetype {GAMEMENU, ACTION, PAUSED, INSTRUCTIONS, YOULOSE, YOUWIN, MOUSECONFIG};


enum menuselectiontype {PLAY, INFO, EXITGAME};

extern menuselectiontype menusel;


extern gamestatetype gamestate;

extern Kdtree *kdtree;

extern Maze *maze;

extern Newfont *nf;

extern MySound robotexplodesound;
extern MySound explodesound;
extern MySound screamsound;
extern MySound rlaunchsound;
extern MySound robotrocketexplodesound;
extern MySound robotlaunchsound;


GLenum texFormat[ 5 ];   // Format of texture (GL_RGB, GL_RGBA)
NSSize texSize[ 5 ];     // Width and height
char *texBytes[ 5 ];     // Texture data

GLuint texture[ 5 ];          // Storage for five textures


int up_arrow_down=0,down_arrow_down=0;
int rightkeydown=0,leftkeydown=0;

int strafe_right_down=0,strafe_left_down=0;
int fire_key_down=0;

extern int mytexture;
extern int physicsactual, physicsgoal;
extern void physicsloop(void);

extern void reseteverything(void);


void keyDown(unsigned char inkey, int px, int py)
{
    
    
	if (inkey=='P' || inkey=='p')
    {
        if (gamestate == ACTION) { gamestate = PAUSED;}
        else if (gamestate == PAUSED) {gamestate = ACTION;}
        
    }
    
    
    
    
    
    if (gamestate == INSTRUCTIONS && inkey==13) {gamestate = GAMEMENU; }
    
    
    
    
    if (gamestate==GAMEMENU)
    {
        
        if (inkey==13)
        {
            
			if (menusel == PLAY) { gamestate = ACTION;}             
			if (menusel == INFO) gamestate = INSTRUCTIONS;
			if (menusel == EXITGAME) exit(0);  
            
            
        }
        
    }
    
    if (inkey==13){
        if (gamestate == YOULOSE || gamestate == YOUWIN) {reseteverything(); }
    }
    
    if (inkey==27) gamestate = GAMEMENU;
    
    inkey = toupper(inkey);
    
    if (inkey == 'D') strafe_right_down=1;
    if (inkey == 'A') strafe_left_down=1;
    if (inkey == 'Z') fire_key_down=1;
    if (inkey == 'W') up_arrow_down=1;
    if (inkey == 'S') down_arrow_down=1;
}


void keyUp(unsigned char inkey, int px, int py)
{
    //printf("%c\n", inkey);
    inkey = toupper(inkey);
    
    if (inkey == 'D') strafe_right_down=0;
    if (inkey == 'A') strafe_left_down=0;
    if (inkey == 'Z') fire_key_down=0;
    if (inkey == 'W') up_arrow_down=0;
    if (inkey == 'S') down_arrow_down=0;
    

}


void specialup(int key, int x, int y)
{
    if (key==GLUT_KEY_DOWN) down_arrow_down=0;
    if (key==GLUT_KEY_UP) up_arrow_down=0;  
    if (key==GLUT_KEY_RIGHT) rightkeydown=0;
    if (key==GLUT_KEY_LEFT) leftkeydown=0;
    
}


void specialdown(int key, int x, int y)
{
    
    
    if (gamestate==GAMEMENU)
    {
        
        if (key==GLUT_KEY_UP) {
			if (menusel == PLAY) menusel = EXITGAME;
			else if (menusel == INFO) menusel = PLAY;
			else if (menusel == EXITGAME) menusel = INFO;
        }
        
        if (key==GLUT_KEY_DOWN) {
            
			if (menusel == PLAY) menusel = INFO;
			else if (menusel == INFO) menusel = EXITGAME;
			else if (menusel == EXITGAME) menusel = PLAY;
        }
        
        
        
        
        return;
        
    }
    
    
    
    
    
    if (key==GLUT_KEY_DOWN) down_arrow_down=1;
    if (key==GLUT_KEY_UP) up_arrow_down=1;  
    if (key==GLUT_KEY_RIGHT) rightkeydown=1;
    if (key==GLUT_KEY_LEFT) leftkeydown=1;  
    
}

void light2(void)
{
    
    glEnable(GL_LIGHTING);
    GLfloat LightAmbient[]= { 0, 0, 0, 1.0f };
    GLfloat LightDiffuse[]= { 1.04, 0.04, 1.04, 1.0f };
    GLfloat LightGlobal[]= { .105, .205, .205, 1.0f };
    
    GLfloat LightPosition[]= { 0.0f,0.0f, 10.0f, 0.0f };
    glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient);	
    glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse);	
    glLightfv(GL_LIGHT1, GL_POSITION,LightPosition);
    glEnable(GL_LIGHT1);
    
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, LightGlobal); 
    
}

void light7(void)
{
    
    glEnable(GL_LIGHTING);
    GLfloat LightAmbient[]= { 0.3, 0.3, 0.3, 1.0f };
    GLfloat LightDiffuse[]= { 1.04, 1.04, 1.04, 1.0f };
    GLfloat LightGlobal[]= { .105, .205, .205, 1.0f };
    
    GLfloat LightPosition[]= { 0.0f,0.0f, 10.0f, 0.0f };
    glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient);	
    glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse);	
    glLightfv(GL_LIGHT1, GL_POSITION,LightPosition);
    glEnable(GL_LIGHT1);
    
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, LightGlobal); 
    
}

void newlight7(void) 
{
    GLfloat mat_specular[] = { 1.0, 1.0, 1.0, 1.0 };
    GLfloat mat_ambient[] = { .73, .73, .73, 1.0 };
    GLfloat mat_diffuse[] = { 10.0, 1.0, 1.0, 1.0 };
    GLfloat mat_shininess[] = { 110.0 };
    GLfloat light_position[] = { 0.0, 0.5, 5.0, 0.0 };
    glClearColor (0.0, 0.0, 0.0, 0.0);
    glShadeModel (GL_SMOOTH);
    
    glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, mat_diffuse);
    glMaterialfv(GL_FRONT, GL_AMBIENT, mat_ambient);
    glMaterialfv(GL_BACK, GL_SPECULAR, mat_specular);
    glMaterialfv(GL_BACK, GL_SHININESS, mat_shininess);
    glLightfv(GL_LIGHT1, GL_POSITION, light_position);
    
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT1);
    //glDisable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
    
    
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT,mat_ambient);

    
    
    
    
}


void display(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    // take care of the physics
    while (physicsactual < physicsgoal) {physicsloop(); 
        physicsactual++;}
    //    

    
    glLoadIdentity();
    
    newlight7();

    glEnable(GL_TEXTURE_2D);

    
    if (gamestate == GAMEMENU) {drawgamemenu(); 
        //Sleep(20);
    }
    else if (gamestate == ACTION) drawgamescreen();
    else if (gamestate == PAUSED) 
    {
        drawgamescreen();
        drawpausedscreen();
    }
    else if (gamestate == INSTRUCTIONS) drawinstructions();
    else if (gamestate == YOULOSE) 
    {
        drawgamescreen();     
        drawyoulose();
    }
    else if (gamestate == YOUWIN) 
    {
        drawgamescreen();     
        drawyouwin();
    }
    
    if (gamestate == ACTION)
    {
        // take care of the physics
        while (physicsactual < physicsgoal) {physicsloop(); 
            physicsactual++;}
        
        if (health == 0) gamestate = YOULOSE;
        if (NUMROBOTS - robotskilled == 0) gamestate = YOUWIN;
    }
    

    glShadeModel( GL_SMOOTH );    
    glutSwapBuffers();
}


void reshape2()
{ 
    
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
    gluPerspective(60.0f, 800.0/560.0, 0.1f, 100.0f);
    
    
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
}



void reshape(int width, int height)
{
    glViewport(0, 0, width, height);
    reshape2();
}

void idle(void)
{
    glutPostRedisplay();
}






/*
 * The NSBitmapImageRep is going to load the bitmap, but it will be
 * setup for the opposite coordinate system than what OpenGL uses, so
 * we copy things around.
 */
//- (BOOL) loadBitmap:(NSString *)filename intoIndex:(int)texIndex

BOOL loadBitmap(NSString* filename, int texIndex)
{
	BOOL success = FALSE;
	NSBitmapImageRep *theImage;
	int bitsPPixel, bytesPRow;
	unsigned char *theImageData;
	int rowNum, destRowNum;
	
	theImage = [ NSBitmapImageRep imageRepWithContentsOfFile:filename ];
	if( theImage != nil )
	{
		bitsPPixel = [ theImage bitsPerPixel ];
		bytesPRow = [ theImage bytesPerRow ];
		if( bitsPPixel == 24 )        // No alpha channel
			texFormat[ texIndex ] = GL_RGB;
		else if( bitsPPixel == 32 )   // There is an alpha channel
			texFormat[ texIndex ] = GL_RGBA;
		texSize[ texIndex ].width = [ theImage pixelsWide ];
		texSize[ texIndex ].height = [ theImage pixelsHigh ];
		texBytes[ texIndex ] = (char*)calloc( bytesPRow * texSize[ texIndex ].height,
                                             1 );
		if( texBytes[ texIndex ] != NULL )
		{
			success = TRUE;
			theImageData = [ theImage bitmapData ];
			destRowNum = 0;
			for( rowNum = texSize[ texIndex ].height - 1; rowNum >= 0;
				rowNum--, destRowNum++ )
			{
				// Copy the entire row in one shot
				memcpy( texBytes[ texIndex ] + ( destRowNum * bytesPRow ),
					   theImageData + ( rowNum * bytesPRow ),
					   bytesPRow );
			}
		}
	}
	
	return success;
}




void loadGLTextures()
{
	
    
    
    
    
    
  /*  loadBitmap( [NSString stringWithFormat:@"%@/%s",
                 [ [ NSBundle mainBundle ] resourcePath ],
                 "roadway.jpg" ],
               0
               
               );*/
    
    loadBitmap( [NSString stringWithFormat:@"%@/%s",
                 [ [ NSBundle mainBundle ] resourcePath ],
                 "newrock2.gif" ],
               0
    
               );
    
//    loadBitmap( [NSString stringWithFormat:@"%@/%s",
//                 [ [ NSBundle mainBundle ] resourcePath ],
//                 "graymud.jpg" ],
//               0
//               
//               );
    
    
    
    glGenTextures( 5, &texture[ 0 ] );   // Create the textures
    
    // Create nearest filtered texture
    glBindTexture( GL_TEXTURE_2D, texture[ 0 ] );
    
    
    
    // select modulate to mix texture with color for shading
    glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
    
    
    //    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    //    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    //    
    
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
    glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR );
    
    //    glTexImage2D( GL_TEXTURE_2D, 0, 3, texSize[ 0 ].width,
    //                 texSize[ 0 ].height, 0, texFormat[ 0 ],
    //                 GL_UNSIGNED_BYTE, texBytes[ 0 ] );
    
    
    gluBuild2DMipmaps( GL_TEXTURE_2D, 3, texSize[ 0 ].width, texSize[ 0 ].height,texFormat[ 0 ], GL_UNSIGNED_BYTE, texBytes[ 0 ]);
    
}



void* PosixThreadMainRoutine(void* data)
{
    
    srand(time(NULL));
    sleep(1);    
    while (1) 
    {                      
        
        if (gamestate == ACTION) 
            physicsgoal++;        
        if (gamestate == GAMEMENU) menuselrotatetime+=.03;  
        
        
        usleep(14000);
    }      
    
}   




pthread_t       posixThreadID;
void LaunchThread()
{
    // Create the thread using POSIX routines.
    pthread_attr_t  attr;
    
    int             returnVal;
    
    returnVal = pthread_attr_init(&attr);
    assert(!returnVal);
    returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    assert(!returnVal);
    
    int     threadError = pthread_create(&posixThreadID, &attr, &PosixThreadMainRoutine, NULL);
    
    returnVal = pthread_attr_destroy(&attr);
    assert(!returnVal);
    if (threadError != 0)
    {
        // Report an error.
    }
}


// Callback handler for mouse event
void mouse(int button, int state, int x, int y) {
    
    
    if (button == GLUT_LEFT_BUTTON && state == GLUT_DOWN) fire_key_down=1;
    if (button == GLUT_LEFT_BUTTON && state == GLUT_UP) fire_key_down=0;
    
    return;
    
    
    if (button == GLUT_LEFT_BUTTON && state == GLUT_DOWN) { // Pause/resume

        
        float actual_width = glutGet(GLUT_WINDOW_WIDTH);
        float actual_height = glutGet(GLUT_WINDOW_HEIGHT);
        
        float xfac = 1280.0/actual_width;
        float yfac = 800/actual_height;
        
        x = float(x)*xfac;
        y = float(y)*yfac;        
        
        
        
        if (gamestate==INSTRUCTIONS) gamestate=GAMEMENU;
        
        if (gamestate==GAMEMENU && 
            x >= 519 && x <= 690 && y >= 331 && y <= 412) gamestate=ACTION;
        
        if (gamestate==GAMEMENU && 
            x >= 510 && x <= 958 && y >= 430 && y <= 501) gamestate=INSTRUCTIONS;
        
        if (gamestate==GAMEMENU && 
            x >= 520 && x <= 670 && y >= 511 && y <= 591) exit(0);
        
        
        } else {

        }
    
}



int main(int argc, char *argv[])
{
    
    explodesound.loadsound(@"rocketexplosion3");
    screamsound.loadsound(@"diescream");
    rlaunchsound.loadsound(@"rlaunch2");
    robotexplodesound.loadsound(@"robotexplosion2");
    robotlaunchsound.loadsound(@"robotlaunch6");
    robotrocketexplodesound.loadsound(@"robotrocketexplosion");
    
    
    
    
    
//    TheMouse *themouse = TheMouse::getInstance();
//    
//    
//    int x, y;
//    for (int ctr = 0; ctr < 100; ctr++)
//    {
//    themouse->getstate(&x,&y);
//    printf("x %d y %d", x, y);
//    sleep(1);
//    }
//    return 0;
    
    nf = new Newfont("myfont.obj", "myfont.mtl", 1); 
    
    maze = new Maze(20, 20);
    
    reseteverything();
    
    vector<Segment> segments = maze->getsegments();
    
    vector<MikePoint> points;
    
    vector<Segment>::iterator i = segments.begin();
    while (i != segments.end()) 
    {
        Segment &seg = *i;
        MikePoint p((seg.x0+seg.x1)/2.0, (seg.y0+seg.y1)/2.0, seg); 
        points.push_back(p);
        ++i;
    }
    
    kdtree = new Kdtree(points);
    
    
    
    
    
    
    
    
    
    
    glutInit(&argc, argv);
    // glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);
    glutInitDisplayMode(GLUT_RGBA | GLUT_SINGLE | GLUT_DEPTH);
    //glutInitWindowSize(1280, 1000);
    //glutInitWindowSize(1280, 800);
    
    // glutInitWindowSize(640, 480);
    glutInitWindowSize(640, 400);
    
    glutCreateWindow("UFO Invasion");
    glutFullScreen();
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    loadGLTextures();
    mytexture = texture[0];
    glEnable(GL_TEXTURE_2D);
    
    LaunchThread();
    
    glutKeyboardFunc (keyDown);
    glutKeyboardUpFunc (keyUp);
    glutMouseFunc(mouse);
    glutSpecialFunc(specialdown);
    glutSpecialUpFunc(specialup);
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    glutIdleFunc(idle);    
    glutMainLoop();
    return EXIT_SUCCESS;
}