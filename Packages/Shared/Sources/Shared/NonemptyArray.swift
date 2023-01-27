/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// Wraps an array which it guarantees to be non-empty
public struct NonemptyArray<T>: CustomDebugStringConvertible {
	public let contents: [T]

	public var debugDescription: String {
		return String(describing: contents)
	}
	
	public init?(_ value: [T]) {
		guard value.isNotEmpty else { return nil }
		contents = value
	}
}

public extension NonemptyArray where T: Equatable {
	static func == (lhs: NonemptyArray<T>, rhs: NonemptyArray<T>) -> Bool {
		return lhs.contents == rhs.contents
	}
}
