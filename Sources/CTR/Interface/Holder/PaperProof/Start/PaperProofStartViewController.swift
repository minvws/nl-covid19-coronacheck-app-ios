/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PaperProofStartViewController: BaseViewController {
	
	private let viewModel: PaperProofStartViewModel
	
	let sceneView = PaperProofStartView()

	override var enableSwipeBack: Bool { true }
	
	init(viewModel: PaperProofStartViewModel) {
		
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

		addBackButton(customAction: #selector(backButtonTapped))
		setupText()
		setupButtons()
		setupItems()
	}

	private func setupText() {

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
	}

	private func setupButtons() {

		viewModel.$nextButtonTitle.binding = { [weak self] in self?.sceneView.primaryButton.title = $0 }
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.userTappedNextButton() }

		viewModel.$selfPrintedButtonTitle.binding = { [weak self] in self?.sceneView.secondaryButton.title = $0 }
		sceneView.secondaryButtonCommand = { [weak self] in self?.viewModel.userTappedSelfPrintedButton() }
	}

	private func setupItems() {

		viewModel.$items.binding = { [weak self] items in
			guard let self = self else { return }

			// Remove previously added items:
			self.sceneView.itemStackView.subviews
				.forEach { $0.removeFromSuperview() }

			// Add new buttons:
			items
				.map { item -> PaperProofItemView in
					PaperProofItemView.makeView(
						title: item.title,
						message: item.message,
						icon: item.icon
					)
				}
				.forEach(self.sceneView.itemStackView.addArrangedSubview)
		}
	}
	
	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
	}
}

extension PaperProofItemView {

	/// Create a vaccination event view
	/// - Parameters:
	///   - title: the title of the view
	///   - message: the sub title of the view
	///   - icon: the icon of the view
	/// - Returns: a paperproof start view
	fileprivate static func makeView(
		title: String,
		message: String,
		icon: UIImage?) -> PaperProofItemView {

			let view = PaperProofItemView()
			view.translatesAutoresizingMaskIntoConstraints = false
			view.title = title
			view.message = message
			view.icon = icon
			return view
		}
}

extension PaperProofStartViewController: UINavigationControllerDelegate {
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

		if let coordinator = navigationController.topViewController?.transitionCoordinator {
			coordinator.notifyWhenInteractionChanges { [weak self] context in
				guard !context.isCancelled else { return }
				// Clean up coordinator when swiping back
				self?.viewModel.backSwipe()
			}
		}
	}
}
