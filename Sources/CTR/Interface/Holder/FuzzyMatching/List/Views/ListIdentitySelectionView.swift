/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared

class ListIdentitySelectionView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 24
			static let bottom: CGFloat = 24
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let titleToHeader: CGFloat = 24
			static let headerToStackview: CGFloat = 32
			static let stackviewToMoreButton: CGFloat = 40
		}
		enum Size {
			static let separatorHeight: CGFloat = 1
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		enum Message {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
	}
	
	let scrollView: UIScrollView = {
		
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	private let titleLabel: Label = {
		
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()
	
	private let separatorView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = C.grey4()
		return view
	}()

	internal let selectionStackView: UIStackView = {
		
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		return stackView
	}()
	
	private let moreButton: Button = {
		
		return Button(style: .textLabelBlue)
	}()
	
	private let errorView = ErrorView()
	
	let footerButtonView: FooterButtonView = {
		
		let view = FooterButtonView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	override func setupViews() {
		
		super.setupViews()
		
		backgroundColor = C.white()
		
		moreButton.touchUpInside(self, action: #selector(readMore))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
		
		footerButtonView.buttonStackView.alignment = .center
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(titleLabel)
		scrollView.addSubview(messageLabel)
		scrollView.addSubview(separatorView)
		scrollView.addSubview(selectionStackView)
		scrollView.addSubview(moreButton)
		
		footerButtonView.buttonStackView.insertArrangedSubview(errorView, at: 0)
	}
	
	override func setupViewConstraints() {

		super.setupViewConstraints()

		setupScrollViewConstraints()
		setupFooterButtonViewConstraints()
		setupTitleLabelViewConstraints()
		setupHeaderLabelViewConstraints()
		setupSeparatorViewContraints()
		setupSelectionStackViewConstraints()
		setupMoreButtonViewConstraints()
	}
	
	func setupScrollViewConstraints() {
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
		])
	}
	
	func setupFooterButtonViewConstraints() {
		
		NSLayoutConstraint.activate([
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	func setupTitleLabelViewConstraints() {
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: ViewTraits.Margin.top
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			titleLabel.rightAnchor.constraint(
				equalTo: scrollView.rightAnchor,
				constant: -ViewTraits.Margin.edge
			),
			titleLabel.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.Margin.edge
			)
		])
	}
	
	func setupHeaderLabelViewConstraints() {
		
		NSLayoutConstraint.activate([
			messageLabel.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: ViewTraits.Spacing.titleToHeader
			),
			messageLabel.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			messageLabel.rightAnchor.constraint(
				equalTo: scrollView.rightAnchor,
				constant: -ViewTraits.Margin.edge
			),
			messageLabel.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.Margin.edge
			)
		])
	}
	
	func setupSeparatorViewContraints() {
		
		NSLayoutConstraint.activate([
			
			separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
			separatorView.rightAnchor.constraint(equalTo: rightAnchor),
			separatorView.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.Spacing.headerToStackview
			),
			separatorView.heightAnchor.constraint(equalToConstant: ViewTraits.Size.separatorHeight)
		])
	}
	
	func setupSelectionStackViewConstraints() {
		
		NSLayoutConstraint.activate([
			selectionStackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
			selectionStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			selectionStackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
			selectionStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
		])
	}
	
	func setupMoreButtonViewConstraints() {
		
		NSLayoutConstraint.activate([
			moreButton.topAnchor.constraint(
				equalTo: selectionStackView.bottomAnchor,
				constant: ViewTraits.Spacing.stackviewToMoreButton
			),
			moreButton.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			moreButton.rightAnchor.constraint(
				lessThanOrEqualTo: scrollView.rightAnchor,
				constant: -ViewTraits.Margin.edge
			),
			moreButton.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.Margin.bottom
			)
		])
	}
	
	@objc private func readMore() {
		
		readMoreCommand?()
	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning,
				textColor: C.black()!)
		}
	}
	
	var header: String? {
		didSet {
			messageLabel.attributedText = header?.setLineHeight(
				ViewTraits.Message.lineHeight,
				kerning: ViewTraits.Message.kerning,
				textColor: C.black()!)
		}
	}
	
	var errorMessage: String? {
		didSet {
			errorView.error = errorMessage
			errorView.isHidden = errorMessage == nil // Hide if errorMessage is nil
		}
	}
	
	var moreButtonTitle: String? {
		didSet {
			moreButton.title = moreButtonTitle
		}
	}
	
	var readMoreCommand: (() -> Void)?
	
	func addIdentityControlView(_ controlView: IdentityControlView) {
		
		selectionStackView.addArrangedSubview(controlView)
	}
}
