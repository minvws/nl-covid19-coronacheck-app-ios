/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ScanLockManaging {
	var state: ScanLockManager.State { get }
	var observatory: Observatory<ScanLockManager.State> { get }
	
	func lock()
	func wipeScanMode()
	func wipePersistedData()

	static var configScanLockDuration: TimeInterval { get }
}

final class ScanLockManager: ScanLockManaging {
	
	// MARK: - Types

	enum State: Equatable {
		case locked(until: Date)
		case unlocked
	}
	
	// MARK: - Static
	
	/// Query the Remote Config Manager for the scan lock duration.
	static var configScanLockDuration: TimeInterval {
		TimeInterval(Current.remoteConfigManager.storedConfiguration.scanLockSeconds ?? 300)
	}
	
	// MARK: - Vars
	
	// Mechanism for registering for external state change notifications:
	let observatory: Observatory<ScanLockManager.State>
	private let notifyObservers: (ScanLockManager.State) -> Void
	
	@Atomic<State> fileprivate(set) var state: State = .unlocked
	private var recheckTimer: Timeable?
	private var keychainScanLockUntil: Date {
		get {
			return secureUserSettings.scanLockUntil
		}
		set {
			secureUserSettings.scanLockUntil = newValue
		}
	}
	
	// MARK: - Dependencies
	
	private let now: () -> Date
	private let notificationCenter: NotificationCenterProtocol
	private let secureUserSettings: SecureUserSettingsProtocol
	private let vendTimer: (TimeInterval, @escaping () -> Void) -> Timeable
	
	// It is important to remember that even if the user puts their system time
	// forward (defeating the lock timer mechanism), that the scanner functionality
	// will not work correctly, thus the user will need to eventually fix the system
	// time. If that happens, the lock should re-engage if necessary. Thus, we should
	// never clear the userdefaults/keychain values, but just check if we're within the
	// lock window or not.
	//
	required init(
		now: @escaping () -> Date,
		notificationCenter: NotificationCenterProtocol = NotificationCenter.default,
		secureUserSettings: SecureUserSettingsProtocol,
		vendTimer: @escaping (TimeInterval, @escaping () -> Void) -> Timeable = { interval, action in
			return Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in action() }
		}
	) {
		self.now = now
		self.notificationCenter = notificationCenter
		self.secureUserSettings = secureUserSettings
		self.vendTimer = vendTimer
		(self.observatory, self.notifyObservers) = Observatory<State>.create()
		
		// Set the correct value of state:
		if keychainScanLockUntil > now() {
			state = .locked(until: keychainScanLockUntil)
		} else {
			state = .unlocked
		}
		
		recheck()
		
		// Add a change handler to `state`:
		$state.projectedValue.didSet = { [weak self] atomic in
			guard let self = self else { return }

			if case .locked(let until) = atomic.wrappedValue {
				// update the keychain:
				self.keychainScanLockUntil = until
			}
			
			self.notifyObservers(self.state)
		}

		setupNotificationCenterObservation()
	}
	
	deinit {
		notificationCenter.removeObserver(self)
	}
	
	/// If already locked, will restart the lock from the beginning:
	func lock() {
		let lockDuration = ScanLockManager.configScanLockDuration
		let lockUntil = now().addingTimeInterval(lockDuration)
		self.keychainScanLockUntil = lockUntil
		recheck()
	}
	
	func setupNotificationCenterObservation() {
		notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
			// Timers aren't reliable in the background. Just remove it, we'll re-add it if/when we return:
			self?.recheckTimer?.invalidate()
			self?.recheckTimer = nil
		}
		notificationCenter.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
			self?.recheck()
		}
	}
	
	/// ⏱
	private func recheck() {
		
		// NSTimer is not 100% accurate, so if we have less than a second left, just unlock
		let inaccuracyMargin: TimeInterval = 1
		
		if keychainScanLockUntil > (now() + inaccuracyMargin) { // should still be locked
			state = .locked(until: keychainScanLockUntil)
			setupRecheckTimer(timeIntervalFromNow: keychainScanLockUntil.timeIntervalSince(now()))
		} else {
			state = .unlocked
			
			// Cancel any previous timer:
			recheckTimer?.invalidate()
		}
	}
	
	private func setupRecheckTimer(timeIntervalFromNow: TimeInterval) {
		guard timeIntervalFromNow > 0 else { return }
		
		// Cancel any previous one:
		recheckTimer?.invalidate()
		
		// Setup new one:
		recheckTimer = vendTimer(timeIntervalFromNow) { [weak self] in
			self?.recheck()
		}
	}
	
	func wipeScanMode() {
		
		keychainScanLockUntil = .distantPast
		state = .unlocked
	}

	func wipePersistedData() {
		
		observatory.removeAll()
		wipeScanMode()
	}
}
