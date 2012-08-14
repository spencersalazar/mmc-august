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
#include "FileWvIn.h"
#include "FileWvOut.h"
#include "CircularBuffer.h"


class Audio
{
public:
    Audio();
    ~Audio();
    
    void callback( Float32 * buffer, UInt32 numFrames, void * userData );
    
    void play();
    void recordStart();
    void recordStop();
    
private:
    
    CircularBuffer<float> * m_fileOutBuffer;
    
    stk::FileWvIn m_fileIn;
    stk::FileWvIn m_fileIn2;
    
    stk::FileWvOut m_fileOut;
    bool m_isRecording;
    bool m_doPlay;
};


#endif
