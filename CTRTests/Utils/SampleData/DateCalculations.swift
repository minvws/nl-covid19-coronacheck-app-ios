/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// e.g. use like so:
// `now.addingTimeInterval(8 * days * ago)`

/// now is 2021-07-15 15:02:39
let now = Date(timeIntervalSince1970: 1626361359)
let ago: TimeInterval = -1
let fromNow: TimeInterval = 1
let seconds: TimeInterval = 1
let second: TimeInterval = seconds
let minutes: TimeInterval = 60
let minute: TimeInterval = minutes
let hours: TimeInterval = 60 * minutes
let hour = hours
let days: TimeInterval = hours * 24
let day: TimeInterval = days
