/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class HolderDashboardView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let messageLineHeight: CGFloat = 26
		static let cardRatio: CGFloat = UIDevice.current.isSmallScreen ? 1.2 : 1.5

		// Margin
		static let margin: CGFloat = 10
	}

	// MARK: Singleton Cards

	/// "To get access to the pilot, you need a.. "
	let headerMessageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The create QR Card
	let makeQRCard: CardView = {

		let view = CardView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let changeRegionView: ChangeRegionView = {
		let view = ChangeRegionView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override func setupViews() {
		super.setupViews()
		stackView.distribution = .fill
	}
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
	}
}
