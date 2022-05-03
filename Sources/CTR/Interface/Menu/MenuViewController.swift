/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MenuViewController: BaseViewController {
	
	enum Item {
		case row(title: String, subTitle: String?, icon: UIImage, action: () -> Void )
		case sectionBreak
	}
	
	private let sceneView = MenuView()
	private let viewModel: MenuViewModel
	
	// MARK: Initializers

	init(viewModel: MenuViewModel) {

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
		title = L.general_menu()
		
		setupBindings()
		addBackButton(customAction: nil)
	}
	
	private func setupBindings() {

		viewModel.$items.binding = { [weak self] items in
			guard let self = self else { return }
			self.sceneView.stackView.removeArrangedSubviews()
			
			items.enumerated().forEach { index, item in
				switch item {
					case let .row(title, subTitle, icon, action):
					
						let row = MenuRowView()
						row.title = title
						row.icon = icon
						row.action = action
						row.shouldShowBottomBorder = {
							// Check if the next item is `case .row`. If so, show a bottom border on this row.
							let nextIndex = index + 1
							guard nextIndex < items.count  else { return false }
							guard case .row = items[nextIndex] else { return false }
							return true
						}()
						if let subTitle = subTitle {
							row.showSubTitle(subTitle)
							row.accessibilityLabel = title + ", " + subTitle
						} else {
							row.accessibilityLabel = title
						}
						self.sceneView.stackView.addArrangedSubview(row)
						
					case .sectionBreak:
						let breaker = MenuSectionBreakView()
						self.sceneView.stackView.addArrangedSubview(breaker)
				}
			}
		}
	}
}
