//
//  NetworkService.m
//  lid-demo
//
//  Created by taomojingato on 15/4/28.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import "NetworkService.h"
#import "NSMutableURLRequest+Upload.h"


@implementation NetworkService

+ (instancetype)sharedClient
{
    static NetworkService *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NetworkService alloc]initWithBaseURL:[NSURL URLWithString:hostNameUrlStr]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    });
    
    return _sharedClient;
}

- (void)startNetwork:(NSString*)url
         andParmDict:(NSDictionary*)parmDict
        andNetworkServiceDelegate:(id<NetworkServiceDelegate>)networkDelegate
        andCompletionBlock:(RequestCompeletionBlock)compeletionBlock
        andFailBlock:(RequestFailBlock)failBlock
{
    if (networkDelegate) {
        self.networkServiceDelegate = networkDelegate ;
    }
    
    [self POST:url parameters:parmDict success:^(NSURLSessionDataTask *task, id responseObject){
        
        if (_networkServiceDelegate && [_networkServiceDelegate respondsToSelector:@selector(requestCompeletion:)]) {
            [_networkServiceDelegate requestCompeletion:responseObject];
        }
        if (compeletionBlock) {
            compeletionBlock(responseObject);
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        
        if (_networkServiceDelegate && [_networkServiceDelegate respondsToSelector:@selector(requestFail:)]) {
            [_networkServiceDelegate requestFail:@"fail"];
        }
        if (failBlock) {
            failBlock(@"fail");
        }
    }];
}
- (void)uploadUrl:(NSString*)urlStr
            andFilePath:(NSString*)filePath
            andNetworkServiceDelegate:(id<NetworkServiceDelegate>)networkDelegate
            andCompletionBlock:(RequestCompeletionBlock)compeletionBlock
            andFailBlock:(RequestFailBlock)failBlock;

{

    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURL *fileURL = [NSURL URLWithString:filePath];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url fileURL:fileURL name:@"upfile"];

    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (error) {
            
            if (_networkServiceDelegate && [_networkServiceDelegate respondsToSelector:@selector(requestFail:)]) {
                [_networkServiceDelegate requestFail:@"fail"];
            }
            if (failBlock) {
                failBlock(@"fail");
            }
        }
        else
        {
            if (_networkServiceDelegate && [_networkServiceDelegate respondsToSelector:@selector(requestCompeletion:)]) {
                [_networkServiceDelegate requestCompeletion:result];
            }
            if (compeletionBlock) {
                compeletionBlock(result);
            }

        }

    }] resume];

}
@end
