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
    [self setupPickerViewData2];
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
        [[self.Submit titleLabel]setText:NSLocalizedString(@"Submitting.....",@"Submitting data to dynamodb")];
        
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
        [nsfNow setLocale:[NSLocale localeWithLocaleIdentifier:@"en"]];
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
                [self showAlertWithTitle:NSLocalizedString(@"Oops!",@"alert") message:NSLocalizedString(@"Incorrect plate number, please check your input !",@"alert msg")];
            }
            else if(numberOfMatches == 1)
            {
                inputIsValid = YES;
            }
        }
        else{
            [self showAlertWithTitle:NSLocalizedString(@"Oops!",@"alert") message:NSLocalizedString(@"Plate number length incorrect, please check your input !",@"alert msg")];
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
                            [self showAlertWithTitle:NSLocalizedString(@"Succeeded",@"Succeeded") message:NSLocalizedString(@"Successfully submitted data for approval !",@"alert msg")];
                        }
                        else
                        {
                            NSLog(@"Error: [%@]", task.error);
                            [self showAlertWithTitle:NSLocalizedString(@"Error",@"error") message:NSLocalizedString([NSString stringWithFormat:@"Failed to submit data ! \n Please try again in a moment."],@"error msg")];
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
        NSString *res = NSLocalizedString([self.topLevelAdministrativeDivisions objectAtIndex:row],@"localize string for chinese (zh-Hant)");
        return res;
    }
    else
    {
        NSArray *result = [self.secondLevelAdministratiiveDivisions objectForKey:[self.topLevelAdministrativeDivisions objectAtIndex:[pickerView selectedRowInComponent:0]]];
        if(row > result.count) return nil;//preventing a bug where you select a deep row first then switch to another division without a row at that deep of a position
//        return [result objectAtIndex:row];
        
        //edited
        NSString *res = NSLocalizedString([result objectAtIndex:row],@"localize string for chinese(zh-Hant)");
        return res;
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //[self resetLocationsTable:[pickerView selectedRowInComponent:0]];
    if(component==0)
    {
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
    }
}



