/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListOptionsViewController: TraitWrappedGenericViewController<ListOptionsView, ListOptionsProtocol> {

	struct OptionModel {
		init(title: String, subTitle: String? = nil, image: UIImage? = nil, action: @escaping () -> Void) {
			self.title = title
			self.subTitle = subTitle
			self.image = image
			self.action = action
		}
		
		let title: String
		let subTitle: String?
		let image: UIImage?
		let action: () -> Void
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		setupBinding()
		setupOptions()
		setupBackButton()
	}

	func setupBinding() {

		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }

		viewModel.bottomButton.observe { [weak self] button in
			self?.sceneView.secondaryButtonTitle = button?.title
			self?.sceneView.secondaryButtonTappedCommand = button?.action
		}
	}
	
	func setupOptions() {
		
		viewModel.optionModels.observe { [weak self] buttons in
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
							icon: optionModel.image,
							command: optionModel.action
						)
					}
				}
				.forEach(self.sceneView.optionStackView.addArrangedSubview)
		}
	}
	
	func setupBackButton() {
		// Only show an arrow as back button
		addBackButton()
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
		icon: UIImage? = nil,
		command: (() -> Void)? ) -> DisclosureButton {

		let button = DisclosureButton()
		button.isUserInteractionEnabled = true
		button.title = title
		button.icon = icon
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
		command: (() -> Void)? ) -> DisclosureSubtitleButton {

		let button = DisclosureSubtitleButton()
		button.isUserInteractionEnabled = true
		button.title = title
		button.subtitle = subtitle
		button.primaryButtonTappedCommand = command
		return button
	}
}
