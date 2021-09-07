/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class EventStartViewController: BaseViewController {

	private let viewModel: EventStartViewModel
	internal let sceneView = EventStartView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: EventStartViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initializer
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

		setupBinding()
		setupInteraction()
	}

	private func setupBinding() {

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
	}

	private func setupInteraction() {

		sceneView.primaryTitle = L.holderVaccinationStartAction()
		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.primaryButtonTapped()
		}

		sceneView.secondaryButtonTitle = L.holderVaccinationStartNodigid()
		sceneView.secondaryButtonTappedCommand = { [weak self] in

			if let url = URL(string: L.holderVaccinationStartNodigidUrl()) {
				self?.viewModel.openUrl(url)
			}
		}

		sceneView.contentTextView.linkTouched { [weak self] url in

			self?.viewModel.openUrl(url)
		}

		addCustomBackButton(action: #selector(backButtonTapped), accessibilityLabel: L.generalBack())
		styleBackButton()
	}

	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
	}
}
