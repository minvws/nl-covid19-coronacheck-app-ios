/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierResultViewController: BaseViewController, Logging {

	private let viewModel: VerifierResultViewModel

	let sceneView = ResultView()

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

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }

		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.scanAgain()
		}

		viewModel.$allowAccess.binding = { [weak self] in

			if $0 == .verified {
				self?.sceneView.imageView.image = .access
				self?.sceneView.actionColor = Theme.colors.access
				self?.sceneView.footerActionColor = Theme.colors.secondary
				self?.sceneView.setupForVerified()
				self?.sceneView.revealIdentityView { [weak self] in
					self?.title = self?.viewModel.title
				}

			} else if $0 == .demo {
				self?.sceneView.imageView.image = .access
				self?.sceneView.actionColor = Theme.colors.grey4
				self?.sceneView.footerActionColor = Theme.colors.secondary
				self?.sceneView.setupForVerified()
				self?.sceneView.revealIdentityView { [weak self] in
					self?.title = self?.viewModel.title
				}
			} else {
				self?.sceneView.imageView.image = .denied
				self?.sceneView.actionColor = Theme.colors.denied
				self?.sceneView.footerActionColor = Theme.colors.denied
				self?.sceneView.setupForDenied()
			}
		}

		viewModel.$linkedMessage.binding = { [weak self] in
			if $0 != nil {
				self?.sceneView.underline($0)
				self?.setupLink()
			}
		}

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

		sceneView.checkIdentityView.disclaimerButtonTappedCommand = { [weak self] in self?.linkTapped() }

		addCloseButton(action: #selector(closeButtonTapped))
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		// Make the navbar the same color as the background.
		navigationController?.navigationBar.backgroundColor = .clear
		layoutForOrientation()
	}

	/// User tapped on the button
	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}

	// MARK: Helper methods

	/// Setup a gesture recognizer for underlined text
	private func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		sceneView.messageLabel.addGestureRecognizer(tapGesture)
		sceneView.messageLabel.isUserInteractionEnabled = true
	}

	// MARK: User interaction

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkTapped()
	}

	private func setupIdentityView() {

		sceneView.checkIdentityView.header = String.verifierResultIdentityTitle
		sceneView.checkIdentityView.firstNameHeader = .verifierResultIdentityFirstname
		sceneView.checkIdentityView.lastNameHeader = .verifierResultIdentityLastname
		sceneView.checkIdentityView.dayOfBirthHeader = .verifierResultIdentityDayOfBirth
		sceneView.checkIdentityView.monthOfBirthHeader = .verifierResultIdentityMonthOfBirth
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
