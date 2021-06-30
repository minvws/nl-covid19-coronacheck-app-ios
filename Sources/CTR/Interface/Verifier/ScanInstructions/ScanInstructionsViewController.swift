/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanInstructionsViewController: BaseViewController, Logging {

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

		viewModel.$title.binding = { [weak self] in self?.title = $0 }

		viewModel.$content.binding = { [weak self] list in

			self?.setupContent(list)
		}

		sceneView.primaryTitle = .verifierStartButtonTitle
		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.primaryButtonTapped()
		}
	}

    private func setupContent(_ content: [ScanInstructions]) {

		for item in content {
			if let image = item.image {
				let imageView = UIImageView(image: image)
                imageView.isAccessibilityElement = true
                imageView.accessibilityLabel = item.imageDescription
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentMode = .center
				sceneView.stackView.addArrangedSubview(imageView)
				sceneView.stackView.setCustomSpacing(32, after: imageView)
			}
            
            let label = Label(title3: item.title, montserrat: true).multiline().header()
			sceneView.stackView.addArrangedSubview(label)
			sceneView.stackView.setCustomSpacing(8, after: label)

			let text = TextView(htmlText: item.text)
			text.linkTouched { [weak self] url in
				self?.logDebug("tapped on \(url)")
				self?.viewModel.linkTapped(url)
			}
			sceneView.stackView.addArrangedSubview(text)
			sceneView.stackView.setCustomSpacing(56, after: text)
		}
	}
}
