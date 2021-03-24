/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenOverviewViewController: BaseViewController {

	private let viewModel: TokenOverviewViewModel

	let sceneView = TokenOverviewView()

	// MARK: Initializers

	init(viewModel: TokenOverviewViewModel) {

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

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }

		viewModel.$providers.binding = { [weak self] providers in

			for provider in providers {
				self?.setupProviderButton(provider)
			}
			self?.setupNoCodeButton()
		}

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	// MARK: Helper Methods

	/// Setup a provider button
	/// - Parameter provider: the provider
	func setupProviderButton(_ provider: TokenProvider) {

		let button = ButtonWithTitleImageSubtitle()
		button.isUserInteractionEnabled = true
		button.icon = provider.icon
		button.subtitle = provider.subTitle
		button.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.providerSelected(provider.identifier)
		}
		self.sceneView.optionStackView.addArrangedSubview(button)
	}

	/// Setup no diigid button
	func setupNoCodeButton() {

		let label = Label(bodyMedium: .holderTokenOverviewNoCode, textColor: Theme.colors.primary).multiline()
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(noCodeTapped))
		label.isUserInteractionEnabled = true
		label.addGestureRecognizer(tapGesture)
		label.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
		sceneView.stackView.addArrangedSubview(label)
	}

	// MARK: User Interaction

	/// The user tapped on the no code option
	@objc func noCodeTapped() {

		viewModel.noCode()
	}
}
