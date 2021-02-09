fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios test_ci
```
fastlane ios test_ci
```
Run tests for integration purposes
### ios deploy
```
fastlane ios deploy
```
Build and deploy via Firebase
### ios deploy_holder_ci
```
fastlane ios deploy_holder_ci
```
Build and deploy the holder app via Firebase from CI
### ios deploy_verifier_ci
```
fastlane ios deploy_verifier_ci
```
Build and deploy the verifier app via Firebase from CI

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
