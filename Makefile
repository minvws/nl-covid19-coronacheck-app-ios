
dev: install_dev_deps install_githooks generate_project
ci: install_ci_deps generate_project

# -- setup environment --

install_dev_deps: build_xcodegen build_swiftlint bundler
	@echo "All dev dependencies are installed"

install_ci_deps: build_xcodegen build_swiftlint bundler
	@echo "All CI dependencies are installed"

bundler: 
ifeq (, $(shell which bundle))
$(error "You must install bundler on your system before setup can continue. You could try running 'gem install bundler'.")
endif
	bundle install
	
# -- generate -- 

generate_project: 
	Vendor/XcodeGen/.build/release/xcodegen  --spec project.yml

# -- building -- 

build_xcodegen:
	@cd Vendor/XcodeGen && swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"

build_swiftlint: 
	@cd Vendor/SwiftLint && swift build -c release -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"

# -- git hooks: -- 

install_githooks: install_githooks_gitlfs install_githooks_xcodegen
	@echo "All githooks are installed"

install_githooks_xcodegen:
	@echo "\nVendor/XcodeGen/.build/release/xcodegen generate --spec project.yml --use-cache" >> .git/hooks/post-checkout
	@chmod +x .git/hooks/post-checkout

install_githooks_gitlfs:
	@git lfs install --force