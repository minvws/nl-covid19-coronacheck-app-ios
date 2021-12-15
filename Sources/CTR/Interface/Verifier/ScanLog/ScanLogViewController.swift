/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanLogViewController: BaseViewController {

	private let viewModel: ScanLogViewModel

	let sceneView = ScanLogView()

	override var enableSwipeBack: Bool { true }

	init(viewModel: ScanLogViewModel) {

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
		addBackButton()
		setupBindings()
		setupEntries()
	}

	private func setupBindings() {

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$appInUseSince.binding = { [weak self] in self?.sceneView.footer = $0 }
		viewModel.$listHeader.binding = { [weak self] in self?.sceneView.listHeader = $0 }
		viewModel.$alert.binding = { [weak self] in self?.showAlert($0) }

		sceneView.messageTextView.linkTouched { [weak self] url in

			self?.viewModel.openUrl(url)
		}
	}

	private func setupEntries() {

		viewModel.$displayEntries.binding = { [weak self] entries in

			guard let strongSelf = self else { return }

			// Clear all items
			strongSelf.sceneView.logStackView.arrangedSubviews.forEach {
				strongSelf.sceneView.logStackView.removeArrangedSubview($0)
				$0.removeFromSuperview()
			}

			// Starting Line
			strongSelf.sceneView.addLineToLogStackView()

			// Entries
			entries.forEach { entry in
				if case let .message(message) = entry {
					strongSelf.sceneView.logStackView.addArrangedSubview(strongSelf.sceneView.createLabel(message))
				}
				if case let .entry(type: riskType, timeInterval: timeInterval, message: message, warning: warning) = entry {
					strongSelf.sceneView.logStackView.addArrangedSubview(
						ScanLogEntryView.makeView(risk: riskType, time: timeInterval, message: message, error: warning)
					)
				}
				// Always add a line underneath the entry
				strongSelf.sceneView.addLineToLogStackView()
			}
		}
	}
}

extension ScanLogEntryView {

	static func makeView(risk: String, time: String, message: String, error: String?) -> ScanLogEntryView {

		let view = ScanLogEntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.risk = risk
		view.time = time
		view.message = message
		view.error = error
		return view
	}
}
