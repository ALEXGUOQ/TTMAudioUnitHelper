//
//  TTMAudioUnitHelper+PlayFile.h
//  OverDubMock
//
//  Created by shuichi on 13/03/01.
//  Copyright (c) 2013年 Shuichi Tsutsumi. All rights reserved.
//

#import "TTMAudioUnitHelper.h"


@interface TTMAudioUnitHelper (PlayFile)

typedef struct {
    
    BOOL                 isStereo;           // set to true if there is data in the audioDataRight member
    UInt64               totalFrames;        // the total number of frames in the audio data
    UInt32               currentFrame;       // the next audio sample to play
    AudioUnitSampleType  *audioDataLeft;     // the complete left (or mono) channel of audio data read from an audio file
    AudioUnitSampleType  *audioDataRight;    // the complete right channel of audio data read from an audio file
    
} SoundStruct, *soundStructPtr;

+ (SoundStruct)loadAudioFile:(NSURL *)fileURL;
+ (void)freeSoundStruct:(SoundStruct *)soundStruct;

@end
