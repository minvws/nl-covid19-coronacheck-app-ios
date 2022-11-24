// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Transport",
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "Transport",
			targets: ["Transport"])
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		// .package(url: /* package url */, from: "1.0.0"),
		.package(name: "Shared", path: "../Shared"),
		.package(url: "https://github.com/minvws/nl-rdo-app-ios-modules", branch: "main"),
		.package(url: "https://github.com/Thomvis/BrightFutures", branch: "master"),
		
		// testing:
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: .init(1, 9, 0)),
		.package(url: "https://github.com/AliSoftware/OHHTTPStubs", exact: .init(9, 1, 0)),
		.package(url: "https://github.com/Quick/Nimble", from: .init(10, 0, 0))
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "Transport",
			dependencies: [
				.product(name: "HTTPSecurity", package: "nl-rdo-app-ios-modules"),
				.product(name: "Shared", package: "Shared"),
				.product(name: "BrightFutures", package: "BrightFutures")
			]),
		.testTarget(
			name: "TransportTests",
			dependencies: [
				"Transport",
				.product(name: "HTTPSecurity", package: "nl-rdo-app-ios-modules"),
				.product(name: "Shared", package: "Shared"),
				.product(name: "BrightFutures", package: "BrightFutures"),
				.product(name: "Nimble", package: "Nimble"),
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
				.product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
			]
		)
	]
)
