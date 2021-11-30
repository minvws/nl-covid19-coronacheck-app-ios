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

		// Dimensions
		static let messageLineHeight: CGFloat = 22
		static let cornerRadius: CGFloat = 15

		// Margins
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 20.0
		static let maskOffset: CGFloat = 100.0
	}
	
	let cameraView: CameraView = {
		let view = CameraView()
		return view
	}()
	
	private let moreInformationButton: Button = {

		let button = Button(style: Button.ButtonType.textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.textAlignment = .center
		return button
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		cameraView.embed(in: self)
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
