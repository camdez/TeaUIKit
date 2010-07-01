//
//  TeaActionSheet.h
//  TeaUIKit
//
//  Created by Cameron Desautels on 6/28/10.
//  Copyright 2010 Too Much Tea, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// Identical to UIActionSheet except automatically dismissed (cancelled) when
// the application enters the background, in accordance with Apple's usability
// suggestions.
@interface TeaActionSheet : UIActionSheet
@end
