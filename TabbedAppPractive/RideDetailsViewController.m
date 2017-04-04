//
//  RideDetailsViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/17/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "RideDetailsViewController.h"

@interface RideDetailsViewController ()

@end

@implementation RideDetailsViewController
#pragma mark fb audience network ad banner
- (void)initFBAd:(BOOL)isTesting
{
    // methods to call when testing ad banner
    //    [FBAdSettings setLogLevel:FBAdLogLevelLog];
    //    [FBAdSettings addTestDevice:@"345002dd5ba9e413f6e1c53918a9edc520c857a9"];
    
    //method to call when done testing
    //[FBAdSettings clearTestDevice:@"345002dd5ba9e413f6e1c53918a9edc520c857a9"];
    NSString *placementID =[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FBAudienceNetworkPlacementID"];
    FBAdView *adView =
    [[FBAdView alloc] initWithPlacementID:placementID
                                   adSize:kFBAdSize320x50
                       rootViewController:self];
    adView.delegate = self;
    
    adView.frame = CGRectMake(0, self.view.frame.size.height-adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
    [adView loadAd];
    [self.view addSubview:adView];
    
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error;
{
    NSLog(@"Ad failed to load");
    // Add code to hide the ad unit...
    // E.g. adView.hidden = YES;
}

- (void)adViewDidLoad:(FBAdView *)adView;
{
    NSLog(@"Ad was loaded and ready to be displayed");
    // Add code to show the ad unit...
    // E.g. adView.hidden = NO;
}

- (void)adViewDidClick:(FBAdView *)adView
{
    NSLog(@"Banner ad was clicked.");
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
    NSLog(@"Banner ad did finish click handling.");
}

- (void)adViewWillLogImpression:(FBAdView *)adView
{
    NSLog(@"Banner ad impression is being captured.");
}

#pragma mark view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _myTableview.separatorColor = [UIColor clearColor];
    [self initFBAd:NO];
    NSLog(@"RideDetailsView did load");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table view data source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    DDBTableRow *item = _rowToDisplay;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Date:";
            //cell.detailTextLabel.text = item.RideTime;
            cell.textLabel.text = [self localizeTime:item.RideTime];
            break;
        case 1:
            cell.textLabel.text = @"Location:";
            //cell.detailTextLabel.text = item.RideLocation;
            cell.detailTextLabel.text = [self localizeLocation:item.RideLocation];
            break;
        case 2:
            cell.textLabel.text = @"Overall Rating:";
            cell.detailTextLabel.text = [item.OverallRating stringValue];
            break;
        case 3:
            cell.textLabel.text = @"Comment:";
            [cell.detailTextLabel setNumberOfLines:0];
            cell.detailTextLabel.text = item.RideComment;
//            cell.detailTextLabel.text = @"this is just the sample example of how to calculate the dynamic height for tableview cell which is of around 7 to 8 lines. you will need to set the height of this string first, not seems to be calculated in cellForRowAtIndexPath method.";
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 3)
    {
        //calculating cell height for the text to not look weird
        UIFont *txtFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        NSDictionary *arialdict = [NSDictionary dictionaryWithObject:txtFont forKey:NSFontAttributeName];
//        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:@"this is just the sample example of how to calculate the dynamic height for tableview cell which is of around 7 to 8 lines. you will need to set the height of this string first, not seems to be calculated in cellForRowAtIndexPath method." attributes:arialdict];
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc]initWithString:_rowToDisplay.RideComment attributes:arialdict];
        //122 is a strange number found out using brute force
        CGRect rect = [message boundingRectWithSize:(CGSize){122,CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGSize requiredSize = rect.size;
        //NSLog(@"dynamic height calculated = %f",requiredSize.height);
        if(requiredSize.height>45)
            return requiredSize.height;
    }
    return 45;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)localizeTime:(NSString *)time
{
    NSDateFormatter *dfDate = [NSDateFormatter new];
    [dfDate setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [dfDate dateFromString:time];
    NSString *result = [dfDate stringFromDate:date];
    return result;
}

-(NSString *)localizeLocation:(NSString *)loc
{
    NSRange range = [loc rangeOfString:@"/"];
    NSString *first = NSLocalizedString([loc substringToIndex:range.location],@"translating");
    NSString *second = NSLocalizedString([loc substringFromIndex:range.location+1],@"translating");
    NSString *result = [first stringByAppendingString:second];
    return result;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
