/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// e.g. use like so:
// `now.addingTimeInterval(8 * days * ago)`

/// now is 2021-07-15 15:02:39
public let now = Date(timeIntervalSince1970: 1626361359)
public let ago: TimeInterval = -1
public let fromNow: TimeInterval = 1
public let seconds: TimeInterval = 1
public let second: TimeInterval = seconds
public let minutes: TimeInterval = 60
public let minute: TimeInterval = minutes
public let hours: TimeInterval = 60 * minutes
public let hour = hours
public let days: TimeInterval = hours * 24
public let day: TimeInterval = days
public let years: TimeInterval = days * 365
public let year: TimeInterval = years
public let yesterday: TimeInterval = 24 * hours * ago
public let tomorrow: TimeInterval = 24 * hours * fromNow
