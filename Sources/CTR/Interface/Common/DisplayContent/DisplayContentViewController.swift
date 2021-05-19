/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class DisplayContentViewController: BaseViewController {

	/// The model
	private let viewModel: DisplayContentViewModel

	/// The view
	let sceneView = DisplayContentView()

	// MARK: Initializers

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: DisplayContentViewModel) {

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

		setupBindings()
		addCloseButton(action: #selector(closeButtonTapped))
	}

	/// Setup the bindings to the view model
	func setupBindings() {

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$content.binding = { [weak self] in

			for (view, spacing) in $0 {
				self?.sceneView.addToStackView(subview: view, followedByCustomSpacing: spacing)
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
