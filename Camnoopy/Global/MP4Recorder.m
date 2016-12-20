//
//  MP4Recorder.m
//  2cu
//
//  Created by wutong on 15/9/21.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "MP4Recorder.h"
#import "Utils.h"       //引用此文件只是因为设置录像文件路径的函数写在此文件中。完全可以自己写函数，去掉这个头文件
//mp4v2
#import "general.h"
#import "file.h"
#import "file_prop.h"
#import "track.h"
#import "sample.h"
#import "track_prop.h"
#import "interf_dec.h"
#import "faac.h"
#import "faaccfg.h"

typedef struct sH264NaluHeader
{
    DWORD  dwFlag;
    BYTE      bNalu_Type;
}sH264NaluHeader;

//mp4文件的参数，固定
#define MP4_TIME_SCAL_VIDEO 1000
#define MP4_TIME_SCAL_AUDIO 8000

//设备端发过来的pcm参数，本来可以动态获取，但是这几个值是固定的
#define PCM_PARAM_CHANNELS      1
#define PCM_PARAM_SAMPLERATE    8000
#define PCM_PARAM_BITWIDTH      16

//因为pcm编码到aac，需要一定长度的pcm才可以，所以设置一个缓存，存储pcm，长度达到要求时编码aac
#define PCM_BUFFER_FOR_AAC_SIZE         1024*32

//rtsp连接时，为了音视频完全同步，给pcm数据设置一个缓存，每次来视频帧时读取该缓存，并且根据pcm长度来设置视频的播放延时
#define PCM_BUFFER_FOR_RTSP_SIZE        320*15

@interface MP4Recorder ()
{
    MP4FileHandle _mp4FileHandle;
    DWORD _isNeedKeyFrame;
    MP4TrackId _trackIdVideo;
    MP4TrackId _trackIdAudio;
    
    void* _pAmrDecoder;
    faacEncHandle _hFaacEncoder;
    
    //attribute
    DWORD _dwVideoHeight;      //视频高
    DWORD _dwVideoWidth;       //视频宽
    
    unsigned long _inputSamples;       //faac编码时所需的原始数据字节数
    unsigned long _maxOutputBytes;
    
    BYTE* _pBufferPCM_aac;
    unsigned long _dwPosPcm_aac;
    DWORD _dwFirstH264PacketLen;
    DWORD _dwSecondH264PacketLen;
    
    DWORD _dwCurrentRecordID;
    
    BYTE* _pBufferPcm_rtsp;
    DWORD _dwPosPcm_rtsp;
}
@end

@implementation MP4Recorder
-(void)dealloc
{
    [super dealloc];
}

+ (id)sharedDefault
{
    static MP4Recorder *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            manager = [[MP4Recorder alloc] init];
            manager->_mp4FileHandle = MP4_INVALID_FILE_HANDLE;
            manager->_isNeedKeyFrame = YES;
            manager->_trackIdVideo = MP4_INVALID_TRACK_ID;
            manager->_trackIdAudio = MP4_INVALID_TRACK_ID;
            
            manager->_pAmrDecoder = nil;
            manager->_hFaacEncoder = nil;
            
            manager->_dwVideoHeight = 0;
            manager->_dwVideoWidth = 0;
            
            manager->_pBufferPCM_aac = nil;
            manager->_pBufferPCM_aac = 0;
            manager->_dwFirstH264PacketLen = 0;
            manager->_dwSecondH264PacketLen = 0;
            
            manager->_statusRecordSwitch = NO;
            manager->_dwCurrentRecordID = 0;
            
            manager->_pBufferPcm_rtsp = nil;
            manager->_dwPosPcm_rtsp = 0;
        }
    }
    return manager;
}

