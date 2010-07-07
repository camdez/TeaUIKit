//
//  TeaWebViewController.m
//  TeaUIKit
//
//  Created by Cameron Desautels on 12/16/09.
//  Copyright 2009 Too Much Tea, LLC. All rights reserved.
//

#import "TeaWebViewController.h"


@interface TeaWebViewController ()

@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, retain) UIBarButtonItem* backButton;
@property (nonatomic, retain) UIBarButtonItem* forwardButton;
@property (nonatomic, retain) UIBarButtonItem* refreshButton;
@property (nonatomic, retain) UIBarButtonItem* actionMenuButton;

- (void)actionMenuButtonAction;

@end

#pragma mark -
@implementation TeaWebViewController

@synthesize initialURL = _initialURL;
@synthesize webView = _webView;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize refreshButton = _refreshButton;
@synthesize actionMenuButton = _actionButton;


// Designated initializer
- (id)initWithURL:(NSURL *)initialURL {
    if (self = [super init]) {
        self.initialURL = initialURL;
    }
    return self;
}

- (id)init {
    return [self initWithURL:[NSURL URLWithString:@"http://teaapps.com"]];
}

- (void)dealloc {
    self.initialURL = nil;
    self.webView.delegate = nil; // official docs require this
    self.webView = nil;
    
    self.backButton = nil;
    self.forwardButton = nil;
    self.refreshButton = nil;
    self.actionMenuButton = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController lifecycle methods

- (void)loadView {
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.view = self.webView;
    [self.webView release];

    // Set up the toolbar buttons
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TeaUIKit-Resources/images/TeaBarButtonArrowLeft.png"]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self.webView action:@selector(goBack)];
    [self.backButton release];
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TeaUIKit-Resources/images/TeaBarButtonArrowRight.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self.webView action:@selector(goForward)];
    [self.forwardButton release];
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                       target:self.webView action:@selector(reload)];
    [self.refreshButton release];
    
    self.actionMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                          target:self action:@selector(actionMenuButtonAction)];
    [self.actionMenuButton release];
    
    UIBarButtonItem* gap = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                         target:nil action:nil];
    [self setToolbarItems:[NSArray arrayWithObjects:self.backButton,    gap, self.forwardButton, gap, gap,
                                                    self.refreshButton, gap, self.actionMenuButton, nil] animated:NO];
    self.navigationController.toolbarHidden = NO;
    [gap release];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.webView.request == nil)
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.initialURL]];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark Action methods

- (IBAction)actionMenuButtonAction {
    NSString* mailButton = [MFMailComposeViewController canSendMail] ? @"Mail Link" : nil;

    // TODO: Make this a TeaActionSheet--conditionally?
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:self.webView.request.URL.absoluteString
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Open in Safari", mailButton, nil];
    [actionSheet showFromToolbar:self.navigationController.toolbar];
    [actionSheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[UIApplication sharedApplication] openURL:self.webView.request.URL];
            break;
        case 1:
            ;
            MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
            mailController.mailComposeDelegate = self;
            [mailController setMessageBody:self.webView.request.URL.absoluteString isHTML:NO];
            [self presentModalViewController:mailController animated:YES];
            [mailController release];
            break;
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    self.actionMenuButton.enabled = NO;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    self.actionMenuButton.enabled = YES;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    self.actionMenuButton.enabled = NO;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
    
    if (error) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }    
}

@end
