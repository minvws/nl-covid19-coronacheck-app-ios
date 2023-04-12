/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Persistence
import Models
import Resources

extension HolderDashboardViewController.Card {

	static func makeHeaderMessageCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {

		guard !state.dashboardHasEmptyState(for: validityRegion) else { return [] }
		
		return [
			.headerMessage(
				message: L.holder_dashboard_filledState_international_0G_message(),
				buttonTitle: L.holderDashboardEmptyInternationalButton()
			)
		]
	}

	static func makeAddCertificateCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard !state.shouldShowAddCertificateFooter else { return [] }
		return [
			.addCertificate(
				title: L.holder_dashboard_addCard_title(),
				didTapAdd: { [weak actionHandler] in
					actionHandler?.didTapAddCertificate()
				})
		]
	}
	
	static func makeDeviceHasClockDeviationCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard state.deviceHasClockDeviation && !state.qrCards.isEmpty else { return [] }
		return [
			.deviceHasClockDeviation(
				message: L.holderDashboardClockDeviationDetectedMessage(),
				callToActionButtonText: L.general_readmore(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapDeviceHasClockDeviationMoreInfo()
				}
			)
		]
	}

	static func makeConfigAlmostOutOfDateCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard state.shouldShowConfigurationIsAlmostOutOfDateBanner else { return [] }
		return [
			.configAlmostOutOfDate(
				message: L.holderDashboardConfigIsAlmostOutOfDateCardMessage(),
				callToActionButtonText: L.holderDashboardConfigIsAlmostOutOfDateCardButton(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapConfigAlmostOutOfDateCTA()
				}
			)
		]
	}
	
	static func makeBlockedEventsCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard state.blockedEventItems.isNotEmpty else { return [] }
			
		return [
			.eventsWereRemoved(
				message: L.holder_invaliddetailsremoved_banner_title(),
				callToActionButtonText: L.holder_invaliddetailsremoved_banner_button_readmore(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapBlockedEventsDeletedMoreInfo(blockedEventItems: state.blockedEventItems)
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapBlockedEventsDeletedDismiss(blockedEventItems: state.blockedEventItems)
				}
			)
		]
	}

	static func makeMismatchedIdentityEventsCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard state.mismatchedIdentityItems.isNotEmpty else { return [] }
			
		return [
			.eventsWereRemoved(
				message: L.holder_identityRemoved_banner_title(),
				callToActionButtonText: L.holder_identityRemoved_banner_button_readmore(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapMismatchedIdentityEventsDeletedMoreInfo(items: state.mismatchedIdentityItems)
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapMismatchedIdentityEventsDeletedDismiss(items: state.mismatchedIdentityItems)
				}
			)
		]
	}

	static func makeExpiredQRCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		return state.regionFilteredExpiredCards(validityRegion: validityRegion)
			.compactMap { expiredQR -> HolderDashboardViewController.Card? in
				
				let message = String.holderDashboardQRExpired(
					originType: expiredQR.type
				)
				let didTapClose: () -> Void = { [weak actionHandler] in
					actionHandler?.didTapCloseExpiredQR(expiredQR: expiredQR)
				}
				return .expiredQR(message: message, didTapClose: didTapClose)
			}
	}
	
	static func makeEmptyStateDescriptionCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		guard state.dashboardHasEmptyState(for: validityRegion) else { return [] }
		
		return [HolderDashboardViewController.Card.emptyStateDescription(
			message: L.holder_dashboard_emptyState_international_0G_message(),
			buttonTitle: L.holder_dashboard_international_0G_action_certificateNeeded()
		)]
	}
	
	static func makeEmptyStatePlaceholderImageCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		guard state.dashboardHasEmptyState(for: validityRegion) else { return [] }
		
		guard let internationalImage = I.dashboard.international() else { return [] }
		return [HolderDashboardViewController.Card.emptyStatePlaceholderImage(
			image: internationalImage,
			title: L.holderDashboardEmptyInternationalTitle()
		)]
	}
	
	static func makeRecommendedUpdateCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard state.shouldShowRecommendedUpdateBanner else { return [] }
		return [
			.recommendedUpdate(
				message: L.recommended_update_card_description(),
				callToActionButtonText: L.recommended_update_card_action(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapRecommendedUpdate()
				}
			)
		]
	}
	
	static func makeDisclosurePolicyInformation0GBanner(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard validityRegion == .europeanUnion,
			  state.shouldShow0GDisclosurePolicyBecameActiveBanner else { return [] }

		return [
			.disclosurePolicyInformation(
				title: L.holder_dashboard_noDomesticCertificatesBanner_0G_title(),
				buttonText: L.holder_dashboard_noDomesticCertificatesBanner_0G_action_linkToRijksoverheid(),
				accessibilityIdentifier: "disclosurePolicy_informationBanner",
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation0GBannerMoreInformation()
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation0GBannerClose()
				}
			)
		]
	}
	
	/// Map a `QRCard` to a `VC.Card`:
	static func makeQRCards(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		return state.regionFilteredQRCards(validityRegion: validityRegion)
			.flatMap { (qrcardDataItem: HolderDashboardViewModel.QRCard) -> [HolderDashboardViewController.Card] in
				qrcardDataItem.toViewControllerCards(
					state: state,
					actionHandler: actionHandler
				)
			}
	}
}

