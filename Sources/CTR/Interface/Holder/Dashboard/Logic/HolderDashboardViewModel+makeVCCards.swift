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

		guard !state.dashboardHasEmptyState(for: validityRegion) else { return [] }

		switch validityRegion {
			case .domestic:
				let domesticTitle: String
				switch state.activeDisclosurePolicyMode {
					case .exclusive1G:
						domesticTitle = L.holder_dashboard_intro_domestic_only1Gaccess()
					case .exclusive3G:
						domesticTitle = L.holder_dashboard_intro_domestic_only3Gaccess()
					case .combined1gAnd3g:
						domesticTitle = L.holder_dashboard_intro_domestic_3Gand1Gaccess()
					case .zeroG:
						domesticTitle = "" // isn't shown in zeroG.
				}
				return [.headerMessage(
					message: domesticTitle,
					buttonTitle: nil
				)]
			case .europeanUnion:
				return [
					.headerMessage(
						message: state.activeDisclosurePolicyMode == .zeroG
							? L.holder_dashboard_filledState_international_0G_message()
							: L.holderDashboardIntroInternational(),
						buttonTitle: L.holderDashboardEmptyInternationalButton()
					)
				]
		}
	}

	static func makeAddCertificateCard(
		validityRegion: QRCodeValidityRegion,
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

	static func makeExpiredQRCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		return state.regionFilteredExpiredCards(validityRegion: validityRegion)
			.compactMap { expiredQR -> HolderDashboardViewController.Card? in
				
				let message = String.holderDashboardQRExpired(
					originType: expiredQR.type,
					region: expiredQR.region
				)
				let didTapClose: () -> Void = { [weak actionHandler] in
					actionHandler?.didTapCloseExpiredQR(expiredQR: expiredQR)
				}
				
				if case .vaccination = expiredQR.type, case .domestic = expiredQR.region {
					return .expiredVaccinationQR(
						message: message,
						callToActionButtonText: L.general_readmore(),
						didTapCallToAction: { [weak actionHandler] in
							actionHandler?.didTapExpiredDomesticVaccinationQRMoreInfo()
						},
						didTapClose: didTapClose
					)
				} else {
					return .expiredQR(message: message, didTapClose: didTapClose)
				}
			}
	}
	
	static func makeEmptyStateDescriptionCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		guard state.dashboardHasEmptyState(for: validityRegion) else { return [] }
		
		switch validityRegion {
			case .domestic:
				let domesticTitle: String
				switch state.activeDisclosurePolicyMode {
					case .exclusive1G:
						domesticTitle = L.holder_dashboard_empty_domestic_only1Gaccess_message()
					case .exclusive3G:
						domesticTitle = L.holder_dashboard_empty_domestic_only3Gaccess_message()
					case .combined1gAnd3g:
						domesticTitle = L.holder_dashboard_empty_domestic_3Gand1Gaccess_message()
					case .zeroG:
						domesticTitle = "" // isn't shown in zeroG.
				}
				return [HolderDashboardViewController.Card.emptyStateDescription(
					message: domesticTitle,
					buttonTitle: nil
				)]
			case .europeanUnion:
			if state.activeDisclosurePolicyMode == .zeroG {
				return [HolderDashboardViewController.Card.emptyStateDescription(
					message: L.holder_dashboard_emptyState_international_0G_message(),
					buttonTitle: L.holder_dashboard_international_0G_action_certificateNeeded()
				)]
			} else {
				return [HolderDashboardViewController.Card.emptyStateDescription(
					message: L.holderDashboardEmptyInternationalMessage(),
					buttonTitle: L.holderDashboardEmptyInternationalButton()
				)]
			}
		}
	}
	
	static func makeEmptyStatePlaceholderImageCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		guard state.dashboardHasEmptyState(for: validityRegion) else { return [] }
		guard !state.shouldShowCompleteYourVaccinationAssessmentBanner(for: validityRegion) else { return [] }
		guard !state.shouldShowVaccinationAssessmentInvalidOutsideNLBanner(for: validityRegion) else { return [] }
	
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
		guard state.shouldShowRecommendCoronaMelderCard else { return [] } // based on feature flag
		
		let regionFilteredQRCards = state.regionFilteredQRCards(validityRegion: validityRegion)
		
		guard !regionFilteredQRCards.isEmpty,
			  !regionFilteredQRCards.contains(where: { $0.shouldShowErrorBeneathCard })
		else { return [] }
		
		return [HolderDashboardViewController.Card.recommendCoronaMelder]
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
					callToActionButtonText: L.general_readmore(),
					didTapCallToAction: { [weak actionHandler] in
						actionHandler?.didTapOriginNotValidInThisRegionMoreInfo(
							originType: originType,
							validityRegion: validityRegion
						)
					}
				)
			}
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
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapCompleteYourVaccinationAssessmentMoreInfo()
				}
			)
		]
	}
	
	static func makeDisclosurePolicyInformation1GBanner(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard validityRegion == .domestic,
				state.shouldShow1GOnlyDisclosurePolicyBecameActiveBanner,
			  state.activeDisclosurePolicyMode == .exclusive1G else { return [] }
		
		return [
			.disclosurePolicyInformation(
				title: L.holder_dashboard_only1GaccessBanner_title(),
				buttonText: L.general_readmore(),
				accessibilityIdentifier: "disclosurePolicy_informationBanner",
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation1GBannerMoreInformation()
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation1GBannerClose()
				}
			)
		]
	}
	
	static func makeDisclosurePolicyInformation3GBanner(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard validityRegion == .domestic,
			  state.shouldShow3GOnlyDisclosurePolicyBecameActiveBanner,
			  state.activeDisclosurePolicyMode == .exclusive3G else { return [] }
		
		return [
			.disclosurePolicyInformation(
				title: L.holder_dashboard_only3GaccessBanner_title(),
				buttonText: L.general_readmore(),
				accessibilityIdentifier: "disclosurePolicy_informationBanner",
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation3GBannerMoreInformation()
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation3GBannerClose()
				}
			)
		]
	}
	
	static func makeDisclosurePolicyInformation1GWith3GBanner(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard validityRegion == .domestic,
				state.shouldShow3GWith1GDisclosurePolicyBecameActiveBanner,
				state.activeDisclosurePolicyMode == .combined1gAnd3g else { return [] }

		return [
			.disclosurePolicyInformation(
				title: L.holder_dashboard_3Gand1GaccessBanner_title(),
				buttonText: L.general_readmore(),
				accessibilityIdentifier: "disclosurePolicy_informationBanner",
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation1GWith3GBannerMoreInformation()
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation1GWith3GBannerClose()
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
				state.shouldShow0GDisclosurePolicyBecameActiveBanner,
				state.activeDisclosurePolicyMode == .zeroG else { return [] }

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
	
	static func makeVaccinationAssessmentInvalidOutsideNLCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard state.shouldShowVaccinationAssessmentInvalidOutsideNLBanner(for: validityRegion) else { return [] }
		
		return [
			.vaccinationAssessmentInvalidOutsideNL(
				title: L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title(),
				buttonText: L.general_readmore(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapVaccinationAssessmentInvalidOutsideNLMoreInfo()
				}
			)
		]
	}
	
	/// Map a `QRCard` to a `VC.Card`:
	static func makeQRCards(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		localDisclosurePolicy: DisclosurePolicy, // the disclosure policy for this group of cards (vs state.activeDisclosurePolicyMode)
		actionHandler: HolderDashboardCardUserActionHandling,
		remoteConfigManager: RemoteConfigManaging
	) -> [HolderDashboardViewController.Card] {
		return state.regionFilteredQRCards(validityRegion: validityRegion)
			.flatMap { (qrcardDataItem: HolderDashboardViewModel.QRCard) -> [HolderDashboardViewController.Card] in
				qrcardDataItem.toViewControllerCards(
					state: state,
					localDisclosurePolicy: localDisclosurePolicy,
					actionHandler: actionHandler
				)
			}
	}
}

extension HolderDashboardViewModel.QRCard {

	fileprivate func toViewControllerCards(
		state: HolderDashboardViewModel.State,
		localDisclosurePolicy: DisclosurePolicy, // the disclosure policy for this card (vs state.activeDisclosurePolicyMode)
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {

		var cards = [HolderDashboardViewController.Card]()
		
		switch self.region {
			case .netherlands:
				cards = domesticQRCard(state: state, localDisclosurePolicy: localDisclosurePolicy, actionHandler: actionHandler)

			case .europeanUnion:
				cards = internationalQRCard(state: state, localDisclosurePolicy: localDisclosurePolicy, actionHandler: actionHandler)
		}

		if let error = state.errorForQRCardsMissingCredentials, shouldShowErrorBeneathCard {
			cards += [HolderDashboardViewController.Card.errorMessage(message: error, didTapTryAgain: { [weak actionHandler] in
				actionHandler?.didTapRetryLoadQRCards()
			})]
		}
		
		return cards
	}
	
	private func domesticQRCard(
		state: HolderDashboardViewModel.State,
		localDisclosurePolicy: DisclosurePolicy, // the disclosure policy for this card (vs state.activeDisclosurePolicyMode)
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		// Certain combinations preclude showing _any_ QR Cards
		// , in which case just return nothing
	
		switch (state.activeDisclosurePolicyMode, localDisclosurePolicy) {
			case (.exclusive1G, .policy1G),
				(.combined1gAnd3g, .policy1G):
				guard hasUnexpiredTest(now: Current.now()) else { return [] }
			case (.exclusive1G, .policy3G):
				guard hasUnexpiredOriginsWhichAreNotOfTypeTest(now: Current.now()) else { return [] }
			case (.exclusive3G, .policy3G),
				(.combined1gAnd3g, .policy3G):
				break
			case (.exclusive3G, .policy1G), (.zeroG, _):
				return []
		}
		
		func isDisabledByDisclosurePolicy() -> Bool {
			
			// Whether we should show "Dit bewijs wordt nu niet gebruikt in Nederland."
			switch (state.activeDisclosurePolicyMode, localDisclosurePolicy) {
				case (.exclusive1G, .policy1G),
					(.exclusive3G, .policy1G), // this case is not shown in UI
					(.exclusive3G, .policy3G),
					(.combined1gAnd3g, .policy1G),
					(.combined1gAnd3g, .policy3G),
					(.zeroG, _):
					return false
					
				case (.exclusive1G, .policy3G):
					return true
			}
		}
		
		func buttonIsEnabled(now: Date) -> Bool {
			
			// Special case when this is for a 1G card:
			if localDisclosurePolicy == .policy1G {
				// If this is the 1G card then the button enabled state should only be determined by tests.
				// We need to filter the origins on the `QRCard`, as it could have a valid vaccination/recovery (which are not 1G).
				// (NB: the `QRCard` abstraction is starting to break down now that 1 `QRCard` can be shown split into 1G and 3G cards in the UI..)
				let hasCurrentlyValidTest = origins
					.filter { $0.type == .test }
					.contains(where: { $0.isCurrentlyValid(now: now) })
				
				return hasCurrentlyValidTest && evaluateEnabledState(now)
			}
			
			// Default case:
			return evaluateEnabledState(now)
		}
	
		return [HolderDashboardViewController.Card.domesticQR(
			disclosurePolicyLabel: localDisclosurePolicy.localization,
			title: {
				switch localDisclosurePolicy {
					case .policy3G: return L.holder_dashboard_domesticQRCard_3G_title()
					case .policy1G: return L.holder_dashboard_domesticQRCard_1G_title()
				}
			}(),
			isDisabledByDisclosurePolicy: isDisabledByDisclosurePolicy(),
			validityTexts: validityTextsGenerator(
				greencards: greencards,
				localDisclosurePolicy: localDisclosurePolicy,
				activeDisclosurePolicy: state.activeDisclosurePolicyMode
			),
			isLoading: state.isRefreshingStrippen,
			didTapViewQR: { [weak actionHandler] in
				guard !isDisabledByDisclosurePolicy() else { return }
				guard buttonIsEnabled(now: Current.now()) else { return }
				actionHandler?.didTapShowQR(greenCardObjectIDs: greencards.compactMap { $0.id }, disclosurePolicy: localDisclosurePolicy)
			},
			buttonEnabledEvaluator: { buttonIsEnabled(now: $0) },
			expiryCountdownEvaluator: { now in
				domesticCountdownText(now: now, origins: origins, localDisclosurePolicy: localDisclosurePolicy)
			}
		)]
	}
	
	private func internationalQRCard(
		state: HolderDashboardViewModel.State,
		localDisclosurePolicy: DisclosurePolicy, // the disclosure policy for this card (vs state.activeDisclosurePolicyMode)
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		return [HolderDashboardViewController.Card.europeanUnionQR(
			title: {
				let localizedProof: String? = state.activeDisclosurePolicyMode == .zeroG
					? self.origins.first?.type.localizedProofInternational0G
					: self.origins.first?.type.localizedProof
				return (localizedProof ?? L.holderDashboardQrTitle()).capitalizingFirstLetter()
			}(),
			stackSize: {
				let minStackSize = 1
				let maxStackSize = 3
				return min(maxStackSize, max(minStackSize, greencards.count))
			}(),
			validityTexts: validityTextsGenerator(
				greencards: greencards,
				localDisclosurePolicy: localDisclosurePolicy,
				activeDisclosurePolicy: state.activeDisclosurePolicyMode
			),
			isLoading: state.isRefreshingStrippen,
			didTapViewQR: { [weak actionHandler] in
				guard evaluateEnabledState(Current.now()) else { return }
				actionHandler?.didTapShowQR(greenCardObjectIDs: greencards.compactMap { $0.id }, disclosurePolicy: nil)
			},
			buttonEnabledEvaluator: evaluateEnabledState,
			expiryCountdownEvaluator: nil
		)]
	}

	// Returns a closure that, given a Date, will return the groups of text ("ValidityText") that should be shown per-origin on the QR Card.
	private func validityTextsGenerator(
		greencards: [HolderDashboardViewModel.QRCard.GreenCard],
		localDisclosurePolicy: DisclosurePolicy, // the mode that the specific card being created is in
		activeDisclosurePolicy: HolderDashboardViewModel.DisclosurePolicyMode // the global active disclosure policy
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
				.filter { (greenCard: HolderDashboardViewModel.QRCard.GreenCard, origin: GreenCard.Origin) in
					guard case .netherlands = self.region else { return true } // can just skip this logic for DCCs
					
					// some local disclosure policies cause origins to be hidden, depending on the active disclosure policy:
					// print("🎏 Filtering origin: [active: .\(activeDisclosurePolicy), local: .\(localDisclosurePolicy), origin: .\(origin.type)]") //swiftlint:disable:this disable_print
					switch (activeDisclosurePolicy, localDisclosurePolicy, origin.type) {

						case (.combined1gAnd3g, .policy1G, .test): return true
						case (.combined1gAnd3g, .policy3G, .test):
							// If there is a test + (some other origin), should show the test only on the 1G card (see `case` above), not this 3G card:
							return !QRCard.hasUnexpiredOriginThatIsNotATest(greencard: greenCard, now: now)
						
						// only tests should ever be shown on a 1G card:
						case (_, .policy1G, .test): return true
						case (_, .policy1G, _): return false
						
						// no tests should be shown on 3G card whilst in 1G mode
						case (.exclusive1G, .policy3G, .test): return false
						case (.exclusive1G, .policy3G, _): return true
						
						// allow everything else by default
						default: return true
					}
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
	let userMessages = originTypesOnlyInOtherRegion.compactMap { (originType: QRCodeOriginType) -> (originType: QRCodeOriginType, message: String)? in
		switch (originType, thisRegion) {
			case (.vaccination, .domestic):
				return (originType, L.holderDashboardOriginNotValidInNetherlandsButIsInEUVaccination())
			case (.test, .domestic):
				let containsDomesticVaccinationAssessment = qrCards.contains(where: { $0.origins.contains { $0.type == .vaccinationassessment } })
				guard !containsDomesticVaccinationAssessment else { return nil }
				fallthrough // continue to next case for regular .domestic behavior:
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

/// For a given `[QRCard.GreenCard.Origin]`, determines which origin expires furthest into future, and
/// if the date is within the threshold, will return a localized string indicating how long until that origin expires.
private func domesticCountdownText(now: Date, origins: [QRCard.GreenCard.Origin], localDisclosurePolicy: DisclosurePolicy) -> String? {
	
	let expiringMostDistantlyInFutureOrigin: QRCard.GreenCard.Origin? = {
		if localDisclosurePolicy == .policy1G {
			return origins.first(where: { $0.type == .test })
		} else {
			
			// Calculate which is the origin with the furthest future expiration:
			return origins.reduce(QRCard.GreenCard.Origin?.none) { previous, next in
				guard let previous = previous else { return next }
				return next.expirationTime > previous.expirationTime ? next : previous
			}
		}
	}()
	
	guard let expiringMostDistantlyInFutureOrigin = expiringMostDistantlyInFutureOrigin else { return nil }
	
	let expirationTime: Date = expiringMostDistantlyInFutureOrigin.expirationTime
	let countdownTimerVisibleThreshold: TimeInterval = expiringMostDistantlyInFutureOrigin.countdownTimerVisibleThreshold
	
	guard expirationTime > now && expirationTime < now.addingTimeInterval(countdownTimerVisibleThreshold)
	else { return nil }

	return countdownText(now: now, to: expirationTime)
}

/// Produces a localized countdown string relative to `now`
private func countdownText(now: Date, to futureExpiryDate: Date) -> String? {
	guard futureExpiryDate > now else { return nil }
	
	let formatter: DateComponentsFormatter = {
		let fiveMinutes: TimeInterval = 5 * 60
		if futureExpiryDate < now.addingTimeInterval(fiveMinutes) {
			// e.g. "4 minuten en 15 seconden"
			return DateFormatter.Relative.hoursMinutesSeconds
		} else {
			// e.g. "23 uur en 59 minuten"
			return DateFormatter.Relative.hoursMinutes
		}
	}()

	guard let relativeDateString = formatter.string(
		from: now,
		to: futureExpiryDate.addingTimeInterval(1) // add 1, so that we don't count down to zero
	)
	else { return nil }

	return (L.holderDashboardQrExpiryDatePrefixExpiresIn() + " " + relativeDateString).trimmingCharacters(in: .whitespacesAndNewlines)
}
