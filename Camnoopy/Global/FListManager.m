

#import "FListManager.h"
#import "Contact.h"
#import "ContactDAO.h"
#import "Constants.h"
#import "UDManager.h"
#import "P2PClient.h"
#import "LocalDevice.h"
#import "ShakeManager.h"

@implementation FListManager{
    ;
}


-(void)dealloc{
    [self.map release];
    [self.localDevices release];
    [super dealloc];
}

+ (FListManager *)sharedFList
{
    
    static FListManager *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            DLog(@"Alloc FListManager");
            
            manager = [[FListManager alloc] init];
            [manager setIsReloadData:NO];
            ContactDAO *contactDAO = [[ContactDAO alloc] init];
            
            
            manager.map = [[NSMutableDictionary alloc] initWithCapacity:0];
            manager.localDevices = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSMutableArray *array = [NSMutableArray arrayWithArray:[contactDAO findAll]];
            
            
            for(int i=0;i<[array count];i++){
                Contact *contact = [array objectAtIndex:i];
                if(contact.contactType==CONTACT_TYPE_PHONE){
                    continue;
                }
                [manager.map setObject:contact forKey:contact.contactId];
            }
            
            [contactDAO release];
        }else{
            if([manager isReloadData]&&[UDManager isLogin]){
                ContactDAO *contactDAO = [[ContactDAO alloc] init];
                
                
                manager.map = [[NSMutableDictionary alloc] initWithCapacity:0];
                manager.localDevices = [[NSMutableDictionary alloc] initWithCapacity:0];
                NSMutableArray *array = [NSMutableArray arrayWithArray:[contactDAO findAll]];
                for(int i=0;i<[array count];i++){
                    Contact *contact = [array objectAtIndex:i];
                    if(contact.contactType==CONTACT_TYPE_PHONE){
                        continue;
                    }
                    [manager.map setObject:contact forKey:contact.contactId];
                }
                
                [contactDAO release];
                [manager setIsReloadData:NO];
            }
        }
    }
    return manager;
}



-(NSArray*)getContacts{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for(NSString *key in self.map.allKeys){
        Contact *contact = [self.map objectForKey:key];
        [array addObject:contact];
    }
    
    NSComparator compareByState = ^(id obj1,id obj2){
        Contact *contact1 = (Contact*)obj1;
        Contact *contact2 = (Contact*)obj2;
        if(contact1.onLineState>contact2.onLineState){
            return (NSComparisonResult)NSOrderedAscending;
        }else if(contact1.onLineState<contact2.onLineState){
            return (NSComparisonResult)NSOrderedDescending;
        }else{
            return (NSComparisonResult)NSOrderedSame;
        }
        
    };
    
    return [array sortedArrayUsingComparator:compareByState];
}

-(NSInteger)getType:(NSString *)contactId{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:contactId];
    [contactDAO release];
    if(contact!=nil){
        return contact.contactType;
    }else{
        return CONTACT_TYPE_UNKNOWN;
    }
}

-(void)setTypeWithId:(NSString*)contactId type:(NSInteger)contactType{
    Contact *contact = [self.map objectForKey:contactId];
    
    if(contact!=nil){
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        contact.contactType = contactType;
        
        [contactDAO update:contact];
        [contactDAO release];
    }
    
}

-(NSInteger)getMessageCount:(NSString *)contactId{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:contactId];
    [contactDAO release];
    if(contact!=nil){
        return contact.messageCount;
    }else{
        return 0;
    }

}

-(void)setMessageCountWithId:(NSString *)contactId count:(NSInteger)count{
    Contact *contact = [self.map objectForKey:contactId];
    
    if(contact!=nil){
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        contact.messageCount = count;
        
        [contactDAO update:contact];
        [contactDAO release];
    }
}

-(NSInteger)getState:(NSString *)contactId{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:contactId];
    [contactDAO release];
    if(contact!=nil){
        return contact.onLineState;
    }else{
        return STATE_OFFLINE;
    }
}

-(void)setStateWithId:(NSString *)contactId state:(NSInteger)onlineState{

    Contact *contact = [self.map objectForKey:contactId];
    if(contact!=nil){
        contact.onLineState = onlineState;
        
         contact.isGettingOnLineState = NO;
    }
}

-(void)setIsClickDefenceStateBtnWithId:(NSString*)contactId isClick:(BOOL)isClick{
    Contact *contact = [self.map objectForKey:contactId];
    if(contact!=nil){
        contact.isClickDefenceStateBtn = isClick;
    }
}

-(BOOL)getIsClickDefenceStateBtn:(NSString*)contactId{
    Contact *contact = [self.map objectForKey:contactId];
    if(contact!=nil){
        return contact.isClickDefenceStateBtn;
    }else{
        return NO;
    }
}

-(void)setDefenceStateWithId:(NSString *)contactId type:(NSInteger)defenceState{
    Contact *contact = [self.map objectForKey:contactId];
    if(contact!=nil){
        contact.defenceState = defenceState;
    }
}

-(void)insert:(Contact *)contact{
    
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    [contactDAO insert:contact];
    [contactDAO release];
    
    [self.map setObject:contact forKey:contact.contactId];
}

-(void)delete:(Contact *)contact{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    [contactDAO delete:contact];
    [contactDAO release];
    [self.map removeObjectForKey:contact.contactId];
}

-(void)update:(Contact *)contact{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    [contactDAO update:contact];
    [contactDAO release];
}

-(void)getDefenceStates{
    NSArray *array = [self getContacts];
    for(Contact *contact in array){
//        if(contact.contactType==CONTACT_TYPE_NPC||
//           contact.contactType==CONTACT_TYPE_IPC||
//           contact.contactType==CONTACT_TYPE_DOORBELL){
            [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
//        }
    }
}

-(void)searchLocalDevices{
    @synchronized([FListManager class]){
        if(![[ShakeManager sharedDefault] isSearching]){
            [self.localDevices removeAllObjects];
            
        }
        
    }
    [[ShakeManager sharedDefault] setSearchTime:5];
    [[ShakeManager sharedDefault] setDelegate:self];
    if(![[ShakeManager sharedDefault] search]){
        
        DLog(@"search local devices failure!");
    }
}


@end
