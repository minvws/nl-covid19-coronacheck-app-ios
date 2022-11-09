# COVID-19 CoronaCheck - iOS

## Introduction

This repository contains the iOS release of the Dutch COVID-19 CoronaCheck project.

* The iOS app is located in the repository you are currently viewing.
* The Android app can also be [found on GitHub](https://github.com/minvws/nl-covid19-coronacheck-app-android).

See minvws/**[nl-covid19-coronacheck-app-coordination](https://github.com/minvws/nl-covid19-coronacheck-app-coordination)** for further technical documentation.

---

## About the Apps

The codebase builds two different app products: 

### [CoronaCheck](https://apps.apple.com/nl/app/coronacheck/id1548269870)

**CoronaCheck** (referred to internally as the *Holder* app) is the official app of the Netherlands for showing coronavirus entry passes. With this digital tool, you can create a certificate with QR code of your negative test, vaccination, or recovery. This allows access to certain venues and activities abroad. Or at the border.

### [Scanner voor CoronaCheck](https://apps.apple.com/nl/app/scanner-voor-coronacheck/id1549842661)

**CoronaCheck Scanner** (referred to internally as the *Verifier* app) is the official scanner app of the Netherlands for coronavirus entry passes. With this digital tool, you can verify if visitors have a valid certificate of their negative test, vaccination, or recovery. You do this by scanning their QR code. This way, you can safely give access to your venue or activity.

### App Requirements

The apps can run on devices that meet the following requirements.

- Operating System: iOS 11.0+
- Internet connection (either Wifi or Mobile Data)

### Feature Overview

#### CoronaCheck

The app works like this:

*First make sure you are vaccinated or have tested for coronavirus.*

- With the CoronaCheck app you can create a certificate based on your vaccination or coronavirus test results. You do this by retrieving your details via DigiD or via the retrieval code you received if you got tested at a test location other than the GGD.

- You can create a vaccination certificate from your vaccination, create a test certificate from your negative coronavirus test result, or create a recovery certificate from your positive coronavirus test result.

- The QR code of your certificate may be checked at the entrance of venues and activities. And also at international borders. This is proof that you have been vaccinated, have had coronavirus or did not have coronavirus at the time of testing

This is a general overview of the features that are available in the app:

* **Onboarding**: When the app starts or the first time, the user is informed of the functionality of the app and views the privacy declaration.

* **Dashboard**: an overview of the user's certificates. Depending on the active [disclosure policy](#disclosure-policies), there can a tab switcher to change between Domestic and International certificates, or else it's hidden and the user can only view International certificates.

* **View QR codes**: View the QR code(s) for a selected certificate.

* **Fuzzy-matching**: For when a user has multiple names in the app, which the backend no longer permits. Before the implementation of server-side fuzzy matching they existed together, but now there needs to be a way for the user to choose which name permutations (+ associated events) to keep, and which to discard. This feature also has an "onboarding" flow explaining the choice the user has to make. This feature is presented to the user as-needed, and is not otherwise accessible.

* **Menu**: 

  * **Add Certificate**: 

    * Vaccination: can be retrieved via authentication with DigiD
    * Positive Test: can be retrieved via authentication with DigiD
    * Negative Test: can be added via authentication with DigiD or by entering a retrieval code from a third-party test provider.  

    For those without a DigiD account, the user can request a certificate from the CoronaCheck Helpdesk or (if the user doesn't have a BSN) directly from the GGD.

  * **Scan to add certificate**: the user can import a paper copy of a various types of certificate by scanning it using the phone's camera.

  * **Add visitor pass**: for users who were vaccinated outside the EU and are visiting the Netherlands, they can obtain a "vaccine approval" code and use it - together with a negative test - to create a visitor pass in the app.

  * **Frequently asked questions**: a webview 

  * **About this app**:

    * Privacy statement: a webview
    * Accessibility: a webview
    * Colophon: a webview
    * Stored data: shows the event data imported from GGD, RIVM, from commerical test providers, or scanned manually by the user. They can be deleted from here.
    * Reset the app: wipes the database, user preferences and keychain entries, restoring the app to a "first-run" state.

    To aid in development/testing of the app, there are some extra menu items when compiling for Development/Test/Acceptance:

    * ***Open Scanner**: open the CoronaCheck Scanner app via a universal-link*

    * ***A list of disclosure policies** (1G, 3G, etc) which can be manually activated to override the remote configuration disclosure policy.*

##### Disclosure policies

Depending on the active disclosure policy (which is set by the remote config), the Dutch certificates are handled differently in the app:

* **0G**: no Dutch certificates displayed, only international certificates.

* **1G** access: the user can only use a negative test to enter places which require a coronavirus pass. The app only displays the QRs of negative test certificates.
* **3G** access: the user can enter anywhere (that requires a coronavirus pass) with a proof of vaccination, recovery, or a negative test. So all certificates are available.
* **1G + 3G**: some venues are operating with 1G rules, others with 3G. Thus the app displays separate certificates for 3G and for 1G access.

#### CoronaCheck Scanner

The app works like this:

- With CoronaCheck Scanner you can scan visitors' QR codes with your smartphone
  camera. Visitors can show their QR code in the CoronaCheck app, or on paper. Tourists can
  use an app or a printed QR code from their own country.
- A number of details appear on your screen, allowing you to verify - using their proof of
  identity - if the QR code really belongs to this visitor.
- If the QR code is valid, and the details are the same as on the proof of identity, a check
  mark will appear on the screen and you can give access to the visitor.

This is how the app uses personal details:

* Visitors' details may only be used to verify the coronavirus entry pass

* Visitors' details are not centrally stored anywhere
* Visitors' location details are neither used nor saved

This is a general overview of the features that are available in the app:

* **Onboarding**: When the app starts or the first time, the user is informed of the purpose of the app and accepts the Acceptable Use Policy.
* **Landing screen**: explains briefly what the app does.
* **"About Scanning" onboarding**: informs the user how to scan & verify a certificate.
* **New Policy screen**: explains the current disclosure policy
* **Scan QR code**: camera view which allows the user to scan a QR code. The device's flashlight can be toggled.
* **Result screen**: shows a green checkmark or a red cross depending on the result of the scan.

* **Menu**: 
  * **How it works**: replay the "About Scanning" onboarding.
  * **Support**: opens a webview.
  * **Scan Setting**: allows the user to choose the active verification policy (feature is only available when multiple verification policies are permitted by the remote config).
  * **About this app:**
    * Acceptable use policy: opens a webview
    * Accessibility: a webview
    * Colophon: a webview
    * Reset the app: wipes the database, user preferences and keychain entries, restoring the app to a "first-run" state. This is only available when compiling for Development/Test/Acceptance.
    * Scan setting log: keeps track of the type of access used during scanning. A civil enforcement officer may request access to this log. For privacy reasons, only scan settings used in the last 60 minutes are saved on this phone. No personal information is saved. (feature is only available when multiple verification policies are permitted by the remote config).

##### Verification Policies 

Related to Disclosure Policies above, but for the Scanner. The verification policy set (by the remote configuration) determines which types of QR codes can be scanned.

* **1G** access: the scanner can only approve QR codes representing valid negative tests.
* **3G** access: the scanner can approve QR codes representing valid vaccination, recovery, and negative tests.
* **1G + 3G**: some venues are operating with 1G rules, others with 3G. The scanner can be set to 1G or 3G mode, depending on the venue where it's intended to be used.

### Remote Configuration

Feature flags / configuration values are loaded dynamically from the backend ([CoronaCheck](https://holder-api.coronacheck.nl/v8/holder/config), [CoronaCheck Scanner](https://holder-api.coronacheck.nl/v8/verifier/config)). The `payload` value is base64 encoded.

*Note: the API is versioned: /v8/, /v9/ etc. See [NetworkConfiguration.swift](/Sources/Transport/Config/NetworkConfiguration.swift) for the current version.*

### Dependencies

The majority of our dependencies are included as Swift Packages. Here is an overview of what dependencies are used and why.

* [BrightFutures](https://github.com/Thomvis/BrightFutures): a Swift implementation of futures and promises.
* [IOSSecuritySuite](https://github.com/securing/IOSSecuritySuite): for detecting a jailbroken environment.

* [Lottie](https://github.com/airbnb/lottie-ios): natively renders vector-based animations.
* [OpenSSL](https://github.com/krzyzanowskim/OpenSSL): provides OpenSSL on iOS.
* [RDOModules](https://github.com/minvws/nl-rdo-app-ios-modules): modules that were extracted from CoronaCheck for reuse.
* [Reachability](https://github.com/ashleymills/Reachability.swift): for detecting network reachability.
* [RSwiftLibrary](https://github.com/mac-cain13/R.swift.Library): for strongly-typed, autocompleted resources like images, fonts, colours.

#### Development only

* [Inject](https://github.com/krzysztofzablocki/Inject): for hot-reloading in the simulator.
* [XcodeGen]([https://github.com/yonaskolb/XcodeGen](https://github.com/minvws/nl-covid19-notification-app-ios/blob/main)): Command Line tool to generate an Xcode projectfile based on a [project.yml](/.project.yml) description file. The .xcodeproj file that is generated by this tool is not checked into the git repository but has to be created when checking out the code by running `make generate_project`.

#### Testing only

* [Nimble](https://github.com/Quick/Nimble): for succinct unit test expressions.
* [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs): for stubbing network requests.
* [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing): for recording the expected state of UI components.
* [ViewControllerPresentationSpy](https://github.com/jonreid/ViewControllerPresentationSpy): for testing UIViewControllers.

#### Continuous Integration only

* [Fastlane](https://github.com/fastlane/fastlane): for automating the build and distribution pipeline.

### CLCore

The Android and iOS apps share a core library, written in Go, which is responsible for producing the QR-code image, and for validating scanned QR-codes. 

`Scripts/fetch_ctcl.sh` builds an xcframework which is linked by the app. 

## Development

#### Build Requirements

To build and develop the app you need:

- Xcode 14
- Xcode Command Line tools (Specifically "Make").
- [Homebrew](https://brew.sh/)

#### Getting started

The Xcode project file ([CTR.xcodeproj](CTR.xcodeproj)) is not checked-in to git. Instead, we generate it dynamically using [XcodeGen](https://github.com/yonaskolb/XcodeGen) based on [project.yml](/.project.yml). 

There is a [Makefile](./Makefile) which makes it easy to get started (if you encounter any issues running this, please do open an issue):

Simply run `make dev` from the command line.  

It will use [Homebrew](https://brew.sh) to install [these tools](./Brewfile), and will install githooks for:

* GitLFS (which will download the [snapshot](https://github.com/pointfreeco/swift-snapshot-testing) PNGs used in our unit tests)
* XcodeGen (which will update the Xcode project each time you change branches)

It will run `bundle install` to setup your [Ruby dependencies](./Gemfile) such as [fastlane](https://fastlane.tools).

Lastly, it will generate and open the Xcode Project for you.

#### Continuous Integration & reproducible builds

In order to facilitate CI and reproducible builds, this codebase can be built using Github Actions.

### Where to begin development

The app uses a few mainstream iOS architectural concepts throughout:

* App Coordinator https://khanlou.com/2015/10/coordinators-redux/
* Environment https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy
* ViewModels https://www.swiftbysundell.com/articles/different-flavors-of-view-models-in-swift/

#### Key classes:

`AppCoordinator` is the main starting point of the app.

`HolderDashboardViewController/ViewModel` drive the dashboard, displaying the QR cards and entrypoint to the menu etc.

`StrippenRefresher` periodically refills the [Strip Card](https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/architecture/Privacy%20Preserving%20Green%20Card.md#the-strip-card-model).

#### Theming, Strings, Fonts and Images 

#### Localized Strings

Localization is managed in a [lokalise](https://lokalise.com) project.

.`strings` files can be downloaded from lokalise using command `make download_translations`. 

A build script combines the separate downloaded Holder and Verifier `.strings` files together (issuing a build warning if there are duplicate keys), and then R.swift generates a static Swift representation of each key (see `R.generated`). This makes sure we don't make errors in the string's name.

Each value has some basic validation to ensure it contains - if any - valid HTML. (see `Scripts/strings_checker.swift`)

#### Colors, Images

R.swift collates the colors and images from bundled asset catalogs, generating a Swift file with an accessor for each asset.

#### Fonts

Fonts are accessible via `Fonts.swift`

## Release Procedure

The release process is the same for CoronaCheck and for CoronaCheck Scanner.

We use fastlane to automate our release processes, and that is executed by GitHub Actions. See [.github/workflows](.github/workflows) for the workflows definition files.

We release test, acceptance and production-like builds internally to Firebase App Distribution. These are triggered whenever there is a commit made to the main branch (ie by merging a pull request).

You can also manually trigger this release process manually, by running the [Deploy: Firebase (manual)](.github/workflows/deploy-firebase-manual.yml) github action and providing a branch name.

Once it is time to start the release train, create a release branch with the format `release/holder-4.7.0` or `release/verifier-4.7.0`, and then increment the `MARKETING_VERSION`  (for Holder or for Verifier) in [project.yml](project.yml). Pushing to this branch will trigger the appropriate Firebase builds.

Once the team is satisfied with the quality of the builds on Firebase, a production build can be sent to TestFlight. A release to TestFlight is kicked off by *tagging* a commit using this format:

`Holder-4.7.0-RC1`, `Holder-4.7.0-RC2`, etc.

or `Verifier-3.0.2-RC1`, `Verifier-3.0.2-RC2`, etc.

Here we perform a manual regression test on the build to make sure the production-ready binary performs as expected.

Once the build is approved by Apple, we release the approved build manually using a phased rollout to give us the opportunity to spot any crashes that might be detected, or bugs that might be reported. At this point  a final tag should be made, with this format:

`Holder-4.7.0`

`Verifier-3.0.2` 

Now that the release is completed, the private git repository should be "synced" with the public reposititory by running [this script](Scripts/sync_public_repo.sh). It pushes new *non-RC* tags to the public repository.

## Contribution process

The development team works on the repository in a private fork (for reasons of compliance with existing processes) and shares its work as often as possible.

If you plan to make non-trivial changes, we recommend to open an issue beforehand where we can discuss your planned changes. This increases the chance that we might be able to use your contribution (or it avoids doing work if there are reasons why we wouldn't be able to use it).

Note that all commits should be signed using a gpg key.
