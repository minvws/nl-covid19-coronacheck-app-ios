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

		viewModel.$title.binding = { [weak self] in self?.title = $0 }

		viewModel.$showCloseButton.binding = { [weak self] in
			guard let strongSelf = self else { return }
			if $0 {
				strongSelf.addCloseButton(action: #selector(strongSelf.closeButtonTapped))
			}
		}

		viewModel.$content.binding = { [weak self] list in

			for item in list {
				if let image = item.image {
					let view = UIImageView(image: image)
					view.translatesAutoresizingMaskIntoConstraints = false
					view.contentMode = .center
					self?.sceneView.stackView.addArrangedSubview(view)
					self?.sceneView.stackView.setCustomSpacing(32, after: view)
				}
				let label = Label(title3: item.title, montserrat: true)
				self?.sceneView.stackView.addArrangedSubview(label)
				self?.sceneView.stackView.setCustomSpacing(8, after: label)

				let content = TextView(htmlText: item.text)
				content.linkTouched { [weak self] url in
					print("tapped on \(url)")
					self?.viewModel.openUrl(url)
				}
				self?.sceneView.stackView.addArrangedSubview(content)
				self?.sceneView.stackView.setCustomSpacing(56, after: content)
			}
		}
	}

	/// User tapped on the button
	@objc private func closeButtonTapped() {

		viewModel.dismiss()
	}
}
