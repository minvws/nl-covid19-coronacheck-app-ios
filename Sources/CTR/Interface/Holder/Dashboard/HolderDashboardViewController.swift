/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class HolderDashboardViewController: BaseViewController {

	private let viewModel: HolderDashboardViewModel

	let sceneView = HolderDashboardView()

	init(viewModel: HolderDashboardViewModel) {

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

		viewModel.$title.binding = { self.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }

		viewModel.$appointmentCard.binding = { cardInfo in

			self.sceneView.appointmentCard.title = cardInfo.title
			self.sceneView.appointmentCard.message = cardInfo.message
			self.sceneView.appointmentCard.primaryTitle = cardInfo.actionTitle
			self.sceneView.appointmentCard.backgroundImage = cardInfo.image
			self.sceneView.appointmentCard.primaryButtonTappedCommand = { [weak self] in
				self?.viewModel.cardClicked(cardInfo.identifier)
			}
		}

		viewModel.$createCard.binding = { cardInfo in

			self.sceneView.createCard.title = cardInfo.title
			self.sceneView.createCard.message = cardInfo.message
			self.sceneView.createCard.primaryTitle = cardInfo.actionTitle
			self.sceneView.createCard.backgroundImage = cardInfo.image
			self.sceneView.createCard.primaryButtonTappedCommand = { [weak self] in
				self?.viewModel.cardClicked(cardInfo.identifier)
			}
		}
		
		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}
}
