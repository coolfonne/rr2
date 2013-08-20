#import <AudioToolbox/AudioToolbox.h>

class MikeSound
{
    SystemSoundID sound_id;
    
    
    
public:
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
    
	void freememory(void)
	{
        AudioServicesDisposeSystemSoundID(sound_id); 
	}
    
};