extension HolderDashboardViewModel.QRCard {

	fileprivate func toViewControllerCards(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		return [HolderDashboardViewController.Card.europeanUnionQR(
			title: {
				let localizedProof: String? = self.origins.first?.type.localizedProofInternational0G
				return (localizedProof ?? L.holderDashboardQrTitle()).capitalizingFirstLetter()
			}(),
			stackSize: {
				let minStackSize = 1
				let maxStackSize = 3
				return min(maxStackSize, max(minStackSize, greencards.count))
			}(),
			validityTexts: validityTextsGenerator(
				greencards: greencards
			),
			isLoading: state.isRefreshingStrippen,
			didTapViewQR: { [weak actionHandler] in
				guard evaluateEnabledState(Current.now()) else { return }
				actionHandler?.didTapShowQR(greenCardObjectIDs: greencards.compactMap { $0.id })
			},
			buttonEnabledEvaluator: evaluateEnabledState,
			expiryCountdownEvaluator: { now in
				internationalCountdownText(now: now, origins: origins)
			},
			error: qrCardError(state: state, actionHandler: actionHandler)
		)]
	}

	/// Returns `HolderDashboardViewController.Card.Error`, if appropriate, which configures the display of an error on the QRCardView.
	private func qrCardError(state: HolderDashboardViewModel.State, actionHandler: HolderDashboardCardUserActionHandling) -> HolderDashboardViewController.Card.Error? {
		guard let error = state.errorForQRCardsMissingCredentials, shouldShowErrorBeneathCard else { return nil }
		
		let errorMessage: String = {
			switch error {
				case .noInternet: return L.holderDashboardStrippenExpiredErrorfooterNointernet()
				case .otherFailureFirstOccurence: return L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
				case .otherFailureSubsequentOccurence: return L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk(Current.contactInformationProvider.phoneNumberLink)
			}
		}()
		
		return HolderDashboardViewController.Card.Error(message: errorMessage, didTapURL: { [weak actionHandler] url in
			if url.absoluteString == AppAction.tryAgain {
				actionHandler?.didTapRetryLoadQRCards()
			} else {
				actionHandler?.openUrl(url)
			}
		})
	}
	
	// Returns a closure that, given a Date, will return the groups of text ("ValidityText") that should be shown per-origin on the QR Card.
	private func validityTextsGenerator(
		greencards: [HolderDashboardViewModel.QRCard.GreenCard]
	) -> (Date) -> [HolderDashboardViewController.ValidityText] {
		
		return { now in
			return greencards
				// Make a list of all origins paired with their greencard
				.flatMap { greencard in
					
					greencard.origins.map { (greencard, $0) }
				}
				// Sort by the customSortIndex, and then by origin eventDate (desc)
				.sorted { lhs, rhs in
					if lhs.1.customSortIndex == rhs.1.customSortIndex {
						return lhs.1.eventDate > rhs.1.eventDate
					}
					return lhs.1.customSortIndex < rhs.1.customSortIndex
				}
				// Map to the ValidityText
				.map { greencard, origin -> HolderDashboardViewController.ValidityText in
					let validityType = QRCard.ValidityType(expiration: origin.expirationTime, validFrom: origin.validFromDate, now: now)
					let first = validityType.text(qrCard: self, greencard: greencard, origin: origin, now: now)
					return first
				}
		}
	}
}

