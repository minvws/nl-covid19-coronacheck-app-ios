/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class IncompleteDutchVaccinationViewController: BaseViewController {
	
	private let viewModel: IncompleteDutchVaccinationViewModel
	private let sceneView = IncompleteDutchVaccinationView()
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: IncompleteDutchVaccinationViewModel) {
		
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
		
		viewModel.$secondVaccineText.binding = { [weak self] in
			self?.sceneView.secondVaccineText = $0
		}
		
		viewModel.$learnMoreText.binding = { [weak self] in
			self?.sceneView.learnMoreText = $0
		}
		
		viewModel.$addVaccinesButtonTitle.binding = { [weak self] in
			self?.sceneView.addVaccinesButtonTitle = $0
		}
		
		sceneView.addVaccinesButtonTapCommand = { [weak self] in
			self?.viewModel.didTapAddVaccines()
		}
		
		sceneView.linkTouchedHandler = { [weak viewModel] url in
			viewModel?.userTappedLink(url: url)
		}
	}
}
