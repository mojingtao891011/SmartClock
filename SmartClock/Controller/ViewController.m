//
//  ViewController.m
//  SmartClock
//
//  Created by taomojingato on 15/4/29.
//  Copyright (c) 2015年 mojingato. All rights reserved.
//

#import "ViewController.h"
#import "NetworkService.h"
#import "MRecord.h"
#import "RecordService.h"
#import "UserService.h"
#import "User.h"
#import "Tool.h"

@interface ViewController ()< MRecordDelegate>
{
    
    MRecord *_mrecord ;
   
    
}
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passworField;

@end

@implementation ViewController
- (IBAction)testAction:(UIButton *)sender {
//    NSArray *arr = [[RecordService shareManager] getAllRecord];
//    NSLog(@"%@" , arr);
    
    User *user =  [[UserService shareManager]getUserByUserID:USER_ID];
    NSArray *arr = [user.record allObjects];
    NSLog(@"%@" , arr);
    
}

- (void)recordStatus:(Status)status
{
    NSLog(@"record = %d" , status);
}
- (void)playRecord:(Status)status
{
     NSLog(@"play = %d" , status);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mrecord = [MRecord mRecord:self];
    
}
- (IBAction)sendData:(UIButton *)sender
{
    //{"privatekey":"......","command":"putmsg","messages":{"recver":"......","typid":"...","content":"......"}}
    NSDictionary *dict = @{@"privatekey":@"smartclock",@"command":@"putmsg",@"messages":@{@"recver":@"10001",@"typid":@"1",@"content":@"hello"}};
    
        [[NetworkService sharedClient]startNetwork:sendInfoUrlStr andParmDict:dict andNetworkServiceDelegate:nil andCompletionBlock:^(id result){
            NSLog(@"%@" , result);
        }andFailBlock:^(NSString *fail){
            NSLog(@"%@" , fail);
        }];
    
}

- (IBAction)regAction:(id)sender
{
    
    //{"publickey":"......","command":"register","user":{"nick":"......","passwd":"......"}}
    NSDictionary *parmDict = @{  @"publickey" : @"smartclock", @"command" : @"register", @"user":@{@"nick":_usernameField.text , @"passwd":_passworField.text}};
    [[NetworkService sharedClient]startNetwork:registerUrlStr andParmDict:parmDict andNetworkServiceDelegate:nil andCompletionBlock:^(id result){
        NSLog(@"%@" , result);
        if ([Tool isSuccess:@"success" command:@"register" result:result]) {
            NSDictionary *dict = (NSDictionary*)result ;
            [[NSUserDefaults standardUserDefaults]setObject:dict[@"userid"] forKey:@"userid"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }andFailBlock:^(NSString *fail){
        NSLog(@"%@" , fail);
    }];
}
- (IBAction)landAction:(id)sender
{
    //{"publickey":"......","command":"login","user":{"account":"......","passwd":"......"}}
    NSDictionary *parmDict =@ {@"publickey":@"smartclock",@"command":@"login",@"user":@{@"account":_usernameField.text,@"passwd":_passworField.text}};
    [[NetworkService sharedClient]startNetwork:loginUrlStr andParmDict:parmDict andNetworkServiceDelegate:nil andCompletionBlock:^(id result){
        NSLog(@"%@" , result);
        
        if ([Tool isSuccess:@"success" command:@"login" result:result]) {
            NSDictionary *dict = (NSDictionary*)result ;
             NSString *privatekeys = dict[@"privatekey"];
            User *user = [[UserService shareManager] getUserByUserID:USER_ID];
            if (!user) {
                //添加一个对象
                User *us= [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[UserService shareManager].context];
                us.userID = USER_ID;
                us.privatekeys = privatekeys ;
                us.password = _passworField.text ;
                
                [[UserService shareManager] addUser:us];
            }
            else{
                user.privatekeys = privatekeys ;
                [[UserService shareManager]modifyUser:user];
            }
        }
        
    }andFailBlock:^(NSString *fail){
        NSLog(@"%@" , fail);
    }];
}
- (IBAction)startRecord:(UIButton *)sender
{
    sender.selected = !sender.selected ;
    if (sender.selected) {
        [sender setTitle:@"停止录音" forState:0];
        
        [_mrecord startRecord];
    }
    else{
        [sender setTitle:@"开始录音" forState:0];

        [_mrecord stopRecord];
        
    }
    
    
    

}
- (IBAction)playrecord:(UIButton *)sender
{
    NSArray *arr = [[RecordService shareManager] getAllRecordByUserID:USER_ID];
    Record *recordModel = [arr lastObject];
    [_mrecord playRecord:recordModel.wavData];
    
}
- (IBAction)sendRecord:(UIButton *)sender
{

    [[NetworkService sharedClient]uploadUrl:uploadUrlStr andFilePath:_mrecord.amrpath andNetworkServiceDelegate:nil andCompletionBlock:^(id result){
        NSLog(@"%@" , result);
    }andFailBlock:^(NSString *fail){
        NSLog(@"%@" , fail);
    }];
}


@end
