//
//  RecordService.h
//  SmartClock
//
//  Created by taomojingato on 15/5/4.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Record.h"

@interface RecordService : NSObject
@property (nonatomic , retain)NSManagedObjectContext            *context ;

+(instancetype)shareManager ;

- (void)addRecord:(Record*)record ;

- (void)removeAllRecordBy:(NSString*)userID;

- (NSArray*)getAllRecordByUserID:(NSString*)userID;

@end
