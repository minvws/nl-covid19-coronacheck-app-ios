/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol UserSettingsProtocol {

	var scanInstructionShown: Bool { get set }

	var jailbreakWarningShown: Bool { get set }

	var executedJun28Patch: Bool { get set }
}

class UserSettings: UserSettingsProtocol {

	@UserDefaults(key: "scanInstructionShown", defaultValue: false)
	var scanInstructionShown: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "jailbreakWarningShown", defaultValue: false)
	var jailbreakWarningShown: Bool // swiftlint:disable:this let_var_whitespace

	@UserDefaults(key: "executedJun28Patch", defaultValue: false)
	var executedJun28Patch: Bool // swiftlint:disable:this let_var_whitespace
}
