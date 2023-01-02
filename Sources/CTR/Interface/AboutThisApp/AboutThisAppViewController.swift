/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class AboutThisAppViewController: TraitWrappedGenericViewController<AboutThisAppView, AboutThisAppViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .always

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$alert.binding = { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}

		addBackButton(customAction: nil)
		setupMenuOptions()
		
		sceneView.resetButtonTapHandler = { [weak viewModel] in
			viewModel?.didTapResetApp()
		}
	}
	
	private func setupMenuOptions() {

		for menu in viewModel.menu {
			let stackView = sceneView.createMenuStackView(title: menu.key)
			for item in menu.value {

				let button = SimpleDisclosureButton.makeButton(
					title: item.name,
					command: { [weak self] in
						self?.viewModel.menuOptionSelected(item.identifier)
					}
				)
				stackView.addArrangedSubview(button)
			}

			sceneView.menuStackView.addArrangedSubview(stackView)
			sceneView.menuStackView.setCustomSpacing(32, after: stackView)
		}
	}
}

extension SimpleDisclosureButton {

	/// Create a simple disclosure button with subtitle
	/// - Parameters:
	///   - title: the title of the button
	///   - command: the command to execute when tapped
	/// - Returns: A disclosure button
	static func makeButton(
		title: String,
		command: (() -> Void)? ) -> SimpleDisclosureButton {

			let button = SimpleDisclosureButton()
			button.isUserInteractionEnabled = true
			button.title = title
			button.primaryButtonTappedCommand = command
			return button
		}
}
