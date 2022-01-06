/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

// swiftlint:disable:next type_name
class VisitorPassCompleteCertificateViewController: BaseViewController {

	private let viewModel: VisitorPassCompleteCertificateViewModel
	let sceneView = VisitorPassCompleteCertificateView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: VisitorPassCompleteCertificateViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		addBackButton()
		
		viewModel.$content.binding = { [weak self] in
			self?.displayContent($0)
		}
	}
	
	override var enableSwipeBack: Bool { true }

	private func displayContent(_ content: Content) {

		// Texts
		sceneView.title = content.title
		sceneView.message = content.subTitle

		// Button
		if let actionTitle = content.primaryActionTitle {
			sceneView.primaryTitle = actionTitle
			sceneView.footerButtonView.isHidden = false
		} else {
			sceneView.primaryTitle = nil
			sceneView.footerButtonView.isHidden = true
		}
		sceneView.primaryButtonTappedCommand = content.primaryAction
		sceneView.secondaryButtonTappedCommand = content.secondaryAction
		sceneView.secondaryButtonTitle = content.secondaryActionTitle
	}
}
