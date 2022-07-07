/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LoginTVSViewController: BaseViewController {

	private let viewModel: LoginTVSViewModel
	let sceneView = FetchRemoteEventsView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: LoginTVSViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		// Binding
		viewModel.$shouldShowProgress.binding = { [weak self] in
			self?.sceneView.shouldShowLoadingSpinner = $0
		}

		viewModel.$content.binding = { [weak self] in self?.sceneView.applyContent($0) }
		viewModel.login(presentingViewController: self)
		
		addBackButton()
		
		NotificationCenter.default.addObserver(self, selector: #selector(displayCancelAuthorization), name: UIApplication.didBecomeActiveNotification, object: nil)
	}
	
	@objc func displayCancelAuthorization() {
		
		viewModel.cancelAuthorization()
	}
}
