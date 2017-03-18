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

#pragma mark view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _myTableview.separatorColor = [UIColor clearColor];
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
            cell.detailTextLabel.text = item.RideTime;
            break;
        case 1:
            cell.textLabel.text = @"Location:";
            cell.detailTextLabel.text = item.RideLocation;
            break;
        case 2:
            cell.textLabel.text = @"Time Submitted:";
            cell.detailTextLabel.text = item.TimeSubmitted;
            break;
        case 3:
            cell.textLabel.text = @"Comment:";
            [cell.detailTextLabel setNumberOfLines:0];
            cell.detailTextLabel.text = item.RideComment;
            //cell.detailTextLabel.text = @"this is just the sample example of how to calculate the dynamic height for tableview cell which is of around 7 to 8 lines. you will need to set the height of this string first, not seems to be calculated in cellForRowAtIndexPath method.";
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
        UIFont *txtFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        NSDictionary *arialdict = [NSDictionary dictionaryWithObject:txtFont forKey:NSFontAttributeName];
        //NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:@"this is just the sample example of how to calculate the dynamic height for tableview cell which is of around 7 to 8 lines. you will need to set the height of this string first, not seems to be calculated in cellForRowAtIndexPath method." attributes:arialdict];
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc]initWithString:_rowToDisplay.RideComment attributes:arialdict];
        //122 is a strange number found out using brute force
        CGRect rect = [message boundingRectWithSize:(CGSize){122,CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGSize requiredSize = rect.size;
        NSLog(@"dynamic height calculated = %f",requiredSize.height);
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
