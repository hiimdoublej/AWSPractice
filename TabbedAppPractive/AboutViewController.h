//
//  AboutViewController.h
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/23/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface AboutViewController : UIViewController<MFMailComposeViewControllerDelegate,TTTAttributedLabelDelegate>
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;

@property (strong, nonatomic) IBOutlet TTTAttributedLabel *emailLabel;

@property (strong, nonatomic) IBOutlet TTTAttributedLabel *githubLink;

@end
