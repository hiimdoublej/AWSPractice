//
//  SecondViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/14/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "SecondViewController.h"
#import "FBLoginView.h"
#import "DynamoDBActions.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AWSCore/AWSCognitoIdentityService.h>

#define kOFFSET_FOR_KEYBOARD 380.0

@interface SecondViewController ()
@property BOOL commentBoxEditing;
@property UIActivityIndicatorView *activityIndicator;
@end

@implementation SecondViewController
#pragma mark view life cycle

- (void)viewDidLoad {
    [self setupPickerViewData];
    self.activityIndicator  =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.commentBoxEditing = NO;
    self.lock = [NSLock new];
    [self setupRatings];
    [self setupCommentTextView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showElements];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{

}
#pragma mark rating system
-(void)setupRatings
{
    [self.RatingStepper setValue:0.0];
    [self.RatingValue setText:[NSString stringWithFormat:@"%d",(int)self.RatingStepper.value]];
}
- (IBAction)tappedOnStepper {
    [self.RatingValue setText:[NSString stringWithFormat:@"%d",(int)self.RatingStepper.value]];
    //NSLog(@"Stepper value:%f",self.RatingStepper.value);
}
#pragma mark text field methods
-(void)setupPlateNumberInput
{
    [self.plateNumberInput setDelegate:self];
}


#pragma mark keyboard hiding/showing
-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
#pragma mark comment text view configs
-(void)setupCommentTextView
{
    [self.commentTextView setDelegate:self];
    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)hideKeyboard:(UITapGestureRecognizer*) tapG
{
    if([self.plateNumberInput isEditing])
    {
        [self.plateNumberInput resignFirstResponder];
    }else{
        [self.commentTextView resignFirstResponder];
    }
}

-(void)hideKeyboard
{
    if([self.plateNumberInput isEditing])
    {
        [self.plateNumberInput resignFirstResponder];
    }else if(self.commentBoxEditing){
        [self.commentTextView resignFirstResponder];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:self.commentTextView])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            self.commentBoxEditing = YES;
            self.placeHolderForCommentBox.hidden = YES;//hide placeholder
            [self setViewMovedUp:YES];
        }
    }
}

- (void)textViewDidChange:(UITextView *)txtView
{
    self.placeHolderForCommentBox.hidden = ([txtView.text length] > 0);
}

- (void)textViewDidEndEditing:(UITextView *)txtView
{
    if([txtView isEqual:self.commentTextView])
    {
        self.commentBoxEditing = NO;
        self.placeHolderForCommentBox.hidden = ([txtView.text length] > 0);
        [self setViewMovedUp:NO];
    }
}
#pragma mark button action
-(void)showAlertWithTitle:(NSString*)title message:(NSString*)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){}];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:^(void){
        [self.lock unlock];
        [self.activityIndicator stopAnimating];
        [self.Submit setEnabled:YES];
        [[self.Submit titleLabel]setText:@"Submit"];
    }];
}

- (IBAction)LoginButtonClicked:(id)sender {
    //code snippet for bringing fbLoginView up
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBLoginView *fbvc = [sb instantiateViewControllerWithIdentifier:@"FBLoginView"];
    [self presentViewController:fbvc animated:YES completion:^(void){}];
}
- (IBAction)submitInfo:(UIButton *)sender {
    [self hideKeyboard];
    [self AWSPut];
}

#pragma mark AWS-related


