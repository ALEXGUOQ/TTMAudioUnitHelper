//
//  TTMAudioUnitHelper.m
//  MTRMock
//
//  Created by shuichi on 13/02/22.
//  Copyright (c) 2013年 Shuichi Tsutsumi. All rights reserved.
//

#import "TTMAudioUnitHelper.h"



@implementation TTMAudioUnitHelper


// =============================================================================
#pragma mark Private

+ (AudioBufferList *)audioBufferListFromAudioDataL:(AudioUnitSampleType *)audioDataL
                                        audioDataR:(AudioUnitSampleType *)audioDataR
                                       numChannels:(UInt32)numChannels
                                       totalFrames:(UInt64)totalFrames
{
    // メモリ領域確保
    size_t bufferSize = sizeof(AudioBufferList) + sizeof(AudioBuffer) * (numChannels - 1);
    
    AudioBufferList *bufferList = (AudioBufferList *)malloc(bufferSize);
    
    if (NULL == bufferList) {
        
        NSLog (@"*** malloc failure for allocating bufferList memory");
        
        return NULL;
    }
    
    // バッファ数 = チャンネル数
    bufferList->mNumberBuffers = numChannels;
    
    
    // mBuffersの初期化
    AudioBuffer emptyBuffer = {0};
    size_t arrayIndex;
    
    for (arrayIndex = 0; arrayIndex < numChannels; arrayIndex++) {
        
        bufferList->mBuffers[arrayIndex] = emptyBuffer;
    }
    
    // set up the AudioBuffer structs in the buffer list
    bufferList->mBuffers[0].mNumberChannels  = 1;
    bufferList->mBuffers[0].mDataByteSize    = (UInt32)totalFrames * sizeof(AudioUnitSampleType);
    bufferList->mBuffers[0].mData            = audioDataL;
    
    if (2 == numChannels) {
        
        bufferList->mBuffers[1].mNumberChannels  = 1;
        bufferList->mBuffers[1].mDataByteSize    = (UInt32)totalFrames * sizeof(AudioUnitSampleType);
        bufferList->mBuffers[1].mData            = audioDataR;
    }
    
    return bufferList;
}



// =============================================================================
#pragma mark Utilities

+ (void)printASBDForAudioUnit:(AudioUnit)audioUnit
                        scope:(AudioUnitScope)scope
                      element:(AudioUnitElement)element
{
    AudioStreamBasicDescription asbd;
    
    [TTMAudioUnitHelper getASBDForAudioUnit:audioUnit
                                   scope:scope
                                 element:element];
    
    [TTMAudioUnitHelper printASBD:asbd];
}

+ (void)printASBD:(AudioStreamBasicDescription)asbd
{
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %lu",    (unsigned long)asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %lu",    (unsigned long)asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %lu",    (unsigned long)asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %lu",    (unsigned long)asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %lu",    (unsigned long)asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %lu",    (unsigned long)asbd.mBitsPerChannel);
}



// =============================================================================
#pragma mark AudioComponentDescription

+ (AudioComponentDescription)audioComponentDescriptionForSubType:(OSType)subType {

    AudioComponentDescription description;
    
    switch (subType) {

        case kAudioUnitSubType_RemoteIO:
        {
            description.componentType          = kAudioUnitType_Output;
            description.componentSubType       = kAudioUnitSubType_RemoteIO;
            description.componentManufacturer  = kAudioUnitManufacturer_Apple;
            description.componentFlags         = 0;
            description.componentFlagsMask     = 0;
            
            break;
        }

        case kAudioUnitSubType_MultiChannelMixer:
        {
            description.componentType          = kAudioUnitType_Mixer;
            description.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
            description.componentManufacturer  = kAudioUnitManufacturer_Apple;
            description.componentFlags         = 0;
            description.componentFlagsMask     = 0;

            break;
        }

        case kAudioUnitSubType_LowPassFilter:
        {
            description.componentType = kAudioUnitType_Effect;
            description.componentSubType = kAudioUnitSubType_LowPassFilter;
            description.componentManufacturer = kAudioUnitManufacturer_Apple;

            break;
        }

        case kAudioUnitSubType_HighPassFilter:
        {
            description.componentType = kAudioUnitType_Effect;
            description.componentSubType = kAudioUnitSubType_HighPassFilter;
            description.componentManufacturer = kAudioUnitManufacturer_Apple;

            break;
        }
            
        case kAudioUnitSubType_AudioFilePlayer:
        {
            description.componentType = kAudioUnitType_Generator;
            description.componentSubType = kAudioUnitSubType_AudioFilePlayer;
            description.componentManufacturer = kAudioUnitManufacturer_Apple;
            
            break;
        }

        case kAudioUnitSubType_Sampler:
        {
            description.componentType = kAudioUnitType_MusicDevice ;
            description.componentSubType = kAudioUnitSubType_Sampler;
            description.componentManufacturer = kAudioUnitManufacturer_Apple;

            break;
        }
            
        default:
            break;
    }
    
    return description;
}



// =============================================================================
#pragma mark AUNode

