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
		
		setupTranslucentNavigationBar()

		viewModel.$topMenu.binding = { [weak self] items in

			for item in items {

				let view = MenuItemView()
				view.title = item.title
				view.titleLabel.textColor = Theme.colors.secondary
				view.titleLabel.font = Theme.fonts.headlineBoldMontserrat
				view.primaryButtonTappedCommand  = { [weak self] in
					self?.viewModel.menuItemTapped(item.identifier)
				}
				self?.sceneView.topStackView.addArrangedSubview(view)
			}
		}

		viewModel.$bottomMenu.binding = { [weak self] items in

			for item in items {

				let view = MenuItemView()
				view.title = item.title
				view.titleLabel.textColor = Theme.colors.secondary
				view.titleLabel.font = Theme.fonts.subheadMontserrat
				view.primaryButtonTappedCommand  = { [weak self] in
					self?.viewModel.menuItemTapped(item.identifier)
				}
				self?.sceneView.bottomStackView.addArrangedSubview(view)
			}
		}

		addMenuCloseButton()
	}

	/// User tapped on the close button
	@objc func closeButtonTapped() {

		viewModel.closeButtonTapped()
	}

	/// Add a close button to the navigation bar.
	private func addMenuCloseButton() {
		
		let config = UIBarButtonItem.Configuration(target: self,
												   action: #selector(closeButtonTapped),
												   content: .image(I.cross()?.withRenderingMode(.alwaysTemplate)),
												   tintColor: Theme.colors.secondary,
												   accessibilityIdentifier: "CloseButton",
												   accessibilityLabel: L.generalMenuClose())
		navigationItem.leftBarButtonItem = .create(config)
	}
}
