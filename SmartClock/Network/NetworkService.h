//
//  NetworkService.h
//  lid-demo
//
//  Created by taomojingato on 15/4/28.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//http://imessage.hapygirl.com/protocol.html

#import "AFHTTPSessionManager.h"


//#define INTERNAL
#ifdef INTERNAL
#define  hostNameUrlStr                        @"http://imessage.hapygirl.com" //外网
#else
#define  hostNameUrlStr                        @"http://qztank.gicp.net" //内网
#endif

//上传文件URL
static NSString *const uploadUrlStr                                          = @"http://qztank.gicp.net/upload/upload_file.php" ;

//发送信息URL
static NSString *const sendInfoUrlStr                                       = @"/sync.php";

//注册URL
static NSString *const registerUrlStr                                         = @"/register.php";

//登录
static NSString *const loginUrlStr                                              = @"/login.php";


@protocol NetworkServiceDelegate <NSObject>

- (void)requestCompeletion:(id)result ;
- (void)requestFail:(NSString*)fail ;

@end

typedef void(^RequestCompeletionBlock)(id);
typedef void(^RequestFailBlock)(NSString*);

@interface NetworkService : AFHTTPSessionManager

@property(nonatomic , assign)id<NetworkServiceDelegate>networkServiceDelegate ;

//单例
+ (instancetype)sharedClient ;

//上传文件(图片、语音)
- (void)uploadUrl:(NSString*)urlStr
      andFilePath:(NSString*)filePath
            andNetworkServiceDelegate:(id<NetworkServiceDelegate>)networkDelegate
            andCompletionBlock:(RequestCompeletionBlock)compeletionBlock
            andFailBlock:(RequestFailBlock)failBlock;

//开始网络请求
- (void)startNetwork:(NSString*)url
         andParmDict:(NSDictionary*)parmDict
        andNetworkServiceDelegate:(id<NetworkServiceDelegate>)networkDelegate
        andCompletionBlock:(RequestCompeletionBlock)compeletionBlock
        andFailBlock:(RequestFailBlock)failBlock;

@end
