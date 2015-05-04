//
//  CoreDataManager.h
//  SmartClock
//
//  Created by taomojingato on 15/5/4.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property(nonatomic , retain)NSManagedObjectContext  *managedObjContext ;

+(instancetype)shareManager ;

@end
