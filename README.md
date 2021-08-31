# COVID-19 CoronaCheck Prototype - iOS

## Introduction
This repository contains the iOS prototype of the Dutch COVID-19 CoronaCheck project.

* The iOS app is located in the repository you are currently viewing.
* The Android app can be found here: https://github.com/minvws/nl-covid19-coronacheck-app-android 

The project is currently an experimental prototype to explore technical possibilities.   

## Development & Contribution process

The development team works on the repository in a private fork (for reasons of compliance with existing processes) and shares its work as often as possible.

If you plan to make non-trivial changes, we recommend to open an issue beforehand where we can discuss your planned changes.
This increases the chance that we might be able to use your contribution (or it avoids doing work if there are reasons why we wouldn't be able to use it).

Note that all commits should be signed using a gpg key.

## Getting started 

The Xcode project file (`CTR.xcodeproj`) is not checked-in to git. Instead, we generate it dynamically using [XcodeGen](https://github.com/yonaskolb/XcodeGen) based on a [project.yml](./.project.yml) file. There is a [Makefile](./Makefile) which should make it easy to get started:

Simply run `make dev` from the command line.  

It will use [Homebrew](https://brew.sh) to install [these tools](./Brewfile), and will install githooks for: 

- GitLFS (which will download the [snapshot](https://github.com/pointfreeco/swift-snapshot-testing) PNGs used in our unit tests) 
- XcodeGen (which will update the Xcode project each time you change branches)

and it will run `bundle install` to setup your [Ruby dependencies](./Gemfile) such as fastlane.

Lastly, it will generate and open the Xcode Project for you.