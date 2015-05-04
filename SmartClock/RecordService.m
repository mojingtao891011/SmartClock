//
//  RecordService.m
//  SmartClock
//
//  Created by taomojingato on 15/5/4.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import "RecordService.h"
#import "CoreDataManager.h"


@implementation RecordService
+(instancetype)shareManager
{
    static RecordService *_shareManager = nil ;
    static dispatch_once_t      onceToken ;
    dispatch_once(&onceToken, ^{
        _shareManager = [[RecordService alloc]init];
        
    });
    
    return _shareManager ;
}

- (NSManagedObjectContext*)context
{
    return [CoreDataManager shareManager].managedObjContext ;
}
- (void)addRecord:(Record *)record
{
    [self addRecordWithRecordTime:record.recordTime wavData:record.wavData wavPath:record.wavPath amrData:record.amrData amrPath:record.amrPath isSending:record.isSending isSendSuccess:record.isSendSuccess user:record.user];
}
- (void)addRecordWithRecordTime:(NSDate *)recordTime wavData:(NSData *)wavData wavPath:(NSString *)wavPath amrData:(NSData *)amrData amrPath:(NSString *)amrPath isSending:(NSNumber *)isSending isSendSuccess:(NSNumber *)isSendSuccess user:(User *)user
{
    
    //添加一个对象
     Record*recordObj= [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:self.context];
    
    recordObj.recordTime = recordTime ;
    recordObj.wavData = wavData ;
    recordObj.wavPath = wavPath ;
    recordObj.amrData = amrData ;
    recordObj.amrPath = amrPath ;
    recordObj.isSending = isSending ;
    recordObj.isSendSuccess = isSendSuccess ;
    recordObj.user = user ;
    
    NSError *error;
    //保存上下文
    if (![self.context save:&error]) {
        NSLog(@"添加过程中发生错误,错误信息：%@！",error.localizedDescription);
    }
    else{
        NSLog(@"Save record info success");
    }
}
- (void)removeAllRecordBy:(NSString *)userID
{
    
}
- (NSArray*)getAllRecordByUserID:(NSString*)userID
{
    NSError *error;
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Record"];
    request.predicate=[NSPredicate predicateWithFormat:@"User.userID=%@",userID];
    NSArray *array=[self.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"查询过程中发生错误,错误信息：%@！",error.localizedDescription);
        return nil ;
    }
    
    return  array;

}
@end
