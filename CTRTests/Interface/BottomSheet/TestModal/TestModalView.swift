/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
@testable import CTR

final class TestModalView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let labelToLabel: CGFloat = 16
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		enum Message {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
	}
	
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = ViewTraits.Spacing.labelToLabel
		return view
	}()
	
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		stackView.embed(in: self, insets: .leftRight(ViewTraits.Margin.edge))
	}
	
	var testTitle: String? {
		didSet {
			titleLabel.attributedText = testTitle?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning)
		}
	}
	
	var testMessage: String? {
		didSet {
			messageLabel.attributedText = testMessage?.setLineHeight(ViewTraits.Message.lineHeight,
																 kerning: ViewTraits.Message.kerning)
		}
	}
}
