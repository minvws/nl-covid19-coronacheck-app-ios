/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class NewMenuViewController: UIViewController {
	
	enum Item {
		case row(title: String, icon: UIImage, action: () -> Void )
		case breaker
	}
	
	private let sceneView = NewMenuView()
	private let viewModel: NewMenuViewModel
	
	// MARK: Initializers

	init(viewModel: NewMenuViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - View Lifecycle
	
	override func loadView() {

		view = sceneView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupBindings()
	}
	
	private func setupBindings() {

		viewModel.$items.binding = { [weak self] items in
			guard let self = self else { return }
			self.sceneView.stackView.removeArrangedSubviews()
			
			items.forEach { item in
				switch item {
					case let .row(title, icon, action):
						let row = NewMenuRowView()
						row.title = title
						row.icon = icon
						row.action = action
						self.sceneView.stackView.addArrangedSubview(row)
						
					case .breaker:
						let breaker = NewMenuBreakerView()
						self.sceneView.stackView.addArrangedSubview(breaker)
				}
			}
		}
	}
}
