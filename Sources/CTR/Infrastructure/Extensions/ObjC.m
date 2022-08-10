/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

#import "ObjC.h"

@implementation ObjC

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error {
	@try {
		tryBlock();
		return YES;
	}
	@catch (NSException *exception) {
		*error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
		return NO;
	}
	@finally {}
}

@end
