/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListOptionsViewController: BaseViewController {

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

	internal let viewModel: ListOptionsProtocol
	
	internal let sceneView = ListOptionsView()
	
	override var enableSwipeBack: Bool { true }

	init(viewModel: ListOptionsProtocol) {

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
		setupBackButton()
	}

	func setupBinding() {

		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }

		viewModel.bottomButton.observe { [weak self] button in
			guard let button = button else {
				return
			}
			self?.sceneView.secondaryButtonTitle = button.title
			self?.sceneView.secondaryButtonTappedCommand = button.action
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
