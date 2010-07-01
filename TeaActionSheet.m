//
//  TeaActionSheet.m
//  TeaUIKit
//
//  Created by Cameron Desautels on 6/28/10.
//  Copyright 2010 Too Much Tea, LLC. All rights reserved.
//

#import "TeaActionSheet.h"


@implementation TeaActionSheet

- (id)initWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    const unsigned int max_args = 8; // TODO see how many will fit on screen and raise this number
    unsigned int arg_count = 0;
    NSString* argsa[max_args]; // XXX I could use an NSMutableArray but I can only pass a fixed number of arguments in the final call anyway

    va_list args;
    va_start(args, otherButtonTitles);

    /*
    while ((argsa[arg_count] = va_arg(args, id)) && (arg_count < max_args)) {
        arg_count++;
    }
     */

    for (NSString *arg = otherButtonTitles; (arg != nil) && (arg_count < max_args); arg = va_arg(args, NSString*))
    {
        argsa[arg_count] = arg;
        arg_count++;
    }

    self = [super initWithTitle:title
                       delegate:delegate
              cancelButtonTitle:cancelButtonTitle
         destructiveButtonTitle:destructiveButtonTitle
              otherButtonTitles:(arg_count > 0 ? argsa[0] : nil),
                                (arg_count > 1 ? argsa[1] : nil),
                                (arg_count > 2 ? argsa[2] : nil),
                                (arg_count > 3 ? argsa[3] : nil),
                                (arg_count > 4 ? argsa[4] : nil),
                                (arg_count > 5 ? argsa[5] : nil),
                                (arg_count > 6 ? argsa[6] : nil),
                                (arg_count > 7 ? argsa[7] : nil),
                                nil];

    va_end(args);

    // Register for notification
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification){
                                                      [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:NO];
                                                  }];

    // TODO should probably do a check to see if the [super init...] call succeeded
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
