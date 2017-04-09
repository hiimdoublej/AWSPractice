//
//  CreditsViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/23/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "CreditsViewController.h"


@interface CreditsViewController ()
@property NSDictionary* correspondence;
@end

@implementation CreditsViewController

#pragma mark view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _correspondence = @{@"<cocoapods>":@"https://cocoapods.org/",
                        @"<podfile>":@"https://github.com/hiimdoublej/AWSPractice/blob/master/Podfile",
                        @"<github>":@"https://github.com/hiimdoublej/AWSPractice",
                        @"<flaticon>":@"http://www.flaticon.com/authors/madebyoliver",
                        @"<AWS>":@"https://aws.amazon.com"};
    
    NSString *flaticonString = NSLocalizedString(@"Report icon, application icon both made by \"Madebyoliver\" from #<flaticon>Flaticon#.",@"Credits View");
    NSString *AWSString = NSLocalizedString(@"Database and login identity management provided by #<AWS>Amazon Web Services#.",@"Credits View");
    NSString *dependenciesString = NSLocalizedString(@"Third party dependencies management made easier by #<cocoapods>CocoaPods#, list of pods used in this project are in the#<podfile>Podfile# located at my #<github>Github repo#.", @"Credits View");
    
    [self configureTTTLabel:_flaticonLabel withLocalizedString:flaticonString];
    [self configureTTTLabel:_AWSLabel withLocalizedString:AWSString];
    [self configureTTTLabel:_CocoapodsLabel withLocalizedString:dependenciesString];
    
    NSLog(@"CreditsViewDidLoad");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBActions
- (IBAction)isDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}
#pragma mark TTTLabel configs
-(void)configureTTTLabel:(TTTAttributedLabel*)TTTlabel withLocalizedString:(NSString*)localizedString
{
    NSMutableDictionary *links = [NSMutableDictionary new];//a dict to store the tags and it's location in string
    
    TTTlabel.delegate = self;//set delegate for the delegate methods to trigger
    NSArray *localizedStringPieces = [localizedString componentsSeparatedByString:@"#"];//get components in string to parse
    NSUInteger firstHashTagLoc = 0;
    NSUInteger secondHashTagLoc = 0;
    NSString *str = @"";
    
    for (NSString *s in localizedStringPieces)
    {
        BOOL pieceAppended = NO;
        if ([s isEqualToString:@""])
        {
            continue;//skip this iteration of loop if this piece empty
        }
        for (NSString *prefix in [_correspondence allKeys])
        {
        //search to see if this piece is a prefix
            if([s hasPrefix:prefix])
            {
                firstHashTagLoc = [str length];
                NSString *temp = [s stringByReplacingOccurrencesOfString:prefix withString:@""];
                str = [str stringByAppendingString:temp];
                secondHashTagLoc = [str length];
                NSRange range = NSMakeRange(firstHashTagLoc,secondHashTagLoc-firstHashTagLoc);
                [links setObject:prefix forKey:NSStringFromRange(range)];//associate the range with the prefix
                pieceAppended = YES;
            }
        }
        if(!pieceAppended)
        {
        //the code reaches here is the text is just a normal text not a link
            str = [str stringByAppendingString:s];
        }
    }
    TTTlabel.text = str;//set string first before setting links
    TTTlabel.linkAttributes = @{NSForegroundColorAttributeName : self.view.tintColor};//change default color to tint color
    
    for(NSString* rangeString in [links allKeys])
    {
        //add links into the TTTAttributedLabel
        NSRange range = NSRangeFromString(rangeString);//restore range from NSString
        NSString *tag = [links objectForKey:rangeString];//get the prefix tag
        NSString *url = [_correspondence objectForKey:tag];//get link from prefix tag
        [TTTlabel addLinkToURL:[NSURL URLWithString:url] withRange:range];//add link
    }
}


#pragma mark TTTAttributedLabelDelegate
-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[url absoluteString] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *open = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open Link in Safari", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"%@",[action title]);
        [[UIApplication sharedApplication] openURL:url];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    [alert addAction:open];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
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
