/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

public class LaunchArgumentsHandler {

	public static func getScannedDCC() -> String? {
		
		if let commandlineArgument = CommandLine.arguments.first(where: { $0.lowercased().starts(with: "-scanneddcc:") }),
		   let base64EncodedDCC = commandlineArgument.split(separator: ":").last,
		   let base64DecodedDCC = String(base64EncodedDCC).base64Decoded() {
			return base64DecodedDCC.trimmingCharacters(in: .whitespacesAndNewlines)
		}
		return nil
	}
	
	public static func getCouplingCode() -> String? {
		
		if let commandlineArgument = CommandLine.arguments.first(where: { $0.lowercased().starts(with: "-couplingcode:") }),
		   let couplingCode = commandlineArgument.split(separator: ":").last {
			return String(couplingCode)
		}
		return nil
	}
	
	public static func shouldDisableTransitions() -> Bool {
		
		return CommandLine.arguments.contains("-disableTransitions")
	}
	
	public static func shouldShowAccessibilityLabels() -> Bool {
		
		return CommandLine.arguments.contains("-showAccessibilityLabels")
	}
	
	public static func shouldResetOnStart() -> Bool {
		
		return CommandLine.arguments.contains("-resetOnStart")
	}

	public static func shouldSkipOnboarding() -> Bool {
		
		return CommandLine.arguments.contains("-skipOnboarding")
	}
}
