/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

final class DCCQRDetailsViewModel {
	
	/// Dismissable Delegate
	weak var coordinator: (Dismissable & OpenUrlProtocol)?
	
	// MARK: - Bindable
	
	/// The title of the information page
	@Bindable private(set) var title: String
	
	@Bindable private(set) var description: String
	
	@Bindable private(set) var details: [(field: String, value: String, dosageMessage: String?)]
	
	@Bindable private(set) var dateInformation: String
	
	@Bindable private(set) var hideForCapture: Bool = false
	
	private let screenCaptureDetector = ScreenCaptureDetector()
	
	init(
		coordinator: Dismissable & OpenUrlProtocol,
		title: String,
		description: String,
		details: [DCCQRDetails],
		dateInformation: String) {
		
		self.coordinator = coordinator
		self.title = title
		self.description = description
		self.dateInformation = dateInformation
		self.details = details.compactMap {
			
			guard let value = $0.value, value.isNotEmpty else {
				return nil
			}
			return (field: $0.field.displayTitle, value: Shared.Sanitizer.sanitize(value), dosageMessage: $0.dosageMessage)
		}
		
		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.hideForCapture = isBeingCaptured
		}
	}
	
	func openUrl(_ url: URL) {

		coordinator?.openUrl(url)
	}
}
