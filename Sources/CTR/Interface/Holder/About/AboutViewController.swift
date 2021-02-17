/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutViewController: BaseViewController {

	/// The model
	private let viewModel: AboutViewModel

	/// The view
	let sceneView = AboutView()

	// MARK: Initializers

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: AboutViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Show always in portrait
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = { self.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }

		viewModel.$link.binding = {
			self.sceneView.link($0)
			self.setupLink()
		}
	}

	// MARK: Helper methods

	/// Setup a gesture recognizer for underlined text
	private func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		sceneView.linkLabel.addGestureRecognizer(tapGesture)
		sceneView.linkLabel.isUserInteractionEnabled = true
	}

	// MARK: User interaction

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkTapped()
	}
}
