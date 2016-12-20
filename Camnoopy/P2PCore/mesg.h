#ifndef __MESG_H_
#define __MESG_H_


#define MAXTYPE_ALARM         8
#define MAX_EMAIL_LEN         32
#define MAX_WIFI_SSID_LEN     128
#define MAX_WIFI_PASSWORD_LEN 128
#define MAX_MESSAGE_LEN 1024
#define LIMITIE_TYPE 2


#import "P2PCInterface.h"
//setting ID
enum
{
  MESG_STTING_ID_DEFENCE,//0 off 布防 ; 1 on 撤防
  MESG_STTING_ID_BUZZER,  //0 off ; 1 on 蜂鸣
  MESG_STTING_ID_MOTION_DECT, //0 off; 1 on  移动侦测
  MESG_STTING_ID_RECORD_TYPE, //0 Manual; 1 alarm; 2 schedule 录像类型
  MESG_STTING_ID_M_RECORD_ON, // 0 off; 1 on 手动录像开关
  MESG_STTING_ID_REC_SCHEDULE, //计划录像时间设置
  MESG_STTING_ID_REC_STATUS,   //0 off ; 1 on 录像状态
  MESG_STTING_ID_SOS,          //0 off ; 1 on sos
    
    MESG_STTING_ID_FORMAT,   //0 PAL, 1  NTSC  视频格式
    MESG_STTING_ID_PASSWD,  //  buzuo shit bitch 管理者密码
    
    MESG_STTING_ID_APP,
    MESG_STTING_ID_ALARM_TIME, //  (==11)  报警录像时间
    
    
    
    MESG_STTING_ID_IPSEL,         //(== 12)
    MESG_STTING_ID_NETSEL,       // 13 网络类型 //高两位 1只有有线 2只有WIFI 3两者都有 低两个字节
    
    MESG_STTING_ID_VOL,           // 14 音量 0-9
    
    MESG_STTING_ID_PIC_REVERSE, //  15
    
    
    MESG_STTING_ID_NUM,
    
    MESG_STTING_ID_MAX  = 0xFF,
    
  
};
//错误代码
enum {
    
    MESG_SET_IP_VALUE_ERROR = 91,  //设置网络信息的方式错误,有可能是配置值超出 范围。
    MESG_SET_GW_IP_VALUE_ERROR = 95 //网关和 IP 地址不在同一网段
};
//ftp错误代码
enum {
     MESG_SET_FTP_ERR = 106,  //设置网络信息的方式错误,有可能是用户名,密码,域 名超过最大字符限度。
     MESG_GET_FTP_ERR = 107,  //设置网络信息的方式错误,有可能是网络故障
};
enum{
    MESG_SET_OK,  // 0  设置成功
    MESG_GET_OK,  // 1  取网络信息配置成功
    
    MESG_SET_DEFENCE_ERR,         // 2
    MESG_SET_BUZZER_ERR,           // 3
    MESG_SET_MOTION_DECT_ERR,     // 4
    MESG_SET_RECORD_TYPE_ERR,       // 5
	MESG_SET_M_RECORD_ON_ERR,    // 6
	MESG_SET_REC_SCHEDULE_ERR,  // 7
	MESG_SET_REC_STATUS_ERR,  // 8
	MESG_SET_SOS_ERR,           // 9
	MESG_SET_FORMAT_ERR,    // 10
	MESG_SET_PASSWD_ERR,   // 11
	MESG_SET_APP_ERR,			// 12
	MESG_SET_ALARM_TIME_ERR,   // 13
	MESG_SET_DATETIME_ERR,  // 14
	MESG_SET_EMAIL_ERR,  // 15,
    
	MESG_SET_ID_IPSEL_ERR, // 16
	MESG_SET_ID_NETSEL_ERR,  // 17
    
	MESG_SET_ID_NOTWIFI_ERR, // 18
	MESG_SET_ID_WIFI_SIZE_ERR,  // 19
	MESG_SET_ID_WIFI_PASSWDLEN_ERR,  // 20
	MESG_SET_ID_WIFI_NOMATCHNAME_ERR, // 21
	
    
	MESG_SET_ID_VOL_ERR,          // 22
    
