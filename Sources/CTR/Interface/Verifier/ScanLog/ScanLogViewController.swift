/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class ScanLogViewController: GenericViewController<ScanLogView, ScanLogViewModel> {

	override var enableSwipeBack: Bool { true }

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
		viewModel.$alert.binding = { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}
		sceneView.messageTextView.linkTouchedHandler = { [weak self] url in

			self?.viewModel.openUrl(url)
		}
	}

	private func setupEntries() {

		viewModel.$displayEntries.binding = { [weak self] entries in

			guard let strongSelf = self else { return }

			// Clear all items
			strongSelf.sceneView.logStackView.removeArrangedSubviews()

			// Starting Line
			strongSelf.sceneView.addLineToLogStackView()

			// Entries
			entries.forEach { entry in
				if case let ScanLogDisplayEntry.logMessage(message) = entry {
					strongSelf.sceneView.logStackView.addArrangedSubview(strongSelf.sceneView.createLabel(message))
				}
				if case let ScanLogDisplayEntry.entry(type: riskType, timeInterval: timeInterval, message: message, warning: warning) = entry {
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
