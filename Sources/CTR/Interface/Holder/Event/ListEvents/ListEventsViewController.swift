/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListEventsViewController: BaseViewController {

	enum State {
		case loading(content: Content)
		case listEvents(content: Content, rows: [Row])
		case feedback(content: Content)
	}

	struct Row {
		let title: String
		let subTitle: String
		let action: (() -> Void)?
	}

	private let viewModel: ListEventsViewModel
	private let sceneView = ListEventsView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ListEventsViewModel) {

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

		addBackButton(customAction: #selector(backButtonTapped))

		viewModel.$shouldShowProgress.binding = { [weak self] in

			if $0 {
				self?.sceneView.spinner.startAnimating()
			} else {
				self?.sceneView.spinner.stopAnimating()
			}
		}

		viewModel.$viewState.binding = { [weak self] in

			switch $0 {
				case let .feedback(content):
					self?.setForFeedback(content)
				case let .loading(content):
					self?.setForLoadingState(content)
				case let .listEvents(content, rows):
					self?.setForListEvents(content, rows: rows)
			}
		}

		viewModel.$alert.binding = { [weak self] in
			self?.showAlert($0, preferredAction: $0?.okTitle)
		}

		viewModel.$shouldPrimaryButtonBeEnabled.binding = { [weak self] in
			self?.sceneView.primaryButton.isEnabled = $0
		}

		viewModel.$hideForCapture.binding = { [weak self] in

			self?.sceneView.hideForCapture = $0
		}
	}
	
	override var enableSwipeBack: Bool { false }

	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
	}

	private func setForLoadingState(_ content: Content) {

		sceneView.spinner.isHidden = false
		displayContent(content)

		removeExistingRows()
	}

	private func removeExistingRows() {
		// Remove previously added rows:
		sceneView.eventStackView.subviews
			.forEach { $0.removeFromSuperview()
		}
	}

	private func setForListEvents(_ content: Content, rows: [Row]) {

		sceneView.spinner.isHidden = true
		displayContent(content)
		sceneView.setEventStackVisibility(ishidden: false)

		// Remove previously added rows:
		removeExistingRows()

		sceneView.addSeparator()

		// Add new rows:
		rows
			.map { rowModel -> VaccinationEventView in
				VaccinationEventView.makeView(
					title: rowModel.title,
					subTitle: rowModel.subTitle,
					command: rowModel.action
				)
			}
			.forEach(self.sceneView.addVaccinationEventView)
	}

	private func setForFeedback(_ content: Content) {

		sceneView.spinner.isHidden = true
		sceneView.setEventStackVisibility(ishidden: true)
		displayContent(content)
		removeExistingRows()
	}

	private func displayContent(_ content: Content) {

		// Texts
		sceneView.title = content.title
		sceneView.message = content.subTitle

		sceneView.contentTextView.linkTouched { [weak self] url in

			self?.viewModel.openUrl(url)
		}

		// Button
		if let actionTitle = content.primaryActionTitle {
			sceneView.primaryTitle = actionTitle
			sceneView.footerButtonView.isHidden = false
		} else {
			sceneView.primaryTitle = nil
			sceneView.footerButtonView.isHidden = true
		}
		sceneView.primaryButtonTappedCommand = content.primaryAction
		sceneView.somethingIsWrongTappedCommand = content.secondaryAction
		sceneView.somethingIsWrongButtonTitle = content.secondaryActionTitle
		
		UIAccessibility.post(
			notification: .screenChanged,
			argument: [sceneView.title, sceneView.message].compactMap { $0 }.joined(separator: ". ")
		)
	}
}

extension VaccinationEventView {

	/// Create a vaccination event view
	/// - Parameters:
	///   - title: the title of the view
	///   - subTitle: the sub title of the view
	///   - command: the command to execute when tapped
	/// - Returns: a vaccination event view
	fileprivate static func makeView(
		title: String,
		subTitle: String,
		command: (() -> Void)? ) -> VaccinationEventView {

		let view = VaccinationEventView()
		view.isUserInteractionEnabled = true
		view.title = title
		view.subTitle = subTitle
		view.link = L.holderEventDetails()
		view.disclaimerButtonTappedCommand = command
		return view
	}
}