	MESG_SET_ID_ALARMCODE_ERR,   // 23
	MESG_SET_ID_LEARN_ALARMCODE_EXIST,           // 24
	MESG_SET_ID_LEARN_ALARMCODE_LEARNING,        // 25
	MESG_SET_ID_LEARN_ALARMCODE_TIMEOUT,         // 26
	MESG_SET_ID_LEARN_ALARMCODE_OTHER_RESON,     // 27
	MESG_SET_ID_CLEAR_ALARMCODE_FAIL_ERR,        // 28
	MESG_SET_ID_CLEAR_ALARMCODE_LEARNING,        // 29
	MESG_SET_ID_CLEAR_ALARMCODE_CLEAR_YET,       // 30
	MESG_SET_ID_CLEAR_ALARMCODE_OTHER_RESON,     // 31
    
	MESG_SET_ID_LEARN_HAV_SAME_RECORD,         // 32
	MESG_SET_ID_CLEAR_ALARMCODE_SELECT_CLEARYET_ERR,  // 33
	MESG_SET_ID_LEARN_ALARMCODE_ISLEARNING_ERR,  // 34
	MESG_SET_ID_LEARN_ALARMCODE_APPTRANS_ERR,  // 35
	MESG_SET_ID_LEARN_ALARMCODE_SELECT_ERR,  // 36
	MESG_SET_ID_LEARN_ALARMCODE_INVALID_KEY_ERR,   // 37
	MESG_SET_ID_LEARN_ALARMCODE_ISNOTLERAN_KEY_ERR,   // 38
    
	MESG_SET_APPID_NUMS_ERR,          // 39
	MESG_SET_APPID_BIG_ERR,             //40
    
    MESG_SET_ID_ALARMCODE_UBOOT_VERSION_ERR, // 41
	MESG_SET_ID_DRBL_ACK_ERR,  // 42
	MESG_SET_PASSWD_INIT_YET_ERR,   // 43   密码已经被初始化
    
	MESG_SET_DEVICE_NOT_SUPPORT = 0XFF,
};

#define MAX_REMOTE_MESSAGE_NS  16
typedef struct sRemoteMesgRecordsType
{
   DWORD       dwSrcID;                //对方(发送方)ID
   BOOL           fgHasVerifyPassword; //是否已经验证密码。true:已验证;false:未验证;
   DWORD       dwMesgSize;             //消息长度(以字节为单位)
   BYTE           bMesgBody[1024];
}PACKED sRemoteMesgRecordsType;

typedef struct sMesgSetInitPasswdType
{
    BYTE bCmd; //MESG_TYPE_MESSAGE 消息头命令
    BYTE bOption; //0
    WORD wLen; //没用
    BYTE bPasswd[8]; //密码 加密以后的数据
}PACKED sMesgSetInitPasswdType;

//设置初始化密码，用来兼容rtsp密码

typedef struct sMesgSetInitPasswdExtOptType

{
    
    BYTE bCmd; //MESG_TYPE_MESSAGE
    
    BYTE bOption; //0
    
    WORD wLen; //没用
    
    BYTE bPasswd[8]; //密码 加密以后的数据
    
    char 		  cRtspPasswdVerification[32];
    
}PACKED sMesgSetInitPasswdExtOptType;

typedef struct sMesgGSetAppIdType
{
    BYTE    bCmd; //MESG_TYPE_MESSAGE
    BYTE    bOption; //0
    BYTE   bAppIdMAXCount;
    BYTE   bAppIdCount;  // 1 <= wdwAppIdCount <= 3
    DWORD  dwAppId[1];
}PACKED sMesgGSetAppIdType;

typedef struct sMesgGetAlarmCodeType
{
    BYTE    bCmd; //MESG_TYPE_MESSAGE
    BYTE    bOption; //0
    BYTE    bAlarmCodeCount; //8
    BYTE    bAlarmKeySta;
    BYTE   bAlarmCodeSta[MAXTYPE_ALARM];           // MAXTYPE_ALARM = 8
}PACKED sMesgGetAlarmCodeType;



typedef struct sAlarmCodeType
{
    DWORD       dwAlarmCodeID;      //防区值(1 ---8)
    DWORD       dwAlarmCodeIndex;   //通道值(0 ---7)
}PACKED sAlarmCodeType;


