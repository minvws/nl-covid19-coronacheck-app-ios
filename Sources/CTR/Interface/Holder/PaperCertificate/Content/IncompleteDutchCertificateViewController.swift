/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class IncompleteDutchCertificateViewController: BaseViewController {
	
	private let viewModel: IncompleteDutchCertificateViewModel
	private let sceneView = IncompleteDutchCertificateView()
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: IncompleteDutchCertificateViewModel) {
		
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
		
		addBackButton()
		
		viewModel.$title.binding = { [weak self] in
			self?.sceneView.title = $0
		}
		
		viewModel.$paragraphA.binding = { [weak self] in
			self?.sceneView.messageA = $0
		}
		
		viewModel.$paragraphB.binding = { [weak self] in
			self?.sceneView.messageB = $0
		}
		
		viewModel.$paragraphC.binding = { [weak self] in
			self?.sceneView.messageC = $0
		}
		
		viewModel.$secondaryButtonA.binding = { [weak self] in
			self?.sceneView.secondaryButtonATitle = $0
		}
		
		viewModel.$secondaryButtonB.binding = { [weak self] in
			self?.sceneView.secondaryButtonBTitle = $0
		}
		
		sceneView.secondaryButtonATappedCommand = { [weak self] in
			self?.viewModel.didTapSecondaryButtonA()
		}
		sceneView.secondaryButtonATitle = viewModel.secondaryButtonA
		
		sceneView.secondaryButtonBTappedCommand = { [weak self] in
			self?.viewModel.didTapSecondaryButtonB()
		}
		sceneView.secondaryButtonBTitle = viewModel.secondaryButtonB
	}
}
