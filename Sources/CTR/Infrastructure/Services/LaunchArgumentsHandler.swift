/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LaunchArgumentsHandler {

	static func getScannedDCC() -> String? {
		
		if let commandlineArgument = CommandLine.arguments.first(where: { $0.lowercased().starts(with: "-scanneddcc:") }),
		   let base64EncodedDCC = commandlineArgument.split(separator: ":").last,
		   let base64DecodedDCC = String(base64EncodedDCC).base64Decoded() {
			return base64DecodedDCC.trimmingCharacters(in: .whitespacesAndNewlines)
		}
		return nil
	}
	
	static func getCouplingCode() -> String? {
		
		if let commandlineArgument = CommandLine.arguments.first(where: { $0.lowercased().starts(with: "-couplingcode:") }),
		   let couplingCode = commandlineArgument.split(separator: ":").last {
			return String(couplingCode)
		}
		return nil
	}
	
	static func shouldDisableTransitions() -> Bool {
		
		return CommandLine.arguments.contains("-disableTransitions")
	}
	
	static func shouldShowAccessibilityLabels() -> Bool {
		
		return CommandLine.arguments.contains("-showAccessibilityLabels")
	}
	
	static func shouldResetOnStart() -> Bool {
		
		return CommandLine.arguments.contains("-resetOnStart")
	}

	static func shouldSkipOnboarding() -> Bool {
		
		return CommandLine.arguments.contains("-skipOnboarding")
	}
	
	static func shouldUseDisclosurePolicyMode0G() -> Bool {
		
		return CommandLine.arguments.contains("-disclosurePolicyMode0G")
	}
	
	static func shouldUseDisclosurePolicyMode1G() -> Bool {
		
		return CommandLine.arguments.contains("-disclosurePolicyMode1G")
	}
	
	static func shouldUseDisclosurePolicyMode1GWith3G() -> Bool {
		
		return CommandLine.arguments.contains("-disclosurePolicyMode1GWith3G")
	}
	
	static func shouldUseDisclosurePolicyMode3G() -> Bool {
		
		return CommandLine.arguments.contains("-disclosurePolicyMode3G")
	}
	
	static func shouldInjectView() -> Bool {
		
		return CommandLine.arguments.contains("-shouldInjectView")
	}
}
