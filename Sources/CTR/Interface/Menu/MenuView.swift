/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class MenuItemView: BaseView {

	/// The message label
	let titleLabel: Label = {

		return Label(body: nil).multiline()
	}()

	let primaryButton: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// Setup the views
	override func setupViews() {

		super.setupViews()
		primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(titleLabel)
		addSubview(primaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		titleLabel.embed(in: self)
		primaryButton.embed(in: self)
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
		
		titleLabel.isAccessibilityElement = false

	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
			primaryButton.accessibilityLabel = title
		}
	}
}

class MenuView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		// MenuItemView has additional margins, so less margins defined here
		static let verticalMargin: CGFloat = 29.0
		static let topMenuSpacing: CGFloat = 20.0
		static let bottomMenuSpacing: CGFloat = 20.0
		static let separatorHeight: CGFloat = 1.0
	}

	/// The stackview for the content
	 let topStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.topMenuSpacing
		return view
	}()

	/// The stackview for the content
	 let bottomStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.bottomMenuSpacing
		return view
	}()
	
	private let separatorView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.secondary.withAlphaComponent(0.5)
		return view
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.primary
		
		stackViewInset = UIEdgeInsets(
			top: ViewTraits.verticalMargin,
			left: ViewTraits.margin,
			bottom: ViewTraits.margin,
			right: ViewTraits.verticalMargin
		)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		stackView.addArrangedSubview(topStackView)
		stackView.addArrangedSubview(separatorView)
		stackView.addArrangedSubview(bottomStackView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			separatorView.heightAnchor.constraint(equalToConstant: ViewTraits.separatorHeight)
		])
	}
}