- (AWSTask*)AWSPut
{
    if([self.lock tryLock])
    {
        NSLog(@"Inserting into dynamodb....");
        //show network activity indicator
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        //disable button
        [self.Submit setEnabled:NO];
        [[self.Submit titleLabel]setText:@"Submitting....."];
        
        //show activity indicator
        [self.activityIndicator setCenter:CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0)];
        self.activityIndicator.hidesWhenStopped = YES;
        self.activityIndicator.color = [UIColor blackColor];
        
        //add the indicator to the view
        [self.view addSubview:self.activityIndicator];
        //start the indicator animation
        [self.activityIndicator startAnimating];
        
        static BOOL use_facebook_userid = YES;
        
        BOOL inputIsValid = NO;
        //generate a dataID
        NSString *d_id = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
        
        //set user platform
        NSString *platform = [NSString new];
        if([FBSDKAccessToken currentAccessToken])
        {
            platform = @"Facebook";
        }
        //get date string
        UIPickerView *LocationPicker = self.PickerView;
        NSDate *selectedDate = self.DatePicker.date;
        NSDateFormatter *dfDate = [NSDateFormatter new];
        [dfDate setDateFormat:@"MM/dd/yyyy"];
        NSString *dateToBeReported = [dfDate stringFromDate:selectedDate];
        //NSLog([dfDate stringFromDate:selectedDate]);
        
        //get location string
        NSString *locationToBeReported = [NSString new];
        locationToBeReported = [self.topLevelAdministrativeDivisions objectAtIndex:[LocationPicker selectedRowInComponent:0]];
        locationToBeReported = [locationToBeReported stringByAppendingString:@"/"];
        NSArray *temp = [self.secondLevelAdministratiiveDivisions objectForKey:[self.topLevelAdministrativeDivisions objectAtIndex:[LocationPicker selectedRowInComponent:0]]];
        locationToBeReported = [locationToBeReported stringByAppendingString:[temp objectAtIndex:[LocationPicker selectedRowInComponent:1]]];
        
        //get current time from user
        NSDate *now = [NSDate date];
        NSDateFormatter *nsfNow = [NSDateFormatter new];
        [nsfNow setTimeStyle:NSDateFormatterMediumStyle];
        [nsfNow setDateStyle:NSDateFormatterMediumStyle];
        [nsfNow setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+8"]];
        NSString *currentTime = [nsfNow stringFromDate:now];
        
        //get user id (udid or facebook id)
        UIDevice *device = [UIDevice currentDevice];
        NSUUID *uuid = [device identifierForVendor];
        NSString *UUID = (use_facebook_userid) ? [[FBSDKAccessToken currentAccessToken]userID] : [uuid UUIDString];
        
        //get plate number
        NSError *error = NULL;
        NSString *plateInput = [self.plateNumberInput.text uppercaseString];
        if(plateInput.length<9 && plateInput.length>6)
        {//check using regular expression
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                          @"((([A-Z]|[0-9]){2,4}(-)([A-Z]|[0-9]){2,4}))" options:0 error:&error];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:plateInput
                                                                options:0
                                                                  range:NSMakeRange(0, [plateInput length])];
            if(numberOfMatches!=1)
            {
                [self showAlertWithTitle:@"Oops!" message:@"Incorrect plate number, please check your input !"];
            }
            else if(numberOfMatches == 1)
            {
                inputIsValid = YES;
            }
        }
        else{
            [self showAlertWithTitle:@"Oops!" message:@"Plate number length incorrect, please check your input !"];
        }
        
        //get rating
        NSNumber *rating = [NSNumber numberWithDouble:self.RatingStepper.value];
        
        //get comments
        NSString *comments = self.commentTextView.text;
        if(comments.length==0)
        {
            comments = @"No comment.";
        }
        
        if(inputIsValid)
        {
            //submit them to dynamodb
            DDBTableRow *tableRow = [DDBTableRow new];
            tableRow.DataID = d_id;
            tableRow.UserPlatform = platform;
            tableRow.TimeSubmitted = currentTime;
            tableRow.UserID = UUID;
            
            tableRow.RideTime = dateToBeReported;
            tableRow.RideLocation = locationToBeReported;
            tableRow.RideVehiclePlate = plateInput;
            tableRow.OverallRating = rating;
            tableRow.RideComment = comments;
            
            //set dynamodb to report(so that data gets to the wait for approval database)
            [DynamoDBActions setIsReporing:YES];
            
            AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            //default object mapper is the objectmapper with facebook authentication configuration
            return [[[dynamoDBObjectMapper save:tableRow] continueWithExecutor:[AWSExecutor mainThreadExecutor] withSuccessBlock:^id(AWSTask *task)
                     { return nil;
                     }] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task)
                    {
                        if(!task.error)
                        {
                            [self showAlertWithTitle:@"Succeeded" message:@"Successfully submitted data for approval !"];
                        }
                        else
                        {
                            NSLog(@"Error: [%@]", task.error);
                            [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to submit data ! \n Details:%@",task.error]];
                        }
                        [self resetElements];
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        return nil;
                    }];
            
        }else{
            [self showAlertWithTitle:@"Error!" message:@"Unexpected error! Something's wrong badly."];
        }
    }
    return nil;
}