typedef struct sMesgAlarmInfoType
{
    BYTE bAlarmMesg[4];
    sAlarmCodeType sAlarmCodes;
}PACKED sMesgAlarmInfoType;

typedef struct sMesgSetAlarmCodeType
{
    BYTE   bCmd; //MESG_TYPE_MESSAGE
    BYTE   bOption; //0
    BYTE   bSetAlarmCodeId; //0  learn ,1  clear
    BYTE   bAlarmCodeCount;// 1    // 1-3
    sAlarmCodeType   sAlarmCodes[1]; // MAXTYPE_ALARM = 8
}PACKED sMesgSetAlarmCodeType; //删除遥控就不能删除房区

typedef struct sNpcWifiListType
{
    BYTE fgReady;
    BYTE bWifiApNs; //wifi个数
    WORD wCurrentConnSSIDIndex; //当前wifi下标
    BYTE bEncTpSigLev[100];     //高四位:类型(0:没有密码 12:有密码)  低四位:信号强度 0-4
    char cAllESSID[1];          //WIFI名字
}PACKED sNpcWifiListType;

typedef struct sAPNpcWifiListType {
    BYTE fgReady; // wifi 是否处于 ready 状态
    BYTE bWifiApNs; // wifi 热点的个数
    WORD wCurConnSSIDIndex; // 当前连接 wifi 编号
    BYTE bEncTpSigLev[100]; // 加密类型 和 信号强度的综合体 每一个 BYTE 按顺序代表 wifi 列表中相应
    //wifi 的加密方式和信号强度, 如 0xAB, A 代表 加密形式 (0 –--- 开放 1 –--- wep 加密 2 --– wpa 加 密),B 代表 信号强度(1 ~ 5,5 为满格信号)。
    char cAllESSID[912]; // 将每个 wifi 的 ssid 按字符串的方式,以 0x00 为间隔分开,逐个排列, 并且按顺 序对于上个数组所代表的加密类型和信号强度。 Size 的值按所搜索到的列表多少而定,最大值 912 BYTE
}PACKED sAPNpcWifiListType ;

typedef struct sMesgLANGetWifiType{
    DWORD dwCmd; //填 LAN_TRANS_AP_WIFI_LIST_GET, 18
    DWORD dwErrNO; //0
    BYTE  bReserve[2];//保留位  填0
    WORD  wMesgSize;// 本次数据包大小  发送请求时填0
    sAPNpcWifiListType sWifiList; // 见下个结构体 发送时每个成员都填 0
}PACKED sMesgLANGetWifiType;


typedef struct sMesgGetWifiListType
{
    BYTE bCmd; //MESG_GET_WIFILIST
    BYTE bOption; //0
    WORD wLen;   //cAllESSID长度
    sNpcWifiListType  sNpcWifiList;
}PACKED sMesgGetWifiListType;

typedef struct sWIFIInfoType
{
    DWORD  dwEncType;  //(0:没有密码 12:有密码)
    char cESSID[MAX_WIFI_SSID_LEN]; //wifi名字
    char cPassword[MAX_WIFI_PASSWORD_LEN]; //密码
}sWIFIInfoType;

typedef struct sDeviceInfoType{
    DWORD      dw3CId;         // 设备3c号
    DWORD 		dwDeviceType;  // 设备类型    //
    BOOL    	fgPasswdFlag;  //设备密码是否已设置 0，未设置， 1，已设置
}sDeviceInfoType;


typedef struct sMesgApModeSetWifiType{
    DWORD dwCmd; // LAN_TRANS_AP_SET_WIFI, //值:16
    DWORD dwErrNO; // 0
    DWORD dwStructSize;// 0
    DWORD dwCurVersion;// 0
    sDeviceInfoType sDeviceInfo;
    sWIFIInfoType sWifiInfo;
}PACKED sMesgApModeSetWifiType;

typedef struct sMesgSetWifiListType
{
    BYTE bCmd; //MESG_SET_WIFIList
    BYTE bOption; //0
    WORD wLen;    //1
    sWIFIInfoType  sPhoneWifiInfo;
}PACKED sMesgSetWifiListType;

