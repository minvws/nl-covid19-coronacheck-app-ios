/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class DeniedAccessViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?
	
	/// The title of the scene
	@Bindable private(set) var accessTitle: String
	
	@Bindable private(set) var primaryTitle: String
	
	@Bindable private(set) var secondaryTitle: String
	
	init(coordinator: (VerifierCoordinatorDelegate & Dismissable)) {
		
		self.coordinator = coordinator
		
		accessTitle = L.verifierResultDeniedTitle()
		primaryTitle = L.verifierResultNext()
		secondaryTitle = L.verifierResultDeniedReadmore()
	}
	
	func dismiss() {

		coordinator?.navigateToVerifierWelcome()
	}
}
