//
//  Audio.cpp
//  Complication
//
//  Created by Spencer Salazar on 8/13/12.
//  Copyright (c) 2012 Spencer Salazar. All rights reserved.
//

#include "Audio.h"

const float SRATE = 44100;
const float BUFFER_SIZE = 256;


float sineOsc(float phase)
{
    return sinf(2*M_PI*phase);
}

float squareOsc(float phase)
{
    if(phase < 0.5)
        return 1;
    else
        return -1;
}

float sawOsc(float phase)
{
    return -1 + 2*phase;
}

float triangleOsc(float phase)
{
    if(phase < 0.5)
        return 2*(2*phase)-1;
    else
        return -1*(2*(2*(phase-0.5))-1);
}


void g_callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    Audio * audio = (Audio *) userData;
    
    audio->callback(buffer, numFrames, userData);
}


Audio::Audio()
{
    MoAudio::init(SRATE, BUFFER_SIZE, 2);
    MoAudio::start(g_callback, this);
    
    m_adsr.setAllTimes(0.01, 0.01, 0.6, 1);
    
    m_phase = 0;
    m_freq = 220;
    m_gain = 0.5;
    
    m_modPhase = 0;
    m_modFreq = m_freq * 0.25;
    m_modGain = 1000;
    
    m_lfoFreq = 2;
    m_lfoGain = 1;
    m_lfoPhase = 0;
    
    m_lfo2Freq = 1.0/16.0;
    m_lfo2Gain = 1;
    m_lfo2Phase = 0;
    
    m_filter.set_sample_rate(SRATE);
    m_filter2.set_sample_rate(SRATE);
    
    m_filter.set_rlpf(m_freq, 1);
    m_filter.set_bpf(m_freq, 1);
}

Audio::~Audio()
{
    
}

void Audio::callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    float last = m_adsr.lastOut();
    m_filter.set_rlpf(440+last*880, 1.1+m_lfo);
    m_filter2.set_bpf(881+m_lfo2*880, 20);
    
    for(int i = 0; i < numFrames; i++)
    {
        m_lfo = m_lfoGain * sawOsc(m_lfoPhase);
        m_lfoPhase += m_lfoFreq/SRATE;
        if(m_lfoPhase > 1) m_lfoPhase -= 1;
        
        m_lfo2 = m_lfo2Gain * sineOsc(m_lfo2Phase);
        m_lfo2Phase += m_lfo2Freq/SRATE;
        if(m_lfo2Phase > 1) m_lfo2Phase -= 1;
        
        float mod = m_modGain * sineOsc(m_modPhase);
        m_modPhase += m_modFreq/SRATE;
        if(m_modPhase > 1) m_modPhase -= 1;
        
        float sample = m_adsr.tick() * m_gain * sineOsc(m_phase);
        
        m_phase += (m_freq+mod)/SRATE;
        if(m_phase > 1)
            m_phase -= 1;
        
        sample = m_filter.tick_rlpf(sample);
        sample = 0.2*sample + 1.8*m_filter2.tick_bpf(sample);
        
        buffer[i*2] = sample;
        buffer[i*2+1] = sample;
    }
}















        











