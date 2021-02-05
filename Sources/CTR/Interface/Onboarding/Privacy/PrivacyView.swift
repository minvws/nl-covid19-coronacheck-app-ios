/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PrivacyView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22
		
		// Margins
		static let margin: CGFloat = 20.0
	}

	private let scrollView: UIScrollView = {

		let scrollView = UIScrollView(frame: .zero)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()

	let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.margin
		return view
	}()

	/// The title label
	private let titleLabel: Label = {
		
		return Label(title1: nil).multiline()
	}()
	
	/// The message label
	let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()

	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = .white
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		scrollView.addSubview(stackView)

		addSubview(scrollView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([

			// Scrollview
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),

			// StackView
			stackView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2.0 * ViewTraits.margin
			),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			stackView.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: ViewTraits.margin
			),
			stackView.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	// MARK: Public Access

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The onboarding message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}
}
