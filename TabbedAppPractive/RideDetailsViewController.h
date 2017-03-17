//
//  RideDetailsViewController.h
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/17/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamoDBActions.h"

@interface RideDetailsViewController : UIViewController
@property DDBTableRow *rowToDisplay;
@end
