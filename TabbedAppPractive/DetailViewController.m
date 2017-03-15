//
//  DetailViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/15/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
#pragma mark Button action

- (IBAction)goBackButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}


#pragma mark Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableRows count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DDBTableRow *item = self.tableRows[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Date: %@",item.RideTime];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Average Rating : %@",item.OverallRating];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//this function should be unused
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DDBTableRow *row = self.tableRows[indexPath.row];
        //[self deleteTableRow:row];
        
        [self.tableRows removeObject:row];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //should be unused
}

#pragma mark - Set Labels

-(void) setLabels
{
    //set plate number label
    NSString *plate = [[_tableRows firstObject]RideVehiclePlate];
    NSLog(@"Plate is %@",plate);
    self.PlateNumberLabel.text = plate;
    //set ratings label
    NSNumber *rating = 0;
    for(DDBTableRow *tableRow in _tableRows)
    {
        rating = [NSNumber numberWithFloat:[rating floatValue]+[tableRow.OverallRating floatValue]];
    }
    rating = [NSNumber numberWithFloat:[rating floatValue] / [self.tableRows count]];
    NSLog(@"Average Rating:%@",rating);
    self.RatingLabel.text = [NSString stringWithFormat:@"Average Rating:%@",[rating stringValue]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setLabels];
    NSLog(@"DetailsView did load");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
