/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class VerifierScanView: BaseView {
	
	/// The display constants
	private struct ViewTraits {

		static let margin: CGFloat = 20.0
	}
	
	let scanView = ScanView()
	
	private let moreInformationButton = Button(style: Button.ButtonType.textLabelBlue)
	
	// A dummy view to move the scrollview below the mask on the overlay
	private let dummyView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		
		moreInformationButton.touchUpInside(self, action: #selector(moreInformationButtonTapped))
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		scanView.embed(in: self)
		addSubview(dummyView)
		addSubview(scrollView)
		scrollView.addSubview(moreInformationButton)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			// Dummy
			dummyView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.margin
			),
			dummyView.leadingAnchor.constraint(equalTo: leadingAnchor),
			dummyView.trailingAnchor.constraint(equalTo: trailingAnchor),
			dummyView.heightAnchor.constraint(equalTo: widthAnchor),

			// ScrollView
			scrollView.topAnchor.constraint(equalTo: dummyView.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			// More information button
			moreInformationButton.topAnchor.constraint(equalTo: scrollView.topAnchor),
			moreInformationButton.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.margin
			),
			moreInformationButton.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			moreInformationButton.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			),
			moreInformationButton.widthAnchor.constraint(
				lessThanOrEqualTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.margin
			),
			moreInformationButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
		])
	}
	
	@objc func moreInformationButtonTapped() {

		moreInformationButtonCommand?()
	}
	
	// MARK: - Public Access
	
	/// The message
	var moreInformationButtonText: String? {
		didSet {
			guard let moreInformationButtonText = moreInformationButtonText else {
				moreInformationButton.title = nil
				return
			}

			let attributedTitle = moreInformationButtonText.underline(
				underlined: moreInformationButtonText,
				with: .white
			)
			moreInformationButton.setAttributedTitle(attributedTitle, for: .normal)
		}
	}
	
	var moreInformationButtonCommand: (() -> Void)?
}
