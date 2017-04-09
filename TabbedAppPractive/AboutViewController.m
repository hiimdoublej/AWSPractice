//
//  AboutViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/23/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
    
    @end

@implementation AboutViewController
#pragma mark view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureGithubLink];
    [self configureEmail];
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)isDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}
#pragma mark set stuff
-(void) configureAuthor
{
    self.authorLabel.text = NSLocalizedString(@"Author:hiimdoublej", @"line for author in about view");
}
-(void) configureEmail
    {//configure the email label(text,delegate,localizations)
        self.emailLabel.delegate = self;
        NSString *str = NSLocalizedString(@"You can contact me via #<email>email#.", @"translate the stuff between #'s but not the tag");
        NSArray *localizedStringPieces = [str componentsSeparatedByString:@"#"];//identify the tags
        NSUInteger firstHashTagLoc = 0;
        NSUInteger lastHashTagLoc = 0;
        str = @"";
        for (NSString *s in localizedStringPieces)
        {
            if ([s isEqualToString:@""])
            {
                continue;//skip loop if empty
            }
            if([s hasPrefix:@"<email>"])
            {
                firstHashTagLoc = [str length];
                NSString *temp = [s stringByReplacingOccurrencesOfString:@"<email>" withString:@""];
                str = [str stringByAppendingString:temp];
                lastHashTagLoc = [str length];
            }
            else
            {
                str = [str stringByAppendingString:s];
            }
        }
        self.emailLabel.text = str;
        self.emailLabel.linkAttributes = @{NSForegroundColorAttributeName : self.view.tintColor};//change default color to tint color
        NSRange range = NSMakeRange(firstHashTagLoc,lastHashTagLoc-firstHashTagLoc);
        [self.emailLabel addLinkToURL:[NSURL URLWithString:@"410221009@gms.ndhu.edu.tw"]withRange:range];
        
    }
-(void) configureGithubLink
    {
        self.githubLink.delegate = self;
        NSString *str = NSLocalizedString(@"Some of the codes are #<github>here#.", @"translate the stuff between #'s but not the tag");
        NSArray *localizedStringPieces = [str componentsSeparatedByString:@"#"];//identify the tags
        NSUInteger firstHashTagLoc = 0;
        NSUInteger lastHashTagLoc = 0;
        str = @"";
        for (NSString *s in localizedStringPieces)
        {
            if ([s isEqualToString:@""])
            {
                continue;//skip loop if empty
            }
            if([s hasPrefix:@"<github>"])
            {
                firstHashTagLoc = [str length];
                NSString *temp = [s stringByReplacingOccurrencesOfString:@"<github>" withString:@""];
                str = [str stringByAppendingString:temp];
                lastHashTagLoc = [str length];
            }
            else
            {
                str = [str stringByAppendingString:s];
            }
        }
        self.githubLink.text = str;
        self.githubLink.linkAttributes = @{NSForegroundColorAttributeName : self.view.tintColor};
        NSRange range = NSMakeRange(firstHashTagLoc, lastHashTagLoc-firstHashTagLoc);
        [self.githubLink addLinkToURL:[NSURL URLWithString:@"https://github.com/hiimdoublej/AWSPractice/tree/master/TabbedAppPractive"] withRange:range];
    }
- (void)toEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController * emailController = [[MFMailComposeViewController alloc] init];
        emailController.mailComposeDelegate = self;
        
        [emailController setSubject:@""];
        [emailController setMessageBody:@"" isHTML:YES];
        [emailController setToRecipients:[NSArray arrayWithObjects:@"410221009@gms.ndhu.edu.tw", nil]];
        
        [self presentViewController:emailController animated:YES completion:nil];
    }
    // Show error if no mail account is active
    else {
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You must have a mail account in order to send an email" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
//        [alertView show];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You must have a email account set up in order to send an email.",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
    
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
    {
        
        // Close the Mail Interface
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
#pragma mark TTTAttributedLabelDelegate
-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
    {
        if([[url relativeString]isEqualToString:@"410221009@gms.ndhu.edu.tw"])
        {
            [self toEmail];
        }
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[url absoluteString] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *open = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open Link in Safari", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                 [[UIApplication sharedApplication] openURL:url];
                }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:open];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
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
