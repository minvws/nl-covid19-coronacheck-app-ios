/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class MenuViewController: GenericViewController<MenuView, MenuViewModelProtocol> {
	
	enum Item {
		case row(title: String, subTitle: String?, icon: UIImage, overrideColor: UIColor?, action: () -> Void)
		case sectionBreak
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
		addBackButton(customAction: nil)
	}
	
	private func setupBindings() {

		viewModel.title.observe { [weak self] in self?.title = $0 }
		
		viewModel.items.observe { [weak self] items in
			guard let self else { return }
			self.sceneView.stackView.removeArrangedSubviews()
			
			items.enumerated().forEach { index, item in
				switch item {
					case let .row(title, subTitle, icon, overrideColor, action):
					
						let row = MenuRowView()
						row.title = title
						row.icon = icon
						row.overrideColor = overrideColor
						row.action = action
						row.shouldShowBottomBorder = {
							// Check if the next item is `case .row`. If so, show a bottom border on this row.
							let nextIndex = index + 1
							guard nextIndex < items.count  else { return false }
							guard case .row = items[nextIndex] else { return false }
							return true
						}()
						if let subTitle {
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
