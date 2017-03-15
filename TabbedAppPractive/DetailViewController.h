//
//  DetailViewController.h
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/15/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamoDBActions.h"

@interface DetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property NSMutableArray *tableRows;

@property (weak, nonatomic) IBOutlet UILabel *PlateNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *RatingLabel;

@property (weak, nonatomic) IBOutlet UITableView *DetailTableView;

@end
