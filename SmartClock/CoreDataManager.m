//
//  CoreDataManager.m
//  SmartClock
//
//  Created by taomojingato on 15/5/4.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager
+(instancetype)shareManager
{
    static CoreDataManager *_shareManager = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [[CoreDataManager alloc]init];
        
    });
    return _shareManager ;
}
- (id)init
{
    if (self = [super init]) {
        _managedObjContext = [self createContext];
    }
    return self ;
}
- (NSManagedObjectContext*)createContext{
    NSManagedObjectContext *context;
    //打开模型文件，参数为nil则打开包中所有模型文件并合并成一个
    NSManagedObjectModel *model=[NSManagedObjectModel mergedModelFromBundles:nil];
    //创建解析器
    NSPersistentStoreCoordinator *storeCoordinator=[[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
    //创建数据库保存路径
    NSString *dir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *path=[dir stringByAppendingPathComponent:@"myDatabase.db"];
    NSURL *url=[NSURL fileURLWithPath:path];
    //添加SQLite持久存储到解析器
    NSError *error;
    [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
    if(error){
        NSLog(@"数据库打开失败！错误:%@",error.localizedDescription);
    }else{
        context=[[NSManagedObjectContext alloc]init];
        context.persistentStoreCoordinator=storeCoordinator;
        NSLog(@"数据库打开成功！");
    }
    return context;
}


@end
