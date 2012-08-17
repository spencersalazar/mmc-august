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
#undef TWO_PI
#include <list>
#include "FileRead.h"

struct Grain
{
    float start;
    float end;
    float current;
    float rate;
};

class Audio
{
public:
    Audio();
    ~Audio();
    
    void start();
    
    void callback( Float32 * buffer, UInt32 numFrames, void * userData );
    
    void setGrainRate(float rate) { m_rate = rate; }
    void setGrainPosition(float pos) { m_pos = pos; }
    
private:
    
    float getSample(Grain g);
    
    float m_rate;
    float m_pos;
    
    stk::StkFrames m_sample;
    
    std::list<Grain> m_grains;
};


#endif
