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

class ListStoredEventsView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {
		
		enum TopView {
			static let inset: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 24, right: 20)
		}

		enum Title {
			static let spacing: CGFloat = 24
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}

		enum List {
			static let spacing: CGFloat = 40
		}

		enum Button {
			static let spacing: CGFloat = 24
		}
	}
	
	private let navigationBackgroundView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let topView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()

	private let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stack view for the intro and title
	private let topStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 0
		return view
	}()
	
	/// The stack view for the event groups
	private let listStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.List.spacing
		return view
	}()

	private let activityIndicatorView: ActivityIndicatorView = {
		
		let view = ActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()

	override func setupViews() {

		super.setupViews()

		setColorsForCurrentTraitCollection()
		
		stackViewInset = .zero
		stackView.spacing = 0
		stackView.distribution = .fill
		stackView.shouldGroupAccessibilityChildren = true
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
		scrollView.bounces = false
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(navigationBackgroundView)
		addSubview(activityIndicatorView)
		
		topStackView.embed(in: topView, insets: ViewTraits.TopView.inset)
		
		topStackView.addArrangedSubview(titleLabel)
		topStackView.setCustomSpacing(ViewTraits.Title.spacing, after: titleLabel)
		topStackView.addArrangedSubview(contentTextView)
		topStackView.setCustomSpacing(ViewTraits.Button.spacing, after: contentTextView)
		topStackView.addArrangedSubview(secondaryButton)
		
		stackView.addArrangedSubview(topView)
		stackView.addArrangedSubview(listStackView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += [navigationBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor)]
		constraints += [navigationBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)]
		constraints += [navigationBackgroundView.topAnchor.constraint(equalTo: topAnchor)]
		constraints += [navigationBackgroundView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)]
		
		constraints += [activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)]
		constraints += [activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)]
		
		NSLayoutConstraint.activate(constraints)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setColorsForCurrentTraitCollection()
	}
	
	private func setColorsForCurrentTraitCollection() {
		navigationBackgroundView.backgroundColor = shouldUseDarkMode ? C.grey5() : C.white()
		topView.backgroundColor = shouldUseDarkMode ? C.grey5() : C.white()
		backgroundColor = shouldUseDarkMode ? C.white() : C.primaryBlue5()
		
//		listStackView.subviews
//			.compactMap { $0 as? SeparatorView }
//			.forEach(setColorForCurrentTraitCollection(separatorView:))
	}
//
//	private func setColorForCurrentTraitCollection(separatorView: SeparatorView) {
//
//		separatorView.backgroundColor = C.grey4()
//	}
	
	private func createSeparatorView() -> SeparatorView {

		let view = SeparatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}

	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		set {
			titleLabel.attributedText = newValue?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
		get {
			titleLabel.attributedText?.string
		}
	}

	/// The message
	var message: String? {
		set {
			contentTextView.applyHTML(newValue)
		}
		get {
			contentTextView.attributedText?.string
		}
	}
	
	var messageLinkTapHandler: ((URL) -> Void)? {
		didSet {
			contentTextView.linkTouchedHandler = messageLinkTapHandler
		}
	}

	var secondaryButtonTappedCommand: (() -> Void)?

	var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
			secondaryButton.isHidden = secondaryButtonTitle?.isEmpty ?? true
		}
	}

	func addSeparator() {

		let separator = createSeparatorView()
		listStackView.addArrangedSubview(separator)

		NSLayoutConstraint.activate([
			separator.heightAnchor.constraint(equalToConstant: 1)
		])
	}

	func addGroupStackView(_ groupView: UIStackView) {

		listStackView.addArrangedSubview(groupView)
		setColorsForCurrentTraitCollection()
	}

	var hideForCapture: Bool = false {
		didSet {
			listStackView.isHidden = hideForCapture
		}
	}

	func setListStackVisibility(ishidden: Bool) {
		listStackView.isHidden = ishidden
	}
	
	func removeExistingRows() {
		// Remove previously added rows:
		listStackView.removeArrangedSubviews()
	}
	
	func addToListStackView(_ view: UIView) {
		listStackView.addArrangedSubview(view)
		
		setColorsForCurrentTraitCollection()
	}
	
	var shouldShowLoadingSpinner: Bool = false {
		didSet {
			activityIndicatorView.shouldShowLoadingSpinner = shouldShowLoadingSpinner
		}
	}
}

private class SeparatorView: UIView {}
