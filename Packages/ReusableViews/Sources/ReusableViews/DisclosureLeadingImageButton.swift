/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Resources

/*
 A grey full width button with a leading image, a title and a disclosure icon
 */
class DisclosureLeadingImageButton: DisclosureButton {
	
	/// The display constants
	private struct ViewTraits {
		
		enum Disclosure {
			static let trailingMargin: CGFloat = 8.0
		}
		enum Title {
			static let topMargin: CGFloat = 29.0
			static let leadMargin: CGFloat = 20.0
		}
		enum Icon {
			static let leadingMargin: CGFloat = 17.0
			static let topMargin: CGFloat = 16.0
		}
	}
	
	override open func setupViews() {
		
		super.setupViews()
		addSubview(iconView)
	}
	
	override open func setupViewConstraints() {
		
		super.setupViewConstraints()
		setupIconViewConstraints()
	}
	
	override func setupTitleLabelViewConstraints() {

		NSLayoutConstraint.activate([

			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLabel.topAnchor.constraint(
				greaterThanOrEqualTo: topAnchor,
				constant: ViewTraits.Title.topMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: iconView.trailingAnchor,
				constant: ViewTraits.Title.leadMargin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: disclosureView.leadingAnchor,
				constant: -ViewTraits.Disclosure.trailingMargin
			)
		])
	}

	override func setupIconViewConstraints() {

		NSLayoutConstraint.activate([

			iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
			iconView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.Icon.leadingMargin
			),
			iconView.topAnchor.constraint(
				greaterThanOrEqualTo: topAnchor,
				constant: ViewTraits.Icon.topMargin
			)
		])
	}
	
	var image: UIImage? {
		didSet {
			iconView.image = image
		}
	}
}
