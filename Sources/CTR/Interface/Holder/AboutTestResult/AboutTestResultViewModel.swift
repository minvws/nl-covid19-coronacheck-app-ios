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
	weak var coordinator: (HolderCoordinatorDelegate & Dismissable)?

	/// The proof manager
	var proofManager: ProofManaging?

	@Bindable private (set) var identity: [(String, String)] = []

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(
		coordinator: HolderCoordinatorDelegate & Dismissable,
		proofManager: ProofManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager

		identity = getDisplayIdentity(proofManager.getTestWrapper()?.result?.holder )
	}

	func dismiss() {

		coordinator?.dismiss()
	}

	/// Get a display version of the holder identity
	/// - Parameter holder: the holder identiy
	/// - Returns: the display version
	func getDisplayIdentity(_ holder: HolderTestCredentials?) -> [(String, String)] {

		guard let holder = holder else {
			return []
		}

		var output: [(String, String)] = []
		let parts = holder.mapIdentity(months: months)
		for (index, part) in parts.enumerated() {
			output.append(("\(index)", part))
		}
		return output
	}

	var months: [String] = [.shortJanuary, .shortFebruary, .shortMarch, .shortApril, .shortMay, .shortJune,
							.shortJuly, .shortAugust, .shortSeptember, .shortOctober, .shortNovember, .shortDecember]
}
