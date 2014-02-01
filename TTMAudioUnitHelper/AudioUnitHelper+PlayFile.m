//
//  TTMAudioUnitHelper+PlayFile.m
//  OverDubMock
//
//  Created by shuichi on 13/03/01.
//  Copyright (c) 2013年 Shuichi Tsutsumi. All rights reserved.
//

#import "AudioUnitHelper+PlayFile.h"

@implementation TTMAudioUnitHelper (PlayFile)

+ (SoundStruct)loadAudioFile:(NSURL *)fileURL
{
    SoundStruct soundStruct;
    
    // ファイルオープン
    ExtAudioFileRef audioFileObject = 0;
    OSStatus result = ExtAudioFileOpenURL((__bridge CFURLRef)(fileURL),
                                          &audioFileObject);
    
    if (noErr != result || NULL == audioFileObject) {

        NSLog(@"error:%d", (int)result);

        return soundStruct;
    }

    // オーディオファイルのプロパティを取得
    // （ファイルの長さをフレーム数で取得）
    UInt64 totalFramesInFile = [TTMAudioUnitHelper getTotalFramesInFile:audioFileObject];
    
    // SoundStructにファイルのフレーム数をセット
    soundStruct.totalFrames = (unsigned int)totalFramesInFile;
    
    // オーディオファイルのプロパティを取得
    // （データフォーマットを取得）
    AudioStreamBasicDescription fileAudioFormat = [TTMAudioUnitHelper getASBDForFile:audioFileObject];
    
    // データフォーマットから、チャンネル数を取得
    UInt32 channelCount = fileAudioFormat.mChannelsPerFrame;
    NSLog(@"channelCount:%u", (unsigned int)channelCount);
    
    
    // ---- SoundStructにデータ読み込み用のメモリ領域を確保 ----
    soundStruct.audioDataLeft = (AudioUnitSampleType *)calloc(totalFramesInFile,
                                                              sizeof(AudioUnitSampleType));
    
    if (2 == channelCount) {
        
        soundStruct.isStereo = YES;
        
        soundStruct.audioDataRight = (AudioUnitSampleType *)calloc(totalFramesInFile,
                                                                   sizeof(AudioUnitSampleType));
    }
    else if (1 == channelCount) {
        
        soundStruct.isStereo = NO;
    }
    // モノラル／ステレオ以外のケースは非対応
    else {
        
        NSLog (@"*** WARNING: File format not supported - wrong number of channels");
        ExtAudioFileDispose (audioFileObject);
        
        return soundStruct;
    }
    
    // データフォーマットをセット
    [TTMAudioUnitHelper setClientDataFormatForFile:audioFileObject
                                    numChannels:channelCount];
    
    
    // AudioBufferListを作成
    AudioBufferList *bufferList;
    if (2 == channelCount) {
        
        bufferList = [TTMAudioUnitHelper audioBufferListFromAudioDataL:soundStruct.audioDataLeft
                                                         audioDataR:soundStruct.audioDataRight
                                                        totalFrames:totalFramesInFile];
    }
    else {
        
        bufferList = [TTMAudioUnitHelper audioBufferListFromAudioData:soundStruct.audioDataLeft
                                                       totalFrames:totalFramesInFile];
    }
    
    // 読み込み開始
    // Perform a synchronous, sequential read of the audio data out of the file and
    //    into the soundStructArray[audioFile].audioDataLeft and (if stereo) .audioDataRight members.
    UInt32 numberOfPacketsToRead = (UInt32) totalFramesInFile;
    
    result = ExtAudioFileRead(audioFileObject,
                              &numberOfPacketsToRead,
                              bufferList);
    
    // AudioBufferListを解放
    free (bufferList);
    
    if (noErr != result) {
        
        NSLog(@"error:%d", (int)result);
        
        // If reading from the file failed, then free the memory for the sound buffer.
        [self freeSoundStruct:&soundStruct];
        
        ExtAudioFileDispose (audioFileObject);
        
        return soundStruct;
    }
    
    // Set the sample index to zero, so that playback starts at the
    //    beginning of the sound.
    soundStruct.currentFrame = 0;
    
    // Dispose of the extended audio file object, which also
    //    closes the associated file.
    ExtAudioFileDispose (audioFileObject);
    
    return soundStruct;
}

+ (void)freeSoundStruct:(SoundStruct *)soundStruct {

    free(soundStruct->audioDataLeft);
    soundStruct->audioDataLeft = 0;
    
    if (soundStruct->isStereo) {
        
        free(soundStruct->audioDataRight);
        soundStruct->audioDataRight = 0;
    }
}

@end
