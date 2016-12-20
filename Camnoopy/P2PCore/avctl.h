#ifndef _AVCTL_H_
#define _AVCTL_H_

#define SUPPORT_REC_TO_FILE

#define  DWORD        unsigned int
#define  BYTE         unsigned char
#define  GBOOL         unsigned int



//bCommandOption
enum
{
   USR_CMD_OPTION_NONE,
   USR_CMD_OPTION_FILE_INFO, //begin PTS = (((UINT64)(pdwData[0])<<32) |pdwData[1]);//End PTS = (((UINT64)(pdwData[2])<<32) |pdwData[3]);
   USR_CMD_OPTION_FILE_END, //
   	
   USR_CMD_OPTION_PAUSE,
   USR_CMD_OPTION_PAUSE_RET,
     
   USR_CMD_OPTION_RESUME,
   USR_CMD_OPTION_RESUME_RET,
   
   USR_CMD_OPTION_JUMP,//memcpy( pData, &u64JumpTargetPTS ,sizeof(UINT64) );
   USR_CMD_OPTION_JUMP_RET, //pdwData[0] : true , false
    
   USR_CMD_OPTION_NEXT_FILE, //memcpy(pData,&sTargetNextFile, sizeof(sRecFilenameType) );
   USR_CMD_OPTION_NEXT_FILE_RET, ///pdwData[0] : true , false

   USR_CMD_OPTION_STOP,
   USR_CMD_OPTION_STOP_RET,//pdwData[0] : true , false

   USR_CMD_OPTION_PLAY,
   USR_CMD_OPTION_PLAY_RET,//pdwData[0] : true , false


};

/////////////////////av encode interface///////////////////////////
GBOOL    fgStartAVEncAndSend(DWORD dwVideoFrameRate);
void     vStopAVEncAndSend(void);
GBOOL    fgFillVideoRawFrame(BYTE *pbData, DWORD dwSize, DWORD dwWidth, DWORD dwHeight, GBOOL fgX2Reflection);
void     vFillAudioRawData(BYTE *pbData, DWORD dwSize);
GBOOL    fgSendUserData(DWORD dwCmd,   DWORD  dwOption , BYTE * pData,  DWORD  dwDataLen) ;

///////////////////////end of av encode interface///////////////////////////////////

typedef struct GAVFrame
{
    BYTE *data[3];
    int  linesize[3];
    int  width;
    int  height;
    uint64_t pts;
}GAVFrame;


#define CONN_TYPE_VIDEO_CALL  0x00
#define CONN_TYPE_MONITOR     0x01
#define CONN_TYPE_FILE_TRANS  0x02

typedef struct sRecAndDecPrm
{
    DWORD  dwConnectType;//以前是传的1或者0 现在需要改一改
    void (* vRecvUserDataCallBack )(DWORD dwCmd, DWORD  dwOption , DWORD * pdwData,  DWORD  dwDataLen);
}sRecAndDecPrm;
////////////////////////av decode interface //////////////////////////////////
GBOOL       fgStartRecvAndDec(sRecAndDecPrm *psInitPrm);
void        vStopRecvAndDec(void);
GBOOL       fgGetAudioDataToPlay(BYTE * pDesBuf,  DWORD dwSize) ;
GBOOL       fgGetVideoFrameToDisplay(GAVFrame ** pFrame);
void       vReleaseVideoFrame(void) ;
void      vSetSupperDrop(BOOL fgDrop);
//////////////////////end of av decode interface////////////////////////////////
//暂停两者不播放
#ifdef SUPPORT_REC_TO_FILE
GBOOL    fgStartRecordToFile(char *pFileName);
void    vStopRecord(void);
#endif


#endif

