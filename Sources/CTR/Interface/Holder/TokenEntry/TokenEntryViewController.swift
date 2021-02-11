/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenEntryView: ScrollView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let buttonWidth: CGFloat = 212.0
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 54.0
		static let titleTopMargin: CGFloat = 34.0
		static let messageTopMargin: CGFloat = 24.0
		static let spacing: CGFloat = 24.0
	}

	/// The title label
	let titleLabel: Label = {

		return Label(title1: nil).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The stackview for the content
	let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.spacing
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(stackView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.titleTopMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			// StackView
			stackView.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.margin
			),
			stackView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			stackView.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	// MARK: Public Access

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The onboarding message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}
}

class TokenEntryViewModel: Logging {

	var loggingCategory: String = "TokenEntryViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var tokenTitle: String
	@Bindable private(set) var tokenPlaceholder: String
	@Bindable private(set) var token: String?
	@Bindable private(set) var verificationCodeTitle: String
	@Bindable private(set) var verificationCodePlaceholder: String
	@Bindable private(set) var verificationCode: String?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(
		coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator

		title = .holderTokenEntryTitle
		message = .holderTokenEntryText
		tokenTitle = .holderTokenEntryTokenTitle
		tokenPlaceholder = .holderTokenEntryTokenPlaceholder
		verificationCodeTitle = .holderTokenEntryVerificationTitle
		verificationCodePlaceholder = .holderTokenEntryVerificationPlaceholder
	}
}

class TokenEntryViewController: BaseViewController {

	private let viewModel: TokenEntryViewModel

	let sceneView = TokenEntryView()

	init(viewModel: TokenEntryViewModel) {

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

		viewModel.$title.binding = {

			self.sceneView.title = $0
		}

		viewModel.$message.binding = {

			self.sceneView.message = $0
		}
	}
}
