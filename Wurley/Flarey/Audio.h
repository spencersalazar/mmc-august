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
#include "ADSR.h"
#include "SPFilter.h"
#include <list>
#include "CircularBuffer.h"
#include "Sitar.h"
#include "Wurley.h"

class HoffAudio
{
private:
    
    stk::Wurley m_wurley;
    
    Butterworth2Filter m_filter;
    Butterworth2Filter m_filter2;
    stk::ADSR m_adsr;
    
    float m_lfoGain;
    float m_lfoFreq;
    float m_lfoPhase;
    float m_lfo;
    
    float m_lfo2Gain;
    float m_lfo2Freq;
    float m_lfo2Phase;
    float m_lfo2;
    
    float m_modGain;
    float m_modFreq;
    float m_modPhase;
    
    float m_gain;
    float m_freq;
    float m_actualFreq;
    float m_phase;

public:
    void init();
    
    void setFreq(float freq) { m_freq = freq; }
    void setRelease(float r) { m_adsr.setReleaseTime(r); }
    void setLFOSpeed(float d) { m_wurley.controlChange(11, d); }
    
    void setCutoff(float freq) { m_filter.set_rlpf(freq, 10); }
    
//    void noteOn() { m_adsr.keyOn(); }
//    void noteOff() { m_adsr.keyOff(); }
    void noteOn() { m_wurley.noteOn(220, 1.0); }
    void noteOff() { m_wurley.noteOff(0.8); }
    
    void updateControl();
    float tick();
    
    bool isFinished() { return m_adsr.lastOut() < 0.001; }
};


class Audio
{
public:
    Audio();
    ~Audio();
    
    void callback( Float32 * buffer, UInt32 numFrames, void * userData );
    
    void addHoffAudio(HoffAudio * ha) { m_addList->put(ha); }
    void removeHoffAudio(HoffAudio * ha) { m_removeList->put(ha); }
    
private:
    
    CircularBuffer<HoffAudio *> * m_addList;
    CircularBuffer<HoffAudio *> * m_removeList;
    
    std::list<HoffAudio *> m_hoffs;
    std::list<HoffAudio *> m_hoffsToRemove;
};


#endif