-(void)startRecordWithID:(NSString*)contactId
{
    @synchronized(self)
    {
        if (_statusRecordSwitch) {
            [self stopRecord];
        }
        
        _dwFirstH264PacketLen = 0;
        _dwSecondH264PacketLen = 0;
        
        self.statusRecordSwitch = YES;
        //录像控制
        if (_mp4FileHandle != MP4_INVALID_FILE_HANDLE)
        {
            NSLog(@"record error 001");
            return;
        }
        
        //根据id设置文件文件的全路径
        NSString* path = [Utils getRecordPathWithContactId:contactId];
        _dwCurrentRecordID = [contactId intValue];
        
        
        char* flag1 = "isom";
        char* flag2 = "iso2";
        char* flag3 = "avc1";
        char* flag4 = "mp41";
        char* ptr[4] = {flag1, flag2, flag3, flag4};
        
        _mp4FileHandle = MP4CreateEx([path UTF8String], 0, 1, 0, "iosm", 0x00000200, ptr, 4);
        
        if (_mp4FileHandle != MP4_INVALID_FILE_HANDLE) {
            MP4SetTimeScale(_mp4FileHandle, 1000);
            _isNeedKeyFrame = YES;
            _pBufferPCM_aac = (BYTE*)malloc(PCM_BUFFER_FOR_AAC_SIZE);
            _dwPosPcm_aac = 0;
            _pAmrDecoder = Decoder_Interface_init();
            _pBufferPcm_rtsp = (BYTE*)malloc(PCM_BUFFER_FOR_RTSP_SIZE);
            _dwPosPcm_rtsp = 0;
        }
        else
        {
            NSLog(@"record error 002");
            [self stopRecord];
        }
    }
}

-(void)stopRecord
{
    @synchronized(self)
    {
        self.statusRecordSwitch = NO;
        if (_pAmrDecoder) {
            Decoder_Interface_exit(_pAmrDecoder);
            _pAmrDecoder = nil;
        }
        if (_hFaacEncoder) {
            faacEncClose(_hFaacEncoder);
            _hFaacEncoder = nil;
        }
        
        if (_mp4FileHandle != MP4_INVALID_FILE_HANDLE)
        {
            MP4Close(_mp4FileHandle, 0);
            _mp4FileHandle = MP4_INVALID_FILE_HANDLE;
        }
        
        if (_pBufferPCM_aac)
        {
            free(_pBufferPCM_aac);
            _pBufferPCM_aac = nil;
        }
        if (_pBufferPcm_rtsp) {
            free(_pBufferPcm_rtsp);
            _pBufferPcm_rtsp = nil;
        }
    }
}

