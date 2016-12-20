//
//  UDPManager.m
//  Camnoopy
//
//  Created by wutong on 15-1-13.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//


#import "UDPManager.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "LocalDevice.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "mesg.h"
#import "DeviceWiFi.h"

@implementation UDPManager

-(void)dealloc
{
    [self.LanlDevices release];
    [super dealloc];
}

+ (id)sharedDefault
{
    static UDPManager *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            manager = [[UDPManager alloc] init];
            manager->_socketSender = SWL_INVALID_SOCKET;
            manager->_socketRecevier = SWL_INVALID_SOCKET;
            manager->_localPort = 8899;                                             //_socketRecevier绑定的端口
            manager.LanlDevices = [[NSMutableDictionary alloc] initWithCapacity:0]; //存储数据
            manager.issetwifisuccess = NO;
            manager.isgetwifilist = NO;
            manager->_isConditionOK = NO;
        }
    }
    return manager;
}

- (void)ScanLanDevice
{
    //循环发送命令
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendSearchCmd];
    });
    
    //循环接收数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self recviveData];
    });

    //循环删除超时的设备
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkTimeout];
    });
}

- (void)GetWifiList
{
    self.isgetwifilist = NO;
    //循环发送命令
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self SendCmdForGetWifilist];
    });
}

- (void)SetWifiInfo:(NSInteger)enctype andssid:(NSString *)ssid andpassword:(NSString *)password
{
    self.issetwifisuccess = NO;
    //循环发送命令
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self SendCmdForSetWifiByEncType:enctype ssid:ssid password:password];
    });
}

-(void)CreateSender
{
    SWL_socket_t sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (SWL_INVALID_SOCKET == sock)
    {
        return;
    }
    
    int bOpt = 1;
    int ret = setsockopt(sock, SOL_SOCKET, SO_BROADCAST, (const void*)&bOpt, sizeof(bOpt));
    if (ret != -1) {
        _socketSender = sock;
    }
}

-(void)CreateRevicer
{
    SWL_socket_t sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (SWL_INVALID_SOCKET == sock)
    {
        return;
    }
    
    int ret;
    int nCount = 0;
    //写此while循环的原因：如果端口8899被占用，则绑定会失败，于是端口号+1000再绑定
    while (nCount<20) {
        struct sockaddr_in addr;
        memset((char*)&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_ANY);
        addr.sin_port = htons(_localPort);
        
        ret = bind(sock, (struct sockaddr*)&addr, sizeof(addr));
        if (ret != -1) {
            break;
        }
        else
        {
            _localPort += 1000;
            usleep(10000);
        }
        nCount++;
    }
    if (ret != -1) {
        _socketRecevier = sock;
    }
}

-(void)sendSearchCmd
{
    while (1)
    {
        if (_socketSender == SWL_INVALID_SOCKET) {
            [self CreateSender];
        }
        
        struct sockaddr_in addr;
        memset((char*)&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_BROADCAST);
        addr.sin_port = htons(8899);
        
        char sendBuf = 1;
        const char* inBuffer = &sendBuf;
        long inLength = sizeof(char);
        int val = sendto(_socketSender, inBuffer, inLength, 0, (struct sockaddr*)&addr, sizeof(addr));
        if (val == -1) {
        }
        usleep(5*1000000);
    }
}

-(void)SendCmdForGetWifilist
{
    while (!self.isgetwifilist) {
        if (_socketSender == SWL_INVALID_SOCKET) {
            [self CreateSender];
        }
        //socket地址
        struct sockaddr_in addr;
        memset((char*)&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_BROADCAST);
        //inet_addr("192.168.0.1");
        addr.sin_port = htons(8899);
        
        sMesgLANGetWifiType sMsg;
        memset(&sMsg, 0, sizeof(sMsg));
        sMsg.dwCmd = 18;
        const char* inBuffer = (char*)&sMsg;
        long inLength = sizeof(sMsg);
        
        int val = sendto(_socketSender, inBuffer, inLength, 0, (struct sockaddr*)&addr, sizeof(addr));
        if (val == -1) {
        }
        usleep(5*1000000);
    }
}

