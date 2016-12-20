//
//  MP4Recorder.h
//  2cu
//
//  Created by wutong on 15/9/21.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2PCInterface.h"

enum
{
    AUDIO_TYPE_AMR,
    AUDIO_TYPE_PCM
};

@interface MP4Recorder : NSObject

@property (nonatomic) BOOL statusRecordSwitch;

+ (id)sharedDefault;
-(void)startRecordWithID:(NSString*)contactId;
-(void)stopRecord;

-(void)vRecvAVData1WithAudioType:(int)dwAudioType pAudioData:(BYTE*)pAudioData dwFrames:(uint32_t)dwFrames pVideoData:(BYTE*)pVideoData dwVideoLen:(uint32_t)dwVideoLen;
-(void)vRecvAVHeader1WithVideoWidth:(int)dwVideoWidth VideoHeight:(int)dwVideoHeight;

-(void)InputRtspPcmData:(BYTE*)pPcmData dwLength:(DWORD)dwLength;
-(void)InputRtspH264Data:(BYTE*)pVideoData dwVideoLen:(DWORD)dwVideoLen;

-(void)resetVideoSize;
@end
