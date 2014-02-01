//
//  TTMAudioUnitHelper+Record.m
//  OverDubMock
//
//  Created by shuichi on 13/03/01.
//  Copyright (c) 2013年 Shuichi Tsutsumi. All rights reserved.
//

#import "TTMAudioUnitHelper+Record.h"

@implementation TTMAudioUnitHelper (Record)

+ (OSStatus)startRecordingToFile:(NSURL *)fileURL
                numInputChannels:(int)numInputChannels
                    extAudioFile:(ExtAudioFileRef *)extAudioFile
                          ioUnit:(AudioUnit *)ioUnit
{

    //変換するフォーマット(AIFF)
    UInt32 formatFlags = kAudioFormatFlagIsBigEndian
	| kLinearPCMFormatFlagIsSignedInteger
	| kLinearPCMFormatFlagIsPacked;
    AudioStreamBasicDescription outputFormat;
    outputFormat.mSampleRate            = 44100.0;
    outputFormat.mFormatID              = kAudioFormatLinearPCM;
    outputFormat.mFormatFlags           = formatFlags;
    outputFormat.mFramesPerPacket       = 1;
    outputFormat.mChannelsPerFrame      = numInputChannels;
    outputFormat.mBitsPerChannel        = 16;
    outputFormat.mBytesPerPacket        = 2;
    outputFormat.mBytesPerFrame         = 2;
    outputFormat.mReserved              = 0;
    
    OSStatus result;
    
    result = ExtAudioFileCreateWithURL((__bridge CFURLRef)fileURL,
                                       kAudioFileAIFFType,
                                       &outputFormat,
                                       NULL,
                                       kAudioFileFlags_EraseFile,
                                       extAudioFile);
    
    if (result != noErr) {

        return result;
    }
    
    NSLog(@"output file created:%@", fileURL);
    
    // ---- 出力ファイルフォーマットの設定 ----
    // Remote OutputのアウトプットのASBDを取得
    AudioStreamBasicDescription audioUnitOutputFormat;
    audioUnitOutputFormat = [TTMAudioUnitHelper getASBDForAudioUnit:*ioUnit
                                                           scope:kAudioUnitScope_Output
                                                         element:0];
    
    NSLog(@"numInputChannels:%d", numInputChannels);
    [TTMAudioUnitHelper printASBD:audioUnitOutputFormat];
    
    
    // ASBDをセット
    ExtAudioFileSetProperty(*extAudioFile,
                            kExtAudioFileProperty_ClientDataFormat,
                            sizeof(AudioStreamBasicDescription),
                            &audioUnitOutputFormat);
    
    // 書き込み開始位置をセット（先頭から）
    ExtAudioFileSeek(*extAudioFile, 0);
    
    return noErr;
}

@end
