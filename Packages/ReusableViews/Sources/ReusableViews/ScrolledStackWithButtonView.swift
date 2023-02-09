/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

/*
 An extention to the Scrolled Stack View, this one has a fixed footer with a blue button in it for a primary action
 */
open class ScrolledStackWithButtonView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let spacing: CGFloat = 24.0
	}

	/// the update button
	public var primaryButton: Button {
		return footerButtonView.primaryButton
	}
	
	/// The footer view with primary button
	public let footerButtonView: FooterButtonView = {
		
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	private var scrollViewToFooterConstraint: NSLayoutConstraint?
	
	/// Setup all the views
	override open func setupViews() {

		super.setupViews()
		stackView.spacing = ViewTraits.spacing
		backgroundColor = C.white()
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}

	/// Setup the hierarchy
	override open func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(footerButtonView)
	}
 
	/// Setup the constraints
	override open func setupViewConstraints() {

		super.setupViewConstraints()
		
		bottomScrollViewConstraint?.isActive = true

		scrollViewToFooterConstraint = footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor)
		scrollViewToFooterConstraint?.isActive = false
				
		NSLayoutConstraint.activate([
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	/// User tapped on the primary button
	@objc public func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}
	
	private var shouldShowFooter: Bool = false {
		didSet {
			footerButtonView.isHidden = !shouldShowFooter
			
			bottomScrollViewConstraint?.isActive = !shouldShowFooter
			scrollViewToFooterConstraint?.isActive = shouldShowFooter
			setNeedsLayout()
		}
	}

	// MARK: Public Access

	/// The title for the primary button
	public var primaryTitle: String? {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
			shouldShowFooter = primaryTitle != nil
		}
	}

	/// The user tapped on the primary button
	public var primaryButtonTappedCommand: (() -> Void)?
}
