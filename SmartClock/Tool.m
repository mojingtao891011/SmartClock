//
//  Tool.m
//  SmartClock
//
//  Created by taomojingato on 15/5/4.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import "Tool.h"

@implementation Tool

+(BOOL)isSuccess:(NSString *)success command:(NSString*)command result:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)result ;
        NSString *resultStr = dict[@"result"];
        NSString *commandStr = dict[@"command"];
        
        if ([resultStr isEqualToString:success] && [commandStr isEqualToString:command]) {
            return YES ;
        }
    }
    
    return NO ;
}
@end
