//
//  SecondViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/14/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "SecondViewController.h"
#import "FBLoginView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface SecondViewController ()

@end

@implementation SecondViewController
#pragma mark view life cycle
- (void)viewDidLoad {
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

@end
