//
//  Tool.h
//  SmartClock
//
//  Created by taomojingato on 15/5/4.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tool : NSObject

//判断请求是否成功
+(BOOL)isSuccess:(NSString *)success command:(NSString*)command result:(id)result ;

@end
