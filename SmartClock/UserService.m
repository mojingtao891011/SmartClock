//
//  UserService.m
//  SmartClock
//
//  Created by taomojingato on 15/5/4.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import "UserService.h"
#import "CoreDataManager.h"

@implementation UserService
+(instancetype)shareManager
{
    static UserService *_shareManager ;
    static dispatch_once_t      onceToken ;
    dispatch_once(&onceToken, ^{
        _shareManager = [[UserService alloc]init];
    });
    return _shareManager ;
}
- (NSManagedObjectContext*)context
{
    return [CoreDataManager shareManager].managedObjContext ;
}
- (void)addUser:(User*)user
{
    [self addUserWithNick:user.nick userID:user.userID password:user.password phoneNunber:user.phoneNunber privatekeys:user.privatekeys];
}
-(void)addUserWithNick:(NSString *)nick userID:(NSString *)userID password:(NSString *)password phoneNunber:(NSString *)phoneNunber privatekeys:(NSString *)privatekeys{
    

    //添加一个对象
    User *us= [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.context];
    
    us.nick = nick ;
    us.userID = userID ;
    us.password = password ;
    us.phoneNunber = phoneNunber ;
    us.privatekeys = privatekeys ;
    
    NSError *error;
    //保存上下文
    if (![self.context save:&error]) {
        NSLog(@"添加过程中发生错误,错误信息：%@！",error.localizedDescription);
    }
    else{
        NSLog(@"save user info success");
    }
}

- (void)modifyUser:(User *)user
{
     [self modifyUserWithNick:user.nick userID:user.userID password:user.password phoneNunber:user.phoneNunber privatekeys:user.privatekeys];
}
-(void)modifyUserWithNick:(NSString *)nick userID:(NSString *)userID password:(NSString *)password phoneNunber:(NSString *)phoneNunber privatekeys:(NSString *)privatekeys{
    User *us=[self getUserByUserID:userID];
    us.nick = nick ;
    us.userID = userID ;
    us.password = password ;
    us.phoneNunber = phoneNunber ;
    us.privatekeys = privatekeys ;
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"修改过程中发生错误,错误信息：%@",error.localizedDescription);
    }
    
}
-(User *)getUserByUserID:(NSString *)userID{
    //实例化查询
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"User"];
    //使用谓词查询是基于Keypath查询的，如果键是一个变量，格式化字符串时需要使用%K而不是%@
    request.predicate=[NSPredicate predicateWithFormat:@"%K=%@",@"userID",userID];
    //    request.predicate=[NSPredicate predicateWithFormat:@"name=%@",name];
    NSError *error;
    User *user;
    //进行查询
    NSArray *results=[self.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"查询过程中发生错误，错误信息：%@！",error.localizedDescription);
    }else{
        user=[results firstObject];
        NSLog(@"get user success");
    }
    
    return user;
}

@end