-(void)vRecvAVData1WithAudioType:(int)dwAudioType pAudioData:(BYTE*)pAudioData dwFrames:(uint32_t)dwFrames pVideoData:(BYTE*)pVideoData dwVideoLen:(DWORD)dwVideoLen
{
    @synchronized(self)
    {
        if (_mp4FileHandle == MP4_INVALID_FILE_HANDLE ||
            self.statusRecordSwitch == NO ||
            dwVideoLen == 0) {
            return;
        }
        
        BOOL isKeyFrame = [self isKeyFrame:pVideoData];
        if (_isNeedKeyFrame)
        {
            if (!isKeyFrame)
            {
                return;
            }
            else
            {
                if (_dwFirstH264PacketLen == 0) {
                    _dwFirstH264PacketLen = GetPacketLen(pVideoData);
                    _dwSecondH264PacketLen = GetPacketLen(pVideoData+_dwFirstH264PacketLen);
                }
                
                //video
                BYTE* pNualData1 = pVideoData+4;
                BYTE* pNualData2 = pVideoData+_dwFirstH264PacketLen+4;
                _trackIdVideo = MP4AddH264VideoTrack(_mp4FileHandle, MP4_TIME_SCAL_VIDEO, MP4_INVALID_DURATION, _dwVideoWidth, _dwVideoHeight, pNualData1[1], pNualData1[2], pNualData1[3], 3);
                if (_trackIdVideo == MP4_INVALID_TRACK_ID) {
                    MP4Close(_mp4FileHandle, 0);
                    _mp4FileHandle = MP4_INVALID_FILE_HANDLE;
                    return;
                }
                MP4SetVideoProfileLevel(_mp4FileHandle, 0x7f);
                MP4AddH264SequenceParameterSet(_mp4FileHandle, _trackIdVideo, (const uint8_t*)pNualData1, _dwFirstH264PacketLen-4);
                MP4AddH264PictureParameterSet(_mp4FileHandle, _trackIdVideo, (const uint8_t*)pNualData2, _dwSecondH264PacketLen-4);
                
                //audio
                _hFaacEncoder = faacEncOpen(PCM_PARAM_SAMPLERATE, PCM_PARAM_CHANNELS, &_inputSamples, &_maxOutputBytes);
                faacEncConfigurationPtr pConfiguration = faacEncGetCurrentConfiguration(_hFaacEncoder);
                if (pConfiguration->version != FAAC_CFG_VERSION) {
                    NSLog(@"faacEncGetCurrentConfiguration failed");
                    return;
                }
                
                if (!pConfiguration) {
                    NSLog(@"faacEncGetCurrentConfiguration failed");
                    return;
                }
                
                pConfiguration->version = MPEG4;
                pConfiguration->aacObjectType = LOW;
                pConfiguration->inputFormat = FAAC_INPUT_16BIT;
                pConfiguration->outputFormat = 0;     // (0 = Raw; 1 = ADTS)录制MP4文件时，要用raw流。检验编码是否正确时可设置为 adts传输流，
                pConfiguration->shortctl = SHORTCTL_NORMAL;
                pConfiguration->useTns = 1;
                pConfiguration->quantqual = 100;
                pConfiguration->bandWidth = 0;
                pConfiguration->bitRate = 0;
                pConfiguration->allowMidside = 1;
                faacEncSetConfiguration(_hFaacEncoder, pConfiguration);
                
                _trackIdAudio = MP4AddAudioTrack(_mp4FileHandle, MP4_TIME_SCAL_AUDIO, MP4_INVALID_DURATION, MP4_MPEG4_AUDIO_TYPE);
                if (_trackIdAudio == MP4_INVALID_TRACK_ID) {
                    MP4Close(_mp4FileHandle, 0);
                    _mp4FileHandle = MP4_INVALID_FILE_HANDLE;
                    return;
                }
                
                MP4SetAudioProfileLevel(_mp4FileHandle, 0x2);
                
                unsigned char* faacDecoderInfo = NULL;
                unsigned long  faacDecoderInfoSize = 0;
                int ret = faacEncGetDecoderSpecificInfo(_hFaacEncoder, &faacDecoderInfo, &faacDecoderInfoSize);
                if (ret != 0)
                {
                    NSLog(@"faacEncGetDecoderSpecificInfo failed");
                }
                
                if (!MP4SetTrackESConfiguration(_mp4FileHandle, _trackIdAudio, faacDecoderInfo, (uint32_t)faacDecoderInfoSize))
                {
                    NSLog(@"MP4SetTrackESConfiguration failed");
                }
                free( faacDecoderInfo );
                
                
                _isNeedKeyFrame = NO;
            }
        }
        
        if (_trackIdVideo != MP4_INVALID_TRACK_ID)
        {
            if (NO == isKeyFrame) {
                BYTE* data = (BYTE*)malloc(dwVideoLen);
                data[0] = (dwVideoLen-4) >> 24;
                data[1] = (dwVideoLen-4) >> 16;
                data[2] = (dwVideoLen-4) >> 8;
                data[3] = (dwVideoLen-4) & 0xff;
                memcpy(data+4, pVideoData+4, dwVideoLen-4);
                MP4WriteSample(_mp4FileHandle, _trackIdVideo, data, dwVideoLen, dwFrames*20, 0, 1);
                free(data);
            }
            else
            {
                DWORD dwVideoLen1 = _dwFirstH264PacketLen;
                BYTE* buffer1 = (BYTE*)malloc(dwVideoLen1);
                buffer1[0] = (dwVideoLen1-4) >> 24;         //除以24次2
                buffer1[1] = (dwVideoLen1-4) >> 16;
                buffer1[2] = (dwVideoLen1-4) >> 8;
                buffer1[3] = (dwVideoLen1-4) & 0xff;
                memcpy(buffer1+4, pVideoData+4, dwVideoLen1-4);
                MP4WriteSample(_mp4FileHandle, _trackIdVideo, buffer1, dwVideoLen1, 0, 0, 1);
                free(buffer1);
                
                int dwVideoLen2 = _dwSecondH264PacketLen;
                BYTE* buffer2 = (BYTE*)malloc(dwVideoLen2);
                buffer2[0] = (dwVideoLen2-4) >> 24;         //除以24次2
                buffer2[1] = (dwVideoLen2-4) >> 16;
                buffer2[2] = (dwVideoLen2-4) >> 8;
                buffer2[3] = (dwVideoLen2-4) & 0xff;
                memcpy(buffer2+4, pVideoData+dwVideoLen1+4, dwVideoLen2-4);
                MP4WriteSample(_mp4FileHandle, _trackIdVideo, buffer2, dwVideoLen2, 0, 0, 1);
                free(buffer2);
                
                //海思 || 鱼眼
                if ((pVideoData[dwVideoLen1 + dwVideoLen2 + 4] == 0x65) ||
                    (pVideoData[dwVideoLen1 + dwVideoLen2 + 4] == 0x25))
                {
                    int dwVideoLen3 = dwVideoLen-(dwVideoLen1+dwVideoLen2);
                    BYTE* buffer3 = (BYTE*)malloc(dwVideoLen3);
                    buffer3[0] = (dwVideoLen3-4) >> 24;         //除以24次2
                    buffer3[1] = (dwVideoLen3-4) >> 16;
                    buffer3[2] = (dwVideoLen3-4) >> 8;
                    buffer3[3] = (dwVideoLen3-4) & 0xff;
                    memcpy(buffer3+4, pVideoData+dwVideoLen1+dwVideoLen2+4, dwVideoLen3-4);
                    MP4WriteSample(_mp4FileHandle, _trackIdVideo, buffer3, dwVideoLen3, dwFrames*20, 0, 1);
                    free(buffer3);
                }
                else    //智源
                {
                    int dwVideoLen3 = 9;
                    BYTE* buffer3 = (BYTE*)malloc(dwVideoLen3);
                    buffer3[0] = (dwVideoLen3-4) >> 24;         //除以24次2
                    buffer3[1] = (dwVideoLen3-4) >> 16;
                    buffer3[2] = (dwVideoLen3-4) >> 8;
                    buffer3[3] = (dwVideoLen3-4) & 0xff;
                    memcpy(buffer3+4, pVideoData+dwVideoLen1+dwVideoLen2+4, dwVideoLen3-4);
                    MP4WriteSample(_mp4FileHandle, _trackIdVideo, buffer3, dwVideoLen3, 0, 0, 1);
                    free(buffer3);
                    
                    int dwVideoLen4 = dwVideoLen-(dwVideoLen1+dwVideoLen2+dwVideoLen3);
                    BYTE* buffer4 = (BYTE*)malloc(dwVideoLen4);
                    buffer4[0] = (dwVideoLen4-4) >> 24;         //除以24次2
                    buffer4[1] = (dwVideoLen4-4) >> 16;
                    buffer4[2] = (dwVideoLen4-4) >> 8;
                    buffer4[3] = (dwVideoLen4-4) & 0xff;
                    memcpy(buffer4+4, pVideoData+dwVideoLen1+dwVideoLen2+dwVideoLen3+4, dwVideoLen4-4);
                    MP4WriteSample(_mp4FileHandle, _trackIdVideo, buffer4, dwVideoLen4, dwFrames*20, 0, 1);
                    free(buffer4);
                }
            }
        }
        
        if (_trackIdAudio != MP4_INVALID_TRACK_ID &&
            dwFrames != 0)
        {
            if (_dwPosPcm_aac + dwFrames*320 >= PCM_BUFFER_FOR_AAC_SIZE) {
                return;
            }
            if (dwAudioType == AUDIO_TYPE_AMR)
            {
                for (int i=0; i<dwFrames; i++)
                {
                    Decoder_Interface_Decode(_pAmrDecoder, pAudioData+i*32, (short*)(_pBufferPCM_aac+_dwPosPcm_aac), 0);
                    _dwPosPcm_aac += 320;
                }
            }
            else if(dwAudioType == AUDIO_TYPE_PCM)
            {
                memcpy(_pBufferPCM_aac+_dwPosPcm_aac, pAudioData, dwFrames*320);
                _dwPosPcm_aac += dwFrames*320;
            }
            
            int inputBytes = (int)_inputSamples*(16/8);      //aac每次编码需要的pcm数据字节数
            int posTemp = 0;
            BOOL isEncode = NO;
            while (_dwPosPcm_aac >= (posTemp+inputBytes))
            {
                isEncode = YES;
                BYTE buffAAC[768] = {0};
                int ret = faacEncEncode(_hFaacEncoder, (int*)(_pBufferPCM_aac+posTemp), (unsigned int)_inputSamples, buffAAC, (unsigned int)_maxOutputBytes);
                
                static int encodeTimes = 0;
                encodeTimes ++;
                
                //write
                uint64_t duration = (MP4_TIME_SCAL_AUDIO*inputBytes*20)/(320*1000);
                if (ret)
                {
                    MP4WriteSample(_mp4FileHandle, _trackIdAudio, (BYTE*)&buffAAC, ret, duration, 0, 1);
                }
                else
                {
                    NSLog(@"faacEncEncode failed = %d", ret);
                }
                
                posTemp += inputBytes;
            }
            
            //编码之后
            if (_dwPosPcm_aac > posTemp && isEncode)
            {
                int lenReamin = (int)_dwPosPcm_aac - posTemp;
                BYTE* buffRemain = (BYTE*)malloc(_dwPosPcm_aac-posTemp);
                memcpy(buffRemain, _pBufferPCM_aac+posTemp, lenReamin);
                memcpy(_pBufferPCM_aac, buffRemain, lenReamin);
                _dwPosPcm_aac = lenReamin;
                free(buffRemain);
            }
            else if (_dwPosPcm_aac == posTemp && isEncode)
            {
                _dwPosPcm_aac = 0;
            }
        }
    }
}

