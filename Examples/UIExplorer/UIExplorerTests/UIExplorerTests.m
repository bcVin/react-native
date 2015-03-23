/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "RCTRedBox.h"

#define TIMEOUT_SECONDS 240

@interface UIExplorerTests : XCTestCase

@end

@implementation UIExplorerTests

- (BOOL)findSubviewInView:(UIView *)view matching:(BOOL(^)(UIView *view))test
{
  if (test(view)) {
    return YES;
  }
  for (UIView *subview in [view subviews]) {
    if ([self findSubviewInView:subview matching:test]) {
      return YES;
    }
  }
  return NO;
}

- (void)testRootViewLoadsAndRenders {
  UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];

  NSDate *date = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT_SECONDS];
  BOOL foundElement = NO;
  NSString *redboxError = nil;

  while ([date timeIntervalSinceNow] > 0 && !foundElement && !redboxError) {
    [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:date];
    [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:date];

    redboxError = [[RCTRedBox sharedInstance] currentErrorMessage];

    foundElement = [self findSubviewInView:vc.view matching:^BOOL(UIView *view) {
      if ([view respondsToSelector:@selector(attributedText)]) {
        NSString *text = [(id)view attributedText].string;
        if ([text isEqualToString:@"<View>"]) {
          return YES;
        }
      }
      return NO;
    }];
  }

  XCTAssertNil(redboxError, @"RedBox error: %@", redboxError);
  XCTAssertTrue(foundElement, @"Cound't find element with '<View>' text in %d seconds", TIMEOUT_SECONDS);
}


@end
