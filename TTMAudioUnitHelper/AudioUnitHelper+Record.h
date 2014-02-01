//
//  TTMAudioUnitHelper+Record.h
//  OverDubMock
//
//  Created by shuichi on 13/03/01.
//  Copyright (c) 2013年 Shuichi Tsutsumi. All rights reserved.
//

#import "TTMAudioUnitHelper.h"

@interface TTMAudioUnitHelper (Record)

+ (OSStatus)startRecordingToFile:(NSURL *)fileURL
                numInputChannels:(int)numInputChannels
                    extAudioFile:(ExtAudioFileRef *)extAudioFile
                          ioUnit:(AudioUnit *)ioUnit;

@end
