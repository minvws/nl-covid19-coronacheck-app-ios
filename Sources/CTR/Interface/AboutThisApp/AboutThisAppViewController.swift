/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutThisAppViewController: BaseViewController {

	/// The model
	private let viewModel: AboutThisAppViewModel

	/// The view
	let sceneView = AboutThisAppView()

	// MARK: Initializers

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: AboutThisAppViewModel) {

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

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$appVersion.binding = { [weak self] in self?.sceneView.appVersion = $0 }
		viewModel.$configVersion.binding = { [weak self] in self?.sceneView.configVersion = $0 }
		viewModel.$alert.binding = { [weak self] in self?.showAlert($0, okActionIsDestructive: true) }

		setupMenuOptions()
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