typedef struct sSettingType
{
    DWORD       dwSettingID;
    DWORD       dwSettingValue;
}PACKED sSettingType;


typedef struct sMessageSettingsType
{
    BYTE           bCmd;//get set setting
    BYTE           bOption;// 0
    WORD           wSettingCount;
    sSettingType   sSettings[1];
}PACKED  sMessageSettingsType;

//修改ipc密码时用这个结构体。用来兼容rtsp的密码
typedef struct sMessageSettingsExtOptType
{
    BYTE           bCmd;
    BYTE           bOption;
    WORD           wSettingCount;
    sSettingType   sSettings[1];
    char 		  cRtspPasswdVerification[32];
}PACKED  sMessageSettingsExtOptType;

typedef struct sMesgIPConfig{
    BYTE     bCmd;  //MESG_TYPE_GET_IP _CONFIG   103
    BYTE     bOption; // bit0（ 0：只获取 IP， 1 ：所有网络参数 包括网关 IP 与 DNS服务器 子网掩码）
    BYTE     bType;	//   1 -- get Network config
    BYTE     fgIsAuto; // 0
    DWORD  dwIP; // 0
    DWORD  dwSubNetMask; // 0
    DWORD  dwGetWay; // 0
    DWORD  dwDNS; // 0
}PACKED sMesgIPConfig;


typedef struct stFtpSvrMsg {
    char hostname[32];//ip or domain name
    char usrname[32]; // usr name
    char passwd[32]; //passwd
    unsigned short svrport;//server port
    unsigned short usrflag;//enable ftp:1 disable ftp:0
}stSVRMSG;

typedef struct sMesgFtpConfig{
    BYTE bCmd; //MESG_TYPE_GET_FTP 217
    BYTE bOption; // //置 0
    stSVRMSG svrInfo;
}PACKED sMesgFtpConfig;

typedef struct sMesgEmailType
{
    BYTE bCmd; //MESG_TYPE_EMAIL
    BYTE     bOption; //(0:只获取或设置邮箱地址, 1:获取或设置整个SMTP相关信息)
    WORD   wLen;//发件邮箱密码长度
    char     cString[64];//邮箱地址
    
    DWORD  dwSmtpPort;//SMTP端口
    char     cSmtpServer[64];//SMTP服务器(最多支持5个)
    char     cSmtpUser[64];//SMTP服务器地址
    char     cSmtpPwd[64];//Smtp密码
    char     cEmailSubject[64];//Email主题
    char     cEmailContent[96];//Email内容
    BYTE  bEncryptType;//加密类型
    BYTE  bReserve;//根据GET返回值中 bReserver来判断, 如果bReserve =0x01则显示手工设置(固件新版本一律回0x01),  否则不显示
    WORD  wReserver;//预留
}PACKED sMesgEmailType;

typedef struct sMesgStringMesgType
{
    BYTE bCmd; //MESG_TYPE_MESSAGE
    BYTE bOption; //0
    WORD wLen;
    char cString[MAX_MESSAGE_LEN] ;//
}sMesgStringMesgType;

typedef struct sMesgSysVersionType
{
	BYTE bCmd;
    BYTE bOption;
    WORD wLen;
    DWORD dwCurAppVersion;
    DWORD dwUbootVersion;
    DWORD dwKernelVersion;
    DWORD dwRootfsVersion;
    DWORD dwRes[4];
}PACKED sMesgSysVersionType;

typedef struct  sDateTime
{
    WORD    wYear;
     BYTE     bMon;
     BYTE     bDay;
     BYTE     bHour;
     BYTE     bMin;
} sDateTime;

typedef struct  sMesgDateTimeType
{
    BYTE bCmd; //MESG_TYPE_GET_DATETIME
    BYTE bOption; //0
    WORD wOption; //0
    
    sDateTime sMesgSysTime;
    
    //     sDateTime  sMesgSysTime;  // 2000-1-1 0:0
}PACKED sMesgDateTimeType;

typedef struct sSDCardInfo{
    BYTE bSDCardID;
    UINT64 u64SDTotalSpace;
    UINT64 u64SDCardFreeSpace;
}PACKED sSDCardInfo;

