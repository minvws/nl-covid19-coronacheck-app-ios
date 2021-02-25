/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

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

		viewModel.$showCloseButton.binding = {

			if $0 {
				self.addCloseButton(
					action: #selector(self.closeButtonTapped),
					accessibilityLabel: .close
				)
			}
		}

		viewModel.$content.binding = { list in

			for item in list {
				if let image = item.image {
					let view = UIImageView(image: image)
					view.translatesAutoresizingMaskIntoConstraints = false
					view.contentMode = .center
					self.sceneView.stackView.addArrangedSubview(view)
					self.sceneView.stackView.setCustomSpacing(32, after: view)
				}
				let label = Label(title3: item.title, montserrat: true)
				self.sceneView.stackView.addArrangedSubview(label)
				self.sceneView.stackView.setCustomSpacing(8, after: label)
				let bodyLabel = Label(body: nil).multiline()
				bodyLabel.attributedText = .makeFromHtml(
					text: item.text,
					font: Theme.fonts.body,
					textColor: Theme.colors.dark
				)
				self.sceneView.stackView.addArrangedSubview(bodyLabel)
				self.sceneView.stackView.setCustomSpacing(56, after: bodyLabel)
			}
		}

	}

	/// User tapped on the button
	@objc private func closeButtonTapped() {

		viewModel.dismiss()
	}
}
