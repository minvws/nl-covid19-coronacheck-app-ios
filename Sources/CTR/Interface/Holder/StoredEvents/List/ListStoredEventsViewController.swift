/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListStoredEventsViewController: BaseViewController {

	enum State {
		case loading(content: Content)
		case listEvents(content: Content, rows: [Row])
		case feedback(content: Content)
	}

	struct Row {
		let title: String?
		let details: String
		let action: (() -> Void)?
	}

	internal let viewModel: ListStoredEventsViewModel
	internal let sceneView = ListStoredEventsView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ListStoredEventsViewModel) {

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
		
		// Show back button in navigation push
		addBackButton()

		viewModel.$shouldShowProgress.binding = { [weak self] in
			self?.sceneView.shouldShowLoadingSpinner = $0
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
			self?.showAlert($0)
		}

		viewModel.$hideForCapture.binding = { [weak self] in
			self?.sceneView.hideForCapture = $0
		}
	}

	override var enableSwipeBack: Bool { true }

	private func setForLoadingState(_ content: Content) {

		sceneView.shouldShowLoadingSpinner = true
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

		sceneView.shouldShowLoadingSpinner = false
		displayContent(content)
		sceneView.setEventStackVisibility(ishidden: false)

		// Remove previously added rows:
		removeExistingRows()

		sceneView.addSeparator()

		// Add new rows:
//		rows
//			.map { rowModel -> RemoteEventItemView in
//				RemoteEventItemView.makeView(
//					title: rowModel.title,
//					details: rowModel.details,
//					command: rowModel.action
//				)
//			}
//			.forEach(self.sceneView.addEventItemView)
		
		if let actionTitle = content.primaryActionTitle {
			sceneView.setEventStackVisibility(ishidden: true)
			let button = RedDisclosureButton.makeRedButton(title: actionTitle, command: content.primaryAction)
			sceneView.eventStackView.addArrangedSubview(button)
		}
	}

	private func setForFeedback(_ content: Content) {
//
//		sceneView.shouldShowLoadingSpinner = false
//		sceneView.setEventStackVisibility(ishidden: true)
//		displayContent(content)
//		removeExistingRows()
//		navigationItem.leftBarButtonItem = nil
	}

	private func displayContent(_ content: Content) {

		// Texts
		sceneView.title = content.title
		sceneView.message = content.body

		sceneView.contentTextView.linkTouched { [weak self] url in
			self?.viewModel.openUrl(url)
		}

		sceneView.secondaryButtonTappedCommand = content.secondaryAction
		sceneView.secondaryButtonTitle = content.secondaryActionTitle

		UIAccessibility.post(
			notification: .screenChanged,
			argument: [sceneView.title, sceneView.message].compactMap { $0 }.joined(separator: ". ")
		)
	}
}

extension RedDisclosureButton {

	/// Create a simple disclosure button with subtitle
	/// - Parameters:
	///   - title: the title of the button
	///   - command: the command to execute when tapped
	/// - Returns: A disclosure button
	static func makeRedButton(
		title: String,
		command: (() -> Void)? ) -> RedDisclosureButton {

			let button = RedDisclosureButton()
			button.isUserInteractionEnabled = true
			button.title = title
			button.primaryButtonTappedCommand = command
			return button
		}
}
