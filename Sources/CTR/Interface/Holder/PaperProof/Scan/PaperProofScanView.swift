/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PaperProofScanView: BaseView {
	
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
	
	// A dummy view to move the scrollview below the mask on the overlay
	let dummyView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		scanView.embed(in: self)
		addSubview(dummyView)
		addSubview(scrollView)
		scrollView.addSubview(messageLabel)
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
