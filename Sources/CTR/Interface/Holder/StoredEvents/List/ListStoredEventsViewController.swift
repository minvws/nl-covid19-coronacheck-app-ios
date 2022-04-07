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
		case listEvents(content: Content, groups: [Group])
	}
	
	struct Group {
		let header: String?
		let rows: [Row]
		let action: (() -> Void)?
		let actionTitle: String
	}
	
	struct Row {
		let title: String
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
				case let .loading(content):
					self?.setForLoadingState(content)
				case let .listEvents(content, groups):
					self?.setForListEvents(content, groups: groups)
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
		sceneView.backgroundColor = C.white()
		displayContent(content)

		sceneView.removeExistingRows()
	}

	private func setForListEvents(_ content: Content, groups: [Group]) {

		sceneView.shouldShowLoadingSpinner = false
		sceneView.backgroundColor = C.primaryBlue5()
		displayContent(content)
		sceneView.setListStackVisibility(ishidden: false)

		sceneView.removeExistingRows()
		sceneView.addSeparator()
		
		if groups.isEmpty {
			let view = StoredEventTitleView.makeView(title: L.holder_storedEvents_list_noEvents())
			sceneView.addToListStackView(view)
		} else {
			groups.map { group in
				let groupStack = createGroupStackView()
				if let header = group.header {
					groupStack.addArrangedSubview(
						StoredEventHeaderView.makeHeaderView(title: header)
					)
				}
				group.rows.map { row in
					StoredEventItemView.makeView(
						title: row.title,
						details: [row.details],
						command: row.action
					)
				}.forEach(groupStack.addArrangedSubview)
				
				groupStack.addArrangedSubview(
					RedDisclosureButton.makeRedButton(title: group.actionTitle, command: group.action)
				)
				return groupStack
			}
			.forEach(self.sceneView.addGroupStackView)
		}
	}

	private func displayContent(_ content: Content) {

		// Texts
		sceneView.title = content.title
		sceneView.message = content.body

		sceneView.messageLinkTapHandler = { [weak self] url in
			self?.viewModel.openUrl(url)
		}

		sceneView.secondaryButtonTappedCommand = content.secondaryAction
		sceneView.secondaryButtonTitle = content.secondaryActionTitle

		UIAccessibility.post(
			notification: .screenChanged,
			argument: [sceneView.title, sceneView.message].compactMap { $0 }.joined(separator: ". ")
		)
	}
	
	func createGroupStackView() -> UIStackView {

			let view = UIStackView()
			view.translatesAutoresizingMaskIntoConstraints = false
			view.axis = .vertical
			view.alignment = .fill
			view.distribution = .fill
			view.spacing = 0
			return view
	}
}

extension RedDisclosureButton {

	fileprivate static func makeRedButton(
		title: String,
		command: (() -> Void)? ) -> RedDisclosureButton {

			let button = RedDisclosureButton()
			button.isUserInteractionEnabled = true
			button.title = title
			button.primaryButtonTappedCommand = command
			return button
		}
}

extension StoredEventTitleView {
	
	fileprivate static func makeView(title: String) -> StoredEventTitleView {
		
		let view = StoredEventTitleView()
		view.title = title
		return view
	}
}

extension StoredEventHeaderView {
	
	fileprivate static func makeHeaderView(title: String) -> StoredEventHeaderView {
		
		let view = StoredEventHeaderView()
		view.title = title
		return view
	}
}

extension StoredEventItemView {
	
	fileprivate static func makeView(
		title: String,
		details: [String],
		command: (() -> Void)? ) -> StoredEventItemView {

		let view = StoredEventItemView()
		view.isUserInteractionEnabled = true
		view.title = title
		view.details = details
		view.viewTappedCommand = command
		return view
	}
}
