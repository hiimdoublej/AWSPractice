//
//  myTabBarController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/27/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "myTabBarController.h"

@interface myTabBarController ()

@end

@implementation myTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"TabBarController VDL");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    //preload all view controllers by calling their view property
        dispatch_async(dispatch_get_main_queue(),^(){
            for (UIViewController *vc in self.viewControllers)
            {
                UIView *_ = vc.view;
            }
            NSLog(@"Preloading view controllers done");
        });
    NSLog(@"Tab Bar VDA");
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
