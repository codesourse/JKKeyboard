//
//  UIScrollView+JKKeyboard.m
//  JKKeyboardDemo
//
//  Created by Jakub Kleň on 23.1.2014.
//  Copyright (c) 2014 Jakub Kleň. All rights reserved.
//

#import "UIScrollView+JKKeyboard.h"
#import "UIView+JKKeyboard.h"
#import "NSObject+JKRuntimeAdditions.h"
#import <objc/message.h>


@implementation UIScrollView (JKKeyboard)

#pragma mark Lifecycle

+ (void)load
{
	[self swizzle:NSSelectorFromString(@"dealloc") with:@selector(dealloc_UIScrollView_JKKeyboard)];
}

- (void)dealloc_UIScrollView_JKKeyboard
{
	if(self.shouldScrollToBottomOnNextKeyboardWillShow)
	{
		self.shouldScrollToBottomOnNextKeyboardWillShow = NO;
	}
	
	[self dealloc_UIScrollView_JKKeyboard];
}

#pragma mark Properties

- (CGPoint)topOffset
{
	return CGPointMake(self.contentOffset.x, -self.contentInset.top);
}

- (CGPoint)bottomOffset
{
	return CGPointMake(0.0, MAX(0.0, self.contentSize.height - self.bounds.size.height + self.contentInset.bottom));
}

- (BOOL)isScrolledToTop
{
	return (self.contentOffset.y <= self.topOffset.y);
}

- (BOOL)isScrolledToBottom
{
	return (self.contentSize.height < self.bounds.size.height - self.contentInset.bottom || self.contentOffset.y >= self.bottomOffset.y);
}

- (BOOL)shouldScrollToBottomOnNextKeyboardWillShow
{
	return [objc_getAssociatedObject(self, @selector(shouldScrollToBottomOnNextKeyboardWillShow)) boolValue];
}

- (void)setShouldScrollToBottomOnNextKeyboardWillShow:(BOOL)shouldScrollToBottomOnNextKeyboardWillShow
{
	BOOL oldShouldScrollToBottomOnNextKeyboardWillShow = self.shouldScrollToBottomOnNextKeyboardWillShow;
	objc_setAssociatedObject(self, @selector(shouldScrollToBottomOnNextKeyboardWillShow), @(shouldScrollToBottomOnNextKeyboardWillShow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	if(oldShouldScrollToBottomOnNextKeyboardWillShow != self.shouldScrollToBottomOnNextKeyboardWillShow)
	{
		if(oldShouldScrollToBottomOnNextKeyboardWillShow)
		{
			[self removeObservers_UIScrollView_JKKeyboard];
		}
		
		if(self.shouldScrollToBottomOnNextKeyboardWillShow)
		{
			[self addObservers_UIScrollView_JKKeyboard];
		}
	}
}

#pragma mark Methods

- (void)scrollToTopAnimated:(BOOL)animated
{
	if(![self isScrolledToTop])
	{
		[self setContentOffset:self.topOffset animated:animated];
	}
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
	if(![self isScrolledToBottom])
	{
		[self setContentOffset:self.bottomOffset animated:animated];
	}
}

#pragma mark Observing

- (void)addObservers_UIScrollView_JKKeyboard
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow_UIScrollView_JKKeyboard:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)removeObservers_UIScrollView_JKKeyboard
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow_UIScrollView_JKKeyboard:(NSNotification *)notification
{
	if(self.shouldScrollToBottomOnNextKeyboardWillShow)
	{
		self.shouldScrollToBottomOnNextKeyboardWillShow = NO;
		
		//in some weird circumstances, the animation was not actually being animated without this
		[[NSOperationQueue mainQueue] addOperationWithBlock:^
		 {
			 [UIView animateWithKeyboardNotification:notification animations:^
			 {
				[self scrollToBottomAnimated:NO];
			 }];
		 }];
	}
}

@end
