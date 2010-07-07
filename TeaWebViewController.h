//
//  TeaWebViewController.h
//  TeaUIKit
//
//  Created by Cameron Desautels on 12/16/09.
//  Copyright 2009 Too Much Tea, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface TeaWebViewController : UIViewController 
    <UIActionSheetDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSURL* initialURL;

- (id)initWithURL:(NSURL*)initialURL;

@end
