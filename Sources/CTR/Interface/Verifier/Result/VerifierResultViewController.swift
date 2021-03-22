/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

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

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }

		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.dismiss()
		}

		viewModel.$allowAccess.binding = { [weak self] in

			if $0 == .verified {
				self?.sceneView.imageView.image = .access
				self?.sceneView.backgroundColor = Theme.colors.access
				self?.sceneView.setupForVerified()

			} else if $0 == .demo {
				self?.sceneView.imageView.image = .access
				self?.sceneView.backgroundColor = Theme.colors.demo
			} else {
				self?.sceneView.imageView.image = .denied
				self?.sceneView.backgroundColor = Theme.colors.denied
			}
		}

		viewModel.$identity.binding = { [weak self] in

			self?.sceneView.identityView.elements = $0
		}

		viewModel.$linkedMessage.binding = { [weak self] in
			if $0 != nil {
				self?.sceneView.underline($0)
				self?.setupLink()
			}
		}

		viewModel.$hideForCapture.binding = { [weak self] in

			self?.sceneView.isHidden = $0
		}

		viewModel.$debugInfo.binding = { [weak self] in

			var text = ""
			for element in $0 {
				text += "   \(element)\n"
			}
			self?.sceneView.debugLabel.text = text
			if !text.isEmpty {
				self?.setupDebugLink()
			}
		}

		addCloseButton(action: #selector(closeButtonTapped))
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		// Make the navbar the same color as the background.
		navigationController?.navigationBar.backgroundColor = .clear
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

	/// Setup a gesture recognizer for underlined text
	private func setupDebugLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(debugLinkTapped))
		sceneView.imageView.addGestureRecognizer(tapGesture)
		sceneView.imageView.isUserInteractionEnabled = true
	}

	// MARK: User interaction

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkTapped()
	}

	/// User tapped on the debug link
	@objc func debugLinkTapped() {

		sceneView.debugLabel.isHidden = !sceneView.debugLabel.isHidden
	}
}
