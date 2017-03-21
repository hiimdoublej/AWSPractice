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

@interface SecondViewController ()

@end

@implementation SecondViewController
#pragma mark view life cycle
- (void)viewDidLoad {
    [self setupPickerViewData];
    NSLog(@"Second View did load.");
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self showElements];
}

#pragma mark button action
- (IBAction)LoginButtonClicked:(id)sender {
    //code snippet for bringing fbLoginView up
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBLoginView *fbvc = [sb instantiateViewControllerWithIdentifier:@"FBLoginView"];
    [self presentViewController:fbvc animated:YES completion:^(void){}];
}

- (IBAction)submitInfo:(UIButton *)sender {
    {
        UIPickerView *LocationPicker = self.PickerView;
        //get date string
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
        
        //get user id (udid)
        UIDevice *device = [UIDevice currentDevice];
        NSUUID *uuid = [device identifierForVendor];
        NSString *UUID = [uuid UUIDString];
        
        //submit them to dynamodb
        DDBTableRow *tableRow = [DDBTableRow new];
        tableRow.RideLocation = locationToBeReported;
        tableRow.TimeSubmitted = currentTime;
        tableRow.UserID = UUID;
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        [[dynamoDBObjectMapper save:tableRow] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task)
         {
             if(!task.error)
             {
                 //             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succeeded"
                 //                                                             message:@"Successfully inserted the data into the table."
                 //                                                            delegate:nil
                 //                                                   cancelButtonTitle:@"OK"
                 //                                                   otherButtonTitles:nil];
                 //             [alert show];
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Succeeded"
                                                                                message:@"Successfully insrted data into the table."
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){}];
                 [alert addAction:action];
                 [self presentViewController:alert animated:YES completion:nil];
                 
             }
             else
             {
                 NSLog(@"Error: [%@]", task.error);
                 //             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                 //                                                             message:@"Failed to insert the data into the table."
                 //                                                            delegate:nil
                 //                                                   cancelButtonTitle:@"OK"
                 //                                                   otherButtonTitles:nil];
                 //             [alert show];
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                message:@"Failed to insert the data into the table."
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){}];
                 [alert addAction:action];
                 [self presentViewController:alert animated:YES completion:nil];
                 
             }
             return nil;
         }];
        
        
    }
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
    }
}

