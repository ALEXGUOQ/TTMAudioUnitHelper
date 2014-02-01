//
//  TTMAudioUnitHelper.h
//  MTRMock
//
//  Created by shuichi on 13/02/22.
//  Copyright (c) 2013年 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>



@interface TTMAudioUnitHelper : NSObject


// =============================================================================
#pragma mark Utilities

+ (void)printASBDForAudioUnit:(AudioUnit)audioUnit
                        scope:(AudioUnitScope)scope
                      element:(AudioUnitElement)element;

+ (void)printASBD:(AudioStreamBasicDescription)asbd;



// =============================================================================
#pragma mark AudioComponentDescription

+ (AudioComponentDescription)audioComponentDescriptionForSubType:(OSType)subType;



// =============================================================================
#pragma mark AUNode

+ (void)setupRemoteIOUnitWithGraph:(AUGraph)graph
                           pIONode:(AUNode *)pIONode
                           pIOUnit:(AudioUnit *)pIOUnit;

+ (void)setupMultiChannelMixerWithGraph:(AUGraph)graph
                             pMixerNode:(AUNode *)pMixerNode
                             pMixerUnit:(AudioUnit *)pMixerUnit;



// =============================================================================
#pragma mark ASBD

+ (AudioStreamBasicDescription)getASBDForAudioUnit:(AudioUnit)audioUnit
                                             scope:(AudioUnitScope)scope
                                           element:(AudioUnitElement)element;

+ (AudioStreamBasicDescription)canonicalASBDWithSampleRate:(Float64)sampleRate
                                               numChannels:(UInt32)numChannels;



// =============================================================================
#pragma mark File Reading

+ (UInt64)getTotalFramesInFile:(ExtAudioFileRef)audioFileObject;

+ (AudioStreamBasicDescription)getASBDForFile:(ExtAudioFileRef)audioFileObject;

+ (void)setClientDataFormatForFile:(ExtAudioFileRef)audioFileObject
                       numChannels:(UInt32)numChannels;

+ (AudioBufferList *)audioBufferListFromAudioDataL:(AudioUnitSampleType *)audioDataL
                                        audioDataR:(AudioUnitSampleType *)audioDataR
                                       totalFrames:(UInt64)totalFrames;

+ (AudioBufferList *)audioBufferListFromAudioData:(AudioUnitSampleType *)audioData
                                      totalFrames:(UInt64)totalFrames;

@end
