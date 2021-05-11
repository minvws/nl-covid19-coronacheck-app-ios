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
### remove_temp_keychain
```
fastlane remove_temp_keychain
```


----

## iOS
### ios ian
```
fastlane ios ian
```

### ios remove_temp_keychain
```
fastlane ios remove_temp_keychain
```

### ios test_ci
```
fastlane ios test_ci
```
Run tests for integration purposes
### ios deploy_test_ci
```
fastlane ios deploy_test_ci
```
Build and deploy the apps for Test via Firebase from CI
### ios deploy_acc_ci
```
fastlane ios deploy_acc_ci
```
Build and deploy the apps for Acc via Firebase from CI
### ios deploy_prod_ci
```
fastlane ios deploy_prod_ci
```
Build and deploy the apps for Prod via Firebase from CI
### ios deploycombined
```
fastlane ios deploycombined
```

### ios deploy_holder_test_ci
```
fastlane ios deploy_holder_test_ci
```
Build and deploy the Holder app for Test via Firebase from CI
### ios deploy_verifier_test_ci
```
fastlane ios deploy_verifier_test_ci
```
Build and deploy the Verifier app for Test via Firebase from CI
### ios deploy_holder_acc_ci
```
fastlane ios deploy_holder_acc_ci
```
Build and deploy the Holder app for Acc via Firebase from CI
### ios deploy_verifier_acc_ci
```
fastlane ios deploy_verifier_acc_ci
```
Build and deploy the Verifier app for Acc via Firebase from CI
### ios deploy_holder_prod_ci
```
fastlane ios deploy_holder_prod_ci
```
Build and deploy the Holder app for Prod via Firebase from CI
### ios deploy_verifier_prod_ci
```
fastlane ios deploy_verifier_prod_ci
```
Build and deploy the Verifier app for Prod via Firebase from CI

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
