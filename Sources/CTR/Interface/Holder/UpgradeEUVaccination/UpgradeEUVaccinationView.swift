/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class UpgradeEUVaccinationView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()

	private let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var loadingButtonOverlay: ButtonLoadingOverlayView = {
		let overlay = ButtonLoadingOverlayView()

		overlay.translatesAutoresizingMaskIntoConstraints = false
		overlay.isHidden = true
		return overlay
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextView)

		addSubview(loadingButtonOverlay)
	}

	override func setupViewConstraints() {
		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			loadingButtonOverlay.leadingAnchor.constraint(equalTo: primaryButton.leadingAnchor),
			loadingButtonOverlay.trailingAnchor.constraint(equalTo: primaryButton.trailingAnchor),
			loadingButtonOverlay.topAnchor.constraint(equalTo: primaryButton.topAnchor),
			loadingButtonOverlay.bottomAnchor.constraint(equalTo: primaryButton.bottomAnchor)
		])
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}

	/// The message
	var message: String? {
		didSet {
			contentTextView.html(message)
		}
	}

	var isLoading: Bool = false {
		didSet {
			loadingButtonOverlay.buttonAppearsEnabled = !isLoading
			loadingButtonOverlay.isHidden = !isLoading
		}
	}
}
