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
    /*
     XXX: This implementation is a bit odd, but there's currently no way around it.  Because the only
     initializer for UIActionSheet is variadic, and because there's no way in Objective-C (/C) to unpack the
     variadic arguments we receive in order to pass them on to the [super init:...] call, it's impossible to
     subclass UIActionSheet properly.  In fact, it's impossible to properly subclass any class with methods
     taking variadic arguments unless we are provided with a non-variadic version of the method that we can
     call (generally either a version taking an NSArray* or va_list).  Given this sitation, the best we can do
     is to provide a version of the method that works with a fixed maximum number of arguments.

     While this sounds awful, for this particular class things aren't so bad--the variadic arguments represent
     buttons to be displayed on the screen, and since only so many buttons will fit on the screen, there's a
     built in maximum...basically.  The maximum number of buttons that will fit on the screen turns out to be
     six, so that's the maximum enforced here.  Actually, however, UIActionSheet is willing to take an
     unbounded number of button titles, which it then puts into a UITableView (interesting trivia, eh?).  But
     considering that adding that many buttons is a horrible UI decision, I'm leaving the cap at six.
    */

    // Unpack the variadic arguments
    const unsigned int maxArgs = 6;
    NSString* args[maxArgs];

    va_list packedArgs;
    va_start(packedArgs, otherButtonTitles);

    unsigned int argCount = 0;

    for (NSString *arg = otherButtonTitles; (arg != nil) && (argCount < maxArgs); arg = va_arg(packedArgs, NSString*))
        args[argCount++] = arg;

    va_end(packedArgs);

    // Initialize, passing the otherButtonTitles we got
    self = [super initWithTitle:title
                       delegate:delegate
              cancelButtonTitle:cancelButtonTitle
         destructiveButtonTitle:destructiveButtonTitle
              otherButtonTitles:(argCount > 0 ? args[0] : nil),
                                (argCount > 1 ? args[1] : nil),
                                (argCount > 2 ? args[2] : nil),
                                (argCount > 3 ? args[3] : nil),
                                (argCount > 4 ? args[4] : nil),
                                (argCount > 5 ? args[5] : nil),
                                nil];

    if (self) {
        // XXX addObserverForName:object:queue:usingBlock: was added in 4.0, so prevent crashes on iOS < 4.0
        if ([[NSNotificationCenter defaultCenter] respondsToSelector:@selector(addObserverForName:object:queue:usingBlock:)]) {
            // XXX Using a string here instead of the notification constant is critical for running on iOS < v4.0
            [[NSNotificationCenter defaultCenter] addObserverForName:@"UIApplicationDidEnterBackgroundNotification"
                                                              object:nil
                                                               queue:nil
                                                          usingBlock:^(NSNotification *notification){
                                                              [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:NO];
                                                          }];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