// Remote IOノードを作成し、AUGraphに追加する
+ (void)setupRemoteIOUnitWithGraph:(AUGraph)graph
                           pIONode:(AUNode *)pIONode
                           pIOUnit:(AudioUnit *)pIOUnit
{
    AudioComponentDescription ioUnitDescription
    = [TTMAudioUnitHelper audioComponentDescriptionForSubType:kAudioUnitSubType_RemoteIO];
    
    OSStatus result = AUGraphAddNode(graph,
                                     &ioUnitDescription,
                                     pIONode);
    
    if (noErr != result) {
        
        NSLog(@"error:%ld", (long)result);
        
        return;
    }
    
    result =	AUGraphNodeInfo(graph,
                                *pIONode,
                                NULL,
                                pIOUnit);
	
	if (result) {
        
        NSLog(@"error:%ld", (long)result);
        
        return;
    }
}


// MultiChannel Mixerノードを作成し、AUGraphに追加する
+ (void)setupMultiChannelMixerWithGraph:(AUGraph)graph
                             pMixerNode:(AUNode *)pMixerNode
                             pMixerUnit:(AudioUnit *)pMixerUnit
{
    AudioComponentDescription MixerUnitDescription
    = [TTMAudioUnitHelper audioComponentDescriptionForSubType:kAudioUnitSubType_MultiChannelMixer];
    
    OSStatus result = AUGraphAddNode(graph,
                                     &MixerUnitDescription,
                                     pMixerNode
                                     );
    
    if (noErr != result) {
        
        NSLog(@"error:%ld", (long)result);
        
        return;
    }
    
    result = AUGraphNodeInfo(graph,
                             *pMixerNode,
                             NULL,
                             pMixerUnit
                             );
    
    if (noErr != result) {
        
        NSLog(@"error:%ld", (long)result);
        
        return;
    }
}



// =============================================================================
#pragma mark ASBD

+ (AudioStreamBasicDescription)getASBDForAudioUnit:(AudioUnit)audioUnit
                                             scope:(AudioUnitScope)scope
                                           element:(AudioUnitElement)element
{

    AudioStreamBasicDescription asbd;
    UInt32 asbdSize = sizeof(asbd);
    
    AudioUnitGetProperty(audioUnit,
                         kAudioUnitProperty_StreamFormat,
                         scope,
                         element,
                         &asbd,
                         &asbdSize);

    return asbd;
}

+ (AudioStreamBasicDescription)canonicalASBDWithSampleRate:(Float64)sampleRate
                                               numChannels:(UInt32)numChannels
{    
    AudioStreamBasicDescription asbd;
    
    size_t bytesPerSample = sizeof(AudioUnitSampleType);

    asbd.mSampleRate        = sampleRate;
    asbd.mFormatID          = kAudioFormatLinearPCM;
    asbd.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    asbd.mChannelsPerFrame  = numChannels;
    asbd.mBytesPerPacket    = (UInt32)bytesPerSample;
    asbd.mBytesPerFrame     = (UInt32)bytesPerSample;
    asbd.mFramesPerPacket   = 1;
    asbd.mBitsPerChannel    = 8 * (UInt32)bytesPerSample;
    asbd.mReserved           = 0;

    return asbd;
}



// =============================================================================
#pragma mark File Reading

+ (UInt64)getTotalFramesInFile:(ExtAudioFileRef)audioFileObject {

    OSStatus result;

    UInt64 totalFramesInFile = 0;
    UInt32 frameLengthPropertySize = sizeof(totalFramesInFile);
    
    result = ExtAudioFileGetProperty(audioFileObject,
                                     kExtAudioFileProperty_FileLengthFrames,
                                     &frameLengthPropertySize,
                                     &totalFramesInFile);
    
    if (noErr != result) {

        NSLog(@"error:%ld", (long)result);
    }
    
    return totalFramesInFile;
}

+ (AudioStreamBasicDescription)getASBDForFile:(ExtAudioFileRef)audioFileObject {

    OSStatus result;
    
    AudioStreamBasicDescription fileAudioFormat = {0};
    UInt32 formatPropertySize = sizeof(fileAudioFormat);

    result = ExtAudioFileGetProperty(audioFileObject,
                                     kExtAudioFileProperty_FileDataFormat,
                                     &formatPropertySize,
                                     &fileAudioFormat);
    
    if (noErr != result) {
        
        NSLog(@"error:%ld", (long)result);
    }
    
    return fileAudioFormat;
}


+ (void)setClientDataFormatForFile:(ExtAudioFileRef)audioFileObject
                       numChannels:(UInt32)numChannels
{
    OSStatus result;

    AudioStreamBasicDescription importFormat = {0};

    importFormat = [TTMAudioUnitHelper canonicalASBDWithSampleRate:44100.0
                                                    numChannels:numChannels];
    
    result =    ExtAudioFileSetProperty (audioFileObject,
                                         kExtAudioFileProperty_ClientDataFormat,
                                         sizeof(importFormat),
                                         &importFormat);
    
    if (noErr != result) {
        
        NSLog(@"error:%ld", (long)result);
    }
}

+ (AudioBufferList *)audioBufferListFromAudioDataL:(AudioUnitSampleType *)audioDataL
                                        audioDataR:(AudioUnitSampleType *)audioDataR
                                       totalFrames:(UInt64)totalFrames
{
    return [TTMAudioUnitHelper audioBufferListFromAudioDataL:audioDataL
                                                  audioDataR:audioDataR
                                                 numChannels:2
                                                 totalFrames:totalFrames];
}

+ (AudioBufferList *)audioBufferListFromAudioData:(AudioUnitSampleType *)audioData
                                       totalFrames:(UInt64)totalFrames
{
    return [TTMAudioUnitHelper audioBufferListFromAudioDataL:audioData
                                                  audioDataR:NULL
                                                 numChannels:1
                                                 totalFrames:totalFrames];
}

@end
