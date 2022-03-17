/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class RemoteEventDetailsViewModel {
	
	/// Dismissable Delegate
	weak var coordinator: Dismissable?
	
	// MARK: - Bindable
	
	/// The title of the information page
	@Bindable private(set) var title: String
	
	@Bindable private(set) var details: [(detail: NSAttributedString, hasExtraLineBreak: Bool, isSeparator: Bool)]

	@Bindable private(set) var footer: String?

	@Bindable private(set) var hideForCapture: Bool = false
	
	// MARK: - Private
	private let hideBodyForScreenCapture: Bool
	private let screenCaptureDetector = ScreenCaptureDetector()
	
	init(
		coordinator: Dismissable,
		title: String,
		details: [EventDetails],
		footer: String? = nil,
		hideBodyForScreenCapture: Bool = false) {
		
		self.coordinator = coordinator
		self.title = title
		self.footer = footer
		self.hideBodyForScreenCapture = hideBodyForScreenCapture
		self.details = details.compactMap {

			guard $0.field.isRequired || $0.value?.isEmpty == false else {

				if $0.field.isSeparator {
					return (NSAttributedString(), false, true)
				}
				return nil
			}
			
			let field = NSMutableAttributedString(string: $0.field.displayTitle, attributes: [.font: Fonts.body])
			if let value = $0.value, !value.isEmpty {
				field.append(NSAttributedString(string: " \(value)", attributes: [.font: Fonts.bodyBold]))
			}
			return (field, $0.field.hasLineBreak, $0.field.isSeparator)
		}
		
		if hideBodyForScreenCapture {
			screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
				self?.hideForCapture = isBeingCaptured
			}
		}
	}
}
