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

	override var enableSwipeBack: Bool { false }
	
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
