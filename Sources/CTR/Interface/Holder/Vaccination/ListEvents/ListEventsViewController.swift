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
		case emptyEvents(content: Content)
	}

	struct Content {
		let title: String
		let subTitle: String?
		let primaryActionTitle: String?
		let primaryAction: (() -> Void)?
		let secondaryActionTitle: String?
		let secondaryAction: (() -> Void)?
	}

	struct Row {
		let title: String
		let subTitle: String
		let action: (() -> Void)?
	}

	struct AlertContent {
		let title: String
		let subTitle: String
		let cancelAction: ((UIAlertAction) -> Void)?
		let cancelTitle: String
		let okAction: ((UIAlertAction) -> Void)
		let okTitle: String
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

		viewModel.$navigationAlert.binding = { [weak self] in
			self?.showAlert($0)
		}

		viewModel.$shouldPrimaryButtonBeEnabled.binding = { [weak self] in
			self?.sceneView.primaryButton.isEnabled = $0
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

		// Remove previously added rows:
		sceneView.eventStackView.subviews
			.forEach { $0.removeFromSuperview() }

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
		if let actionTitle = content.primaryActionTitle {
			sceneView.primaryTitle = actionTitle
			sceneView.footerBackground.isHidden = false
			sceneView.primaryButton.isHidden = false
			sceneView.footerGradientView.isHidden = false
		} else {
			sceneView.primaryTitle = nil
			sceneView.footerBackground.isHidden = true
			sceneView.primaryButton.isHidden = true
			sceneView.footerGradientView.isHidden = true
		}
		sceneView.primaryButtonTappedCommand = content.primaryAction
		sceneView.somethingIsWrongTappedCommand = content.secondaryAction
		sceneView.somethingIsWrongButtonTitle = content.secondaryActionTitle
	}

	func showAlert(_ alertContent: AlertContent?) {

		guard let content = alertContent else {
			return
		}

		let alertController = UIAlertController(
			title: content.title,
			message: content.subTitle,
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: content.okTitle,
				style: .default,
				handler: content.okAction
			)
		)
		alertController.addAction(
			UIAlertAction(
				title: content.cancelTitle,
				style: .default,
				handler: content.cancelAction
			)
		)
		present(alertController, animated: true, completion: nil)
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
		view.disclaimerButtonTappedCommand = command
		return view
	}
}
