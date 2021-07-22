/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// e.g. use like so:
// `now.addingTimeInterval(8 * days * ago)`

let now = Date(timeIntervalSince1970: 1626361359) // 2021-07-15 15:02:39
let ago: TimeInterval = -1
let fromNow: TimeInterval = 1
let seconds: TimeInterval = 1
let minutes: TimeInterval = 60
let hours: TimeInterval = 60 * minutes
let days: TimeInterval = hours * 24
