//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanInstructionsView: ScrolledStackView {

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		stackView.distribution = .fill
	}
}

class ScanInstructionsViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "ScanInstructionsViewModel"

	/// Coordination Delegate
	weak var coordinator: VerifierCoordinator?

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var content: [(title: String, text: String, image: UIImage?)]

	/// Initialzier
	/// - Parameters:
	///   - coordinator: the dismissable delegae
	///   - attributes: the decrypted attributes
	init(coordinator: VerifierCoordinator) {

		self.coordinator = coordinator
		self.title = .verifierScanInstructionsTitle
		self.content = [
			(title: .verifierScanInstructionsDistanceTitle, text: .verifierScanInstructionsDistanceText, image: nil),
			(title: .verifierScanInstructionsScanTitle, text: .verifierScanInstructionsScanText, image: nil),
			(title: .verifierScanInstructionsAccessTitle, text: .verifierScanInstructionsAccessText, image: .greenScreen),
			(title: .verifierScanInstructionsDeniedTitle, text: .verifierScanInstructionsDeniedText, image: .redScreen)
		]
	}
}

class ScanInstructionsViewController: BaseViewController {

	private let viewModel: ScanInstructionsViewModel

	let sceneView = ScanInstructionsView()

	init(viewModel: ScanInstructionsViewModel) {

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

		viewModel.$title.binding = { self.title = $0 }

		viewModel.$content.binding = { list in

			for item in list {
				if let image = item.image {
					let view = UIImageView(image: image)
					view.translatesAutoresizingMaskIntoConstraints = false
					view.contentMode = .center
					self.sceneView.stackView.addArrangedSubview(view)
					self.sceneView.stackView.setCustomSpacing(32, after: view)
				}
				let label = Label(title3: item.title)
				self.sceneView.stackView.addArrangedSubview(label)
				self.sceneView.stackView.setCustomSpacing(8, after: label)
				let bodyLabel = Label(body: nil).multiline()
				bodyLabel.attributedText = .makeFromHtml(text: item.text, font: Theme.fonts.body, textColor: Theme.colors.dark)
				self.sceneView.stackView.addArrangedSubview(bodyLabel)
				self.sceneView.stackView.setCustomSpacing(56, after: bodyLabel)
			}
		}
	}
}
