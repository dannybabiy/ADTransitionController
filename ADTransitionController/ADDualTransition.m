//
//  ADDualTransition.m
//  AppLibrary
//
//  Created by Patrick Nollet on 14/03/11.
//  Copyright 2011 Applidium. All rights reserved.
//

#import "ADDualTransition.h"

@implementation ADDualTransition
@synthesize inAnimation = _inAnimation;
@synthesize outAnimation = _outAnimation;

- (id)initWithInAnimation:(CAAnimation *)inAnimation andOutAnimation:(CAAnimation *)outAnimation {
    if (self = [self init]) {
        _inAnimation = [inAnimation retain];
        _outAnimation = [outAnimation retain];
        [self finishInit];
    }
    return self;
}

- (id)initWithDuration:(CFTimeInterval)duration {
    return nil;
}

- (void)dealloc {
    [_inAnimation release];
    [_outAnimation release];
    [super dealloc];
}

- (void)finishInit {
    _delegate = nil;
    _inAnimation.delegate = self; // The delegate object is retained by the receiver. This is a rare exception to the memory management rules described in 'Memory Management Programming Guide'.
    [_inAnimation setValue:ADTransitionAnimationInValue forKey:ADTransitionAnimationKey]; // See 'Core Animation Extensions To Key-Value Coding' : "while the key “someKey” is not a declared property of the CALayer class, however you can still set a value for the key “someKey” "
    _outAnimation.delegate = self;
    [_outAnimation setValue:ADTransitionAnimationOutValue forKey:ADTransitionAnimationKey];

    // Make sure that the animation doesn't jump to the originating position right at the end.
    // This avoids a flicker that is seen when the two overlapping views have transparent backgrounds.
    _inAnimation.fillMode = kCAFillModeForwards;
    _outAnimation.fillMode = kCAFillModeForwards;
    _inAnimation.removedOnCompletion = NO;
    _outAnimation.removedOnCompletion = NO;
}

- (ADTransition *)reverseTransition {
    CAAnimation * inAnimationCopy = [self.inAnimation copy];
    CAAnimation * outAnimationCopy = [self.outAnimation copy];
    ADDualTransition * reversedTransition = [[ADDualTransition alloc] initWithInAnimation:outAnimationCopy // Swapped
                                                                          andOutAnimation:inAnimationCopy];
    reversedTransition.delegate = self.delegate; // Pointer assignment
    reversedTransition.inAnimation.speed = -1.0 * reversedTransition.inAnimation.speed;
    reversedTransition.outAnimation.speed = -1.0 * reversedTransition.outAnimation.speed;
    [outAnimationCopy release];
    [inAnimationCopy release];
    return [reversedTransition autorelease];
}

#pragma mark -
#pragma mark CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if ([[animation valueForKey:ADTransitionAnimationKey] isEqualToString:ADTransitionAnimationOutValue]) {
        _outAnimation.delegate = nil;
    }
    if ([[animation valueForKey:ADTransitionAnimationKey] isEqualToString:ADTransitionAnimationInValue]) {
        _inAnimation.delegate = nil;
        [super animationDidStop:animation finished:flag];
    }
}

@end
