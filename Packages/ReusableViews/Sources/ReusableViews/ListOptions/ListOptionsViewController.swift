/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

open class ListOptionsViewController: TraitWrappedGenericViewController<ListOptionsView, ListOptionsProtocol> {
	
	public enum OptionType: String {
		case singleLine
		case multiLine
		case singleWithIcon
		case singleWithImage
	}

	public struct OptionModel {
		public init(title: String, subTitle: String? = nil, image: UIImage? = nil, type: ListOptionsViewController.OptionType, action: @escaping () -> Void) {
			self.title = title
			self.subTitle = subTitle
			self.image = image
			self.type = type
			self.action = action
		}
		
		public let title: String
		public let subTitle: String?
		public let image: UIImage?
		public let type: OptionType
		public let action: () -> Void
	}

	override public func viewDidLoad() {

		super.viewDidLoad()

		setupBinding()
		setupOptions()
		setupBackButton()
	}

	public func setupBinding() {

		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }

		viewModel.bottomButton.observe { [weak self] button in
			self?.sceneView.secondaryButtonTitle = button?.title
			self?.sceneView.secondaryButtonTappedCommand = button?.action
		}
	}
	
	public func setupOptions() {
		
		viewModel.optionModels.observe { [weak self] buttons in
			guard let self else { return }

			// Remove previously added buttons:
			self.sceneView.optionStackView.subviews
				.forEach { $0.removeFromSuperview() }

			// Add new buttons:
			buttons
				.map { optionModel -> UIView in
					switch optionModel.type {
						case .singleLine, .singleWithIcon:
							return DisclosureButton.makeButton(
								title: optionModel.title,
								icon: optionModel.image,
								command: optionModel.action
							)
						case .multiLine:
							return DisclosureSubtitleButton.makeButton(
								title: optionModel.title,
								subtitle: optionModel.subTitle,
								command: optionModel.action
							)
						case .singleWithImage:
							return DisclosureLeadingImageButton.makeButton(
								title: optionModel.title,
								image: optionModel.image,
								command: optionModel.action
							)
					}
				}
				.forEach(self.sceneView.optionStackView.addArrangedSubview)
		}
	}
	
	public func setupBackButton() {
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
	public static func makeButton(
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
	public static func makeButton(
		title: String,
		subtitle: String?,
		command: (() -> Void)? ) -> DisclosureSubtitleButton {

		let button = DisclosureSubtitleButton()
		button.isUserInteractionEnabled = true
		button.title = title
		button.subtitle = subtitle
		button.primaryButtonTappedCommand = command
		return button
	}
}

extension DisclosureLeadingImageButton {

	/// Create a disclosure button with subtitle and an image
	/// - Parameters:
	///   - title: the title of the button
	///   - image: the image
	///   - command: the command to execute when tapped
	/// - Returns: A disclosure button
	public static func makeButton(
		title: String,
		image: UIImage?,
		command: (() -> Void)? ) -> DisclosureLeadingImageButton {
		
		let button = DisclosureLeadingImageButton()
		button.isUserInteractionEnabled = true
		button.title = title
		button.image = image
		button.primaryButtonTappedCommand = command
		return button
	}
}