#pragma mark hide-show elements
-(void) showElements
{
    if([FBSDKAccessToken currentAccessToken])
    {
        //logged in
        [self.loginPromptLabel setHidden:YES];
        [self.loginButton setHidden:YES];
        
        [self.whenLabel setHidden:NO];
        [self.whereLabel setHidden:NO];
        [self.DatePicker setHidden:NO];
        [self.PickerView setHidden:NO];
        [self.Submit setHidden:NO];
        [self.plateNumberInput setHidden:NO];
        [self.PlateNumberText setHidden:NO];
        [self.RateLabel setHidden:NO];
        [self.RatingValue setHidden:NO];
        [self.RatingStepper setHidden:NO];
        [self.commentTextView setHidden:NO];
        [self.AnyComments setHidden:NO];
        [self.placeHolderForCommentBox setHidden:NO];
    }
    else
    {
        [self.loginPromptLabel setHidden:NO];
        [self.loginButton setHidden:NO];
        
        [self.whenLabel setHidden:YES];
        [self.whereLabel setHidden:YES];
        [self.DatePicker setHidden:YES];
        [self.PickerView setHidden:YES];
        [self.Submit setHidden:YES];
        [self.plateNumberInput setHidden:YES];
        [self.PlateNumberText setHidden:YES];
        [self.RateLabel setHidden:YES];
        [self.RatingValue setHidden:YES];
        [self.RatingStepper setHidden:YES];
        [self.commentTextView setHidden:YES];
        [self.AnyComments setHidden:YES];
        [self.placeHolderForCommentBox setHidden:YES];
    }
}

