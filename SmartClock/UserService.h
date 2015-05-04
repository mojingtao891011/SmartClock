//
//  UserService.h
//  SmartClock
//
//  Created by taomojingato on 15/5/4.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserService : NSObject

@property (nonatomic , retain)NSManagedObjectContext            *context ;


+(instancetype)shareManager ;

- (void)addUser:(User*)user;

-(User *)getUserByUserID:(NSString*)userID;

-(void)modifyUser:(User *)user;

@end
