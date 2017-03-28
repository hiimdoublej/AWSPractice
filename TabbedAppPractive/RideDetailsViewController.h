//
//  RideDetailsViewController.h
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/17/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamoDBActions.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface RideDetailsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,FBAdViewDelegate>

@property DDBTableRow *rowToDisplay;
@property (weak, nonatomic) IBOutlet UITableView *myTableview;

@end
