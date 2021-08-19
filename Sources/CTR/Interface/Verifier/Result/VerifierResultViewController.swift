/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierResultViewController: BaseViewController, Logging {

	private let viewModel: VerifierResultViewModel

	let sceneView = VerifierResultView()

	init(viewModel: VerifierResultViewModel) {

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
		
		// Make the navbar the same color as the background
		setupTranslucentNavigationBar()

//		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
//		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
//		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }

		sceneView.scanNextTappedCommand = { [weak self] in

			self?.viewModel.scanAgain()
		}
		
		sceneView.readMoreTappedCommand = { [weak self] in
			
			self?.viewModel.linkTapped()
		}

		viewModel.$allowAccess.binding = { [weak self] in

			switch $0 {
				case .verified:
					self?.sceneView.setup(for: .verified)
				case .demo:
					self?.sceneView.setup(for: .demo)
				case .denied:
					self?.sceneView.setup(for: .denied)
			}
		}

//		viewModel.$linkedMessage.binding = { [weak self] in
//			if $0 != nil {
//				self?.buttonTapped()
//			}
//		}

		viewModel.$hideForCapture.binding = { [weak self] in

            #if DEBUG
            self?.logDebug("Skipping hiding of result because in DEBUG mode")
            #else
            self?.sceneView.isHidden = $0
            #endif
		}
		
		// Identity
		setupIdentityView()
		viewModel.$lastName.binding = { [weak self] in self?.sceneView.checkIdentityView.lastName = $0 }
		viewModel.$firstName.binding = { [weak self] in self?.sceneView.checkIdentityView.firstName = $0 }
		viewModel.$dayOfBirth.binding = { [weak self] in self?.sceneView.checkIdentityView.dayOfBirth = $0 }
		viewModel.$monthOfBirth.binding = { [weak self] in self?.sceneView.checkIdentityView.monthOfBirth = $0 }

//		sceneView.checkIdentityView.disclaimerButtonTappedCommand = { [weak self] in self?.linkTapped() }

		addCloseButton(action: #selector(closeButtonTapped))
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		
		layoutForOrientation()
	}

	/// User tapped on the button
	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}

	// MARK: User interaction

	/// User tapped on the link
	@objc func buttonTapped() {

		viewModel.linkTapped()
	}

	private func setupIdentityView() {

		sceneView.checkIdentityView.header = L.verifierResultIdentityTitle()
		sceneView.checkIdentityView.firstNameHeader = L.verifierResultIdentityFirstname()
		sceneView.checkIdentityView.lastNameHeader = L.verifierResultIdentityLastname()
		sceneView.checkIdentityView.dayOfBirthHeader = L.verifierResultIdentityDayofbirth()
		sceneView.checkIdentityView.monthOfBirthHeader = L.verifierResultIdentityMonthofbirth()
	}

	// Rotation

	override func willTransition(
		to newCollection: UITraitCollection,
		with coordinator: UIViewControllerTransitionCoordinator) {

		coordinator.animate { [weak self] _ in
			self?.layoutForOrientation()
		}
	}

	/// Layout for different orientations
	private func layoutForOrientation() {

		sceneView.layoutForOrientation()
	}
}
