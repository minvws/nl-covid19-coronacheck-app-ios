/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutTestResultViewController: BaseViewController {

	/// The model
	private let viewModel: AboutTestResultViewModel

	/// The view
	let sceneView = AboutTestResultView()

	let identityView = IdentityView()

	// MARK: Initializers

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: AboutTestResultViewModel) {

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
		setupContent()

		viewModel.$identity.binding = { [weak self] in self?.identityView.elements = $0 }

		addCloseButton(action: #selector(closeButtonTapped))
	}

	func setupContent() {
        let title = Label(title1: .holderAboutTestResultsTitle, montserrat: true).multiline().header()
		self.sceneView.stackView.addArrangedSubview(title)
		self.sceneView.stackView.setCustomSpacing(24, after: title)

		let label1 = Label(body: .holderAboutTestResultsSectionOne).multiline()
		self.sceneView.stackView.addArrangedSubview(label1)
		self.sceneView.stackView.setCustomSpacing(24, after: label1)

		let label2 = Label(body: .holderAboutTestResultsSectionTwo).multiline()
		self.sceneView.stackView.addArrangedSubview(label2)
		self.sceneView.stackView.setCustomSpacing(24, after: label2)

		self.sceneView.stackView.addArrangedSubview(identityView)
		self.sceneView.stackView.setCustomSpacing(40, after: identityView)

		let label3 = Label(bodyBold: .holderAboutTestResultsSectionThree).multiline()
		self.sceneView.stackView.addArrangedSubview(label3)
		self.sceneView.stackView.setCustomSpacing(8, after: label3)

		let label4 = Label(body: .holderAboutTestResultsSectionFour).multiline()
		self.sceneView.stackView.addArrangedSubview(label4)
	}

	/// User tapped on the button
	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}
}
