//
//  Audio.cpp
//  Complication
//
//  Created by Spencer Salazar on 8/13/12.
//  Copyright (c) 2012 Spencer Salazar. All rights reserved.
//

#include "Audio.h"
#include "Filepaths.h"

const float SRATE = 44100;
const float BUFFER_SIZE = 256;

float rand2f(float f1, float f2)
{
    return ((f2-f1) * ((float) arc4random())/UINT_MAX) + f1;
}


void g_callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    Audio * audio = (Audio *) userData;
    
    audio->callback(buffer, numFrames, userData);
}



Audio::Audio()
{
}

Audio::~Audio()
{
    
}

void Audio::start()
{
    stk::FileRead file;
    //file.open(stlResourceFilepath("ImmaBuyYouADrank.wav"));
    file.open(stlDocumentsFilepath("export.wav"));
    m_sample = stk::StkFrames(file.fileSize(), file.channels());
    file.read(m_sample);
    file.close();
    
    m_rate = 1;
    m_pos = 0;
    
    MoAudio::init(SRATE, BUFFER_SIZE, 2);
    MoAudio::start(g_callback, this);
}


float Audio::getSample(Grain g)
{
    float sample = 0;
    
    if(g.current >= 0 && g.current < m_sample.frames())
        sample = m_sample.interpolate(g.current);
    
    return sample;
}


void Audio::callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    // generate a grain
    Grain g;
    float pos_sigma = numFrames;
    float grain_length = numFrames*50*m_rate;
    // m_pos is between [0,1]
    g.start = m_pos*m_sample.frames() + rand2f(-pos_sigma, pos_sigma);
    g.end = g.start + grain_length;
    g.current = g.start;
    g.rate = m_rate;
    m_grains.push_back(g);
    
    for(int i = 0; i < numFrames; i++)
    {
        float sample = 0;
        
        for(std::list<Grain>::iterator i = m_grains.begin();
            i != m_grains.end();)
        {
            Grain &g = *i;
            sample += getSample(g) * 0.1;
            // advance the grain
            g.current += g.rate;
            
            if(g.current >= g.end || g.current > m_sample.frames())
            {
                std::list<Grain>::iterator r = i;
                i++;
                m_grains.erase(r);
            }
            else
                i++;
        }
        
        buffer[i*2] = sample;
        buffer[i*2+1] = sample;
    }
}















        











