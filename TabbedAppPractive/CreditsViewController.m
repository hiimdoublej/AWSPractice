//
//  CreditsViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/23/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "CreditsViewController.h"


@interface CreditsViewController ()

@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"CreditsViewDidLoad");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toFlaticon:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.flaticon.com/authors/madebyoliver"]];
}

- (IBAction)toAWS:(id)sender {
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://aws.amazon.com/"]];
}

- (IBAction)isDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
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
