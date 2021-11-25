/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

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
	
	func scanAgain() {

//		stopAutoCloseTimer()
		coordinator?.navigateToScan()
	}
	
	func showMoreInformation() {

		// By default, unordered lists have a space above them in HTML
		let bulletSpacing: CGFloat = -24
		let spacing: CGFloat = 16

		let textViews = [(TextView(htmlText: L.verifierDeniedMessageOne()), spacing),
						 (TextView(htmlText: L.verifierDeniedMessageTwo()), bulletSpacing),
						 (TextView(htmlText: L.verifierDeniedMessageThree()), spacing),
						 (TextView(htmlText: L.verifierDeniedMessageFour()), 0),
						 (TextView(htmlText: L.verifierDeniedMessageFive()), spacing),
						 (TextView(htmlText: L.verifierDeniedMessageSix()), spacing)]

		coordinator?.displayContent(
			title: L.verifierDeniedTitle(),
			content: textViews
		)
	}
}
