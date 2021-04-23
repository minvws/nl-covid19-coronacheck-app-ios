/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutTestResultViewModel: Logging {

	var loggingCategory: String = "AboutTestResultViewModel"

	/// Coordination Delegate
	weak private var coordinator: Dismissable?

	/// The proof manager
	weak private var proofManager: ProofManaging?

	@Bindable private (set) var identity: [(String, String)] = []

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(
		coordinator: Dismissable,
		proofManager: ProofManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager

		identity = getDisplayIdentity(proofManager.getTestWrapper()?.result?.holder)
	}

	func dismiss() {

		coordinator?.dismiss()
	}

	/// Get a display version of the holder identity
	/// - Parameter holder: the holder identity
	/// - Returns: the display version
	private func getDisplayIdentity(_ holder: TestHolderIdentity?) -> [(String, String)] {

		guard let holder = holder else {
			return []
		}

		var output: [(String, String)] = []
		let parts = holder.mapIdentity(months: String.shortMonths)
		for (index, part) in parts.enumerated() {
			output.append(("\(index + 1)", part))
		}
		return output
	}
}
