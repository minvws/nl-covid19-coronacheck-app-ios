//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChangeRegionView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let verticalPadding: CGFloat = 8
	}

	private let currentLocationLabel: Label = {
		let label = Label(body: nil, textColor: Theme.colors.grey2)
		label.numberOfLines = 0
		label.textAlignment = .center
		return label
	}()

	private let changeRegionButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Ik ben een banaan", for: .normal)
		button.titleLabel?.font = Theme.fonts.bodyBold
		button.setTitleColor(Theme.colors.iosBlue, for: .normal)
		return button
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .white
		changeRegionButton.addTarget(self, action: #selector(changeRegionButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(currentLocationLabel)
		addSubview(changeRegionButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			currentLocationLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			currentLocationLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			currentLocationLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

			changeRegionButton.topAnchor.constraint(equalTo: currentLocationLabel.bottomAnchor, constant: ViewTraits.verticalPadding),

			changeRegionButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			changeRegionButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			changeRegionButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
		])
	}

	@objc func changeRegionButtonTapped() {
		changeRegionButtonTappedCommand?()
	}

	// MARK: Public Access

	var currentLocationTitle: String? {
		didSet {
			currentLocationLabel.text = currentLocationTitle
		}
	}

	var changeRegionButtonTitle: String? {
		didSet {
			changeRegionButton.setTitle(changeRegionButtonTitle, for: .normal)
		}
	}

	var changeRegionButtonTappedCommand: (() -> Void)?
}
