//
//  ThirdViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/14/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "ThirdViewController.h"
#import "FBLoginView.h"

@implementation ThirdViewController

- (IBAction)toLogin:(id)sender {
    //code snippet for bringing fbLoginView up
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBLoginView *fbvc = [sb instantiateViewControllerWithIdentifier:@"FBLoginView"];
    [self presentViewController:fbvc animated:YES completion:^(void){}];
}


@end
