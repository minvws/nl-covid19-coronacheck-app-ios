/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ForcedInformationViewModel {

	// MARK: - Bindable variables

	@Bindable private(set) var title: String

	@Bindable private(set) var highlights: String

	@Bindable private(set) var content: String

	@Bindable private(set) var primaryButtonTitle: String

	@Bindable private(set) var secondaryButtonTitle: String?

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - delegate: the coordinator delegate
	///   - consent: the consent
	init(_ delegate: ForcedInformationCoordinatorDelegate, consent: ForcedInformationConsent) {

		self.title = consent.title
		self.highlights = consent.highlight
		self.content = consent.content

		if consent.mustGiveConsent {
			primaryButtonTitle = "Rolus: Akkoord"
			secondaryButtonTitle = "Rolus: Niet akkoord"
		} else {
			primaryButtonTitle = .next
		}
	}
}

class ForcedInformationViewController: BaseViewController {

	/// The model
	let viewModel: ForcedInformationViewModel

	/// The view
	let sceneView = ForcedInformationConsentView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ForcedInformationViewModel) {

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

		setupBindings()

		navigationItem.hidesBackButton = true
	}

	func setupBindings() {

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$highlights.binding = { [weak self] in self?.sceneView.highlight = $0 }
		viewModel.$content.binding = { [weak self] in self?.sceneView.content = $0 }

		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		viewModel.$secondaryButtonTitle.binding = { [weak self] in self?.sceneView.secondaryTitle = $0 ?? "" }
	}
}
