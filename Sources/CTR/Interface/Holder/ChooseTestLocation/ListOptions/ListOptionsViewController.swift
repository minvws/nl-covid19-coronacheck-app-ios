/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListOptionsViewController: BaseViewController {

	struct OptionModel {
		let title: String
		let subTitle: String?
		let image: UIImage?
		let action: () -> Void
	}

	private let viewModel: ListOptionsViewModel

	let sceneView = ListOptionsView()

	init(viewModel: ListOptionsViewModel) {

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
		setupOptions()

		// Only show an arrow as back button
		addBackButton()
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
			self?.sceneView.secondaryButtonTitle = button.title
			self?.sceneView.secondaryButtonTappedCommand = button.action
		}
	}
	
	func setupOptions() {
		
		viewModel.$buttonModels.binding = { [weak self] buttons in
			guard let self = self else { return }

			// Remove previously added buttons:
			self.sceneView.optionStackView.subviews
				.forEach { $0.removeFromSuperview() }

			// Add new buttons:
			buttons
				.map { optionModel -> UIView in
					if let subTitle = optionModel.subTitle {
						return DisclosureSubtitleButton.makeButton(
							title: optionModel.title,
							subtitle: subTitle,
							command: optionModel.action
						)
					} else {
						return DisclosureButton.makeButton(
							title: optionModel.title,
							command: optionModel.action
						)
					}
				}
				.forEach(self.sceneView.optionStackView.addArrangedSubview)
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

extension DisclosureSubtitleButton {

	/// Create a disclosure button with subtitle
	/// - Parameters:
	///   - title: the title of the button
	///   - subTitle: the sub title of the button
	///   - command: the command to execute when tapped
	/// - Returns: A disclosure button
	static func makeButton(
		title: String,
		subtitle: String,
		subtitleIcon: UIImage? = nil,
		command: (() -> Void)? ) -> DisclosureSubtitleButton {

		let button = DisclosureSubtitleButton()
		button.isUserInteractionEnabled = true
		button.title = title
		button.subtitle = subtitle
		button.primaryButtonTappedCommand = command
		return button
	}
}
