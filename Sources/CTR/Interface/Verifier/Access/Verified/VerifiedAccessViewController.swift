/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class VerifiedAccessViewController: BaseViewController, Logging {
	
	private let viewModel: VerifiedAccessViewModel

	let sceneView = VerifiedAccessView()

	init(viewModel: VerifiedAccessViewModel) {

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
		
		addCloseButton(action: #selector(closeButtonTapped))
		
		viewModel.$accessTitle.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$verifiedType.binding = { [weak self] in
			
			self?.sceneView.verifiedType = $0
			self?.navigationItem.leftBarButtonItem?.tintColor = $0.tintColor
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		viewModel.startScanAgainTimer()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		
		return viewModel.verifiedType.statusBarStyle
	}
}

private extension VerifiedAccessViewController {
	
	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}
}

extension VerifiedType {
	
	var statusBarStyle: UIStatusBarStyle {
		
		if case .verified(let risk) = self, risk.isHigh {
			return .lightContent
		} else {
			return .default
		}
	}
}
