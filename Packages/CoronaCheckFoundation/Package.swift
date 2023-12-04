// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CoronaCheckFoundation",
	products: [
		.library(
			name: "CoronaCheckFoundation",
			targets: ["CoronaCheckFoundation"]
		)
	],
	dependencies: [
		// Internal:
		.package(name: "Models", path: "../Models"),
		.package(name: "Persistence", path: "../Persistence"),
		.package(name: "Shared", path: "../Shared"),
		.package(name: "Transport", path: "../Transport")
	],
	targets: [
		.target(
			name: "CoronaCheckFoundation",
			dependencies: [
				.product(name: "Models", package: "Models"),
				.product(name: "Persistence", package: "Persistence"),
				.product(name: "Shared", package: "Shared"),
				.product(name: "Transport", package: "Transport")
			]
		)
	]
)
