/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class FetchEventsViewController: BaseViewController {

	enum State {
		case loading(content: Content)
		case listEvents(content: Content, rows: [Row])
		case emptyEvents(content: Content)
	}

	struct Content {
		let title: String
		let subTitle: String?
		let actionTitle: String?
		let action: (() -> Void)?
	}

	struct Row {
		let title: String
		let subTitle: String
		let action: (() -> Void)?
	}

	private let viewModel: FetchEventsViewModel
	private let sceneView = FetchEventsView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: FetchEventsViewModel) {

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

		navigationItem.hidesBackButton = true
		addCustomBackButton(action: #selector(backButtonTapped), accessibilityLabel: .back)

		viewModel.$shouldShowProgress.binding = { [weak self] in

			if $0 {
				self?.sceneView.spinner.startAnimating()
			} else {
				self?.sceneView.spinner.stopAnimating()
			}
		}

		viewModel.$viewState.binding = { [weak self] in

			switch $0 {
				case let .emptyEvents(content):
					self?.setForNoEvents(content)
				case let .loading(content):
					self?.setForLoadingState(content)
				case let .listEvents(content, rows):
					self?.setForListEvents(content, rows: rows)
			}
		}
	}

	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
	}

	private func setForLoadingState(_ content: Content) {

		sceneView.spinner.isHidden = false
		displayContent(content)
	}

	private func setForListEvents(_ content: Content, rows: [Row]) {

		sceneView.spinner.isHidden = true
		displayContent(content)

		// Remove previously added buttons:
		self.sceneView.eventStackView.subviews
			.forEach { $0.removeFromSuperview() }

		// Add new buttons:
		rows
			.map { rowModel -> VaccinationEventView in
				VaccinationEventView.makeView(
					title: rowModel.title,
					subTitle: rowModel.subTitle,
					command: rowModel.action
				)
			}
			.forEach(self.sceneView.eventStackView.addArrangedSubview)

	}

	private func setForNoEvents(_ content: Content) {

		sceneView.spinner.isHidden = true
		displayContent(content)
	}

	private func displayContent(_ content: Content) {

		// Texts
		sceneView.title = content.title
		sceneView.message = content.subTitle

		// Button
		sceneView.showLineView = false
		if let actionTitle = content.actionTitle {
			sceneView.primaryTitle = actionTitle
			sceneView.footerBackground.isHidden = false
			sceneView.primaryButton.isHidden = false
			sceneView.footerGradientView.isHidden = false
		} else {
			sceneView.footerBackground.isHidden = true
			sceneView.primaryButton.isHidden = true
			sceneView.footerGradientView.isHidden = true
		}
		sceneView.primaryButtonTappedCommand = {
			content.action?()
		}
	}
}

extension VaccinationEventView {

	/// Create a vaccination event view
	/// - Parameters:
	///   - title: the title of the view
	///   - subTitle: the sub title of the view
	///   - command: the command to execute when tapped
	/// - Returns: a vacation event view
	fileprivate static func makeView(
		title: String,
		subTitle: String,
		command: (() -> Void)? ) -> VaccinationEventView {

		let view = VaccinationEventView()
		view.isUserInteractionEnabled = true
		view.title = title
		view.subTitle = subTitle
		view.disclaimerButtonTappedCommand = command
		return view
	}
}
