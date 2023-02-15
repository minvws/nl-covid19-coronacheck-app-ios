// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Shared",
	defaultLocalization: "nl",
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "Shared",
			targets: ["Shared"])
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/Quick/Nimble", from: "10.0.0"),
		.package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.1.0")
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "Shared",
			dependencies: [
				.product(name: "Reachability", package: "Reachability.swift")
			]
		),
		.testTarget(
			name: "SharedTests",
			dependencies: [
				"Shared",
				.product(name: "Nimble", package: "Nimble"),
			])
	]
)
