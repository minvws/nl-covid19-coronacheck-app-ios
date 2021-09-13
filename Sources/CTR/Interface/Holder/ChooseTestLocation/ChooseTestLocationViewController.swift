/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseTestLocationViewController: BaseViewController {

	struct ButtonModel {
		let title: String
		let subtitle: String?
		let action: () -> Void
	}

	struct BottomButtonModel {
		let title: String
		let action: () -> Void
	}

	private let viewModel: ChooseTestLocationViewModel

	let sceneView = ChooseTestLocationView()

	init(viewModel: ChooseTestLocationViewModel) {

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
		styleBackButton()
	}

	func setupBinding() {

		viewModel.$title.binding = { [weak self] title in
			self?.sceneView.title = title
		}

		viewModel.$message.binding = { [weak self] message in
			self?.sceneView.message = message
		}

		viewModel.$bottomButton.binding = { [weak self] button in
			guard let button = button else {
				return
			}
			self?.sceneView.noTestTitle = button.title
			self?.sceneView.noTestButtonTappedCommand = button.action
		}

		viewModel.$buttonModels.binding = { [weak self] buttons in
			guard let self = self else { return }

			// Remove previously added buttons:
			self.sceneView.buttonsStackView.subviews
				.forEach { $0.removeFromSuperview() }

			// Add new buttons:
			buttons
				.map { buttonModel -> UIView in
					if let subTitle = buttonModel.subtitle {

						return DisclosureSubTitleButton.makeButton(
							title: buttonModel.title,
							subTitle: subTitle,
							command: buttonModel.action
						)
					} else {
						return DisclosureButton.makeButton(
							title: buttonModel.title,
							command: buttonModel.action
						)
					}
				}
				.forEach(self.sceneView.buttonsStackView.addArrangedSubview)
		}
	}
}

extension DisclosureButton {

	/// Create a disclosure button with subtitle
	/// - Parameters:
	///   - title: the title of the button
	///   - command: the command to execute when tapped
	/// - Returns: A disclosure button
	static func makeButton(
		title: String,
		command: (() -> Void)? ) -> DisclosureButton {

		let button = DisclosureButton()
		button.isUserInteractionEnabled = true
		button.title = title
		button.primaryButtonTappedCommand = command
		return button
	}
}
