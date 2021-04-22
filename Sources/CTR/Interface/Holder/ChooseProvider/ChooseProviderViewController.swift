/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import MBProgressHUD

class ChooseProviderViewController: BaseViewController {

	private let viewModel: ChooseProviderViewModel

	let sceneView = ChooseProviderView()

	// MARK: Initializers

	init(viewModel: ChooseProviderViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

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
		viewModel.$header.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$body.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$image.binding = { [weak self] in self?.sceneView.headerImage = $0 }
		viewModel.$providers.binding = { [weak self] providers in

			for provider in providers {
				self?.setupProviderButton(provider)
			}
		}

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		layoutForOrientation()
	}

	// Rotation

	override func willTransition(
		to newCollection: UITraitCollection,
		with coordinator: UIViewControllerTransitionCoordinator) {

		coordinator.animate { [weak self] _ in
			self?.layoutForOrientation()
			self?.sceneView.setNeedsLayout()
		}
	}

	// MARK: Helper Methods

	/// Setup a provider button
	/// - Parameter provider: the provider
	private func setupProviderButton(_ provider: DisplayProvider) {

		let primaryButtonTappedCommand: (() -> Void)? = { [weak self] in
			self?.viewModel.providerSelected(
				provider.identifier,
				presentingViewController: self
			)
		}

		if let subTitle = provider.subTitle {
			self.sceneView.innerStackView.addArrangedSubview(
				createButtonWithSubtitle(
					provider.name,
					subTitle: subTitle,
					command: primaryButtonTappedCommand
				)
			)
		} else {
			self.sceneView.innerStackView.addArrangedSubview(
				createDisclosureButton(
					provider.name,
					command: primaryButtonTappedCommand
				)
			)
		}
	}

	/// Create a disclosure button
	/// - Parameters:
	///   - title: the title of the button
	///   - command: the command to execute when tapped
	/// - Returns: A disclosure button
	private func createDisclosureButton(
		_ title: String,
		command: (() -> Void)? ) -> DisclosureButton {

		let button = DisclosureButton()
		button.isUserInteractionEnabled = true
		button.title = title
		button.primaryButtonTappedCommand = command
		return button
	}
	/// Create a disclosure button with subtitle
	/// - Parameters:
	///   - title: the title of the button
	///   - subTitle: the sub title of the button
	///   - command: the command to execute when tapped
	/// - Returns: A disclosure button
	private func createButtonWithSubtitle(
		_ title: String,
		subTitle: String,
		command: (() -> Void)? ) -> DisclosureSubTitleButton {

		let button = DisclosureSubTitleButton()
		button.isUserInteractionEnabled = true
		button.title = title
		button.subtitle = subTitle
		button.primaryButtonTappedCommand = command
		return button
	}

	/// Layout for different orientations
	private func layoutForOrientation() {

		if traitCollection.verticalSizeClass == .compact {
			sceneView.hideImage()
		} else {
			sceneView.showImage()
		}
	}
}