typedef struct sMesgSDCardInfoType{
    BYTE bCommandType;
    BYTE bOption;
    WORD wSDCardCount;
    
    sSDCardInfo sSDCard[2];
}PACKED sMesgSDCardInfoType;

typedef struct sMesgSDCardFormatType{
    BYTE bCommandType;
    BYTE bOption;
    WORD wRemainByte;
    BYTE bSDCardID;
}sMesgSDCardFormatType;

#pragma mark - 设置/获取 报警类型摄像头预置位置
typedef struct sMesgAlarmTypePresetMotorPos{
    BYTE  bCmd;
    BYTE	bOption;	 // 0
    BYTE  bAlarmOrDefence; // 0 -- alarm  1 -- defence area
    BYTE  bAlarmType;
    BYTE  bDefenceArea;
    BYTE  bChannel;
    BYTE  bPresetNum;
}PACKED sMesgAlarmTypePresetMotorPos;

#pragma mark - 预置位
typedef struct sMesgPresetMotorPos{
    BYTE    bCmd;          //消息头命令填 MESG_TYPE_SET_MOTOR_PRESET_POS
    BYTE    bOption;	   // 0
    BYTE    bOperation;    // 操作:1 --保存当前预置位 0 –查看预置位位置
    BYTE    bPresetNum;    // 保存/查看预置位位置范围: 0 ~ 4
}PACKED sMesgPresetMotorPos;

typedef struct sMesgGetDefenceSwitchType{
    BYTE    bCmd; //MESG_TYPE_MESSAGE
    BYTE    bOption; //0
    BYTE    bDefenceSetSwitchCount;
    BYTE    bReserve; // 保留区
    BYTE    bDefenceSetSwitch[MAXTYPE_ALARM];  //  MAXTYPE = 8
}PACKED sMesgGetDefenceSwitchType;

typedef struct sAlarmCodesType{
    DWORD       dwAlarmCodeID;//  要设置的防区
    DWORD       dwAlarmCodeIndex;//  要设置的通道
}PACKED sAlarmCodesType;

typedef struct sMesgSetDefenceSwitchType{
    BYTE   bCmd; //MESG_TYPE_MESSAGE
    BYTE   bOption; //0
    BYTE   bSetDefenceSetSwitchId; //  1  on,  0  off
    BYTE   bDefenceSetSwitchCount;
    sAlarmCodeType    sAlarmCodes[1];           // MAXTYPE_ALARM = 8
}PACKED sMesgSetDefenceSwitchType;

typedef struct  sMesgGetRecListType
{
     BYTE bCmd; //MESG_TYPE_GET_REC_LIST
     BYTE bOption; //0
     WORD wOption; //0
     
     sDateTime  sBeginTime;  // 2000-1-1 0:0
     sDateTime  sEndTime ;   // 2100-12-31 23:59
}sMesgGetRecListType;

typedef struct  sRecFilenameType
{
    WORD    wYear;
     BYTE     bMon; /// (bDiscID<<4)|(bMon) for remote
     BYTE     bDay;
     BYTE     bHour;
     BYTE     bMin;
     BYTE     bSec;
     char      cType;//'M','S','A'
}PACKED sRecFilenameType;

typedef struct  sMesgRetRecListType
{
     BYTE bCmd; //MESG_TYPE_RET_REC_LIST
     BYTE bOption0;//0
     BYTE bOption1;//0
     BYTE bFileNs;//
     
     sRecFilenameType   sFileName[1];//files info
}sMesgRetRecListType;

//
typedef struct  sMesgAlarmCallType
{
   BYTE bCmd; //MESG_TYPE_ALARM_CALL
   BYTE bAlarmType;
}sMesgAlarmCallType;

enum{
	LAN_MESG_SET_OK, // 没用
	LAN_MESG_GET_OK,
	LAN_MESG_GET_SHAKE_SIZE_ERR,       // 3
    
	LAN_MESG_GET_DRBL_CHECK_ERR,      // 4
	LAN_MESG_GET_DRBL_IS_NOT_ASK_ERR,        //5
};
enum{
	LAN_TRANS_MIN,          // 没用
	LAN_TRANS_SHAKE_GET,     //
	LAN_TRANS_SHAKE_RET,     //
    
