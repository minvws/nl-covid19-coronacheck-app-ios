/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

extension String {

	static var verifierScanTitle: String {

		return Localization.string(for: "verifier.scan.title")
	}

	static var verifierScanMessage: String {

		return Localization.string(for: "verifier.scan.message")
	}

	static var verifierScanTorchEnable: String {

		return Localization.string(for: "verifier.scan.torch.enable")
	}
    
    static var verifierScanTorchDisable: String {

        return Localization.string(for: "verifier.scan.torch.disable")
    }

	static var verifierScanPermissionTitle: String {

		return Localization.string(for: "verifier.scan.permission.title")
	}

	static var verifierScanPermissionMessage: String {

		return Localization.string(for: "verifier.scan.permission.message")
	}

	static var verifierScanPermissionSettings: String {

		return Localization.string(for: "verifier.scan.permission.settings")
	}
}
