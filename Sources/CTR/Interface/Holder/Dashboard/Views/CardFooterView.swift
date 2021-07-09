/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// Can be deleted once EU launch date is past
class CardFooterView: BaseView {

	private let titleLabel: Label = {
		let label = Label(subhead: nil, textColor: Theme.colors.grey1)
		label.numberOfLines = 0

		return label
	}()

	// MARK: - Lifecycle

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(titleLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}
}
