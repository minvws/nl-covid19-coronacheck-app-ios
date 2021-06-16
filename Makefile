dev: install_dev_deps install_githooks generate_project open_project
ci: install_ci_deps generate_project

# -- setup environment --

install_dev_deps: homebrew_dev bundler
	@echo "All dev dependencies are installed"

install_ci_deps: homebrew_ci

bundler: 
ifeq (, $(shell which bundle))
$(error "You must install bundler on your system before setup can continue. You could try running 'gem install bundler'.")
endif
	bundle install

homebrew_dev:
	@brew install swiftlint xcodegen git-lfs

homebrew_ci:
	@brew install imagemagick swiftlint xcodegen
	
# -- generate -- 

generate_project: 
	Vendor/XcodeGen/.build/release/xcodegen  --spec project.yml

open_project: 
	open CTR.xcodeproj

# -- linting -- 

run_swiftlint:
	swiftlint --quiet --strict --config=./.swiftlint.yml
	
# -- git hooks: -- 

install_githooks: install_githooks_gitlfs install_githooks_xcodegen
	@echo "All githooks are installed"

install_githooks_xcodegen:
	@echo "\nVendor/XcodeGen/.build/release/xcodegen generate --spec project.yml --use-cache" >> .git/hooks/post-checkout
	@chmod +x .git/hooks/post-checkout

install_githooks_gitlfs:
	@git lfs install --force