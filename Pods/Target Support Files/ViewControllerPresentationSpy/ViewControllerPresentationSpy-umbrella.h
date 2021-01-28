#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "QCOMockPopoverPresentationController.h"
#import "UIAlertAction+QCOMock.h"
#import "UIAlertController+QCOMock.h"
#import "UIViewController+QCOMock.h"

FOUNDATION_EXPORT double ViewControllerPresentationSpyVersionNumber;
FOUNDATION_EXPORT const unsigned char ViewControllerPresentationSpyVersionString[];

