/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

public class BottomSheetContentViewModel {

	// MARK: - Observable

	private(set) var title: Observable<String>
	private(set) var body: Observable<String>
	private(set) var secondaryButtonTitle: Observable<String?>
	private(set) var hideForCapture = Observable<Bool>(value: false)

	// MARK: - Private
	private let linkTapHander: ((URL) -> Void)?
	private let screenCaptureDetector: ScreenCaptureDetectorProtocol
	public let content: Content
	
	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - title: The title of the page
	///   - message: The message of the page
	public init(
		content: Content,
		screenCaptureDetector: ScreenCaptureDetectorProtocol,
		linkTapHander: ((URL) -> Void)? = nil, // todo: merge this into Content?
		hideBodyForScreenCapture: Bool = false
	) {

		self.content = content
		self.title = Observable(value: content.title)
		self.body = Observable(value: content.body ?? "")
		self.secondaryButtonTitle = Observable(value: content.secondaryActionTitle)
		self.linkTapHander = linkTapHander
		self.screenCaptureDetector = screenCaptureDetector
		
		if hideBodyForScreenCapture {
			screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
				self?.hideForCapture.value = isBeingCaptured
			}
		}
	}

	// MARK: - Methods

	func userDidTapURL(url: URL) {
		linkTapHander?(url)
	}

	func userDidTapSecondaryButton() {
		content.secondaryAction?()
	}
}
