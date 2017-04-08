//
//  CreditsViewController.h
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/23/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface CreditsViewController : UIViewController<TTTAttributedLabelDelegate>

@property (strong, nonatomic) IBOutlet TTTAttributedLabel *flaticonLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *AWSLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *CocoapodsLabel;



@end