#pragma mark location picker data source
-(void)setupPickerViewData2
{
        //setup top level
        self.topLevelAdministrativeDivisions = [[NSMutableArray alloc]init];
        [self.topLevelAdministrativeDivisions addObject:@"Taipei"];
        [self.topLevelAdministrativeDivisions addObject:@"NewTaipei"];
        [self.topLevelAdministrativeDivisions addObject:@"Taichung"];
        [self.topLevelAdministrativeDivisions addObject:@"Kaohsiung"];
        [self.topLevelAdministrativeDivisions addObject:@"Taoyuan City"];
        [self.topLevelAdministrativeDivisions addObject:@"Keelung"];
        [self.topLevelAdministrativeDivisions addObject:@"Tainan"];
        [self.topLevelAdministrativeDivisions addObject:@"Changhua"];
        [self.topLevelAdministrativeDivisions addObject:@"PingTung"];
        [self.topLevelAdministrativeDivisions addObject:@"Yunlin"];
        [self.topLevelAdministrativeDivisions addObject:@"Miaoli"];
        [self.topLevelAdministrativeDivisions addObject:@"Hsinchu"];
        [self.topLevelAdministrativeDivisions addObject:@"Chiayi"];
        [self.topLevelAdministrativeDivisions addObject:@"Nantou"];
        [self.topLevelAdministrativeDivisions addObject:@"Yilan"];
        [self.topLevelAdministrativeDivisions addObject:@"Hualien"];
        [self.topLevelAdministrativeDivisions addObject:@"Taitung"];
        [self.topLevelAdministrativeDivisions addObject:@"Kinmen"];
        [self.topLevelAdministrativeDivisions addObject:@"Penghu"];
        [self.topLevelAdministrativeDivisions addObject:@"Lienchiang"];
        
        
        //set second level locations
        self.secondLevelAdministratiiveDivisions = [[NSMutableDictionary alloc]init];
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Songshan",@"XinYi",@"Da-An",@"Zhongshan",@"Zhongzheng",@"DaTong",@"Wanhua",@"Nangang",@"Neihu",@"Shilin",@"Beitou", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:0]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Banqiao",@"Zhonghe",@"Xinzhuang",@"Sanchong",@"Xindian",@"Tucheng",@"Yonghe",@"Luzhou",@"Xizhi",@"Shulin",@"Tamsui",@"Sanxia",@"Linkou",@"Yingge",@"Wugu",@"Taishan",@"Ruifang",@"Bali",@"Shenkeng",@"Sanzhi",@"Wanli",@"Jinshan",@"Gongliao",@"Shimen",@"Shiding",@"Pinglin",@"Wulai",@"Pingxi", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:1]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Beitun",@"Central",@"East",@"Nantun",@"North",@"South",@"West",@"Xitun",@"Dali",@"Taiping",@"Wufeng",@"Wuri",@"Fengyuan",@"Dongshi",@"Daya",@"Heping",@"Houli",@"Shengang",@"Shigang",@"Tanzi",@"Xinshe",@"Dajia",@"Qingshui",@"Shalu",@"Wuqi",@"Da-An",@"Dadu",@"Longjing",@"Waipu", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:2]];
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Fengshan",@"Sanmin",@"Zuoying",@"Qianzhen",@"Nanzi",@"Lingya",@"Xiaogang",@"Gushan",@"Daliao",@"Gangshan",@"Renwu",@"Linyuan",@"Luzhu",@"Xinxing",@"Niaosong",@"Dashu",@"Meinong",@"Qishan",@"Qiaotou",@"Ziguan",@"Dashe",@"Qieding",@"Yanchao",@"Hunei",@"Alian",@"Qijin",@"Yancheng",@"Mituo",@"Neimen",@"Yong-An",@"Liugui",@"Shanlin",@"Tianliao",@"Jiaxian",@"Taoyuan",@"Namaxia",@"Maolin", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:3]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"TaoYuan",@"Zhongli",@"Pingzhen",@"Bade",@"Yangmei",@"Luzhu",@"Guishan",@"Longtan",@"Daxi",@"Dayuan",@"Guanyin",@"Xinwu",@"Fuxing", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:4]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Anle",@"Nuannuan",@"Qidu",@"Ren-Ai",@"XinYi",@"Zhongshan",@"Zhongzheng",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:5]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Anding", @"Annan", @"Anping", @"Baihe", @"Beimen", @"Danei",@"Dongshan",@"East",@"Guanmiao",@"Guantian",@"Guiren", @"Houbi",@"Jiali",@"Jiangjun",@"Liujia",@"Liuying",@"Longqi",@"Madou",@"Nanhua",@"Nanxi",@"North", @"Qigu",@"Rende",@"Shanhua",@"Shanshang",@"South",@"WestCentral",@"Xiaying",@"Xigang",@"Xinhua",@"Xinshi",@"Xinying",@"Xuejia",@"Yanshui",@"Yongkang",@"Yujing",@"Zuozhen", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:6]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"ChangHua",@"Yuanlin",@"Beidou",@"Erlin",@"Hemei",@"Lukang",@"Tianzhong",@"XiHu",@"Dacheng",@"Dacun",@"Ershui",@"Fangyuan",@"Fenyuan",@"Fuxing",@"Huatan",@"Pitou",@"Puxin",@"Puyan",@"Shengang",@"Shetou",@"Tianwei",@"Xianxi",@"Xiushui",@"Xizhou",@"Yongjing",@"Zhutang",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:7]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Pingtung",@"Chaozhou",@"Donggang",@"Hengchun",@"Changzhi",@"Checheng",@"Fangliao",@"Fangshan",@"Gaoshu",@"Jiadong",@"Jiuru",@"Kanding",@"Ligang",@"Linbian",@"Linluo",@"Liuqiu",@"Manzhou",@"Nanzhou",@"Neipu",@"Wandan",@"Wanluan",@"Xinpi",@"Xinyuan",@"Yanpu",@"Zhutian",@"Chunri",@"Laiyi",@"Majia",@"Mudan",@"Sandimen",@"Shizi",@"Taiwu",@"Wutai",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:8]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Douliu",@"Beigang",@"Dounan",@"Huwei",@"Tuku",@"Xiluo",@"Baozhong",@"Citong",@"Dapi",@"Dongshi",@"Erlun",@"Gukeng",@"Kouhu",@"Linnei",@"Lunbei",@"Mailiao",@"Shuilin",@"Sihu",@"Taixi",@"Yuanchang",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:9]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Miaoli City",@"Toufen",@"Houlong",@"Tongxiao",@"Yuanli",@"Zhunan",@"Zhuolan",@"Dahu",@"Gongguan",@"Nanzhuang",@"Sanwan",@"Sanyi",@"Shitan",@"Tongluo",@"Touwu",@"Xihu",@"Zaoqiao",@"Tai’an",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:10]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Zhubei",@"Hukou", @"Xinfeng",@"Xinpu",@"Zhudong",@"Baoshan",@"Beipu",@"Emei",@"Guanxi",@"Hengshan",@"Qionglin",@"Jianshi",@"Wufeng",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:11]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Puzi",@"Taibao",@"Budai",@"Dalin",@"Dapu",@"Dongshi",@"Fanlu",@"Liujiao",@"Lucao",@"Meishan",@"Minxiong",@"Shuishang",@"Xikou",@"Xingang",@"Yizhu",@"Zhongpu",@"Zhuqi",@"Alishan",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:12]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Nantou",@"Caotun",@"Jiji",@"Puli",@"Zhushan",@"Guoxing",@"Lugu",@"Mingjian",@"Shuili",@"Yuchi",@"Zhongliao",@"RenAi",@"Xinyi",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:13]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Yilan",@"Luodong",@"Su'ao",@"Toucheng",@"Dongshan",@"Jiaoxi",@"Sanxing",@"Wujie",@"Yuanshan",@"Zhuangwei",@"Datong",@"NanAo",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:14]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Hualien",@"Fenglin",@"Yuli",@"Fengbin",@"Fuli",@"Guangfu",@"JiAn",@"Ruisui" ,@"Shoufeng",@"Xincheng",@"Wanrong",@"Xiulin",@"Zhuoxi",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:15]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Taitung",@"Chenggong",@"Guanshan",@"Beinan",@"Changbin",@"Chishang",@"Dawu",@"Donghe",@"Luye",@"Lüdao",@"Taimali",@"Daren",@"Haiduan" ,@"Jinfeng",@"Lanyu",@"Yanping",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:16]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Jincheng",@"Jinhu",@"Jinsha",@"Jinning",@"Lieyu",@"Wuqiu",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:17]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Magong",@"Baisha",@"Huxi",@"Qimei",@"Xiyu",@"WangAn",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:18]];
        
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Nangan",@"Beigan" ,@"Dongyin",@"Juguang",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:19]];
        
        [self.PickerView reloadAllComponents];
    }


@end
