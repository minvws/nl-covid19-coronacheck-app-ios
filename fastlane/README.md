fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### remove_temp_keychain

```sh
[bundle exec] fastlane remove_temp_keychain
```



----


## iOS

### ios test_ci

```sh
[bundle exec] fastlane ios test_ci
```

Run tests for integration purposes

### ios smoketest_ui

```sh
[bundle exec] fastlane ios smoketest_ui
```

Run Holder UI Smoketests

### ios test_ui

```sh
[bundle exec] fastlane ios test_ui
```

Run Holder UI Tests

### ios ship_holder_to_testflight

```sh
[bundle exec] fastlane ios ship_holder_to_testflight
```

Build and ship the Holder app to TestFlight

### ios ship_verifier_to_testflight

```sh
[bundle exec] fastlane ios ship_verifier_to_testflight
```

Build and ship the Verifier app to TestFlight

### ios deploy_holder_test_ci

```sh
[bundle exec] fastlane ios deploy_holder_test_ci
```

Build and deploy the Holder app for Test via Firebase from CI

### ios deploy_verifier_test_ci

```sh
[bundle exec] fastlane ios deploy_verifier_test_ci
```

Build and deploy the Verifier app for Test via Firebase from CI

### ios deploy_holder_acc_ci

```sh
[bundle exec] fastlane ios deploy_holder_acc_ci
```

Build and deploy the Holder app for Acc via Firebase from CI

### ios deploy_verifier_acc_ci

```sh
[bundle exec] fastlane ios deploy_verifier_acc_ci
```

Build and deploy the Verifier app for Acc via Firebase from CI

### ios deploy_holder_prod_ci

```sh
[bundle exec] fastlane ios deploy_holder_prod_ci
```

Build and deploy the Holder app for Prod via Firebase from CI

### ios deploy_verifier_prod_ci

```sh
[bundle exec] fastlane ios deploy_verifier_prod_ci
```

Build and deploy the Verifier app for Prod via Firebase from CI

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