-(void)SendCmdForSetWifiByEncType:(NSInteger)encType ssid:(NSString*)ssid password:(NSString*)password
{
    while(!self.issetwifisuccess)
    {
        if (_socketSender == SWL_INVALID_SOCKET) {
            [self CreateSender];
        }
        //socket地址
        struct sockaddr_in addr;
        memset((char*)&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_BROADCAST);
        //inet_addr("192.168.0.1");
        addr.sin_port = htons(8899);
    
        sMesgApModeSetWifiType sMsg;
        memset(&sMsg, 0, sizeof(sMsg));
        sMsg.dwCmd = 16;
        sMsg.sWifiInfo.dwEncType = encType;
        const char * tempstr = [ssid UTF8String];
        memcpy(sMsg.sWifiInfo.cESSID,tempstr,strlen(tempstr));
        tempstr = [password UTF8String];
        memcpy(sMsg.sWifiInfo.cPassword, tempstr, strlen(tempstr));
        
        int val = sendto(_socketSender, (char*)&sMsg, sizeof(sMsg), 0, (struct sockaddr*)&addr, sizeof(addr));
        if (val == -1) {
        }
        usleep(5*1000000);
    }
}

-(void)recviveData
{
    struct sockaddr_in addr_cli;
    int addr_cli_len = sizeof(addr_cli);
    
    char receiveBuffer[MAX_COMMAND_SIZE] = {0};
    long bytes = 0;
    _isReceving = TRUE;
    //_isReceving
    while (_isReceving) {
        if (_socketRecevier == SWL_INVALID_SOCKET)
        {
            [self CreateRevicer];
            if (_socketRecevier == SWL_INVALID_SOCKET) {
                continue;
            }
        }
        bytes = recvfrom(_socketRecevier, (char*)receiveBuffer, MAX_COMMAND_SIZE, 0, (struct sockaddr *)&addr_cli, (socklen_t *)&addr_cli_len);
        if (bytes == -1 || bytes == 0)
        {
            _isReceving = FALSE;
        }
        else if (bytes == 1)
        {
            usleep(1*100000);
        }
        else
        {
            int orderid = *(int*)(receiveBuffer);
            if (orderid == 19) {
                //wifilist结果
                self.isgetwifilist = YES;
                self.WifiListDevices = [NSMutableDictionary dictionary];
                sMesgLANGetWifiType *p =(struct sMesgLANGetWifiType *)(receiveBuffer);
                int wifinumber = (int)(p->sWifiList.bWifiApNs);
                short SSIDIndex = (short)(p->sWifiList.wCurConnSSIDIndex);
                NSString * nowcontactWifi = [NSString stringWithFormat:@"%d",SSIDIndex];
                NSMutableArray * wifilist = [NSMutableArray array];
                char buffer[128];
                int n = 0;
                NSMutableArray * ssidseparr = [NSMutableArray array];
                for(int i=0;i<912;i++){
                    if(p->sWifiList.cAllESSID[i]!='\0'){
                        buffer[n] = p->sWifiList.cAllESSID[i];
                        n++;
                    }else{
                        buffer[n] = '\0';
                        
                        if([NSString stringWithUTF8String:buffer]){
                            
                            [ssidseparr addObject:[NSString stringWithUTF8String:buffer]];
                        }else{
                            [ssidseparr addObject:@"Error Name"];
                        }
                        n = 0;
                    }
                }
                for (int i = 0; i<wifinumber; i++) {
                    DeviceWiFi * wifi = [[DeviceWiFi alloc] init];
                    wifi.wifiname = ssidseparr[i];
                    [wifilist addObject:wifi];
                }
                NSMutableString * contString = [NSMutableString string];
                for (int i =0; i<sizeof(p->sWifiList.bEncTpSigLev); i++) {
                    [contString appendFormat:@"%x ",(p->sWifiList.bEncTpSigLev)[i]];
                }
                NSArray * contseparr = [contString componentsSeparatedByString:@" "];
                NSMutableArray * contmutarr = [NSMutableArray array];
                for (int i = 0; i<wifinumber; i++) {
                    [contmutarr addObject:contseparr[i]];
                }
                
                for (int i = 0; i<[contmutarr count]; i++) {
                    NSInteger  single = [contmutarr[i] integerValue];
                    NSInteger encryptType = single/10;
                    NSInteger siglevel = single%10;
                    DeviceWiFi * wifi = wifilist[i];
                    wifi.encryptType = encryptType;
                    wifi.sigLevel = siglevel;
                }
                [self.WifiListDevices setObject:wifilist forKey:@"wifinamelist"];
                [self.WifiListDevices setObject:nowcontactWifi forKey:@"nowcontactwifi"];
                
                if ([self.getwifidelegate respondsToSelector:@selector(receiveWifiList:)]) {
                    [self.getwifidelegate receiveWifiList:self.WifiListDevices];
                }
            }else if (orderid == 17){
                sMesgApModeSetWifiType *p =(struct sMesgApModeSetWifiType *)(receiveBuffer);
                int dwerrNO = (int)(p->dwErrNO);
                self.issetwifisuccess = YES;
                if (dwerrNO == 0) {
                    if ([self.setwifidelegate respondsToSelector:@selector(setWifiSuccess)]) {
                        [self.setwifidelegate setWifiSuccess];
                    }
                }
            }else if(orderid == 2){
                //局域网结果
                char* szIP = inet_ntoa(addr_cli.sin_addr);
                int isSupportRtsp = *(int*)(&receiveBuffer[12]);
                isSupportRtsp = ((isSupportRtsp>>2)&1);
                int contactId = *(int*)(&receiveBuffer[16]);
                int type = *(int*)(&receiveBuffer[20]);
                int flag = *(int*)(&receiveBuffer[24]);
                
                NSDate* date = [[NSDate alloc]init];
                double interval = [date timeIntervalSince1970];
                [date release];
                
                LocalDevice *localDevice = [[LocalDevice alloc] init];
                localDevice.contactId = [NSString stringWithFormat:@"%i",contactId];
                localDevice.contactType = type;
                localDevice.flag = flag;
                localDevice.isSupportRtsp = isSupportRtsp;
                localDevice.address = [NSString stringWithFormat:@"%s", szIP];
                localDevice.lanTimeInterval = interval;
                @synchronized(self)
                {
                    [self.LanlDevices setObject:localDevice forKey:[NSString stringWithFormat:@"%i",contactId]];
                }
                [localDevice release];
            }
            
        }
    }
}

-(void)checkTimeout
{
    while (1)
    {
        @synchronized(self)
        {
            NSDate* date = [[NSDate alloc]init];
            double interval = [date timeIntervalSince1970];
            [date release];
            
            for(NSString *key in self.LanlDevices.allKeys)
            {
                LocalDevice *localDevice = [self.LanlDevices objectForKey:key];
                if ((interval - localDevice.lanTimeInterval)>60.0)
                {
                    [self.LanlDevices removeObjectForKey:key];
                }
            }
        }
        usleep(3*1000000);
    }
}

-(NSArray*)getLanDevices
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    @synchronized(self)
    {
        for(NSString *key in self.LanlDevices.allKeys)
        {
            LocalDevice *localDevice = [self.LanlDevices objectForKey:key];
            [array addObject:localDevice];
        }
    }
    
    return array;
}

-(void)quitWifiSet
{
    self.issetwifisuccess = NO;
    self.isgetwifilist = NO;
}
@end
