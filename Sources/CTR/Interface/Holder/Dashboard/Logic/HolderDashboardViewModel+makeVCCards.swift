/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension HolderDashboardViewController.Card {

	static func makeHeaderMessageCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {

		guard !state.qrCards.isEmpty || !state.regionFilteredExpiredCards(validityRegion: validityRegion).isEmpty
		else { return [] }

		switch validityRegion {
			case .domestic:
				return [.headerMessage(
					message: L.holderDashboardIntroDomestic(),
					buttonTitle: nil
				)]
			case .europeanUnion:
				return [.headerMessage(
					message: L.holderDashboardIntroInternational(),
					buttonTitle: L.holderDashboardEmptyInternationalButton()
				)]
		}
	}

	static func makeDeviceHasClockDeviationCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard state.deviceHasClockDeviation && !state.qrCards.isEmpty else { return [] }
		return [
			.deviceHasClockDeviation(
				message: L.holderDashboardClockDeviationDetectedMessage(),
				callToActionButtonText: L.generalReadmore(),
				didTapCallToAction: actionHandler.didTapDeviceHasClockDeviationMoreInfo
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
				didTapCallToAction: actionHandler.didTapConfigAlmostOutOfDateCTA
			)
		]
	}

	static func makeRecoveryValidityCards(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard validityRegion == .domestic else { return [] }
		
		if state.shouldShowRecoveryValidityExtensionAvailableBanner {
			return HolderDashboardViewController.Card.makeRecoveryValidityExtensionAvailableCard(
				didTapCallToAction: actionHandler.didTapRecoveryValidityExtensionAvailableMoreInfo
			)
		} else if state.shouldShowRecoveryValidityReinstationAvailableBanner {
			return HolderDashboardViewController.Card.makeRecoveryValidityReinstationAvailableCard(
				didTapCallToAction: actionHandler.didTapRecoveryValidityReinstationAvailableMoreInfo
			)
		} else if state.shouldShowRecoveryValidityExtensionCompleteBanner {
			return HolderDashboardViewController.Card.makeRecoveryValidityExtensionCompleteCard(
				didTapCallToAction: actionHandler.didTapRecoveryValidityExtensionCompleteMoreInfo,
				didTapClose: actionHandler.didTapRecoveryValidityExtensionCompleteClose
			)
		} else if state.shouldShowRecoveryValidityReinstationCompleteBanner {
			return HolderDashboardViewController.Card.makeRecoveryValidityReinstationCompleteCard(
				didTapCallToAction: actionHandler.didTapRecoveryValidityReinstationCompleteMoreInfo,
				didTapClose: actionHandler.didTapRecoveryValidityReinstationCompleteClose
			)
		}
		return []
	}
	
	static func makeExpiredQRCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		return state.regionFilteredExpiredCards(validityRegion: validityRegion)
			.compactMap { expiredQR -> HolderDashboardViewController.Card? in
				
				let message = String.holderDashboardQRExpired(
					localizedRegion: expiredQR.region.localizedAdjective,
					localizedOriginType: expiredQR.type.localizedProof
				)
				
				return .expiredQR(
					message: message,
					didTapClose: {
						actionHandler.didTapCloseExpiredQR(expiredQR: expiredQR)
					})
			}
	}
	
	static func makeEmptyStateDescriptionCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		guard !state.dashboardHasQRCards(for: validityRegion) else { return [] }
		
		switch validityRegion {
			case .domestic:
				return [HolderDashboardViewController.Card.emptyStateDescription(
					message: L.holderDashboardEmptyDomesticMessage(),
					buttonTitle: nil
				)]
			case .europeanUnion:
				return [HolderDashboardViewController.Card.emptyStateDescription(
					message: L.holderDashboardEmptyInternationalMessage(),
					buttonTitle: L.holderDashboardEmptyInternationalButton()
				)]
		}
	}
	
	static func makeEmptyStatePlaceholderImageCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		guard !state.dashboardHasQRCards(for: validityRegion) else { return [] }
		guard !state.shouldShowCompleteYourVaccinationAssessmentBanner(for: validityRegion) else { return [] }
	
		switch validityRegion {
			case .domestic:
				guard let domesticImage = I.dashboard.domestic() else { return [] }
				return [HolderDashboardViewController.Card.emptyStatePlaceholderImage(
					image: domesticImage,
					title: L.holderDashboardEmptyDomesticTitle()
				)]
			case .europeanUnion:
				guard let internationalImage = I.dashboard.international() else { return [] }
				return [HolderDashboardViewController.Card.emptyStatePlaceholderImage(
					image: internationalImage,
					title: L.holderDashboardEmptyInternationalTitle()
				)]
		}
	}
	
	static func makeRecommendCoronaMelderCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		let regionFilteredQRCards = state.regionFilteredQRCards(validityRegion: validityRegion)
		
		guard !regionFilteredQRCards.isEmpty,
			  !regionFilteredQRCards.contains(where: { $0.shouldShowErrorBeneathCard })
		else { return [] }
		
		return [HolderDashboardViewController.Card.recommendCoronaMelder]
	}
	
	static func makeTestOnlyValidFor3GCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard validityRegion == .domestic else { return [] }
		guard state.shouldShowDomestic3GTestBanner else { return [] }
		
		return [HolderDashboardViewController.Card.testOnlyValidFor3G(
			message: L.holder_my_overview_3g_test_validity_card(),
			callToActionButtonText: L.generalReadmore(),
			didTapCallToAction: actionHandler.didTapTestOnlyValidFor3GMoreInfo)
		]
	}
	
	/// for each origin which is in the other region but not in this one, add a new MessageCard to explain.
	/// e.g. "Je vaccinatie is niet geldig in Europa. Je hebt alleen een Nederlandse QR-code."
	static func makeOriginNotValidInThisRegionCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		now: Date,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		return localizedOriginsValidOnlyInOtherRegionsMessages(qrCards: state.qrCards, thisRegion: validityRegion, now: now)
			.sorted(by: { $0.originType.customSortIndex < $1.originType.customSortIndex })
			.map { originType, message in
				return .originNotValidInThisRegion(
					message: message,
					callToActionButtonText: L.generalReadmore(),
					didTapCallToAction: {
						actionHandler.didTapOriginNotValidInThisRegionMoreInfo(
							originType: originType,
							validityRegion: validityRegion
						)
					}
				)
			}
	}
	
	static func makeRecoveryValidityExtensionAvailableCard(didTapCallToAction: @escaping () -> Void) -> [HolderDashboardViewController.Card] {
		return [.recoveryValidityExtensionAvailable(
			title: L.holderDashboardRecoveryvalidityextensionExtensionavailableBannerTitle(),
			buttonText: L.generalReadmore(),
			didTapCallToAction: didTapCallToAction
		)]
	}
	
	static func makeRecoveryValidityReinstationAvailableCard(didTapCallToAction: @escaping () -> Void) -> [HolderDashboardViewController.Card] {
		return [.recoveryValidityExtensionAvailable(
			title: L.holderDashboardRecoveryvalidityextensionReinstationavailableBannerTitle(),
			buttonText: L.generalReadmore(),
			didTapCallToAction: didTapCallToAction
		)]
	}
	
	static func makeRecoveryValidityExtensionCompleteCard(didTapCallToAction: @escaping () -> Void, didTapClose: @escaping () -> Void) -> [HolderDashboardViewController.Card] {
		return [.recoveryValidityExtensionDidComplete(
			title: L.holderDashboardRecoveryvalidityextensionExtensioncompleteBannerTitle(),
			buttonText: L.generalReadmore(),
			didTapCallToAction: didTapCallToAction,
			didTapClose: didTapClose
		)]
	}
	
	static func makeRecoveryValidityReinstationCompleteCard(didTapCallToAction: @escaping () -> Void, didTapClose: @escaping () -> Void) -> [HolderDashboardViewController.Card] {
		return [.recoveryValidityExtensionDidComplete(
			title: L.holderDashboardRecoveryvalidityextensionReinstationcompleteBannerTitle(),
			buttonText: L.generalReadmore(),
			didTapCallToAction: didTapCallToAction,
			didTapClose: didTapClose
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
				didTapCallToAction: actionHandler.didTapRecommendedUpdate
			)
		]
	}

	static func makeNewValidityInfoForVaccinationAndRecoveriesCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
	
		guard validityRegion == .domestic, state.shouldShowNewValidityInfoForVaccinationsAndRecoveriesBanner else { return [] }
		return [
			.newValidityInfoForVaccinationAndRecoveries(
				title: L.holder_dashboard_newvaliditybanner_title(),
				buttonText: L.holder_dashboard_newvaliditybanner_action(),
				didTapCallToAction: actionHandler.didTapNewValidityBannerMoreInfo,
				didTapClose: actionHandler.didTapNewValidiyBannerClose
			)
		]
	}
	
	static func makeCompleteYourVaccinationAssessmentCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
	
		guard state.shouldShowCompleteYourVaccinationAssessmentBanner(for: validityRegion) else { return [] }
		return [
			.completeYourVaccinationAssessment(
				title: L.holder_dashboard_visitorpassincompletebanner_title(),
				buttonText: L.holder_dashboard_visitorpassincompletebanner_button_makecomplete(),
				didTapCallToAction: actionHandler.didTapVaccinationAssessmentEventAndNoOriginMoreInfo
			)
		]
	}
	
	/// Map a `QRCard` to a `VC.Card`:
	static func makeQRCards(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling,
		remoteConfigManager: RemoteConfigManaging
	) -> [HolderDashboardViewController.Card] {
		return state.regionFilteredQRCards(validityRegion: validityRegion)
			.flatMap { (qrcardDataItem: HolderDashboardViewModel.QRCard) -> [HolderDashboardViewController.Card] in
				qrcardDataItem.toViewControllerCards(
					state: state,
					actionHandler: actionHandler,
					remoteConfigManager: remoteConfigManager
				)
			}
	}
}

