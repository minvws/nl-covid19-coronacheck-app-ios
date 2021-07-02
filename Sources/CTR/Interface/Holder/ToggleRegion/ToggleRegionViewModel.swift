/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ToggleRegionViewModel: Logging {

	@Bindable private(set) var topText: String?
	@Bindable private(set) var bottomText: String?
	@Bindable private(set) var segments: [(String, Int, Bool)]?

	private let didChangeCallback: (QRCodeValidityRegion) -> Void

	init(currentRegion: QRCodeValidityRegion, didChangeCallback: @escaping (QRCodeValidityRegion) -> Void) {
		self.didChangeCallback = didChangeCallback

		segments = [
			(.netherlands, 0, currentRegion == .domestic),
			(.europeanUnion, 1, currentRegion == .europeanUnion)
		]

		updateTexts(selectedRegion: currentRegion)
	}

	func updateTexts(selectedRegion: QRCodeValidityRegion) {
		switch selectedRegion {
			case .europeanUnion:
				topText = L.toggleRegionLabelTopTextEu()
				bottomText = L.toggleRegionLabelBottomTextEu()
			case .domestic:
				topText = L.toggleRegionLabelTopTextNl()
				bottomText = L.toggleRegionLabelBottomTextNl()
		}
	}

	func didSelectIndex(_ index: Int) {

		let newRegion: QRCodeValidityRegion? = { [weak self] in
			switch index {
				case 0: return .domestic
				case 1: return .europeanUnion
				default:
					self?.logError("Unknown index for Region selector: \(index)")
					return nil
			}
		}()

		if let newRegion = newRegion {
			didChangeCallback(newRegion)
			updateTexts(selectedRegion: newRegion)
		}
	}
}