#pragma mark location picker data source
-(void)setupPickerViewData
{
    //setup top level
    self.topLevelAdministrativeDivisions = [[NSMutableArray alloc]init];
    [self.topLevelAdministrativeDivisions addObject:@"Taipei"];
    [self.topLevelAdministrativeDivisions addObject:@"New Taipei"];
    [self.topLevelAdministrativeDivisions addObject:@"Taichung"];
    [self.topLevelAdministrativeDivisions addObject:@"Kaoshiung"];
    [self.topLevelAdministrativeDivisions addObject:@"Taoyuan"];
    [self.topLevelAdministrativeDivisions addObject:@"Tainan"];
    [self.topLevelAdministrativeDivisions addObject:@"Changhua"];
    [self.topLevelAdministrativeDivisions addObject:@"Pingtung"];
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
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"SongShan",@"XinYi",@"Da-An",@"ZhongShan",@"ZhongZheng",@"DaTong",@"WanHua",@"NanGang",@"NeiHu",@"ShiLin",@"BeiTou", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:0]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"BanQiao",@"ZhonHe",@"XinZhunag",@"SanChong",@"XinDian",@"TuCheng",@"YongHe",@"LuZhou",@"XiZhi",@"ShuLin",@"TamSui",@"SanXia",@"LinKou",@"YingGe",@"WuGu",@"TaiShan",@"RuiFang",@"Bali",@"ShenKeng",@"SanZhi",@"WanLi",@"JinShan",@"GongLiao",@"ShiMen",@"ShiDing",@"PingLin",@"WuLai",@"PingXi", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:1]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"BeiTung",@"Central",@"East",@"NanTun",@"North",@"South",@"West",@"XiTun",@"DaLi",@"TaiPing",@"WuFeng",@"WuRi",@"FengYuan",@"DongShi",@"DaYa",@"HePing",@"HouLi",@"ShenGang",@"ShiGana",@"TanZi",@"XinShe",@"DaJia",@"QingShui",@"ShaLu",@"WuQi",@"Da-An",@"DaDu",@"LongJing",@"WaiPu", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:2]];
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"FengShan",@"SanMin",@"ZuoYing",@"QianZhen",@"NanZi",@"LingYa",@"XiaoGang",@"GuShan",@"DaLiao",@"GangShan",@"RenWu",@"LinYuan",@"LuZhu",@"XinXing",@"NiaoSong",@"DaShu",@"MeiNong",@"QiShang",@"QiaoTou",@"ZiGuan",@"DaShe",@"QieDing",@"YanChao",@"HuNei",@"ALian",@"QiJin",@"YanCheng",@"MiTuo",@"NeiMen",@"YongAn",@"LiuGui",@"ShanLin",@"TianLiao",@"JiaXian",@"TaoYuan",@"NaMaXia",@"MaoLin", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:3]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"TaoYuan City",@"ZhongLi",@"PingZhen",@"Bade",@"YangMei",@"LuZhu",@"GuiShan",@"LongTan",@"DaXi",@"DaYuan",@"GuanYin",@"XinWu",@"FuXing", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:4]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Anding", @"Annan", @"Anping", @"Baihe", @"Beimen", @"Danei",@"Dongshan",@"East",@"Guanmiao",@"Guantian",@"Guiren", @"Houbi",@"Jiali",@"Jiangjun",@"Liujia",@"Liuying",@"Longqi",@"Madou",@"Nanhua",@"Nanxi",@"North", @"Qigu",@"Rende",@"Shanhua",@"Shanshang",@"South",@"West Central",@"Xiaying",@"Xigang",@"Xinhua" @"Xinshi",@"Xinying",@"Xuejia",@"Yanshui",@"Yongkang",@"Yujing",@"Zuozhen", nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:5]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Changhua",@"Yuanlin",@"Beidou",@"Erlin",@"Hemei",@"Lukang",@"Tianzhong",@"Xihu",@"Dacheng",@"Dacun",@"Ershui",@"Fangyuan",@"Fenyuan",@"Fuxing",@"Huatan",@"Pitou",@"Puxin",@"Puyan",@"Shengang",@"Shetou",@"Tianwei",@"Xianxi",@"Xiushui",@"Xizhou",@"Yongjing",@"Zhutang",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:6]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Pingtung",@"Chaozhou",@"Donggang",@"Hengchun",@"Changzhi",@"Checheng",@"Fangliao",@"Fangshan",@"Gaoshu",@"Jiadong",@"Jiuru",@"Kanding",@"Ligang",@"Linbian",@"Linluo"@"Liuqiu"@"Manzhou",@"Nanzhou",@"Neipu",@"Wandan",@"Wanluan",@"Xinpi",@"Xinyuan",@"Yanpu",@"Zhutian",@"Chunri",@"Laiyi",@"Majia",@"Mudan",@"Sandimen",@"Shizi",@"Taiwu",@"Wutai",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:7]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Douliu",@"Beigang",@"Dounan",@"Huwei",@"Tuku",@"Xiluo",@"Baozhong"@"Citong",@"Dapi",@"Dongshi",@"Erlun",@"Gukeng",@"Kouhu",@"Linnei",@"Lunbei",@"Mailiao",@"Shuilin",@"Sihu",@"Taixi",@"Yuanchang",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:8]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Miaoli",@"Toufen",@"Houlong",@"Tongxiao",@"Yuanli",@"Zhunan",@"Zhuolan",@"Dahu",@"Gongguan",@"Nanzhuang",@"Sanwan",@"Sanyi",@"Shitan",@"Tongluo",@"Touwu",@"Xihu",@"Zaoqiao",@"Tai'an",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:9]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Zhubei",@"Hukou", @"Xinfeng",@"Xinpu",@"Zhudong",@"Baoshan",@"Beipu",@"Emei",@"Guanxi",@"Hengshan",@"Qionglin",@"Jianshi",@"Wufeng",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:10]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Puzi",@"Taibao",@"Budai",@"Dalin",@"Dapu",@"Dongshi",@"Fanlu",@"Liujiao",@"Lucao",@"Meishan",@"Minxiong",@"Shuishang",@"Xikou",@"Xingang",@"Yizhu",@"Zhongpu",@"Zhuqi",@"Alishan",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:11]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Nantou",@"Caotun",@"Jiji",@"Puli",@"Zhushan",@"Guoxing",@"Lugu",@"Mingjian",@"Shuili",@"Yuchi",@"Zhongliao",@"Ren'ai",@"Xinyi",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:12]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Yilan",@"Luodong",@"Su'ao",@"Toucheng",@"Dongshan",@"Jiaoxi",@"Sanxing",@"Wujie",@"Yuanshan",@"Zhuangwei",@"Datong",@"Nan'ao",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:13]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Hualien",@"Fenglin",@"Yuli",@"Fengbin",@"Fuli",@"Guangfu",@"Ji'an",@"Ruisui" ,@"Shoufeng",@"Xincheng",@"Wanrong",@"Xiulin",@"Zhuoxi",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:14]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Taitung",@"Chenggong",@"Guanshan",@"Beinan",@"Changbin",@"Chishang",@"Dawu",@"Donghe",@"Luye",@"Lüdao",@"Taimali",@"Daren",@"Haiduan" ,@"Jinfeng",@"Lanyu",@"Yanping",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:15]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Jincheng",@"Jinhu",@"Jinsha",@"Jinning",@"Lieyu",@"Wuqiu",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:16]];
    
        [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Magong",@"Baisha",@"Huxi",@"Qimei",@"Xiyu",@"Wang'an",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:17]];
    
    [self.secondLevelAdministratiiveDivisions setObject:[[NSArray alloc]initWithObjects:@"Nangan",@"Beigan" ,@"Dongyin",@"Juguang",nil] forKey:[self.topLevelAdministrativeDivisions objectAtIndex:18]];
    
    }

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


@end