extension HolderDashboardViewModel.QRCard {

	fileprivate func toViewControllerCards(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling,
		remoteConfigManager: RemoteConfigManaging
	) -> [HolderDashboardViewController.Card] {

		var cards = [HolderDashboardViewController.Card]()
		
		switch self.region {
			case .netherlands:

				cards += [HolderDashboardViewController.Card.domesticQR(
					title: L.holderDashboardQrTitle(),
					validityTexts: validityTextsGenerator(greencards: greencards, remoteConfigManager: remoteConfigManager),
					isLoading: state.isRefreshingStrippen,
					didTapViewQR: {
						actionHandler.didTapShowQR(greenCardObjectIDs: greencards.compactMap { $0.id })
					},
					buttonEnabledEvaluator: evaluateEnabledState,
					expiryCountdownEvaluator: { now in
						let mostDistantFutureExpiryDate = origins.reduce(now) { result, nextOrigin in
							nextOrigin.expirationTime > result ? nextOrigin.expirationTime : result
						}

						// if all origins will be expired in next six hours:
						let sixHours: TimeInterval = 6 * 60 * 60
						guard mostDistantFutureExpiryDate > now && mostDistantFutureExpiryDate < now.addingTimeInterval(sixHours)
						else { return nil }
 
						let fiveMinutes: TimeInterval = 5 * 60
						let formatter: DateComponentsFormatter = {
							if mostDistantFutureExpiryDate < now.addingTimeInterval(fiveMinutes) {
								// e.g. "4 minuten en 15 seconden"
								return HolderDashboardViewModel.hmsRelativeFormatter
							} else {
								// e.g. "5 uur 59 min"
								return HolderDashboardViewModel.hmRelativeFormatter
							}
						}()

						guard let relativeDateString = formatter.string(from: now, to: mostDistantFutureExpiryDate)
						else { return nil }

						return (L.holderDashboardQrExpiryDatePrefixExpiresIn() + " " + relativeDateString).trimmingCharacters(in: .whitespacesAndNewlines)
					}
				)]

			case .europeanUnion:
				cards += [HolderDashboardViewController.Card.europeanUnionQR(
					title: (self.origins.first?.type.localizedProof ?? L.holderDashboardQrTitle()).capitalizingFirstLetter(),
					stackSize: {
						let minStackSize = 1
						let maxStackSize = 3
						return min(maxStackSize, max(minStackSize, greencards.count))
					}(),
					validityTexts: validityTextsGenerator(greencards: greencards, remoteConfigManager: remoteConfigManager),
					isLoading: state.isRefreshingStrippen,
					didTapViewQR: {
						actionHandler.didTapShowQR(greenCardObjectIDs: greencards.compactMap { $0.id })
					},
					buttonEnabledEvaluator: evaluateEnabledState,
					expiryCountdownEvaluator: nil
				)]
		}

		if let error = state.errorForQRCardsMissingCredentials, shouldShowErrorBeneathCard {
			cards += [HolderDashboardViewController.Card.errorMessage(message: error, didTapTryAgain: actionHandler.didTapRetryLoadQRCards)]
		}
		
		return cards
	}

