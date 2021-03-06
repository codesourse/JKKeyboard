//
//  UIView+JKKeyboard.m
//  JKKeyboardDemo
//
//  Created by Jakub Kleň on 8.2.2014.
//  Copyright (c) 2014 Jakub Kleň. All rights reserved.
//

#import "UIView+JKKeyboard.h"
#import "JKKeyboardObserver.h"


@implementation UIView (JKKeyboard)

#pragma mark Class

+ (void)animateWithKeyboardNotification:(NSNotification *)notification animations:(void (^)(void))animations
{
	if(animations)
	{
		CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
		UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
		
		duration = MAX(0.15, duration);
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:duration];
		[UIView setAnimationCurve:curve];
		
		animations();
		
		[UIView commitAnimations];
	}
}

#pragma mark Properties

- (CGRect)keyboardFrameInView
{
	JKKeyboardObserver *observer = [JKKeyboardObserver sharedObserver];
	return [self convertRect:observer.keyboardFrameInRootView fromView:observer.rootView];
}

- (CGFloat)keyboardIntersectionInView
{
	CGFloat keyboardIntersectionInView = self.bounds.size.height - self.keyboardFrameInView.origin.y;
	keyboardIntersectionInView = MAX(0.0, keyboardIntersectionInView);
	
	return keyboardIntersectionInView;
}

- (UIResponder *)firstResponder
{
    if(self.isFirstResponder)
	{
        return self;
    }
	
    for(UIView *subView in self.subviews)
	{
        UIResponder *firstResponder = subView.firstResponder;
		
        if(firstResponder)
		{
            return firstResponder;
        }
    }
	
    return nil;
}

#pragma mark Methods

- (void)reassignFirstResponder
{
    UIResponder *inputView = self.firstResponder;
	
    if(inputView)
	{
		[inputView resignFirstResponder];
		[inputView becomeFirstResponder];
    }
}

@end
