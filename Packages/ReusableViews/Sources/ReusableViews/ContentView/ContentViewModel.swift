/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

public final class ContentViewModel {

	@Bindable public private(set) var content: Content
	
	public let showBackButton: Bool
	public let allowsSwipeBack: Bool
	private var backbuttonAction: (() -> Void)?
	private let linkTapHander: ((URL) -> Void)?
	
	public init(
		content: Content,
		backAction: (() -> Void)?,
		allowsSwipeBack: Bool,
		linkTapHander: ((URL) -> Void)? = nil
	) {

		self.content = content
		self.backbuttonAction = backAction
		self.showBackButton = backbuttonAction != nil
		self.allowsSwipeBack = allowsSwipeBack
		self.linkTapHander = linkTapHander
	}

	public func backButtonTapped() {

		backbuttonAction?()
	}
	
	public func openUrl(_ url: URL) {
		
		linkTapHander?(url)
	}
}