	// Returns a closure that, given a Date, will return the groups of text ("ValidityText") that should be shown per-origin on the QR Card.
	private func validityTextsGenerator(greencards: [HolderDashboardViewModel.QRCard.GreenCard], remoteConfigManager: RemoteConfigManaging) -> (Date) -> [HolderDashboardViewController.ValidityText] {
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
					let first = validityType.text(qrCard: self, greencard: greencard, origin: origin, now: now, remoteConfigManager: remoteConfigManager)
					return first
				}
		}
	}
}

private func localizedOriginsValidOnlyInOtherRegionsMessages(qrCards: [QRCard], thisRegion: QRCodeValidityRegion, now: Date) -> [(originType: QRCodeOriginType, message: String)] {

	// Calculate origins which exist in the other region but are not in this region:
	let originTypesForCurrentRegion = Set(
		qrCards
			.filter { $0.isOfRegion(region: thisRegion) }
			.flatMap { $0.origins }
			.filter {
				$0.isNotYetExpired(now: now)
			}
			.compactMap { $0.type }
	)

	let originTypesForOtherRegion = Set(
		qrCards
			.filter { !$0.isOfRegion(region: thisRegion) }
			.flatMap { $0.origins }
			.filter {
				$0.isNotYetExpired(now: now)
			}
			.compactMap { $0.type }
	)

	let originTypesOnlyInOtherRegion = originTypesForOtherRegion
		.subtracting(originTypesForCurrentRegion)

	// Map it to user messages:
	let userMessages = originTypesOnlyInOtherRegion.map { (originType: QRCodeOriginType) -> (originType: QRCodeOriginType, message: String) in
		switch (originType, thisRegion) {
			case (.vaccination, .domestic):
				return (originType, L.holderDashboardOriginNotValidInNetherlandsButIsInEUVaccination())
			case (_, .domestic):
				return (originType, L.holderDashboardOriginNotValidInNetherlandsButIsInEU(originType.localizedProof))
			case (.vaccinationassessment, .europeanUnion):
				return (originType, L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title())
			case (_, .europeanUnion):
				return (originType, L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(originType.localizedProof))
		}
	}

	return userMessages
}
