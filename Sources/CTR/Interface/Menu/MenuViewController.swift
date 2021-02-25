/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class MenuViewController: BaseViewController {

	private let viewModel: MenuViewModel

	let sceneView = MenuView()

	init(viewModel: MenuViewModel) {

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

		viewModel.$topMenu.binding = { items in

			for item in items {

				let view = MenuItemView()
				view.titleLabel.text = item.title
				view.titleLabel.textColor = Theme.colors.secondary
				view.titleLabel.font = Theme.fonts.title3Montserrat
				view.primaryButtonTappedCommand  = { [weak self] in
					self?.viewModel.menuItemTapped(item.identifier)
				}
				self.sceneView.topStackView.addArrangedSubview(view)
			}
		}

		viewModel.$bottomMenu.binding = { items in

			for item in items {

				let view = MenuItemView()
				view.titleLabel.text = item.title
				view.titleLabel.textColor = Theme.colors.secondary.withAlphaComponent(0.8)
				view.titleLabel.font = Theme.fonts.subheadMontserrat
				view.primaryButtonTappedCommand  = { [weak self] in
					self?.viewModel.menuItemTapped(item.identifier)
				}
				self.sceneView.bottomStackView.addArrangedSubview(view)
			}
		}

		addMenuCloseButton(action: #selector(clossButtonTapped), accessibilityLabel: .close)
	}

	/// User tapped on the close button
	@objc func clossButtonTapped() {

		viewModel.clossButtonTapped()
	}

	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: the action when the users taps the close button
	///   - accessibilityLabel: the label for Voice Over
	func addMenuCloseButton(
		action: Selector?,
		accessibilityLabel: String) {

		if let image: UIImage = .cross {
			let button = UIBarButtonItem(
				image: image.withRenderingMode(.alwaysTemplate),
				style: .plain,
				target: self,
				action: action
			)
			button.accessibilityIdentifier = "CloseButton"
			button.accessibilityLabel = accessibilityLabel
			button.accessibilityTraits = UIAccessibilityTraits.button
			button.tintColor = Theme.colors.secondary
			navigationItem.hidesBackButton = true
			navigationItem.leftBarButtonItem = button
		}
	}
}
