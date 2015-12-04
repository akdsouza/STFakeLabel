//
//  UILabel+STFakeAnimation.m
//  STFakeLabel-ObjC
//
//  Created by TangJR on 12/3/15.
//  Copyright © 2015 tangjr. All rights reserved.
//

#import "UILabel+STFakeAnimation.h"
#import <objc/runtime.h>

// st_isAnimating asscoiate key
static void * STFakeLabelAnimationIsAnimatingKey = &STFakeLabelAnimationIsAnimatingKey;

@interface UILabel ()

@property (assign, nonatomic) BOOL st_isAnimating; ///< default is NO

@end

@implementation UILabel (STFakeAnimation)

// animate with direction
// 'toText' is the new text should showing
- (void)st_startAnimationWithDirection:(STFakeAnimationDirection)direction toText:(NSString *)toText {
    if (![toText respondsToSelector:@selector(length)]) {
        return;
    }
    // if self is animating, shall not pass!!!
    // set YES when animation is starting
    // set NO when animation completed
    if (self.st_isAnimating) {
        return;
    }
    self.st_isAnimating = YES;
    
    // copy self to fakeLabel
    UILabel *fakeLabel = [UILabel new];
    fakeLabel.frame = self.frame;
    fakeLabel.textAlignment = self.textAlignment;
    fakeLabel.font = self.font;
    fakeLabel.textColor = self.textColor;
    fakeLabel.text = toText;
    fakeLabel.backgroundColor = self.backgroundColor;
    [self.superview addSubview:fakeLabel];
    
    CGFloat labelOffsetX = 0.0; // label make translation offset x
    CGFloat labelOffsetY = 0.0; // label make translation offset y
    CGFloat labelScaleX = 0.1; // label make scale x
    CGFloat labelScaleY = 0.1; // label make scale y
    
    // if direction is vertical, label offset y is the half of label height and scale x not changed
    // the code below 'CGRectGetHeight(self.bounds) / 4' corse that STFakeAnimationDown / STFakeAnimationUp raw value is -2 / 2
    if (direction == STFakeAnimationDown || direction == STFakeAnimationUp) {
        labelOffsetY = direction * CGRectGetHeight(self.bounds) / 4;
        labelScaleX = 1.0;
    }
    // if direction is vertical, label offset x is the half of label width and scale y not changed
    if (direction == STFakeAnimationLeft || direction == STFakeAnimationRight) {
        labelOffsetX = direction * CGRectGetWidth(self.bounds) / 2;
        labelScaleY = 1.0;
    }
    // do scale and translation transform with variable
    fakeLabel.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(labelScaleX, labelScaleY), CGAffineTransformMakeTranslation(labelOffsetX, labelOffsetY));
    
    // animation block
    // fake lbael transform identity
    // width / height of self scale result to 0.1, and do translation also
    [UIView animateWithDuration:STFakeLabelAnimationDuration animations:^{
        fakeLabel.transform = CGAffineTransformIdentity;
        self.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(labelScaleX, labelScaleY), CGAffineTransformMakeTranslation(-labelOffsetX, -labelOffsetY));
    } completion:^(BOOL finished) {
        // restore self
        // remove fake label
        // reset aniamtion flag
        self.transform = CGAffineTransformIdentity;
        [fakeLabel removeFromSuperview];
        self.text = toText;
        self.st_isAnimating = NO;
    }];
}

- (BOOL)st_isAnimating {
    NSNumber *isAnimatingNumber = objc_getAssociatedObject(self, STFakeLabelAnimationIsAnimatingKey);
    return isAnimatingNumber.boolValue;
}

- (void)setSt_isAnimating:(BOOL)st_isAnimating {
    objc_setAssociatedObject(self, STFakeLabelAnimationIsAnimatingKey, @(st_isAnimating), OBJC_ASSOCIATION_ASSIGN);
}

@end