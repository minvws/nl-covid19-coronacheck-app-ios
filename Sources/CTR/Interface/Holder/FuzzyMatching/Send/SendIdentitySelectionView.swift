/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Resources

class SendIdentitySelectionView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let activityIndicatorView: ActivityIndicatorView = {
		
		let view = ActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(activityIndicatorView)

		stackView.addArrangedSubview(titleLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
			activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
	
	override func setupAccessibility() {
		
		super.setupAccessibility()
		titleLabel.isAccessibilityElement = false
		activityIndicatorView.isAccessibilityElement = true
		activityIndicatorView.accessibilityLabel = L.holder_identitySelection_loading_accessibility()
		accessibilityElements = [activityIndicatorView]
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	var shouldShowLoadingSpinner: Bool = false {
		didSet {
			activityIndicatorView.shouldShowLoadingSpinnerWithoutVoiceOver = shouldShowLoadingSpinner
		}
	}
}
