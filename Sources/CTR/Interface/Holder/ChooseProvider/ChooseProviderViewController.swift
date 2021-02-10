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

		viewModel.$title.binding = {

			self.title = $0
		}

		viewModel.$subtitle.binding = {

			self.sceneView.title = $0
		}

		viewModel.$body.binding = {

			self.sceneView.message = $0
		}

		viewModel.$providers.binding = { providers in

			for provider in providers {
				let button = ButtonWithSubtitle()
				button.isUserInteractionEnabled = true
				button.title = provider.name
				button.subtitle = provider.subTitle
				button.primaryButtonTappedCommand = { [weak self] in
					self?.viewModel.providerSelected(provider.identifier)
				}
				self.sceneView.stackView.addArrangedSubview(button)
			}
		}

		viewModel.$showProgress.binding = {

			if $0 {
				MBProgressHUD.showAdded(to: self.sceneView, animated: true)
			} else {
				MBProgressHUD.hide(for: self.sceneView, animated: true)
			}
		}
	}
}
