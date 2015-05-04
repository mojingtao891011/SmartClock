//
//  MRecord.h
//  
//
//  Created by taomojingato on 15/4/30.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Record.h"
#import "User.h"
#import "CoreDataManager.h"

typedef enum :NSInteger
{
    compeletion              = 0 ,           //完成
    fail                                 = 1,             //失败
    interruption                 = 2,              //开始中断
    endInterruption         =3               //中断结束
    
}Status;

@protocol MRecordDelegate <NSObject>

- (void)recordStatus:(Status)status ;

- (void)playRecord:(Status)status ;

@end

@interface MRecord : NSObject<AVAudioRecorderDelegate , AVAudioPlayerDelegate>

@property (nonatomic , copy)AVAudioRecorder             *audioRecorder ;
@property (nonatomic , copy)AVAudioPlayer                   *audioPlayer ;
@property (nonatomic , copy)NSData                                  *wavData ;
@property (nonatomic , copy)NSData                                  *amrData ;
@property (nonatomic , copy)NSString                                  *amrpath ;
@property (nonatomic , assign)NSTimeInterval                     recordTotleTime ;

@property (nonatomic , assign)id<MRecordDelegate> delegate ;

+(instancetype)mRecord:(id<MRecordDelegate>)delegate;

- (void)startRecord ;
- (void)stopRecord ;

- (void)playRecord:(NSData*)data ;
- (void)stopPlayRecord:(NSData*)data ;

@end
