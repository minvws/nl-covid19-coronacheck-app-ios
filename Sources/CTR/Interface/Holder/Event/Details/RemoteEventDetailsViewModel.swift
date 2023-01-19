/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

final class RemoteEventDetailsViewModel {
	
	// MARK: - Bindable
	
	/// The title of the information page
	@Bindable private(set) var title: String
	
	@Bindable private(set) var details: [(detail: String, hasExtraPrecedingLineBreak: Bool, hasExtraFollowingLineBreak: Bool, isSeparator: Bool)]

	@Bindable private(set) var footer: String?

	@Bindable private(set) var hideForCapture: Bool = false
	
	// MARK: - Private
	private let screenCaptureDetector = ScreenCaptureDetector()
	
	init(
		title: String,
		details: [EventDetails],
		footer: String? = nil,
		hideBodyForScreenCapture: Bool = false) {
		
		self.title = title
		self.footer = footer
		self.details = details.compactMap {

			guard $0.field.isRequired || $0.value?.isEmpty == false else {

				if $0.field.isSeparator {
					return (String(), false, false, true)
				}
				return nil
			}
			
			var field = $0.field.displayTitle
			if let value = $0.value, !value.isEmpty {
				field += " <b>\(value)</b>"
			}
			return (field, $0.field.isPrecededByLineBreak, $0.field.isFollowedByLineBreak, $0.field.isSeparator)
		}
		
		if hideBodyForScreenCapture {
			screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
				self?.hideForCapture = isBeingCaptured
			}
		}
	}
}
