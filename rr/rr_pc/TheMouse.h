#ifndef __TheMouse__
#define __TheMouse__

#include <iostream>
#include <GLUT/glut.h>
#include <CoreGraphics/CGDirectDisplay.h>
#include <CoreGraphics/CGRemoteOperation.h>

class TheMouse
{
private:
    
    static TheMouse* instance;
    
    TheMouse()
    {
        CGDisplayHideCursor(NULL);
        glutPassiveMotionFunc(TheMouse::passive_motion_func);
        CGAssociateMouseAndMouseCursorPosition(false);
    }
    
    static void passive_motion_func(int x, int y) {}
    
public:
    
    static TheMouse* getInstance()
    {
        if (instance == NULL) instance = new TheMouse();
        return instance;
    }
    
    
    void getstate(int *dx, int *dy)
    {

        CGGetLastMouseDelta(dx, dy);
        
        static bool first_nonzero_value_found = false;
        
        // the first nonzero value is very big and strange
        // so we just discard it
        if (!first_nonzero_value_found && (*dx > 0 || *dy > 0))
        {
            first_nonzero_value_found = true;
            *dx = 0;
            *dy = 0;
        }

    }
    
    ~TheMouse()
    {
        glutPassiveMotionFunc(NULL);
    }
    
    
    
};

#endif
