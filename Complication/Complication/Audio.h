//
//  Audio.h
//  Complication
//
//  Created by Spencer Salazar on 8/13/12.
//  Copyright (c) 2012 Spencer Salazar. All rights reserved.
//

#ifndef Complication_Audio_h
#define Complication_Audio_h

#include "mo_audio.h"


class Audio
{
public:
    Audio();
    ~Audio();
    
    void callback( Float32 * buffer, UInt32 numFrames, void * userData );
    
    void setFreq(float freq) { m_freq = freq; }
    
private:
    
    float m_modGain;
    float m_modFreq;
    float m_modPhase;
    
    float m_gain;
    float m_freq;
    float m_phase;
};


#endif
