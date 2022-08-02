/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

// MARK: - Model

extension HolderDashboardViewModel {

	// Domestic:
	//  - A single greencard
	//  - An array of Origins

	// International:
	//  - Multiple greencards
	//  - each with an array of origins

	/// Represents a (set of) Greencard(s) in the UI,
	/// Can be a single card or a stack, depending if it contains greencards which have been grouped together.
	struct QRCard {

		/// Represents the region that the Greencard applies to
		enum Region {
			case netherlands(evaluateCredentialAttributes: (QRCard.GreenCard, Date) -> DomesticCredentialAttributes?)
			case europeanUnion(evaluateCredentialAttributes: (QRCard.GreenCard, Date) -> EuCredentialAttributes?)
		}

		struct GreenCard: Equatable {
			let id: NSManagedObjectID
			let origins: [Origin]

			struct Origin: Equatable, Hashable { // swiftlint:disable:this nesting

				let type: QRCodeOriginType // vaccination | test | recovery | vaccinationassessment
				let eventDate: Date
				let expirationTime: Date
				let validFromDate: Date
				let doseNumber: Int?

				/// There is a particular order to sort these onscreen
				var customSortIndex: Double {
				
					guard type == .recovery || type == .test else {
						return type.customSortIndex
					}
					
					let index = type.customSortIndex
					if validFromDate < Current.now() {
						// Valid, sort based on expirationtime. latest one first.
						/// now is 2021-07-15 15:02:39
						/// epoch = 1626361359
						/// index = type.customSortIndex +1 - 0.1626361359
						return index + 1 - expirationTime.timeIntervalSince1970 / 10000000000
					} else {
						// Future valid, highest sort index (displayed last)
						return index + 0.99
					}
				}

				func isNotYetExpired(now: Date) -> Bool {
					expirationTime > now
				}

				func isCurrentlyValid(now: Date) -> Bool {
					isValid(duringDate: now)
				}

				func isValid(duringDate date: Date) -> Bool {
					date.isWithinTimeWindow(from: validFromDate, to: expirationTime)
				}

				func expiryIsBeyondThreeYearsFromNow(now: Date) -> Bool {
					let threeYearsFromNow: TimeInterval = 60 * 60 * 24 * 365 * 3
					return expirationTime > now.addingTimeInterval(threeYearsFromNow)
				}
				
				/// The point at which a countdown timer will be shown for this origin `type`
				func countdownTimerVisibleThreshold(isInternational: Bool) -> TimeInterval? {
					switch (isInternational, type) {
						case (_, .test):
							return 6 * 60 * 60 // tests have a countdown of 6 hours
						case (_, .recovery):
							return 21 * 24 * 60 * 60 // recoveries have a 21 day countdown
						case (false, _):
							return 24 * 60 * 60 // everything else Domestic has countdown for the last 24 hours
						case (true, _):
							return nil // other international `type`s have no countdown.
					}
				}
			}
			
			/// Note: may _not yet_ be valid!
			func hasUnexpiredOrigin(ofType type: QRCodeOriginType, now: Date) -> Bool {
				return origins
					.filter { $0.isNotYetExpired(now: now) }
					.contains(where: { $0.type == type })
			}
		}

		let region: Region // A QR Card only has one region
		let greencards: [GreenCard]
		let shouldShowErrorBeneathCard: Bool
		let evaluateEnabledState: (Date) -> Bool

		func isOfRegion(region: QRCodeValidityRegion) -> Bool {
			switch (self.region, region) {
				case (.europeanUnion, .europeanUnion): return true
				case (.netherlands, .domestic): return true
				default: return false
			}
		}

		/// There is a particular order to sort these onscreen
		var customSortIndex: Double {
			guard let firstGreenCard = greencards.first, // assumption: when multiple greencards, should all have same origin type.
				  let firstOrigin = firstGreenCard.origins.first
			else { return .greatestFiniteMagnitude }

			return firstOrigin.customSortIndex
		}

		var origins: [GreenCard.Origin] {
			greencards.flatMap { $0.origins }
		}
		
		/// Note: may _not yet_ be valid!
		func hasUnexpiredTest(now: Date) -> Bool {
			// Find greencards where there is a test not yet expired
			let greencardsWithUnexpiredTest = greencards.filter { greencard in
				greencard.hasUnexpiredOrigin(ofType: .test, now: now)
			}
			return greencardsWithUnexpiredTest.isNotEmpty
		}
		
		func hasUnexpiredOriginsWhichAreNotOfTypeTest(now: Date) -> Bool {
			greencards.filter({ QRCard.hasUnexpiredOriginThatIsNotATest(greencard: $0, now: now) }).isNotEmpty
		}
		
		static func hasUnexpiredOriginThatIsNotATest(greencard: HolderDashboardViewModel.QRCard.GreenCard, now: Date) -> Bool {
			return greencard.hasUnexpiredOrigin(ofType: .vaccination, now: now)
				|| greencard.hasUnexpiredOrigin(ofType: .recovery, now: now)
				|| greencard.hasUnexpiredOrigin(ofType: .vaccinationassessment, now: now)
		}
	}

	struct ExpiredQR: Equatable {
		let id = UUID().uuidString
		let region: QRCodeValidityRegion
		let type: QRCodeOriginType
	}
	
	enum DisclosurePolicyMode {
		case exclusive3G
		case exclusive1G
		case combined1gAnd3g
		case zeroG
	}
}

// MARK: - Custom Equatable conformances

extension QRCard.Region: Equatable {
	static func == (lhs: HolderDashboardViewModel.QRCard.Region, rhs: HolderDashboardViewModel.QRCard.Region) -> Bool {
		switch (lhs, rhs) {
			case (.netherlands, .netherlands): return true
			case (.europeanUnion, .europeanUnion):
				// No need to compare the associated-value `evaluate` functions
				return true
			default:
				return false
		}
	}
}

extension QRCard: Equatable {
	static func == (lhs: HolderDashboardViewModel.QRCard, rhs: HolderDashboardViewModel.QRCard) -> Bool {
		let regionsMatch = lhs.region == rhs.region
		let greencardsMatch = lhs.greencards == rhs.greencards
		let shouldShowErrorBeneathCardMatch = lhs.shouldShowErrorBeneathCard == rhs.shouldShowErrorBeneathCard

		return regionsMatch && greencardsMatch && shouldShowErrorBeneathCardMatch
	}
}
