#import <AudioToolbox/AudioToolbox.h>

class MySound
{
    SystemSoundID sound_id;
    
public:
    
    
    MySound(NSString* filename)
    {
        loadsound(filename);
    }
    
    MySound()
    {
    }
    
	void loadsound(NSString* filename)
	{
        
        NSURL *sound_URL   = [[NSBundle mainBundle] URLForResource: filename
                                                     withExtension: @"wav"];
        AudioServicesCreateSystemSoundID((CFURLRef)sound_URL, &sound_id);
        
	}
    
	void play(void)
	{
        AudioServicesPlaySystemSound(sound_id);
	}
    
	~MySound()
	{
        AudioServicesDisposeSystemSoundID(sound_id);
	}
    
};