-(void)vRecvAVHeader1WithVideoWidth:(int)dwVideoWidth VideoHeight:(int)dwVideoHeight
{
    @synchronized(self)
    {
        BOOL isNeedRestart = NO;
        if (_dwVideoHeight !=0 && _dwVideoWidth != 0 && _statusRecordSwitch && (dwVideoHeight!= _dwVideoHeight || dwVideoWidth != _dwVideoWidth))
        {
//            停止记录
            [self stopRecord];
            isNeedRestart = YES;
        }
        //音视频属性
        _dwVideoHeight = dwVideoHeight;
        _dwVideoWidth = dwVideoWidth;
        
        //分辨率改变时，重新打包mp4文件
        if (isNeedRestart) {
            [self startRecordWithID:[NSString stringWithFormat:@"%d", _dwCurrentRecordID]];
        }
    }
}

-(BOOL) isKeyFrame:(BYTE*) pVideoData
{
    BOOL bIFrame = FALSE;
    sH264NaluHeader* pH264NaluHder = (sH264NaluHeader*) pVideoData;
    if( (pH264NaluHder->dwFlag == 0x1000000)
       && (((pH264NaluHder->bNalu_Type&0x1F) == 0x07) || ((pH264NaluHder->bNalu_Type&0x1F) == 0x05)))  ////0x07:SPS	0x05:I-Pic	 0x01:P/B pic
    {
        bIFrame = TRUE;
    }
    return bIFrame;
}


