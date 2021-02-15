/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierResultViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "VerifierResultViewModel"

	/// Coordination Delegate
	weak var delegate: Dismissable?

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The linked message of the scene
	@Bindable private(set) var linkedMessage: String?

	/// The title of the button
	@Bindable private(set) var primaryButtonTitle: String

	/// Allow Access?
	@Bindable private(set) var allowAccess: Bool = false

	/// Initializer
	/// - Parameters:
	///   - delegate: the coordinator delegate
	init(delegate: Dismissable) {

		self.delegate = delegate
		self.allowAccess = true

		title = ""
		message = ""
		primaryButtonTitle = .verifierResultButtonTitle

		if allowAccess {
			showAccessAllowed()
		} else {
			showAccessDenied()
		}
	}

	/// Show access allowed
	private func showAccessAllowed() {

		title =  .verifierResultAccessTitle
		message =  .verifierResultAccessMessage
		linkedMessage = nil
	}

	/// Show access denied
	private func showAccessDenied() {

		title = .verifierResultDeniedTitle
		message = .verifierResultDeniedMessage
		linkedMessage = .verifierResultDeniedLink
	}

	/// Dismiss ourselves
	func dismiss() {

		delegate?.dismiss()
	}

	func linkTapped() {

		logDebug("Tapped on link")
	}
}

class VerifierResultViewController: BaseViewController {

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

		viewModel.$title.binding = { self.sceneView.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }
		viewModel.$primaryButtonTitle.binding = { self.sceneView.primaryTitle = $0 }

		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.dismiss()
		}

		viewModel.$allowAccess.binding = {

			if $0 {
				self.sceneView.imageView.image = .access
				self.sceneView.backgroundColor = Theme.colors.access
			} else {
				self.sceneView.imageView.image = .denied
				self.sceneView.backgroundColor = Theme.colors.denied
			}
		}

		viewModel.$linkedMessage.binding = {
			if $0 != nil {
				self.sceneView.underline($0)
				self.setupLink()
			}
		}

		addCloseButton(action: #selector(closeButtonTapped), accessibilityLabel: .close)
	}

	/// User tapped on the button
	@objc private func closeButtonTapped() {

		viewModel.dismiss()
	}

	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: the action when the users taps the close button
	///   - accessibilityLabel: the label for Voice Over
	func addCloseButton(
		action: Selector?,
		accessibilityLabel: String) {

		let button = UIBarButtonItem(
			image: .cross,
			style: .plain,
			target: self,
			action: action
		)
		button.accessibilityIdentifier = "CloseButton"
		button.accessibilityLabel = accessibilityLabel
		button.accessibilityTraits = UIAccessibilityTraits.button
		navigationItem.hidesBackButton = true
		navigationItem.leftBarButtonItem = button
		navigationController?.navigationItem.leftBarButtonItem = button
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
}
