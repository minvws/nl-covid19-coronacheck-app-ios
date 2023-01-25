/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

final class PaperProofScanView: BaseView, HasScanView {
	
	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let messageLineHeight: CGFloat = 22

		// Margins
		static let margin: CGFloat = 20.0
	}
	
	/// The message label
	private let messageLabel: Label = {

		return Label(bodySemiBold: nil).multiline()
	}()
	
	let scanView = ScanView()

	let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.accessibilityIdentifier = "scrollViewA"
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	override func setupViews() {
		super.setupViews()
		scanView.accessibilityIdentifier = "scanView"
		backgroundColor = C.black()
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		scanView.embed(in: self)
		addSubview(scrollView)
		scrollView.addSubview(messageLabel)
	}
	
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		setupScrollViewConstraints()
		setupMessageLabelViewConstraints()
	}
	
	func setupScrollViewConstraints() {
		
		NSLayoutConstraint.activate([
			// ScrollView
			scrollView.topAnchor.constraint(lessThanOrEqualTo: scanView.maskLayoutGuide.bottomAnchor, constant: 40),
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	func setupMessageLabelViewConstraints() {
		
		NSLayoutConstraint.activate([
			// Message
			messageLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
			messageLabel.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			// Extra constraints to make the message scrollable
			messageLabel.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.margin
			),
			messageLabel.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			),
			messageLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
		])
	}

	// MARK: - Public Access
	
	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(
				ViewTraits.messageLineHeight,
				alignment: .center,
				textColor: C.white()!
			)
		}
	}
}
