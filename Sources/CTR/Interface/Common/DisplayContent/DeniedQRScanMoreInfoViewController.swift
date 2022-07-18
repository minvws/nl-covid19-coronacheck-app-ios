/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class DeniedQRScanMoreInfoViewController: GenericViewController<DeniedQRScanMoreInfoView, DeniedQRScanMoreInfoViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()

		setupBindings()
		addCloseButton(action: #selector(closeButtonTapped))
	}

	/// Setup the bindings to the view model
	func setupBindings() {

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$content.binding = { [weak self] in

			for (text, spacing) in $0 {
				let textView = TextView()
				textView.attributedText = NSAttributedString.makeFromHtml(
					text: text,
					style: .bodyDark
				)
				self?.sceneView.addToStackView(subview: textView, followedByCustomSpacing: spacing)
			}
		}

		viewModel.$hideForCapture.binding = { [weak self] in

			self?.sceneView.isHidden = $0
		}
	}
	
	/// User tapped on the button
	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}
}
