// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "RestrictedBrowser",
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "RestrictedBrowser",
			targets: ["RestrictedBrowser"])
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		.package(name: "Shared", path: "../Shared"),
		.package(name: "Resources", path: "../Resources"),
		.package(name: "ReusableViews", path: "../ReusableViews"),
		.package(url: "https://github.com/Quick/Nimble", from: "10.0.0")
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "RestrictedBrowser",
			dependencies: [
				.product(name: "Shared", package: "Shared"),
				.product(name: "Resources", package: "Resources"),
				.product(name: "ReusableViews", package: "ReusableViews"),
			]
		),
		.testTarget(
			name: "RestrictedBrowserTests",
			dependencies: [
				"RestrictedBrowser",
//				.product(name: "Nimble", package: "Nimble")
			])
	]
)
