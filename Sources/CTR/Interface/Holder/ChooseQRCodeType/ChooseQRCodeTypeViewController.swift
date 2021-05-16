//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseQRCodeTypeViewController: BaseViewController {

	struct ButtonModel {
		let title: String
		let subtitle: String
		let action: () -> Void
	}

	private let viewModel: ChooseQRCodeTypeViewModel

	let sceneView = ChooseQRCodeTypeView()

	init(viewModel: ChooseQRCodeTypeViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
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

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
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
			self.sceneView.buttonsStackView.subviews
				.forEach { $0.removeFromSuperview() }

			// Add new buttons:
			buttons
				.map { buttonModel -> DisclosureSubTitleButton in
					DisclosureSubTitleButton.makeButton(
						title: buttonModel.title,
						subTitle: buttonModel.subtitle,
						command: buttonModel.action
					)
				}
				.forEach(self.sceneView.buttonsStackView.addArrangedSubview)
		}
	}
}

extension DisclosureSubTitleButton {

	/// Create a disclosure button with subtitle
	/// - Parameters:
	///   - title: the title of the button
	///   - subTitle: the sub title of the button
	///   - command: the command to execute when tapped
	/// - Returns: A disclosure button
	fileprivate static func makeButton(
		title: String,
		subTitle: String,
		command: (() -> Void)? ) -> DisclosureSubTitleButton {

		let button = DisclosureSubTitleButton()
		button.isUserInteractionEnabled = true
		button.title = title
		button.subtitle = subTitle
		button.primaryButtonTappedCommand = command
		return button
	}
}
