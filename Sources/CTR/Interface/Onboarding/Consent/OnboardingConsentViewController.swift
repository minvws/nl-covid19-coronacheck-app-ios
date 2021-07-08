/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class OnboardingConsentViewController: BaseViewController {

	/// The model
	let viewModel: OnboardingConsentViewModel

	/// The view
	let sceneView = OnboardingConsentView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: OnboardingConsentViewModel) {

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

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$underlinedText.binding = { [weak self] in
			self?.sceneView.underline($0)
			self?.setupLink()
		}

		viewModel.$isContinueButtonEnabled.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }
		sceneView.primaryButton.setTitle(L.generalNext(), for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))

		viewModel.$consentText.binding = { [weak self] in self?.sceneView.consent = $0 }
		self.sceneView.consentButton.valueChanged(self, action: #selector(consentValueChanged))

		viewModel.$summary.binding = { [weak self] in

			let total = $0.count
			for (index, item) in $0.enumerated() {
				self?.sceneView.addPrivacyItem(item, number: index + 1, total: total)
			}
		}
		viewModel.$shouldHideBackButton.binding = { [weak self] in self?.navigationItem.hidesBackButton = $0 }
		viewModel.$shouldHideConsentButton.binding = { [weak self] in self?.sceneView.consentButton.isHidden = $0 }
	}

	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)
		sceneView.lineView.isHidden = !sceneView.scrollView.canScroll()
	}

	/// Setup a gesture recognizer for underlined text
	private func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		sceneView.messageLabel.addGestureRecognizer(tapGesture)
		sceneView.messageLabel.isUserInteractionEnabled = true
	}

	/// User tapped on the consent button
	@objc func consentValueChanged(_ sender: ConsentButton) {

		viewModel.consentGiven(sender.isSelected)
	}

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkTapped()
	}

	/// The user tapped on the primary button
	@objc func primaryButtonTapped() {

		if sceneView.primaryButton.isEnabled {
			viewModel.primaryButtonTapped()
		}
	}
}

extension UIScrollView {

	func canScroll() -> Bool {

		let totalHeight = contentSize.height
		return totalHeight > frame.size.height
	}
}
