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
    NSString *flaticonString = NSLocalizedString(@"Report icon, application icon both made by \"Madebyoliver\" from #<flaticon>flaticon#.",@"Credits View");
    NSString *AWSString = NSLocalizedString(@"Database and login identity management provide by #<AWS>Amazon Web Services#.",@"Credits View");
    
    [self configureTTTLabel:_flaticonLabel withLocalizedString:flaticonString];
    [self configureTTTLabel:_AWSLabel withLocalizedString:AWSString];
    
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

-(void)configureTTTLabel:(TTTAttributedLabel*)TTTlabel withLocalizedString:(NSString*)localizedString
{
    NSString *targetPrefix;
    NSString *targetLink;
    
    //check string type(aws or flaticon)
    if([localizedString rangeOfString:@"#<AWS>"].location != NSNotFound)
    {
        targetPrefix = @"<AWS>";
        targetLink = @"https://aws.amazon.com";
    }
    else if ([localizedString rangeOfString:@"#<flaticon>"].location != NSNotFound)
    {
        targetPrefix = @"<flaticon>";
        targetLink = @"http://www.flaticon.com/authors/madebyoliver";
    }
    
    TTTlabel.delegate = self;
    NSArray *localizedStringPieces = [localizedString componentsSeparatedByString:@"#"];
    NSUInteger firstHashTagLoc = 0;
    NSUInteger secondHashTagLoc = 0;
    NSString *str = @"";
    
    for (NSString *s in localizedStringPieces)
    {
        if ([s isEqualToString:@""])
        {
            continue;//skip loop if empty
        }
        if([s hasPrefix:targetPrefix])
        {
            firstHashTagLoc = [str length];
            NSString *temp = [s stringByReplacingOccurrencesOfString:targetPrefix withString:@""];
            str = [str stringByAppendingString:temp];
            secondHashTagLoc = [str length];
        }
        else
        {
            str = [str stringByAppendingString:s];
        }
    }
    TTTlabel.text = str;
    TTTlabel.linkAttributes = @{NSForegroundColorAttributeName : self.view.tintColor};//change default color to tint color
    NSRange range = NSMakeRange(firstHashTagLoc,secondHashTagLoc-firstHashTagLoc);
    [TTTlabel addLinkToURL:[NSURL URLWithString:targetLink]withRange:range];
}

#pragma mark TTTAttributedLabelDelegate
-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:self.view];
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
