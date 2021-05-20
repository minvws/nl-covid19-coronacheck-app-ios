//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ToggleRegionView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let segmentedControlHeight: CGFloat = 50

		// Margins
		static let horizontalMargin: CGFloat = 3
		static let topLabelBottomMargin: CGFloat = 32
		static let bottomLabelBottomMargin: CGFloat = 16
		static let segmentedControlBottomMargin: CGFloat = 20
		static let segmentedControlToBottomMinimumHeight: CGFloat = 90
	}

	private let topLabel: Label = {
		let label = Label(body: nil, textColor: Theme.colors.dark)
		label.numberOfLines = 0
		label.textAlignment = .left

		return label
	}()

	private let bottomLabel: Label = {
		let label = Label(body: nil, textColor: Theme.colors.dark)
		label.numberOfLines = 0
		label.font = Theme.fonts.subhead
		label.textAlignment = .left
		return label
	}()

	private let segmentedControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl()
		segmentedControl.backgroundColor = Theme.colors.grey5
		segmentedControl.setTitleTextAttributes([
			NSAttributedString.Key.foregroundColor: Theme.colors.primary,
			NSAttributedString.Key.font: Theme.fonts.bodySemiBold
		], for: .normal)

		if #available(iOS 13.0, *) {
			segmentedControl.selectedSegmentTintColor = .white
		} else {
			// Fallback on earlier versions
		}

		return segmentedControl
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .white
		segmentedControl.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(topLabel)
		addSubview(segmentedControl)
		addSubview(bottomLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		topLabel.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		bottomLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			topLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			topLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: ViewTraits.horizontalMargin),
			topLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -ViewTraits.horizontalMargin),

			segmentedControl.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: ViewTraits.topLabelBottomMargin),
			segmentedControl.heightAnchor.constraint(equalToConstant: ViewTraits.segmentedControlHeight),
			segmentedControl.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: ViewTraits.horizontalMargin),
			segmentedControl.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -ViewTraits.horizontalMargin),

			bottomLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: ViewTraits.segmentedControlBottomMargin),
			bottomLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: ViewTraits.horizontalMargin),
			bottomLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -ViewTraits.horizontalMargin),

			segmentedControl.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor, constant: -ViewTraits.segmentedControlToBottomMinimumHeight),
			bottomLabel.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor, constant: -ViewTraits.bottomLabelBottomMargin)
		])
	}

	@objc func toggleValueChanged() {
		toggleRegionSelectedIndexChangedCommand?(segmentedControl.selectedSegmentIndex)
	}

	// MARK: Public Access

	var topText: String? {
		didSet {
			topLabel.text = topText
		}
	}

	var bottomText: String? {
		didSet {
			bottomLabel.text = bottomText
		}
	}

	var segmentValues: [(String, Int, Bool)]? {
		didSet {
			segmentedControl.removeAllSegments()
			segmentValues?.forEach {
				segmentedControl.insertSegment(withTitle: $0.0, at: $0.1, animated: false)
			}

			if let selectedIndex = segmentValues?.first(where: { $0.2 })?.1 {
				segmentedControl.selectedSegmentIndex = selectedIndex
			}
		}
	}

	var toggleRegionSelectedIndexChangedCommand: ((Int) -> Void)?
}
