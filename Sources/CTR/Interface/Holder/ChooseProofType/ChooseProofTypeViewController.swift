/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseProofTypeViewController: BaseViewController {

	struct ButtonModel {
		let title: String
		let subtitle: String
		let action: () -> Void
	}

	private let viewModel: ChooseProofTypeViewModel
	
	override var enableSwipeBack: Bool { true }

	let sceneView = ChooseProofTypeView()

	init(viewModel: ChooseProofTypeViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = TraitWrapper(sceneView)
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		setupBinding()

		// Show back button in navigation push
		addBackButton()
	}

	func setupBinding() {

		viewModel.$title.binding = { [weak self] title in
			self?.sceneView.title = title
		}

		viewModel.$message.binding = { [weak self] message in
			self?.sceneView.message = message
		}

		viewModel.$buttonModels.binding = { [weak self] buttons in
			guard let self = self else { return }

			// Remove previously added buttons:
			self.sceneView.buttonsStackView.removeArrangedSubviews()

			// Add new buttons:
			buttons
				.map { buttonModel -> DisclosureSubtitleButton in
					DisclosureSubtitleButton.makeButton(
						title: buttonModel.title,
						subtitle: buttonModel.subtitle,
						command: buttonModel.action
					)
				}
				.forEach(self.sceneView.buttonsStackView.addArrangedSubview)
		}
	}
}