DWORD GetPacketLen(BYTE* pDataH264)
{
    for (int i=4; i<32; i++)		//此处32表示一个大概数，已知的两种情况，13 / 14
    {
        if (pDataH264[i] == 0 &&
            pDataH264[i+1] == 0 &&
            pDataH264[i+2] == 0 &&
            pDataH264[i+3] == 1)
        {
            return i;
        }
    }
    return -1;
}


//----------record for rtst
//输入实时流传输数据
-(void)InputRtspPcmData:(BYTE*)pPcmData dwLength:(DWORD)dwLength
{
    if (!_statusRecordSwitch) {
        return;
    }
    @synchronized(self)
    {
        if (_dwPosPcm_rtsp + dwLength >= PCM_BUFFER_FOR_RTSP_SIZE) {
            return;
        }
        else
        {
            memcpy(_pBufferPcm_rtsp+_dwPosPcm_rtsp, pPcmData, dwLength);
            _dwPosPcm_rtsp += dwLength;
        }
    }
}

-(void)InputRtspH264Data:(BYTE*)pVideoData dwVideoLen:(DWORD)dwVideoLen
{
    if (!_statusRecordSwitch) {
        return;
    }
    
    @synchronized(self)
    {
        BYTE* pAudioData = nil;
        int dwPcmPacketCount = 0;
        if (_dwPosPcm_rtsp >= 320) {
            pAudioData = _pBufferPcm_rtsp;
            dwPcmPacketCount = _dwPosPcm_rtsp/320;
        }
        
        [self vRecvAVData1WithAudioType:AUDIO_TYPE_PCM pAudioData:pAudioData dwFrames:dwPcmPacketCount pVideoData:pVideoData dwVideoLen:dwVideoLen];
        
        if (dwPcmPacketCount != 0)
        {
            int dwRemainPcm = _dwPosPcm_rtsp%320;
            memcpy(_pBufferPcm_rtsp, _pBufferPcm_rtsp+dwPcmPacketCount*320, dwRemainPcm);
            _dwPosPcm_rtsp = dwRemainPcm;
        }
    }
}

-(void)resetVideoSize
{
    _dwVideoWidth = 0;
    _dwVideoHeight = 0;
}

@end
