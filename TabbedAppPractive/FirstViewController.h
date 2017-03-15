//
//  FirstViewController.h
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/14/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSCore/AWSIdentityProvider.h>
#import <AWSCore/AWSCredentialsProvider.h>
#import "DynamoDBActions.h"
#import "DetailViewController.h"

@interface FirstViewController : UIViewController<AWSIdentityProviderManager,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;

@end

