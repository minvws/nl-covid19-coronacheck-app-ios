
dev: install_dev_deps install_githooks generate_project open_project
ci: install_ci_deps generate_project

# -- setup environment --

install_dev_deps: build_xcodegen build_swiftlint bundler
	@echo "All dev dependencies are installed"

bundler: 
ifeq (, $(shell which bundle))
$(error "You must install bundler on your system before setup can continue. You could try running 'gem install bundler'.")
endif
	bundle install
	
# -- generate -- 

generate_project: 
	Vendor/XcodeGen/.build/release/xcodegen  --spec project.yml

open_project: 
	open CTR.xcodeproj

# -- linting -- 

run_swiftlint:
	Vendor/SwiftLint/.build/release/swiftlint --quiet --strict --config=./.swiftlint.yml

# -- building for dev -- 

build_xcodegen:
	@cd Vendor/XcodeGen && swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"

build_swiftlint: 
	@cd Vendor/SwiftLint && swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"

# -- building for CI  -- 
# On CI the builds are cached with a hash of the sourcecode as the key. 
# If a `.build` folder exists, that means there's a valid build of the latest source, restored from a cache.
# So building can be skipped. 
#
# We were seeing that `swift build` - only on CI - did not use previous `.build` to make an incremental build,
# and rebuilt from scratch every time. So that's why this check is necessary.

build_xcodegen_ci:
	@[ -d "Vendor/XcodeGen/.build" ] || (cd Vendor/XcodeGen && swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13")

build_swiftlint_ci: 
	@[ -d "Vendor/SwiftLint/.build" ] || (cd Vendor/SwiftLint && swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13")

homebrew_ci:
	@brew install imagemagick
	
# -- git hooks: -- 

install_githooks: install_githooks_gitlfs install_githooks_xcodegen
	@echo "All githooks are installed"

install_githooks_xcodegen:
	@echo "\nVendor/XcodeGen/.build/release/xcodegen generate --spec project.yml --use-cache" >> .git/hooks/post-checkout
	@chmod +x .git/hooks/post-checkout

install_githooks_gitlfs:
	@git lfs install --force