/// For a given `[QRCard.GreenCard.Origin]`, determines which origin expires furthest into future, and
/// if the date is within the threshold, will return a localized string indicating how long until that origin expires.
private func domesticCountdownText(now: Date, origins: [QRCard.GreenCard.Origin]) -> String? {
	
	let expiringMostDistantlyInFutureOrigin: QRCard.GreenCard.Origin? = {
		// Calculate which is the origin with the furthest future expiration:
		return origins.reduce(QRCard.GreenCard.Origin?.none) { previous, next in
			guard let previous = previous else { return next }
			return next.expirationTime > previous.expirationTime ? next : previous
		}
	}()
	
	guard let expiringMostDistantlyInFutureOrigin = expiringMostDistantlyInFutureOrigin,
		  let countdownTimerVisibleThreshold: TimeInterval = expiringMostDistantlyInFutureOrigin.countdownTimerVisibleThreshold(isInternational: false)
	else { return nil }
	
	let expirationTime: Date = expiringMostDistantlyInFutureOrigin.expirationTime
	
	guard expirationTime > now && expirationTime < now.addingTimeInterval(countdownTimerVisibleThreshold)
	else { return nil }

	return countdownText(now: now, to: expirationTime)
}

private func internationalCountdownText(now: Date, origins: [QRCard.GreenCard.Origin]) -> String? {
	
	let uniqueOrigins = Set(origins.map { $0.type })
	guard uniqueOrigins.count == 1, let originType = uniqueOrigins.first else { return nil } // assumption: international cards have a single OriginType per-card.
	
	guard originType == .recovery else { return nil } // Only show a countdown on international cards when it's for type Recovery
	
	let expiringMostDistantlyInFutureOrigin: QRCard.GreenCard.Origin? = {
		// Calculate which is the origin with the furthest future expiration:
		return origins.reduce(QRCard.GreenCard.Origin?.none) { previous, next in
			guard let previous = previous else { return next }
			return next.expirationTime > previous.expirationTime ? next : previous
		}
	}()
	
	guard let expiringMostDistantlyInFutureOrigin = expiringMostDistantlyInFutureOrigin,
		  let countdownTimerVisibleThreshold: TimeInterval = expiringMostDistantlyInFutureOrigin.countdownTimerVisibleThreshold(isInternational: true)
	else { return nil }
	
	let expirationTime: Date = expiringMostDistantlyInFutureOrigin.expirationTime
	
	guard expirationTime > now && expirationTime < now.addingTimeInterval(countdownTimerVisibleThreshold)
	else { return nil }

	return countdownText(now: now, to: expirationTime)
}

/// Produces a localized countdown string relative to `now`
private func countdownText(now: Date, to futureExpiryDate: Date) -> String? {
	guard futureExpiryDate > now else { return nil }
	
	let formatter: DateComponentsFormatter = {
		let minute: TimeInterval = 60; let hour = minute * 60; let day = hour * 24

		if futureExpiryDate < now.addingTimeInterval(5 * minute) {
			
			// < 5 minutes: show minutes + seconds
			// e.g. "4 minuten en 15 seconden"
			return DateFormatter.Relative.hoursMinutesSeconds
		} else if futureExpiryDate < now.addingTimeInterval(25 * hour) {
			
			// < 1 day + 1 hour: show hours + minutes
			// e.g. "24 uur en 59 minuten"
			return DateFormatter.Relative.hoursMinutes
		} else if futureExpiryDate < now.addingTimeInterval(2 * day) {
			
			// < 2 days: show days + hours
			// e.g. "1 day, 2 hours"
			return DateFormatter.Relative.daysHours
		} else {
			
			// > 2 days: show days
			// e.g. "10 days"
			return DateFormatter.Relative.days
		}
	}()

	guard let relativeDateString = formatter.string(
		from: now,
		to: futureExpiryDate.addingTimeInterval(1) // add 1, so that we don't count down to zero
	)
	else { return nil }

	return (L.holderDashboardQrExpiryDatePrefixExpiresIn() + " " + relativeDateString).trimmingCharacters(in: .whitespacesAndNewlines)
}
