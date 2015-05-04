//
//  MRecord.m
//  
//
//  Created by taomojingato on 15/4/30.
//
//

#import "MRecord.h"
#import "amrFileCodec.h"
#import "RecordService.h"
#import "UserService.h"

@implementation MRecord

{
    NSString *wavPath ;
}

- (id)initWithDelegate:(id<MRecordDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate ;
    }
    return self ;
}
+(instancetype)mRecord:(id<MRecordDelegate>)delegate
{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    //加大音量
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    

    return delegate?[[MRecord alloc]initWithDelegate:delegate]:[[MRecord alloc]init];
}
- (NSTimeInterval)recordTotleTime
{
    NSError * error;
    AVAudioPlayer*play = [[AVAudioPlayer alloc] initWithData:_wavData error:&error];
    NSTimeInterval n = [play duration];
    return n;

}
- (void)startRecord
{
    if (_audioRecorder == nil) {
        NSError *error ;
        _audioRecorder = [[AVAudioRecorder alloc]initWithURL:[self getSavePath] settings:[self getAudioSetting] error:&error];
        _audioRecorder.delegate = self ;
        _audioRecorder.meteringEnabled = YES ;
    
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return ;
        }
    }
    if ([_audioRecorder isRecording]) {
        [_audioRecorder stop];
    }
    else{
        [_audioRecorder record];
        
    }
    
}
- (void)stopRecord
{
    if (_audioRecorder&&[_audioRecorder isRecording]) {
        [_audioRecorder stop];
        
    }
}
-(NSURL *)getSavePath
{
    
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //NSString *dateStr = [NSString stringWithFormat:@"%ld.wav" , (long)[[NSDate date]timeIntervalSince1970]];
    urlStr=[urlStr stringByAppendingPathComponent:@"22.wav"];
    wavPath = urlStr ;
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}
-(NSDictionary *)getAudioSetting
{
    
    /*
        NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
        //设置录音格式
        [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
        //设置录音采样率，8000是电话采样率，对于一般录音已经够了
        [dicM setObject:@(8000) forKey:AVSampleRateKey];
        //设置通道,这里采用单声道
        [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
        //每个采样点位数,分为8、16、24、32
        [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
        //是否使用浮点数采样
        [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
        //....其他设置等
    */
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithFloat:8000.0], AVSampleRateKey,                // 采样率
                              [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                              [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,             // 采样位数 默认 16
                              [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,              // 通道的数目
                              [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,         // 大端还是小端 是内存的组织方式
                              [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,             // 采样信号是整数还是浮点数
                              [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,//音频编码质量
                              nil];
    
    
    return settings;
}

- (void)playRecord:(NSData*)data
{
    NSError *error ;
    _audioPlayer = [[AVAudioPlayer alloc]initWithData:data error:&error];
    if (error) {
        if (_delegate && [_delegate respondsToSelector:@selector(playRecord:)]) {
            [_delegate playRecord:fail];
        }
        return ;
    }
    _audioPlayer.delegate = self ;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}
- (void)stopPlayRecord:(NSData *)data
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
}
- (void)saveToCoredata
{
    
    
    //添加一个对象
    Record *record= [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:[UserService shareManager].context];
    
    record.recordTime = [[NSDate alloc]initWithTimeIntervalSinceReferenceDate:self.recordTotleTime];
    record.wavData = _wavData ;
    record.wavPath = wavPath ;
    record.amrData = _amrData ;
    record.amrPath = _amrpath ;
    record.isSending = [NSNumber numberWithBool:YES];
    record.isSendSuccess = [NSNumber numberWithBool:YES];
    
    User *user = [[UserService shareManager] getUserByUserID:USER_ID];
    record.user = user ;
    
    [[RecordService shareManager] addRecord:record];
}
#pragma mark - AVAudioRecorderDelegate
//录音完成
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        
        
        //将wav转amr
        self.wavData = [NSData dataWithContentsOfURL:[self getSavePath]];
        self.amrData = EncodeWAVEToAMR([NSData dataWithContentsOfURL:[self getSavePath]],1,16);
        
        NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dateStr = [NSString stringWithFormat:@"%ld.amr" , (long)[[NSDate date]timeIntervalSince1970]];
        self.amrpath=[urlStr stringByAppendingPathComponent:dateStr];
        
        if ([self.amrData writeToFile: self.amrpath atomically:YES]) {
            [self saveToCoredata];
        }
       
        
        if (_delegate && [_delegate respondsToSelector:@selector(recordStatus:)]) {
            [_delegate recordStatus:compeletion];
        }
    }
}
//录音失败
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(recordStatus:)]) {
        [_delegate recordStatus:fail];
    }
}
//录音中断
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    if (_delegate && [_delegate respondsToSelector:@selector(recordStatus:)]) {
        [_delegate recordStatus:interruption];
    }
}
//录音中断结束
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
{
    if (_delegate && [_delegate respondsToSelector:@selector(recordStatus:)]) {
        [_delegate recordStatus:endInterruption];
    }
}

#pragma mark-AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        if (_delegate && [_delegate respondsToSelector:@selector(playRecord:)]) {
            [_delegate playRecord:compeletion];
        }
    }
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(playRecord:)]) {
        [_delegate playRecord:fail];
    }
}
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if (_delegate && [_delegate respondsToSelector:@selector(playRecord:)]) {
        [_delegate playRecord:interruption];
    }
}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    if (_delegate && [_delegate respondsToSelector:@selector(playRecord:)]) {
        [_delegate playRecord:endInterruption];
    }
}

@end
