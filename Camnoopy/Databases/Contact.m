

#import "Contact.h"
#import "Constants.h"
@implementation Contact
-(void)dealloc{
    DLog(@"release");
    [super dealloc];
}

-(id)init{
    self = [super init];
    if (self) {
        self.messageCount = 0;
        self.defenceState = DEFENCE_STATE_LOADING;
        self.isClickDefenceStateBtn = NO;
    }
    return self;
}

@end
