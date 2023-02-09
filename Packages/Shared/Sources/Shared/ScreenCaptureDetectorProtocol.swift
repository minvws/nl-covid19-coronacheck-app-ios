import Foundation

public protocol ScreenCaptureDetectorProtocol: AnyObject {
	var screenIsBeingCaptured: Bool { get }

	var screenshotWasTakenCallback: (() -> Void)? { get set }
	var screenCaptureDidChangeCallback: ((Bool) -> Void)? { get set }
}