	LAN_TRANS_DRBL_ACK_GET, // 4
    LAN_TRANS_DRBL_ACK_RET,   // 5
    LAN_TRANS_MAX,
    LAN_TRANS_AP_WIFI_LIST_GET = 18,
};
enum AlarmType{
    ALARM_TYPE_NONE,
    ALARM_TYPE_EXT, // 1 外部报警
    ALARM_TYPE_MD,  // 2 移动侦测
    ALARM_TYPE_FORCE,   // 3 紧急
    ALARM_TYPE_DEBUG,   // 4 调试
    ALARM_TYPE_EXT_LINE,    // 5 有线
    ALARM_TYPE_LOW_VOL,     //6  低电压
    ALARM_TYPE_PIR, //7 人体红外
    ALARM_TYPE_DEF_ENABLE, //8 布防
    ALARM_TYPE_DEF_DISABLE, //9 撤防
    ALARM_TYPE_BATTERY_LOW_VOL,//10 电池低电
    ALARM_TYPE_UPDATE_TO_SERVER,    //11参数上传服务器
    ALARM_TYPE_TEMPERATURE,         //12温度报警
    ALARM_TYPE_DOOLBEL = 13,        //门铃报警
    ALARM_TYPE_KEYPRESS,            //按键触发报警
    ALARM_TYPE_REC_FAIL,             //录像失败
    ALARM_TYPE_MAX
};

typedef struct sMesgShakeType{
	DWORD 		dwCmd;        // 	LAN_TRANS_SHAKE_GET
	DWORD 		dwErrNO;      //  错误码
	DWORD 		dwStructSize; // 结构体的大小 sizeof(sMesgShakeType) 28
	DWORD 		dwStrCon;     // 字符串的个数                        0
	sDeviceInfoType 		sDeviceInfo;   //设备的信息
}sMesgShakeType;

typedef struct sUpgMesg
{
    DWORD       dwUpgID;
    DWORD       dwUpgVal;
}PACKED sUpgMesg;


typedef struct sMesgUpgType
{
	BYTE bCmd;     //MESG_TYPE_UPG_DEVICE ,     BYTE bOption; //0
	BYTE bOption;
    WORD wLen;
    sUpgMesg sRemoteUpgMesg;
}PACKED sMesgUpgType;

#pragma mark - 温湿度
typedef  struct  sMesgTHData{
    BYTE  bCmd;   // MESG_TYPE_SET_TH_DATA
    BYTE  bOption;  //  0
    BYTE  bTempOrHumi; // 0  Temperatrue  1  Humidity
    BYTE  bLimiteType;  // 0  Lower_limite  1 Upper_limite
    float  fTemperature; // 当前温度
    float  fTempLmt[LIMITIE_TYPE];//fTempLmt[ 0 ] ： 温度下限值。fTempLmt[ 1 ] ：温度上限值。
    DWORD  dwHumidity; // 当前湿度
    DWORD  dwHumiLmt[LIMITIE_TYPE];//dwHumiLmt[ 0 ] : 湿度下限值。dwHumiLmt[ 1 ] : 湿度上限值
}PACKED  sMesgTHData;
/*注：一次消息只能设置一个限度。*/

#pragma mark - 设备重启
typedef struct sMesgRemoteReboot{
    BYTE  bCmd;
    BYTE	  bOption;	// 0
    BYTE  bRebootType; // 0 -- now      1 --  after dwTimer_s seconds
    BYTE  bReserve;   // 0
    DWORD  dwTimer_s; //  dwTimer_s秒后重启。立即重启填0。
}PACKED sMesgRemoteReboot;

//GPIO口控制
typedef struct sMesgSetGpioCtrl
{
    BYTE bCmd; // MESG_TYPE_SET_GPIO_CTL
    BYTE bOption; // 0
    BYTE bGroup; // GPIO 所属组
    BYTE bPin;  // GPIO 管脚编号
    BYTE bValueNs;  // 波形值改变的个数
    int  iTimer_ms[8];  // 波形依次保持的 时间 ， 以毫秒为单位
}PACKED  sMesgSetGpioCtrl;

#endif






