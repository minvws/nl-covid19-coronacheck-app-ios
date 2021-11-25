/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class CheckIdentityViewController: BaseViewController, Logging {
	
	override var enableSwipeBack: Bool { false }
	
	private let viewModel: CheckIdentityViewModel

	let sceneView = CheckIdentityView()

	init(viewModel: CheckIdentityViewModel) {

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
		
		// Make the navbar the same color as the background
		setupTranslucentNavigationBar()
		
		sceneView.scanNextTappedCommand = { [weak self] in

			self?.viewModel.scanAgain()
		}
		
		sceneView.readMoreTappedCommand = { [weak self] in
			
			self?.viewModel.showMoreInformation()
		}
		
		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$checkIdentity.binding = { [weak self] in self?.sceneView.checkIdentity = $0 }
		viewModel.$lastName.binding = { [weak self] in self?.sceneView.lastName = $0 }
		viewModel.$firstName.binding = { [weak self] in self?.sceneView.firstName = $0 }
		viewModel.$dayOfBirth.binding = { [weak self] in self?.sceneView.dayOfBirth = $0 }
		viewModel.$monthOfBirth.binding = { [weak self] in self?.sceneView.monthOfBirth = $0 }
		viewModel.$dccFlag.binding = { [weak self] in self?.sceneView.dccFlag = $0 }
		viewModel.$dccScanned.binding = { [weak self] in self?.sceneView.dccScanned = $0 }
		/// Confirm that a valid QR code is scanned on this view. The verified view is shown for a limited duration
		viewModel.$verifiedAccessibility.binding = { [weak self] in self?.navigationItem.accessibilityLabel = $0 }
		
		sceneView.firstNameHeader = L.verifierResultIdentityFirstname()
		sceneView.lastNameHeader = L.verifierResultIdentityLastname()
		sceneView.dayOfBirthHeader = L.verifierResultIdentityDayofbirth()
		sceneView.monthOfBirthHeader = L.verifierResultIdentityMonthofbirth()
		
		viewModel.$primaryTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		viewModel.$secondaryTitle.binding = { [weak self] in self?.sceneView.secondaryTitle = $0 }
		viewModel.$primaryButtonIcon.binding = { [weak self] in self?.sceneView.primaryButtonIcon = $0 }
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		viewModel.startAutoCloseTimer()
	}
	
	/// User tapped on the button
	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}
}
