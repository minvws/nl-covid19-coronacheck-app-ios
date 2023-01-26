/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// For recording calls to an observer during tests (e.g. in ScanLockManagerTests)
public class ObserverCallbackRecorder<T> {
	
	public var values: [T] = []
	
	public init() {
		self.values = []
	}

	public func recordEvents(_ value: T) {
		values += [value]
	}
}