-(void)resetElements
{
    [[self DatePicker]setDate:[NSDate date]];
    [[self PickerView]selectRow:0 inComponent:0 animated:YES];
    [[self PickerView]selectRow:0 inComponent:1 animated:YES];
    [[self plateNumberInput]setText:@""];
    [[self RatingStepper]setValue:0.0];
    [[self RatingValue]setText:@"0"];
    [[self commentTextView]setText:@""];
}
#pragma mark picker view delagate methods
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return [self.topLevelAdministrativeDivisions count];
    }
    else{
        NSArray *result = [self.secondLevelAdministratiiveDivisions objectForKey:[self.topLevelAdministrativeDivisions objectAtIndex:[pickerView selectedRowInComponent:0]]];
        return [result count];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;//2 columns
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
    {
        return [self.topLevelAdministrativeDivisions objectAtIndex:row];
    }
    else
    {
        NSArray *result = [self.secondLevelAdministratiiveDivisions objectForKey:[self.topLevelAdministrativeDivisions objectAtIndex:[pickerView selectedRowInComponent:0]]];
        
        return [result objectAtIndex:row];
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //[self resetLocationsTable:[pickerView selectedRowInComponent:0]];
    if(component==0)
    {
        [pickerView reloadComponent:1];
    }
}



#pragma mark location picker data source
-(void)setupPickerViewData
{
    //setup top level
    self.topLevelAdministrativeDivisions = [[NSMutableArray alloc]init];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Taipei",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"New Taipei",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Taichung",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Kaoshiung",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Taoyuan",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Tainan",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Changhua",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Pingtung",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Yunlin",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Miaoli",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Hsinchu",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Chiayi",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Nantou",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Yilan",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Hualien",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Taitung",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Kinmen",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Penghu",@"Generated line")];
    [self.topLevelAdministrativeDivisions addObject:NSLocalizedString(@"Lienchiang",@"Generated line")];
    
    
    //set second level locations
    self.secondLevelAdministratiiveDivisions = [[NSMutableDictionary alloc]init];
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"SongShan",@"Generated line"),NSLocalizedString(@"XinYi",@"Generated line"),NSLocalizedString(@"Da-An",@"Generated line"),NSLocalizedString(@"ZhongShan",@"Generated line"),NSLocalizedString(@"ZhongZheng",@"Generated line"),NSLocalizedString(@"DaTong",@"Generated line"),NSLocalizedString(@"WanHua",@"Generated line"),NSLocalizedString(@"NanGang",@"Generated line"),NSLocalizedString(@"NeiHu",@"Generated line"),NSLocalizedString(@"ShiLin",@"Generated line"),NSLocalizedString(@"BeiTou",@"Generated line"), nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:0]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"BanQiao",@"Generated line"),NSLocalizedString(@"ZhonHe",@"Generated line"),NSLocalizedString(@"XinZhunag",@"Generated line"),NSLocalizedString(@"SanChong",@"Generated line"),NSLocalizedString(@"XinDian",@"Generated line"),NSLocalizedString(@"TuCheng",@"Generated line"),NSLocalizedString(@"YongHe",@"Generated line"),NSLocalizedString(@"LuZhou",@"Generated line"),NSLocalizedString(@"XiZhi",@"Generated line"),NSLocalizedString(@"ShuLin",@"Generated line"),NSLocalizedString(@"TamSui",@"Generated line"),NSLocalizedString(@"SanXia",@"Generated line"),NSLocalizedString(@"LinKou",@"Generated line"),NSLocalizedString(@"YingGe",@"Generated line"),NSLocalizedString(@"WuGu",@"Generated line"),NSLocalizedString(@"TaiShan",@"Generated line"),NSLocalizedString(@"RuiFang",@"Generated line"),NSLocalizedString(@"Bali",@"Generated line"),NSLocalizedString(@"ShenKeng",@"Generated line"),NSLocalizedString(@"SanZhi",@"Generated line"),NSLocalizedString(@"WanLi",@"Generated line"),NSLocalizedString(@"JinShan",@"Generated line"),NSLocalizedString(@"GongLiao",@"Generated line"),NSLocalizedString(@"ShiMen",@"Generated line"),NSLocalizedString(@"ShiDing",@"Generated line"),NSLocalizedString(@"PingLin",@"Generated line"),NSLocalizedString(@"WuLai",@"Generated line"),NSLocalizedString(@"PingXi",@"Generated line"), nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:1]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"BeiTung",@"Generated line"),NSLocalizedString(@"Central",@"Generated line"),NSLocalizedString(@"East",@"Generated line"),NSLocalizedString(@"NanTun",@"Generated line"),NSLocalizedString(@"North",@"Generated line"),NSLocalizedString(@"South",@"Generated line"),NSLocalizedString(@"West",@"Generated line"),NSLocalizedString(@"XiTun",@"Generated line"),NSLocalizedString(@"DaLi",@"Generated line"),NSLocalizedString(@"TaiPing",@"Generated line"),NSLocalizedString(@"WuFeng",@"Generated line"),NSLocalizedString(@"WuRi",@"Generated line"),NSLocalizedString(@"FengYuan",@"Generated line"),NSLocalizedString(@"DongShi",@"Generated line"),NSLocalizedString(@"DaYa",@"Generated line"),NSLocalizedString(@"HePing",@"Generated line"),NSLocalizedString(@"HouLi",@"Generated line"),NSLocalizedString(@"ShenGang",@"Generated line"),NSLocalizedString(@"ShiGana",@"Generated line"),NSLocalizedString(@"TanZi",@"Generated line"),NSLocalizedString(@"XinShe",@"Generated line"),NSLocalizedString(@"DaJia",@"Generated line"),NSLocalizedString(@"QingShui",@"Generated line"),NSLocalizedString(@"ShaLu",@"Generated line"),NSLocalizedString(@"WuQi",@"Generated line"),NSLocalizedString(@"Da-An",@"Generated line"),NSLocalizedString(@"DaDu",@"Generated line"),NSLocalizedString(@"LongJing",@"Generated line"),NSLocalizedString(@"WaiPu",@"Generated line"), nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:2]];
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"FengShan",@"Generated line"),NSLocalizedString(@"SanMin",@"Generated line"),NSLocalizedString(@"ZuoYing",@"Generated line"),NSLocalizedString(@"QianZhen",@"Generated line"),NSLocalizedString(@"NanZi",@"Generated line"),NSLocalizedString(@"LingYa",@"Generated line"),NSLocalizedString(@"XiaoGang",@"Generated line"),NSLocalizedString(@"GuShan",@"Generated line"),NSLocalizedString(@"DaLiao",@"Generated line"),NSLocalizedString(@"GangShan",@"Generated line"),NSLocalizedString(@"RenWu",@"Generated line"),NSLocalizedString(@"LinYuan",@"Generated line"),NSLocalizedString(@"LuZhu",@"Generated line"),NSLocalizedString(@"XinXing",@"Generated line"),NSLocalizedString(@"NiaoSong",@"Generated line"),NSLocalizedString(@"DaShu",@"Generated line"),NSLocalizedString(@"MeiNong",@"Generated line"),NSLocalizedString(@"QiShang",@"Generated line"),NSLocalizedString(@"QiaoTou",@"Generated line"),NSLocalizedString(@"ZiGuan",@"Generated line"),NSLocalizedString(@"DaShe",@"Generated line"),NSLocalizedString(@"QieDing",@"Generated line"),NSLocalizedString(@"YanChao",@"Generated line"),NSLocalizedString(@"HuNei",@"Generated line"),NSLocalizedString(@"ALian",@"Generated line"),NSLocalizedString(@"QiJin",@"Generated line"),NSLocalizedString(@"YanCheng",@"Generated line"),NSLocalizedString(@"MiTuo",@"Generated line"),NSLocalizedString(@"NeiMen",@"Generated line"),NSLocalizedString(@"YongAn",@"Generated line"),NSLocalizedString(@"LiuGui",@"Generated line"),NSLocalizedString(@"ShanLin",@"Generated line"),NSLocalizedString(@"TianLiao",@"Generated line"),NSLocalizedString(@"JiaXian",@"Generated line"),NSLocalizedString(@"TaoYuan",@"Generated line"),NSLocalizedString(@"NaMaXia",@"Generated line"),NSLocalizedString(@"MaoLin",@"Generated line"), nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:3]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"TaoYuan City",@"Generated line"),NSLocalizedString(@"ZhongLi",@"Generated line"),NSLocalizedString(@"PingZhen",@"Generated line"),NSLocalizedString(@"Bade",@"Generated line"),NSLocalizedString(@"YangMei",@"Generated line"),NSLocalizedString(@"LuZhu",@"Generated line"),NSLocalizedString(@"GuiShan",@"Generated line"),NSLocalizedString(@"LongTan",@"Generated line"),NSLocalizedString(@"DaXi",@"Generated line"),NSLocalizedString(@"DaYuan",@"Generated line"),NSLocalizedString(@"GuanYin",@"Generated line"),NSLocalizedString(@"XinWu",@"Generated line"),NSLocalizedString(@"FuXing",@"Generated line"), nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:4]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Anding",@"Generated line"), NSLocalizedString(@"Annan",@"Generated line"), NSLocalizedString(@"Anping",@"Generated line"), NSLocalizedString(@"Baihe",@"Generated line"), NSLocalizedString(@"Beimen",@"Generated line"), NSLocalizedString(@"Danei",@"Generated line"),NSLocalizedString(@"Dongshan",@"Generated line"),NSLocalizedString(@"East",@"Generated line"),NSLocalizedString(@"Guanmiao",@"Generated line"),NSLocalizedString(@"Guantian",@"Generated line"),NSLocalizedString(@"Guiren",@"Generated line"), NSLocalizedString(@"Houbi",@"Generated line"),NSLocalizedString(@"Jiali",@"Generated line"),NSLocalizedString(@"Jiangjun",@"Generated line"),NSLocalizedString(@"Liujia",@"Generated line"),NSLocalizedString(@"Liuying",@"Generated line"),NSLocalizedString(@"Longqi",@"Generated line"),NSLocalizedString(@"Madou",@"Generated line"),NSLocalizedString(@"Nanhua",@"Generated line"),NSLocalizedString(@"Nanxi",@"Generated line"),NSLocalizedString(@"North",@"Generated line"), NSLocalizedString(@"Qigu",@"Generated line"),NSLocalizedString(@"Rende",@"Generated line"),NSLocalizedString(@"Shanhua",@"Generated line"),NSLocalizedString(@"Shanshang",@"Generated line"),NSLocalizedString(@"South",@"Generated line"),NSLocalizedString(@"West Central",@"Generated line"),NSLocalizedString(@"Xiaying",@"Generated line"),NSLocalizedString(@"Xigang",@"Generated line"),NSLocalizedString(@"Xinhua",@"Generated line"),NSLocalizedString(@"Xinshi",@"Generated line"),NSLocalizedString(@"Xinying",@"Generated line"),NSLocalizedString(@"Xuejia",@"Generated line"),NSLocalizedString(@"Yanshui",@"Generated line"),NSLocalizedString(@"Yongkang",@"Generated line"),NSLocalizedString(@"Yujing",@"Generated line"),NSLocalizedString(@"Zuozhen",@"Generated line"), nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:5]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Changhua",@"Generated line"),NSLocalizedString(@"Yuanlin",@"Generated line"),NSLocalizedString(@"Beidou",@"Generated line"),NSLocalizedString(@"Erlin",@"Generated line"),NSLocalizedString(@"Hemei",@"Generated line"),NSLocalizedString(@"Lukang",@"Generated line"),NSLocalizedString(@"Tianzhong",@"Generated line"),@"Xihu",NSLocalizedString(@"Dacheng",@"Generated line"),NSLocalizedString(@"Dacun",@"Generated line"),NSLocalizedString(@"Ershui",@"Generated line"),NSLocalizedString(@"Fangyuan",@"Generated line"),NSLocalizedString(@"Fenyuan",@"Generated line"),NSLocalizedString(@"Fuxing",@"Generated line"),NSLocalizedString(@"Huatan",@"Generated line"),NSLocalizedString(@"Pitou",@"Generated line"),NSLocalizedString(@"Puxin",@"Generated line"),NSLocalizedString(@"Puyan",@"Generated line"),NSLocalizedString(@"Shengang",@"Generated line"),NSLocalizedString(@"Shetou",@"Generated line"),NSLocalizedString(@"Tianwei",@"Generated line"),NSLocalizedString(@"Xianxi",@"Generated line"),NSLocalizedString(@"Xiushui",@"Generated line"),NSLocalizedString(@"Xizhou",@"Generated line"),NSLocalizedString(@"Yongjing",@"Generated line"),NSLocalizedString(@"Zhutang",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:6]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Pingtung",@"Generated line"),NSLocalizedString(@"Chaozhou",@"Generated line"),NSLocalizedString(@"Donggang",@"Generated line"),NSLocalizedString(@"Hengchun",@"Generated line"),NSLocalizedString(@"Changzhi",@"Generated line"),NSLocalizedString(@"Checheng",@"Generated line"),NSLocalizedString(@"Fangliao",@"Generated line"),NSLocalizedString(@"Fangshan",@"Generated line"),NSLocalizedString(@"Gaoshu",@"Generated line"),NSLocalizedString(@"Jiadong",@"Generated line"),NSLocalizedString(@"Jiuru",@"Generated line"),NSLocalizedString(@"Kanding",@"Generated line"),NSLocalizedString(@"Ligang",@"Generated line"),NSLocalizedString(@"Linbian",@"Generated line"),NSLocalizedString(@"Linluo",@"Generated line"),NSLocalizedString(@"Liuqiu",@"Generated line"),NSLocalizedString(@"Manzhou",@"Generated line"),NSLocalizedString(@"Nanzhou",@"Generated line"),NSLocalizedString(@"Neipu",@"Generated line"),NSLocalizedString(@"Wandan",@"Generated line"),NSLocalizedString(@"Wanluan",@"Generated line"),NSLocalizedString(@"Xinpi",@"Generated line"),NSLocalizedString(@"Xinyuan",@"Generated line"),NSLocalizedString(@"Yanpu",@"Generated line"),NSLocalizedString(@"Zhutian",@"Generated line"),NSLocalizedString(@"Chunri",@"Generated line"),NSLocalizedString(@"Laiyi",@"Generated line"),NSLocalizedString(@"Majia",@"Generated line"),NSLocalizedString(@"Mudan",@"Generated line"),NSLocalizedString(@"Sandimen",@"Generated line"),NSLocalizedString(@"Shizi",@"Generated line"),NSLocalizedString(@"Taiwu",@"Generated line"),NSLocalizedString(@"Wutai",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:7]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Douliu",@"Generated line"),NSLocalizedString(@"Beigang",@"Generated line"),NSLocalizedString(@"Dounan",@"Generated line"),NSLocalizedString(@"Huwei",@"Generated line"),NSLocalizedString(@"Tuku",@"Generated line"),NSLocalizedString(@"Xiluo",@"Generated line"),NSLocalizedString(@"Baozhong",@"Generated line"),NSLocalizedString(@"Citong",@"Generated line"),NSLocalizedString(@"Dapi",@"Generated line"),NSLocalizedString(@"Dongshi",@"Generated line"),NSLocalizedString(@"Erlun",@"Generated line"),NSLocalizedString(@"Gukeng",@"Generated line"),NSLocalizedString(@"Kouhu",@"Generated line"),NSLocalizedString(@"Linnei",@"Generated line"),NSLocalizedString(@"Lunbei",@"Generated line"),NSLocalizedString(@"Mailiao",@"Generated line"),NSLocalizedString(@"Shuilin",@"Generated line"),NSLocalizedString(@"Sihu",@"Generated line"),NSLocalizedString(@"Taixi",@"Generated line"),NSLocalizedString(@"Yuanchang",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:8]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Miaoli",@"Generated line"),NSLocalizedString(@"Toufen",@"Generated line"),NSLocalizedString(@"Houlong",@"Generated line"),NSLocalizedString(@"Tongxiao",@"Generated line"),NSLocalizedString(@"Yuanli",@"Generated line"),NSLocalizedString(@"Zhunan",@"Generated line"),NSLocalizedString(@"Zhuolan",@"Generated line"),NSLocalizedString(@"Dahu",@"Generated line"),NSLocalizedString(@"Gongguan",@"Generated line"),NSLocalizedString(@"Nanzhuang",@"Generated line"),NSLocalizedString(@"Sanwan",@"Generated line"),NSLocalizedString(@"Sanyi",@"Generated line"),NSLocalizedString(@"Shitan",@"Generated line"),NSLocalizedString(@"Tongluo",@"Generated line"),NSLocalizedString(@"Touwu",@"Generated line"),NSLocalizedString(@"Xihu",@"Generated line"),NSLocalizedString(@"Zaoqiao",@"Generated line"),NSLocalizedString(@"Tai'an",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:9]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Zhubei",@"Generated line"),NSLocalizedString(@"Hukou",@"Generated line"), NSLocalizedString(@"Xinfeng",@"Generated line"),NSLocalizedString(@"Xinpu",@"Generated line"),NSLocalizedString(@"Zhudong",@"Generated line"),NSLocalizedString(@"Baoshan",@"Generated line"),NSLocalizedString(@"Beipu",@"Generated line"),NSLocalizedString(@"Emei",@"Generated line"),NSLocalizedString(@"Guanxi",@"Generated line"),NSLocalizedString(@"Hengshan",@"Generated line"),NSLocalizedString(@"Qionglin",@"Generated line"),NSLocalizedString(@"Jianshi",@"Generated line"),NSLocalizedString(@"Wufeng",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:10]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Puzi",@"Generated line"),NSLocalizedString(@"Taibao",@"Generated line"),NSLocalizedString(@"Budai",@"Generated line"),NSLocalizedString(@"Dalin",@"Generated line"),NSLocalizedString(@"Dapu",@"Generated line"),NSLocalizedString(@"Dongshi",@"Generated line"),NSLocalizedString(@"Fanlu",@"Generated line"),NSLocalizedString(@"Liujiao",@"Generated line"),NSLocalizedString(@"Lucao",@"Generated line"),NSLocalizedString(@"Meishan",@"Generated line"),NSLocalizedString(@"Minxiong",@"Generated line"),NSLocalizedString(@"Shuishang",@"Generated line"),NSLocalizedString(@"Xikou",@"Generated line"),NSLocalizedString(@"Xingang",@"Generated line"),NSLocalizedString(@"Yizhu",@"Generated line"),NSLocalizedString(@"Zhongpu",@"Generated line"),NSLocalizedString(@"Zhuqi",@"Generated line"),NSLocalizedString(@"Alishan",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:11]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Nantou",@"Generated line"),NSLocalizedString(@"Caotun",@"Generated line"),NSLocalizedString(@"Jiji",@"Generated line"),NSLocalizedString(@"Puli",@"Generated line"),NSLocalizedString(@"Zhushan",@"Generated line"),NSLocalizedString(@"Guoxing",@"Generated line"),NSLocalizedString(@"Lugu",@"Generated line"),NSLocalizedString(@"Mingjian",@"Generated line"),NSLocalizedString(@"Shuili",@"Generated line"),NSLocalizedString(@"Yuchi",@"Generated line"),NSLocalizedString(@"Zhongliao",@"Generated line"),NSLocalizedString(@"Ren'ai",@"Generated line"),NSLocalizedString(@"Xinyi",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:12]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Yilan",@"Generated line"),NSLocalizedString(@"Luodong",@"Generated line"),NSLocalizedString(@"Su'ao",@"Generated line"),NSLocalizedString(@"Toucheng",@"Generated line"),NSLocalizedString(@"Dongshan",@"Generated line"),NSLocalizedString(@"Jiaoxi",@"Generated line"),NSLocalizedString(@"Sanxing",@"Generated line"),NSLocalizedString(@"Wujie",@"Generated line"),NSLocalizedString(@"Yuanshan",@"Generated line"),NSLocalizedString(@"Zhuangwei",@"Generated line"),NSLocalizedString(@"Datong",@"Generated line"),NSLocalizedString(@"Nan'ao",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:13]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Hualien",@"Generated line"),NSLocalizedString(@"Fenglin",@"Generated line"),NSLocalizedString(@"Yuli",@"Generated line"),NSLocalizedString(@"Fengbin",@"Generated line"),NSLocalizedString(@"Fuli",@"Generated line"),NSLocalizedString(@"Guangfu",@"Generated line"),NSLocalizedString(@"Ji'an",@"Generated line"),NSLocalizedString(@"Ruisui",@"Generated line") ,NSLocalizedString(@"Shoufeng",@"Generated line"),NSLocalizedString(@"Xincheng",@"Generated line"),NSLocalizedString(@"Wanrong",@"Generated line"),NSLocalizedString(@"Xiulin",@"Generated line"),NSLocalizedString(@"Zhuoxi",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:14]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Taitung",@"Generated line"),NSLocalizedString(@"Chenggong",@"Generated line"),NSLocalizedString(@"Guanshan",@"Generated line"),NSLocalizedString(@"Beinan",@"Generated line"),NSLocalizedString(@"Changbin",@"Generated line"),NSLocalizedString(@"Chishang",@"Generated line"),NSLocalizedString(@"Dawu",@"Generated line"),NSLocalizedString(@"Donghe",@"Generated line"),NSLocalizedString(@"Luye",@"Generated line"),NSLocalizedString(@"Lüdao",@"Generated line"),NSLocalizedString(@"Taimali",@"Generated line"),NSLocalizedString(@"Daren",@"Generated line"),NSLocalizedString(@"Haiduan",@"Generated line") ,NSLocalizedString(@"Jinfeng",@"Generated line"),NSLocalizedString(@"Lanyu",@"Generated line"),NSLocalizedString(@"Yanping",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:15]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Jincheng",@"Generated line"),NSLocalizedString(@"Jinhu",@"Generated line"),NSLocalizedString(@"Jinsha",@"Generated line"),NSLocalizedString(@"Jinning",@"Generated line"),NSLocalizedString(@"Lieyu",@"Generated line"),NSLocalizedString(@"Wuqiu",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:16]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Magong",@"Generated line"),NSLocalizedString(@"Baisha",@"Generated line"),NSLocalizedString(@"Huxi",@"Generated line"),NSLocalizedString(@"Qimei",@"Generated line"),NSLocalizedString(@"Xiyu",@"Generated line"),NSLocalizedString(@"Wang'an",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:17]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:NSLocalizedString(@"Nangan",@"Generated line"),NSLocalizedString(@"Beigan",@"Generated line") ,NSLocalizedString(@"Dongyin",@"Generated line"),NSLocalizedString(@"Juguang",@"Generated line"),nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:18]];
    
    [self.PickerView reloadAllComponents];
}


@end
