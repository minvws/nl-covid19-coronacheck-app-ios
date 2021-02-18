/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppointmentViewController: BaseViewController {

	private let viewModel: AppointmentViewModel

	let sceneView = AppointmentView()

	// MARK: Initializers

	init(viewModel: AppointmentViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle

	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = {
			self.title = $0
		}

		viewModel.$header.binding = {
			self.sceneView.title = $0
		}

		viewModel.$body.binding = { self.sceneView.message = $0 }

		viewModel.$linkedBody.binding = {
			self.sceneView.underline($0)
			self.setupLink()
		}

		viewModel.$buttonTitle.binding = { self.sceneView.primaryTitle = $0 }
		viewModel.$image.binding = { self.sceneView.headerImage = $0 }

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.buttonClick()
		}
	}

	// MARK: Helper methods

	/// Setup a gesture recognizer for underlined text
	private func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		sceneView.messageLabel.addGestureRecognizer(tapGesture)
		sceneView.messageLabel.isUserInteractionEnabled = true
	}

	// MARK: User interaction

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkedClick()
	}
}
