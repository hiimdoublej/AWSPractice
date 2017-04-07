//
//  FBLoginView.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/14/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "FBLoginView.h"

@implementation FBLoginView

- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    NSLog(@"Logged in, returning to Tabbed View.");
    [self dismissFBLoginView];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog(@"Logged out");
    [self dismissFBLoginView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myFBLoginButton.readPermissions = @[@"public_profile",@"email"];
    [self.myFBLoginButton setDelegate:self];
    self.myFBLoginButton.titleLabel.text = @"WOOHOO";
    //    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc]init];
    //    [loginButton setDelegate:self];
    //    loginButton.center = self.view.center;
    //    [self.view addSubview:loginButton];
    //    loginButton.readPermissions = @[@"public_profile",@"email"];
    
    NSLog(@"FBLoginViewDidLoad");
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)dismissFBLoginView {
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end
